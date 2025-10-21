// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IVelirionReferral
 * @notice Interface for the Velirion Referral System
 * @dev Defines the standard interface for referral tracking and bonus distribution
 */
interface IVelirionReferral {
    // ============================================================================
    // Structs
    // ============================================================================

    struct Referrer {
        address addr;
        uint256 level; // 1-4 tier
        uint256 directReferrals;
        uint256 totalEarned;
        uint256 purchaseBonusEarned;
        uint256 stakingBonusEarned;
        uint256 registrationTime;
        bool isActive;
    }

    struct ReferralStats {
        uint256 totalVolume;
        uint256 totalStakingVolume;
        address[] directReferrals;
    }

    // ============================================================================
    // Events
    // ============================================================================

    event ReferralRegistered(address indexed user, address indexed referrer);
    event TierUpgraded(
        address indexed referrer,
        uint256 oldTier,
        uint256 newTier
    );
    event PurchaseBonusDistributed(
        address indexed referrer,
        address indexed buyer,
        uint256 bonusAmount
    );
    event StakingBonusDistributed(
        address indexed referrer,
        address indexed staker,
        uint256 bonusAmount
    );
    event RewardsClaimed(address indexed referrer, uint256 amount);
    event AuthorizedContractUpdated(address indexed contractAddress, bool status);

    // ============================================================================
    // Core Functions
    // ============================================================================

    /**
     * @notice Register a user with a referrer
     * @param referrer Address of the referrer
     */
    function register(address referrer) external;

    /**
     * @notice Distribute purchase bonus to referrer
     * @param buyer Address of the buyer
     * @param tokenAmount Amount of tokens purchased
     */
    function distributePurchaseBonus(
        address buyer,
        uint256 tokenAmount
    ) external;

    /**
     * @notice Distribute staking bonus to referrer
     * @param staker Address of the staker
     * @param rewardAmount Amount of staking rewards
     */
    function distributeStakingBonus(
        address staker,
        uint256 rewardAmount
    ) external;

    /**
     * @notice Claim accumulated rewards
     */
    function claimRewards() external;

    // ============================================================================
    // View Functions
    // ============================================================================

    /**
     * @notice Get the referrer of a user
     * @param user Address of the user
     * @return Address of the referrer
     */
    function getReferrer(address user) external view returns (address);

    /**
     * @notice Get tier bonuses (purchase and staking)
     * @param tier Tier level (1-4)
     * @return purchaseBonus Purchase bonus in basis points
     * @return stakingBonus Staking bonus in basis points
     */
    function getTierBonuses(
        uint256 tier
    ) external view returns (uint256 purchaseBonus, uint256 stakingBonus);

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
        returns (uint256 level, uint256 directReferrals, uint256 totalEarned);

    /**
     * @notice Get complete referrer data
     * @param user Address of the referrer
     * @return Referrer struct with all data
     */
    function getReferrerData(
        address user
    ) external view returns (Referrer memory);

    /**
     * @notice Get referral statistics
     * @param user Address of the referrer
     * @return ReferralStats struct with statistics
     */
    function getReferralStats(
        address user
    ) external view returns (ReferralStats memory);

    /**
     * @notice Get pending rewards for a referrer
     * @param user Address of the referrer
     * @return Amount of pending rewards
     */
    function getPendingRewards(address user) external view returns (uint256);

    /**
     * @notice Check if an address is an authorized contract
     * @param contractAddress Address to check
     * @return True if authorized
     */
    function isAuthorizedContract(
        address contractAddress
    ) external view returns (bool);
}
