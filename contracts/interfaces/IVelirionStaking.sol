// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IVelirionStaking
 * @notice Interface for the Velirion Staking System
 * @dev Defines the standard interface for 4-tier staking with variable APR
 * 
 * Staking Tiers:
 * - Flexible: 6% APR, no lock, 100 VLR min
 * - Medium: 12-15% APR, 90-180 days lock, 1,000 VLR min
 * - Long: 20-22% APR, 1 year lock, 5,000 VLR min
 * - Elite: 30-32% APR, 2 years lock, 250,000 VLR min
 */
interface IVelirionStaking {
    // ============================================================================
    // Enums
    // ============================================================================

    enum StakingTier {
        Flexible,  // 0: 6% APR, no lock
        Medium,    // 1: 12-15% APR, 90-180 days
        Long,      // 2: 20-22% APR, 1 year
        Elite      // 3: 30-32% APR, 2 years
    }

    // ============================================================================
    // Structs
    // ============================================================================

    struct Stake {
        uint256 amount;           // Amount staked
        uint256 startTime;        // When stake started
        uint256 lockDuration;     // Lock period in seconds
        uint256 lastClaimTime;    // Last reward claim
        StakingTier tier;         // Staking tier
        uint16 apr;               // APR in basis points (600 = 6%)
        bool renewed;             // Has been renewed
        bool active;              // Is stake active
    }

    struct UserStakingInfo {
        uint256 totalStaked;         // Total amount staked
        uint256 totalRewardsClaimed; // Total rewards claimed
        uint256 activeStakes;        // Number of active stakes
        uint256 stakingPower;        // For DAO voting (M5)
    }

    // ============================================================================
    // Events
    // ============================================================================

    event Staked(
        address indexed user,
        uint256 indexed stakeId,
        uint256 amount,
        StakingTier tier,
        uint256 lockDuration,
        uint16 apr
    );

    event Unstaked(
        address indexed user,
        uint256 indexed stakeId,
        uint256 amount,
        uint256 penalty,
        uint256 netAmount
    );

    event RewardsClaimed(
        address indexed user,
        uint256 indexed stakeId,
        uint256 rewards,
        uint256 referralBonus
    );

    event StakeRenewed(
        address indexed user,
        uint256 indexed stakeId,
        uint16 oldApr,
        uint16 newApr
    );

    event ReferralContractUpdated(address indexed newReferralContract);

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
    ) external;

    /**
     * @notice Unstake tokens (with penalty if before lock period ends)
     * @param stakeId ID of the stake to unstake
     */
    function unstake(uint256 stakeId) external;

    /**
     * @notice Claim accumulated staking rewards
     * @param stakeId ID of the stake to claim rewards from
     */
    function claimRewards(uint256 stakeId) external;

    /**
     * @notice Renew a stake to get +2% APR bonus
     * @param stakeId ID of the stake to renew
     */
    function renewStake(uint256 stakeId) external;

    // ============================================================================
    // View Functions
    // ============================================================================

    /**
     * @notice Calculate pending rewards for a stake
     * @param user Address of the user
     * @param stakeId ID of the stake
     * @return Pending rewards amount
     */
    function calculateRewards(
        address user,
        uint256 stakeId
    ) external view returns (uint256);

    /**
     * @notice Get all stake IDs for a user
     * @param user Address of the user
     * @return Array of stake IDs
     */
    function getUserStakes(address user) external view returns (uint256[] memory);

    /**
     * @notice Get detailed information about a stake
     * @param user Address of the user
     * @param stakeId ID of the stake
     * @return amount Amount staked
     * @return startTime When stake started
     * @return lockDuration Lock period in seconds
     * @return tier Staking tier
     * @return apr APR in basis points
     * @return renewed Has been renewed
     * @return active Is stake active
     */
    function getStakeInfo(
        address user,
        uint256 stakeId
    )
        external
        view
        returns (
            uint256 amount,
            uint256 startTime,
            uint256 lockDuration,
            StakingTier tier,
            uint16 apr,
            bool renewed,
            bool active
        );

    /**
     * @notice Get user's total staking information
     * @param user Address of the user
     * @return info UserStakingInfo struct
     */
    function getUserStakingInfo(
        address user
    ) external view returns (UserStakingInfo memory info);

    /**
     * @notice Get minimum stake amount for a tier
     * @param tier Staking tier
     * @return Minimum stake amount
     */
    function getMinimumStake(StakingTier tier) external pure returns (uint256);

    /**
     * @notice Get minimum lock duration for a tier
     * @param tier Staking tier
     * @return Minimum lock duration in seconds
     */
    function getMinimumLock(StakingTier tier) external pure returns (uint256);

    /**
     * @notice Get maximum lock duration for a tier
     * @param tier Staking tier
     * @return Maximum lock duration in seconds
     */
    function getMaximumLock(StakingTier tier) external pure returns (uint256);

    /**
     * @notice Calculate early withdrawal penalty
     * @param user Address of the user
     * @param stakeId ID of the stake
     * @return Penalty amount
     */
    function calculatePenalty(
        address user,
        uint256 stakeId
    ) external view returns (uint256);

    /**
     * @notice Get voting power for DAO (2x for Long/Elite tiers)
     * @param user Address of the user
     * @return Total voting power
     */
    function getVotingPower(address user) external view returns (uint256);

    /**
     * @notice Check if a stake can be unstaked without penalty
     * @param user Address of the user
     * @param stakeId ID of the stake
     * @return True if can unstake without penalty
     */
    function canUnstakeWithoutPenalty(
        address user,
        uint256 stakeId
    ) external view returns (bool);

    /**
     * @notice Get total staked amount across all users
     * @return Total staked amount
     */
    function getTotalStaked() external view returns (uint256);

    /**
     * @notice Get contract statistics
     * @return totalStaked Total amount staked
     * @return totalStakers Number of unique stakers
     * @return totalRewardsDistributed Total rewards distributed
     * @return contractBalance Contract VLR balance
     */
    function getContractStats()
        external
        view
        returns (
            uint256 totalStaked,
            uint256 totalStakers,
            uint256 totalRewardsDistributed,
            uint256 contractBalance
        );
}
