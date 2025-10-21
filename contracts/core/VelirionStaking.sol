// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IVelirionStaking.sol";
import "../interfaces/IVelirionReferral.sol";

/**
 * @title VelirionStaking
 * @notice 4-tier staking system with variable APR and referral integration
 * 
 * Staking Tiers:
 * - Flexible: 6% APR, no lock, 100 VLR min, no penalty
 * - Medium: 12-15% APR, 90-180 days, 1K VLR min, 5% penalty
 * - Long: 20-22% APR, 1 year, 5K VLR min, 7% penalty, 2x DAO vote
 * - Elite: 30-32% APR, 2 years, 250K VLR min, 10% penalty, 2x DAO vote
 * 
 * Features:
 * - Manual reward claiming (gas efficient)
 * - Renewal bonus (+2% APR)
 * - Referral bonus integration (2%-5% to referrer)
 * - Early withdrawal penalties
 * - DAO voting weight (2x for Long/Elite)
 */
contract VelirionStaking is
    IVelirionStaking,
    Ownable,
    Pausable,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;

    // ============================================================================
    // Constants - Minimum Stake Amounts
    // ============================================================================

    uint256 public constant MIN_FLEXIBLE_STAKE = 100 * 10**18;      // 100 VLR
    uint256 public constant MIN_MEDIUM_STAKE = 1000 * 10**18;       // 1,000 VLR
    uint256 public constant MIN_LONG_STAKE = 5000 * 10**18;         // 5,000 VLR
    uint256 public constant MIN_ELITE_STAKE = 250000 * 10**18;      // 250,000 VLR

    // ============================================================================
    // Constants - Lock Durations
    // ============================================================================

    uint256 public constant FLEXIBLE_LOCK = 0;                      // No lock
    uint256 public constant MEDIUM_MIN_LOCK = 90 days;              // 90 days
    uint256 public constant MEDIUM_MAX_LOCK = 180 days;             // 180 days
    uint256 public constant LONG_LOCK = 365 days;                   // 1 year
    uint256 public constant ELITE_LOCK = 730 days;                  // 2 years

    // ============================================================================
    // Constants - APR (in basis points, 10000 = 100%)
    // ============================================================================

    uint16 public constant FLEXIBLE_APR = 600;                      // 6%
    uint16 public constant MEDIUM_MIN_APR = 1200;                   // 12%
    uint16 public constant MEDIUM_MAX_APR = 1500;                   // 15%
    uint16 public constant LONG_APR = 2000;                         // 20%
    uint16 public constant LONG_RENEWED_APR = 2200;                 // 22%
    uint16 public constant ELITE_APR = 3000;                        // 30%
    uint16 public constant ELITE_RENEWED_APR = 3200;                // 32%

    // ============================================================================
    // Constants - Penalties (in basis points)
    // ============================================================================

    uint16 public constant MEDIUM_PENALTY = 500;                    // 5%
    uint16 public constant LONG_PENALTY = 700;                      // 7%
    uint16 public constant ELITE_PENALTY = 1000;                    // 10%

    // ============================================================================
    // Constants - Other
    // ============================================================================

    uint16 public constant RENEWAL_BONUS = 200;                     // +2%
    uint256 public constant BASIS_POINTS = 10000;                   // 100%
    uint256 public constant SECONDS_PER_YEAR = 365 days;

    // ============================================================================
    // State Variables
    // ============================================================================

    IERC20 public immutable vlrToken;
    IVelirionReferral public referralContract;

    // User stakes: user => stakeId => Stake
    mapping(address => mapping(uint256 => Stake)) public stakes;
    
    // User stake IDs: user => array of stake IDs
    mapping(address => uint256[]) private userStakeIds;
    
    // User staking info: user => UserStakingInfo
    mapping(address => UserStakingInfo) public userStakingInfo;
    
    // Next stake ID for each user
    mapping(address => uint256) public nextStakeId;

    // Global statistics
    uint256 public totalStaked;
    uint256 public totalStakers;
    uint256 public totalRewardsDistributed;

    // Track unique stakers
    mapping(address => bool) private hasStaked;

    // ============================================================================
    // Errors
    // ============================================================================

    error InvalidAmount();
    error InvalidTier();
    error InvalidLockDuration();
    error BelowMinimumStake();
    error StakeNotFound();
    error StakeNotActive();
    error InsufficientContractBalance();
    error NoRewardsToClaim();
    error CannotRenewFlexible();
    error AlreadyRenewed();
    error CannotRenewBeforeLockEnd();

    // ============================================================================
    // Constructor
    // ============================================================================

    constructor(address _vlrToken) Ownable(msg.sender) {
        require(_vlrToken != address(0), "Invalid VLR token");
        vlrToken = IERC20(_vlrToken);
    }

    // ============================================================================
    // Core Functions
    // ============================================================================

    /**
     * @notice Stake VLR tokens for a specific tier
     * @param amount Amount of VLR to stake
     * @param tier Staking tier (Flexible, Medium, Long, Elite)
     * @param lockDuration Lock duration in seconds (must match tier requirements)
     */
    function stake(
        uint256 amount,
        StakingTier tier,
        uint256 lockDuration
    ) external override nonReentrant whenNotPaused {
        if (amount == 0) revert InvalidAmount();
        if (uint8(tier) > 3) revert InvalidTier();

        // Validate minimum stake amount
        uint256 minStake = getMinimumStake(tier);
        if (amount < minStake) revert BelowMinimumStake();

        // Validate lock duration
        uint256 minLock = getMinimumLock(tier);
        uint256 maxLock = getMaximumLock(tier);
        if (lockDuration < minLock || lockDuration > maxLock) {
            revert InvalidLockDuration();
        }

        // Calculate APR for this stake
        uint16 apr = _calculateAPR(tier, lockDuration, false);

        // Get next stake ID for user
        uint256 stakeId = nextStakeId[msg.sender];
        nextStakeId[msg.sender]++;

        // Create stake
        stakes[msg.sender][stakeId] = Stake({
            amount: amount,
            startTime: block.timestamp,
            lockDuration: lockDuration,
            lastClaimTime: block.timestamp,
            tier: tier,
            apr: apr,
            renewed: false,
            active: true
        });

        // Update user stake IDs
        userStakeIds[msg.sender].push(stakeId);

        // Update user staking info
        UserStakingInfo storage info = userStakingInfo[msg.sender];
        info.totalStaked += amount;
        info.activeStakes++;
        info.stakingPower += _calculateStakingPower(amount, tier);

        // Update global statistics
        totalStaked += amount;
        if (!hasStaked[msg.sender]) {
            hasStaked[msg.sender] = true;
            totalStakers++;
        }

        // Transfer tokens from user
        vlrToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, stakeId, amount, tier, lockDuration, apr);
    }

    /**
     * @notice Unstake tokens (with penalty if before lock period ends)
     * @param stakeId ID of the stake to unstake
     */
    function unstake(uint256 stakeId) external override nonReentrant whenNotPaused {
        Stake storage userStake = stakes[msg.sender][stakeId];
        
        if (userStake.amount == 0) revert StakeNotFound();
        if (!userStake.active) revert StakeNotActive();

        uint256 amount = userStake.amount;
        uint256 penalty = _calculatePenaltyInternal(userStake);
        uint256 netAmount = amount - penalty;

        // Claim any pending rewards first
        uint256 rewards = _calculateRewardsInternal(userStake);
        if (rewards > 0) {
            _claimRewardsInternal(msg.sender, stakeId, userStake, rewards);
        }

        // Mark stake as inactive
        userStake.active = false;

        // Update user staking info
        UserStakingInfo storage info = userStakingInfo[msg.sender];
        info.totalStaked -= amount;
        info.activeStakes--;
        info.stakingPower -= _calculateStakingPower(amount, userStake.tier);

        // Update global statistics
        totalStaked -= amount;

        // Transfer tokens back to user (minus penalty)
        vlrToken.safeTransfer(msg.sender, netAmount);

        // Penalty stays in contract for rewards pool
        
        emit Unstaked(msg.sender, stakeId, amount, penalty, netAmount);
    }

    /**
     * @notice Claim accumulated staking rewards
     * @param stakeId ID of the stake to claim rewards from
     */
    function claimRewards(uint256 stakeId) external override nonReentrant whenNotPaused {
        Stake storage userStake = stakes[msg.sender][stakeId];
        
        if (userStake.amount == 0) revert StakeNotFound();
        if (!userStake.active) revert StakeNotActive();

        uint256 rewards = _calculateRewardsInternal(userStake);
        if (rewards == 0) revert NoRewardsToClaim();

        _claimRewardsInternal(msg.sender, stakeId, userStake, rewards);
    }

    /**
     * @notice Renew a stake to get +2% APR bonus
     * @param stakeId ID of the stake to renew
     */
    function renewStake(uint256 stakeId) external override nonReentrant whenNotPaused {
        Stake storage userStake = stakes[msg.sender][stakeId];
        
        if (userStake.amount == 0) revert StakeNotFound();
        if (!userStake.active) revert StakeNotActive();
        if (userStake.tier == StakingTier.Flexible) revert CannotRenewFlexible();
        if (userStake.renewed) revert AlreadyRenewed();

        // Can only renew after lock period ends
        uint256 unlockTime = userStake.startTime + userStake.lockDuration;
        if (block.timestamp < unlockTime) revert CannotRenewBeforeLockEnd();

        uint16 oldApr = userStake.apr;
        uint16 newApr = oldApr + RENEWAL_BONUS;

        userStake.apr = newApr;
        userStake.renewed = true;
        userStake.startTime = block.timestamp; // Reset start time
        userStake.lastClaimTime = block.timestamp;

        emit StakeRenewed(msg.sender, stakeId, oldApr, newApr);
    }

    // ============================================================================
    // Internal Functions
    // ============================================================================

    /**
     * @notice Internal function to claim rewards
     */
    function _claimRewardsInternal(
        address user,
        uint256 stakeId,
        Stake storage userStake,
        uint256 rewards
    ) internal {
        uint256 contractBalance = vlrToken.balanceOf(address(this));
        uint256 availableBalance = contractBalance - totalStaked;
        
        if (availableBalance < rewards) revert InsufficientContractBalance();

        // Update last claim time
        userStake.lastClaimTime = block.timestamp;

        // Update statistics
        userStakingInfo[user].totalRewardsClaimed += rewards;
        totalRewardsDistributed += rewards;

        // Distribute referral bonus (2%-5% based on referrer tier)
        uint256 referralBonus = 0;
        if (address(referralContract) != address(0)) {
            try referralContract.distributeStakingBonus(user, rewards) {
                // Get referrer info to calculate actual bonus
                try referralContract.getReferrerInfo(
                    referralContract.getReferrer(user)
                ) returns (uint256 level, uint256, uint256) {
                    (, uint256 stakingBonusBps) = referralContract.getTierBonuses(level);
                    referralBonus = (rewards * stakingBonusBps) / BASIS_POINTS;
                } catch {}
            } catch {
                // Failed silently, don't revert user's claim
            }
        }

        // Transfer rewards to user
        vlrToken.safeTransfer(user, rewards);

        emit RewardsClaimed(user, stakeId, rewards, referralBonus);
    }

    /**
     * @notice Calculate APR based on tier, lock duration, and renewal status
     */
    function _calculateAPR(
        StakingTier tier,
        uint256 lockDuration,
        bool renewed
    ) internal pure returns (uint16) {
        if (tier == StakingTier.Flexible) {
            return FLEXIBLE_APR; // 6%
        }
        
        if (tier == StakingTier.Medium) {
            // Linear interpolation between 12% and 15%
            if (lockDuration <= MEDIUM_MIN_LOCK) return MEDIUM_MIN_APR;
            if (lockDuration >= MEDIUM_MAX_LOCK) return MEDIUM_MAX_APR;
            
            uint256 range = MEDIUM_MAX_LOCK - MEDIUM_MIN_LOCK;
            uint256 position = lockDuration - MEDIUM_MIN_LOCK;
            uint256 aprRange = MEDIUM_MAX_APR - MEDIUM_MIN_APR;
            
            return uint16(MEDIUM_MIN_APR + (aprRange * position) / range);
        }
        
        if (tier == StakingTier.Long) {
            return renewed ? LONG_RENEWED_APR : LONG_APR; // 20% or 22%
        }
        
        if (tier == StakingTier.Elite) {
            return renewed ? ELITE_RENEWED_APR : ELITE_APR; // 30% or 32%
        }
        
        revert InvalidTier();
    }

    /**
     * @notice Calculate rewards for a stake
     */
    function _calculateRewardsInternal(
        Stake memory userStake
    ) internal view returns (uint256) {
        if (!userStake.active) return 0;
        
        uint256 stakingDuration = block.timestamp - userStake.lastClaimTime;
        
        // rewards = (amount * APR * time) / (BASIS_POINTS * SECONDS_PER_YEAR)
        uint256 rewards = (userStake.amount * userStake.apr * stakingDuration) 
                         / (BASIS_POINTS * SECONDS_PER_YEAR);
        
        return rewards;
    }

    /**
     * @notice Calculate early withdrawal penalty
     */
    function _calculatePenaltyInternal(
        Stake memory userStake
    ) internal view returns (uint256) {
        // Flexible tier has no penalty
        if (userStake.tier == StakingTier.Flexible) {
            return 0;
        }
        
        uint256 unlockTime = userStake.startTime + userStake.lockDuration;
        
        // No penalty if lock period completed
        if (block.timestamp >= unlockTime) {
            return 0;
        }
        
        // Calculate penalty based on tier
        uint16 penaltyRate;
        if (userStake.tier == StakingTier.Medium) {
            penaltyRate = MEDIUM_PENALTY; // 5%
        } else if (userStake.tier == StakingTier.Long) {
            penaltyRate = LONG_PENALTY; // 7%
        } else if (userStake.tier == StakingTier.Elite) {
            penaltyRate = ELITE_PENALTY; // 10%
        }
        
        return (userStake.amount * penaltyRate) / BASIS_POINTS;
    }

    /**
     * @notice Calculate staking power for DAO voting (2x for Long/Elite)
     */
    function _calculateStakingPower(
        uint256 amount,
        StakingTier tier
    ) internal pure returns (uint256) {
        // Long and Elite tiers get 2x voting power
        if (tier == StakingTier.Long || tier == StakingTier.Elite) {
            return amount * 2;
        }
        return amount;
    }

    // ============================================================================
    // View Functions
    // ============================================================================

    /**
     * @notice Calculate pending rewards for a stake
     */
    function calculateRewards(
        address user,
        uint256 stakeId
    ) external view override returns (uint256) {
        Stake memory userStake = stakes[user][stakeId];
        return _calculateRewardsInternal(userStake);
    }

    /**
     * @notice Get all stake IDs for a user
     */
    function getUserStakes(
        address user
    ) external view override returns (uint256[] memory) {
        return userStakeIds[user];
    }

    /**
     * @notice Get detailed information about a stake
     */
    function getStakeInfo(
        address user,
        uint256 stakeId
    )
        external
        view
        override
        returns (
            uint256 amount,
            uint256 startTime,
            uint256 lockDuration,
            StakingTier tier,
            uint16 apr,
            bool renewed,
            bool active
        )
    {
        Stake memory userStake = stakes[user][stakeId];
        return (
            userStake.amount,
            userStake.startTime,
            userStake.lockDuration,
            userStake.tier,
            userStake.apr,
            userStake.renewed,
            userStake.active
        );
    }

    /**
     * @notice Get user's total staking information
     */
    function getUserStakingInfo(
        address user
    ) external view override returns (UserStakingInfo memory) {
        return userStakingInfo[user];
    }

    /**
     * @notice Get minimum stake amount for a tier
     */
    function getMinimumStake(
        StakingTier tier
    ) public pure override returns (uint256) {
        if (tier == StakingTier.Flexible) return MIN_FLEXIBLE_STAKE;
        if (tier == StakingTier.Medium) return MIN_MEDIUM_STAKE;
        if (tier == StakingTier.Long) return MIN_LONG_STAKE;
        if (tier == StakingTier.Elite) return MIN_ELITE_STAKE;
        revert InvalidTier();
    }

    /**
     * @notice Get minimum lock duration for a tier
     */
    function getMinimumLock(
        StakingTier tier
    ) public pure override returns (uint256) {
        if (tier == StakingTier.Flexible) return FLEXIBLE_LOCK;
        if (tier == StakingTier.Medium) return MEDIUM_MIN_LOCK;
        if (tier == StakingTier.Long) return LONG_LOCK;
        if (tier == StakingTier.Elite) return ELITE_LOCK;
        revert InvalidTier();
    }

    /**
     * @notice Get maximum lock duration for a tier
     */
    function getMaximumLock(
        StakingTier tier
    ) public pure override returns (uint256) {
        if (tier == StakingTier.Flexible) return FLEXIBLE_LOCK;
        if (tier == StakingTier.Medium) return MEDIUM_MAX_LOCK;
        if (tier == StakingTier.Long) return LONG_LOCK;
        if (tier == StakingTier.Elite) return ELITE_LOCK;
        revert InvalidTier();
    }

    /**
     * @notice Calculate early withdrawal penalty
     */
    function calculatePenalty(
        address user,
        uint256 stakeId
    ) external view override returns (uint256) {
        Stake memory userStake = stakes[user][stakeId];
        return _calculatePenaltyInternal(userStake);
    }

    /**
     * @notice Get voting power for DAO (2x for Long/Elite tiers)
     */
    function getVotingPower(
        address user
    ) external view override returns (uint256) {
        return userStakingInfo[user].stakingPower;
    }

    /**
     * @notice Check if a stake can be unstaked without penalty
     */
    function canUnstakeWithoutPenalty(
        address user,
        uint256 stakeId
    ) external view override returns (bool) {
        Stake memory userStake = stakes[user][stakeId];
        
        if (!userStake.active) return false;
        if (userStake.tier == StakingTier.Flexible) return true;
        
        uint256 unlockTime = userStake.startTime + userStake.lockDuration;
        return block.timestamp >= unlockTime;
    }

    /**
     * @notice Get total staked amount across all users
     */
    function getTotalStaked() external view override returns (uint256) {
        return totalStaked;
    }

    /**
     * @notice Get contract statistics
     */
    function getContractStats()
        external
        view
        override
        returns (
            uint256 _totalStaked,
            uint256 _totalStakers,
            uint256 _totalRewardsDistributed,
            uint256 contractBalance
        )
    {
        return (
            totalStaked,
            totalStakers,
            totalRewardsDistributed,
            vlrToken.balanceOf(address(this))
        );
    }

    // ============================================================================
    // Owner Functions
    // ============================================================================

    /**
     * @notice Set referral contract address
     * @param _referralContract Address of the referral contract
     */
    function setReferralContract(
        address _referralContract
    ) external onlyOwner {
        require(_referralContract != address(0), "Invalid address");
        referralContract = IVelirionReferral(_referralContract);
        emit ReferralContractUpdated(_referralContract);
    }

    /**
     * @notice Emergency withdrawal (only unstaked tokens)
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        require(amount > 0, "Invalid amount");
        uint256 contractBalance = vlrToken.balanceOf(address(this));
        uint256 availableBalance = contractBalance - totalStaked;
        require(availableBalance >= amount, "Insufficient available balance");
        
        vlrToken.safeTransfer(owner(), amount);
    }

    /**
     * @notice Pause contract
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}
