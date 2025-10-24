// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IVelirionNFT
 * @notice Interface for Velirion NFT reward system
 */
interface IVelirionNFT {
    // ============================================================================
    // Structs
    // ============================================================================

    struct NFTMetadata {
        uint256 tier;              // Tier level (2, 3, 4 for referral; 5 for guardian)
        uint256 mintedAt;          // Timestamp of minting
        uint256 referralCount;     // Number of referrals (for referral NFTs)
        uint256 totalEarned;       // Total rewards earned (for referral NFTs)
        uint256 stakedAmount;      // Staked amount (for guardian NFTs)
        bool isActive;             // Whether NFT is active
    }

    // ============================================================================
    // Events
    // ============================================================================

    event NFTMinted(
        address indexed user,
        uint256 indexed tokenId,
        uint256 tier,
        uint256 timestamp
    );

    event NFTUpgraded(
        uint256 indexed tokenId,
        uint256 oldTier,
        uint256 newTier,
        uint256 timestamp
    );

    event MetadataUpdated(
        uint256 indexed tokenId,
        uint256 referralCount,
        uint256 totalEarned
    );

    // ============================================================================
    // Core Functions
    // ============================================================================

    /**
     * @notice Mint a new NFT for a user
     * @param user Address to mint NFT to
     * @param tier Tier level of the NFT
     */
    function mintNFT(address user, uint256 tier) external;

    /**
     * @notice Upgrade an existing NFT to a higher tier
     * @param tokenId The NFT token ID
     * @param newTier The new tier level
     */
    function upgradeNFT(uint256 tokenId, uint256 newTier) external;

    /**
     * @notice Update NFT metadata
     * @param tokenId The NFT token ID
     * @param referralCount Updated referral count
     * @param totalEarned Updated total earned
     */
    function updateMetadata(
        uint256 tokenId,
        uint256 referralCount,
        uint256 totalEarned
    ) external;

    // ============================================================================
    // View Functions
    // ============================================================================

    /**
     * @notice Get NFT metadata
     * @param tokenId The NFT token ID
     * @return NFT metadata struct
     */
    function getMetadata(uint256 tokenId) external view returns (NFTMetadata memory);

    /**
     * @notice Get user's NFT token ID
     * @param user User address
     * @return Token ID (0 if no NFT)
     */
    function getUserNFT(address user) external view returns (uint256);

    /**
     * @notice Check if user has an NFT
     * @param user User address
     * @return True if user has NFT
     */
    function hasNFT(address user) external view returns (bool);
}
