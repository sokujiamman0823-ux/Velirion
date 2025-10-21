// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IVelirionReferral.sol";

/**
 * @title VelirionReferral
 * @notice 4-tier referral system with purchase and staking bonuses
 * 
 * Tier Structure:
 * - Tier 1 (Starter): 0 referrals   → 5% purchase, 2% staking
 * - Tier 2 (Bronze):  10+ referrals → 7% purchase, 3% staking + NFT
 * - Tier 3 (Silver):  25+ referrals → 10% purchase, 4% staking + Bonuses
 * - Tier 4 (Gold):    50+ referrals → 12% purchase, 5% staking + Pool Access
 * 
 * Features:
 * - Automatic tier upgrades based on referral count
 * - Dual bonus system (purchase + staking)
 * - Manual reward claiming
 * - Anti-gaming protections
 * - Full referral tree tracking
 */
contract VelirionReferral is
    IVelirionReferral,
    Ownable,
    Pausable,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;

    // ============================================================================
    // Constants
    // ============================================================================

    uint256 public constant BASIS_POINTS = 10000;
    uint256 public constant MAX_TIER = 4;

    // Tier thresholds
    uint256 public constant TIER_2_THRESHOLD = 10; // Bronze
    uint256 public constant TIER_3_THRESHOLD = 25; // Silver
    uint256 public constant TIER_4_THRESHOLD = 50; // Gold

    // Tier 1 bonuses (Starter)
    uint256 public constant TIER_1_PURCHASE_BONUS = 500; // 5%
    uint256 public constant TIER_1_STAKING_BONUS = 200; // 2%

    // Tier 2 bonuses (Bronze)
    uint256 public constant TIER_2_PURCHASE_BONUS = 700; // 7%
    uint256 public constant TIER_2_STAKING_BONUS = 300; // 3%

    // Tier 3 bonuses (Silver)
    uint256 public constant TIER_3_PURCHASE_BONUS = 1000; // 10%
    uint256 public constant TIER_3_STAKING_BONUS = 400; // 4%

    // Tier 4 bonuses (Gold)
    uint256 public constant TIER_4_PURCHASE_BONUS = 1200; // 12%
    uint256 public constant TIER_4_STAKING_BONUS = 500; // 5%

    // ============================================================================
    // State Variables
    // ============================================================================

    IERC20 public immutable vlrToken;

    // Referral relationships
    mapping(address => address) public referredBy;
    mapping(address => Referrer) public referrers;
    mapping(address => ReferralStats) private referralStats;
    mapping(address => uint256) public pendingRewards;

    // Authorized contracts (presale, staking)
    mapping(address => bool) public authorizedContracts;

    // Statistics
    uint256 public totalReferrers;
    uint256 public totalBonusesDistributed;
    uint256 public totalRewardsClaimed;

    // ============================================================================
    // Errors
    // ============================================================================

    error InvalidReferrer();
    error CannotReferSelf();
    error AlreadyReferred();
    error ReferrerNotActive();
    error NotAuthorized();
    error NoRewardsToClaim();
    error InsufficientContractBalance();
    error InvalidTier();
    error InvalidAmount();

    // ============================================================================
    // Modifiers
    // ============================================================================

    modifier onlyAuthorized() {
        if (!authorizedContracts[msg.sender] && msg.sender != owner()) {
            revert NotAuthorized();
        }
        _;
    }

    // ============================================================================
    // Constructor
    // ============================================================================

    constructor(address _vlrToken) Ownable(msg.sender) {
        require(_vlrToken != address(0), "Invalid VLR token");
        vlrToken = IERC20(_vlrToken);

        // Initialize owner as active referrer (for first users)
        referrers[msg.sender] = Referrer({
            addr: msg.sender,
            level: MAX_TIER,
            directReferrals: 0,
            totalEarned: 0,
            purchaseBonusEarned: 0,
            stakingBonusEarned: 0,
            registrationTime: block.timestamp,
            isActive: true
        });
        totalReferrers = 1;
    }

    // ============================================================================
    // Core Functions
    // ============================================================================

    /**
     * @notice Register a user with a referrer
     * @param referrer Address of the referrer
     */
    function register(address referrer) external override whenNotPaused {
        if (referrer == address(0)) revert InvalidReferrer();
        if (referrer == msg.sender) revert CannotReferSelf();
        if (referredBy[msg.sender] != address(0)) revert AlreadyReferred();
        if (!referrers[referrer].isActive) revert ReferrerNotActive();

        // Set referral relationship
        referredBy[msg.sender] = referrer;

        // Initialize user as referrer if first time
        if (!referrers[msg.sender].isActive) {
            referrers[msg.sender] = Referrer({
                addr: msg.sender,
                level: 1,
                directReferrals: 0,
                totalEarned: 0,
                purchaseBonusEarned: 0,
                stakingBonusEarned: 0,
                registrationTime: block.timestamp,
                isActive: true
            });
            totalReferrers++;
        }

        // Update referrer stats
        referrers[referrer].directReferrals++;
        referralStats[referrer].directReferrals.push(msg.sender);

        // Check for tier upgrade
        _checkAndUpgradeTier(referrer);

        emit ReferralRegistered(msg.sender, referrer);
    }

    /**
     * @notice Distribute purchase bonus to referrer
     * @param buyer Address of the buyer
     * @param tokenAmount Amount of tokens purchased
     */
    function distributePurchaseBonus(
        address buyer,
        uint256 tokenAmount
    ) external override onlyAuthorized whenNotPaused {
        if (tokenAmount == 0) revert InvalidAmount();

        address referrer = referredBy[buyer];
        if (referrer == address(0)) return; // No referrer, skip

        Referrer storage ref = referrers[referrer];
        (uint256 purchaseBonus, ) = getTierBonuses(ref.level);

        uint256 bonusAmount = (tokenAmount * purchaseBonus) / BASIS_POINTS;

        // Add to pending rewards
        pendingRewards[referrer] += bonusAmount;
        ref.totalEarned += bonusAmount;
        ref.purchaseBonusEarned += bonusAmount;

        // Update stats
        referralStats[referrer].totalVolume += tokenAmount;
        totalBonusesDistributed += bonusAmount;

        emit PurchaseBonusDistributed(referrer, buyer, bonusAmount);
    }

    /**
     * @notice Distribute staking bonus to referrer
     * @param staker Address of the staker
     * @param rewardAmount Amount of staking rewards
     */
    function distributeStakingBonus(
        address staker,
        uint256 rewardAmount
    ) external override onlyAuthorized whenNotPaused {
        if (rewardAmount == 0) revert InvalidAmount();

        address referrer = referredBy[staker];
        if (referrer == address(0)) return; // No referrer, skip

        Referrer storage ref = referrers[referrer];
        (, uint256 stakingBonus) = getTierBonuses(ref.level);

        uint256 bonusAmount = (rewardAmount * stakingBonus) / BASIS_POINTS;

        // Add to pending rewards
        pendingRewards[referrer] += bonusAmount;
        ref.totalEarned += bonusAmount;
        ref.stakingBonusEarned += bonusAmount;

        // Update stats
        referralStats[referrer].totalStakingVolume += rewardAmount;
        totalBonusesDistributed += bonusAmount;

        emit StakingBonusDistributed(referrer, staker, bonusAmount);
    }

    /**
     * @notice Claim accumulated rewards
     */
    function claimRewards() external override nonReentrant whenNotPaused {
        uint256 amount = pendingRewards[msg.sender];
        if (amount == 0) revert NoRewardsToClaim();

        uint256 contractBalance = vlrToken.balanceOf(address(this));
        if (contractBalance < amount) revert InsufficientContractBalance();

        // Reset pending rewards
        pendingRewards[msg.sender] = 0;
        totalRewardsClaimed += amount;

        // Transfer tokens
        vlrToken.safeTransfer(msg.sender, amount);

        emit RewardsClaimed(msg.sender, amount);
    }

    // ============================================================================
    // Internal Functions
    // ============================================================================

    /**
     * @notice Check and upgrade tier if threshold met
     * @param user Address to check
     */
    function _checkAndUpgradeTier(address user) internal {
        Referrer storage ref = referrers[user];
        uint256 referralCount = ref.directReferrals;
        uint256 currentTier = ref.level;
        uint256 newTier = currentTier;

        // Determine new tier based on referral count
        if (referralCount >= TIER_4_THRESHOLD && currentTier < 4) {
            newTier = 4; // Gold
        } else if (referralCount >= TIER_3_THRESHOLD && currentTier < 3) {
            newTier = 3; // Silver
        } else if (referralCount >= TIER_2_THRESHOLD && currentTier < 2) {
            newTier = 2; // Bronze
        }

        // Upgrade if tier changed
        if (newTier > currentTier) {
            ref.level = newTier;
            emit TierUpgraded(user, currentTier, newTier);
        }
    }

    // ============================================================================
    // Owner Functions
    // ============================================================================

    /**
     * @notice Set authorized contract status
     * @param contractAddress Address of the contract
     * @param status Authorization status
     */
    function setAuthorizedContract(
        address contractAddress,
        bool status
    ) external onlyOwner {
        require(contractAddress != address(0), "Invalid address");
        authorizedContracts[contractAddress] = status;
        emit AuthorizedContractUpdated(contractAddress, status);
    }

    /**
     * @notice Manually upgrade a user's tier (emergency only)
     * @param user Address of the user
     * @param newTier New tier level
     */
    function manualTierUpgrade(
        address user,
        uint256 newTier
    ) external onlyOwner {
        if (newTier == 0 || newTier > MAX_TIER) revert InvalidTier();

        Referrer storage ref = referrers[user];
        uint256 oldTier = ref.level;
        ref.level = newTier;

        emit TierUpgraded(user, oldTier, newTier);
    }

    /**
     * @notice Emergency withdrawal (only unsold/unallocated tokens)
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        require(amount > 0, "Invalid amount");
        uint256 contractBalance = vlrToken.balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient balance");

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

    // ============================================================================
    // View Functions
    // ============================================================================

    /**
     * @notice Get the referrer of a user
     * @param user Address of the user
     * @return Address of the referrer
     */
    function getReferrer(address user) external view override returns (address) {
        return referredBy[user];
    }

    /**
     * @notice Get tier bonuses
     * @param tier Tier level (1-4)
     * @return purchaseBonus Purchase bonus in basis points
     * @return stakingBonus Staking bonus in basis points
     */
    function getTierBonuses(
        uint256 tier
    ) public pure override returns (uint256 purchaseBonus, uint256 stakingBonus) {
        if (tier == 1) {
            return (TIER_1_PURCHASE_BONUS, TIER_1_STAKING_BONUS);
        } else if (tier == 2) {
            return (TIER_2_PURCHASE_BONUS, TIER_2_STAKING_BONUS);
        } else if (tier == 3) {
            return (TIER_3_PURCHASE_BONUS, TIER_3_STAKING_BONUS);
        } else if (tier == 4) {
            return (TIER_4_PURCHASE_BONUS, TIER_4_STAKING_BONUS);
        } else {
            return (0, 0);
        }
    }

    /**
     * @notice Get referrer information
     * @param user Address of the referrer
     * @return level Current tier level
     * @return directReferrals Number of direct referrals
     * @return totalEarned Total VLR earned
     */
    function getReferrerInfo(
        address user
    )
        external
        view
        override
        returns (uint256 level, uint256 directReferrals, uint256 totalEarned)
    {
        Referrer memory ref = referrers[user];
        return (ref.level, ref.directReferrals, ref.totalEarned);
    }

    /**
     * @notice Get complete referrer data
     * @param user Address of the referrer
     * @return Referrer struct with all data
     */
    function getReferrerData(
        address user
    ) external view override returns (Referrer memory) {
        return referrers[user];
    }

    /**
     * @notice Get referral statistics
     * @param user Address of the referrer
     * @return ReferralStats struct with statistics
     */
    function getReferralStats(
        address user
    ) external view override returns (ReferralStats memory) {
        return referralStats[user];
    }

    /**
     * @notice Get pending rewards for a referrer
     * @param user Address of the referrer
     * @return Amount of pending rewards
     */
    function getPendingRewards(
        address user
    ) external view override returns (uint256) {
        return pendingRewards[user];
    }

    /**
     * @notice Check if an address is an authorized contract
     * @param contractAddress Address to check
     * @return True if authorized
     */
    function isAuthorizedContract(
        address contractAddress
    ) external view override returns (bool) {
        return authorizedContracts[contractAddress];
    }

    /**
     * @notice Get tier name
     * @param tier Tier level
     * @return Tier name as string
     */
    function getTierName(uint256 tier) external pure returns (string memory) {
        if (tier == 1) return "Starter";
        if (tier == 2) return "Bronze";
        if (tier == 3) return "Silver";
        if (tier == 4) return "Gold";
        return "Unknown";
    }

    /**
     * @notice Get next tier threshold
     * @param currentTier Current tier level
     * @return Next tier threshold (0 if max tier)
     */
    function getNextTierThreshold(
        uint256 currentTier
    ) external pure returns (uint256) {
        if (currentTier == 1) return TIER_2_THRESHOLD;
        if (currentTier == 2) return TIER_3_THRESHOLD;
        if (currentTier == 3) return TIER_4_THRESHOLD;
        return 0; // Max tier reached
    }

    /**
     * @notice Get all direct referrals of a user
     * @param user Address of the referrer
     * @return Array of direct referral addresses
     */
    function getDirectReferrals(
        address user
    ) external view returns (address[] memory) {
        return referralStats[user].directReferrals;
    }

    /**
     * @notice Get contract statistics
     * @return totalReferrers_ Total number of referrers
     * @return totalBonusesDistributed_ Total bonuses distributed
     * @return totalRewardsClaimed_ Total rewards claimed
     * @return contractBalance Contract VLR balance
     */
    function getContractStats()
        external
        view
        returns (
            uint256 totalReferrers_,
            uint256 totalBonusesDistributed_,
            uint256 totalRewardsClaimed_,
            uint256 contractBalance
        )
    {
        return (
            totalReferrers,
            totalBonusesDistributed,
            totalRewardsClaimed,
            vlrToken.balanceOf(address(this))
        );
    }
}
