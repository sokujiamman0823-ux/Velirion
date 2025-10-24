// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/IVelirionNFT.sol";

/**
 * @title VelirionReferralNFT
 * @notice NFT badges for referral program tiers
 * 
 * Tier System:
 * - Tier 2 (Bronze): 10+ referrals → Bronze Badge NFT
 * - Tier 3 (Silver): 25+ referrals → Silver Badge NFT  
 * - Tier 4 (Gold): 50+ referrals → Gold Badge NFT
 * 
 * Features:
 * - Auto-minting on tier upgrade
 * - Automatic tier upgrades (Bronze → Silver → Gold)
 * - Dynamic metadata tracking
 * - Soulbound option (non-transferable)
 * - IPFS metadata integration
 */
contract VelirionReferralNFT is ERC721, ERC721URIStorage, Ownable, IVelirionNFT {
    using Strings for uint256;

    // ============================================================================
    // Constants
    // ============================================================================

    uint256 public constant TIER_2_BRONZE = 2;
    uint256 public constant TIER_3_SILVER = 3;
    uint256 public constant TIER_4_GOLD = 4;

    // ============================================================================
    // State Variables
    // ============================================================================

    uint256 private _tokenIdCounter;
    address public referralContract;
    string public baseTokenURI;
    bool public isSoulbound;  // If true, NFTs cannot be transferred

    mapping(uint256 => NFTMetadata) public nftMetadata;
    mapping(address => uint256) public userToTokenId;

    // ============================================================================
    // Errors
    // ============================================================================

    error OnlyReferralContract();
    error InvalidTier();
    error UserAlreadyHasNFT();
    error NFTNotFound();
    error CannotDowngradeTier();
    error SoulboundToken();

    // ============================================================================
    // Modifiers
    // ============================================================================

    modifier onlyReferralContract() {
        if (msg.sender != referralContract) revert OnlyReferralContract();
        _;
    }

    // ============================================================================
    // Constructor
    // ============================================================================

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseTokenURI,
        address _admin
    ) ERC721(_name, _symbol) Ownable(_admin) {
        baseTokenURI = _baseTokenURI;
        isSoulbound = false;  // Default: transferable
    }

    // ============================================================================
    // Admin Functions
    // ============================================================================

    /**
     * @notice Set the referral contract address
     * @param _referralContract Address of referral contract
     */
    function setReferralContract(address _referralContract) external onlyOwner {
        require(_referralContract != address(0), "Invalid address");
        referralContract = _referralContract;
    }

    /**
     * @notice Set base token URI for metadata
     * @param _baseTokenURI New base URI
     */
    function setBaseTokenURI(string memory _baseTokenURI) external onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    /**
     * @notice Toggle soulbound status
     * @param _isSoulbound True to make NFTs non-transferable
     */
    function setSoulbound(bool _isSoulbound) external onlyOwner {
        isSoulbound = _isSoulbound;
    }

    // ============================================================================
    // Core NFT Functions
    // ============================================================================

    /**
     * @notice Mint a new NFT for a user (called by referral contract)
     * @param user Address to mint NFT to
     * @param tier Tier level (2, 3, or 4)
     */
    function mintNFT(address user, uint256 tier) external override onlyReferralContract {
        if (tier < TIER_2_BRONZE || tier > TIER_4_GOLD) revert InvalidTier();
        if (userToTokenId[user] != 0) revert UserAlreadyHasNFT();

        uint256 tokenId = ++_tokenIdCounter;
        
        _safeMint(user, tokenId);
        
        // Initialize metadata
        nftMetadata[tokenId] = NFTMetadata({
            tier: tier,
            mintedAt: block.timestamp,
            referralCount: 0,
            totalEarned: 0,
            stakedAmount: 0,
            isActive: true
        });

        userToTokenId[user] = tokenId;

        // Set token URI
        _setTokenURI(tokenId, _generateTokenURI(tier));

        emit NFTMinted(user, tokenId, tier, block.timestamp);
    }

    /**
     * @notice Upgrade an existing NFT to a higher tier
     * @param tokenId The NFT token ID
     * @param newTier The new tier level
     */
    function upgradeNFT(uint256 tokenId, uint256 newTier) external override onlyReferralContract {
        if (newTier < TIER_2_BRONZE || newTier > TIER_4_GOLD) revert InvalidTier();
        
        NFTMetadata storage metadata = nftMetadata[tokenId];
        if (newTier <= metadata.tier) revert CannotDowngradeTier();

        uint256 oldTier = metadata.tier;
        metadata.tier = newTier;

        // Update token URI for new tier
        _setTokenURI(tokenId, _generateTokenURI(newTier));

        emit NFTUpgraded(tokenId, oldTier, newTier, block.timestamp);
    }

    /**
     * @notice Update NFT metadata (called by referral contract)
     * @param tokenId The NFT token ID
     * @param referralCount Updated referral count
     * @param totalEarned Updated total earned
     */
    function updateMetadata(
        uint256 tokenId,
        uint256 referralCount,
        uint256 totalEarned
    ) external override onlyReferralContract {
        NFTMetadata storage metadata = nftMetadata[tokenId];
        metadata.referralCount = referralCount;
        metadata.totalEarned = totalEarned;

        emit MetadataUpdated(tokenId, referralCount, totalEarned);
    }

    /**
     * @notice Handle tier upgrade from referral contract
     * @param user User address
     * @param newTier New tier level
     */
    function handleTierUpgrade(address user, uint256 newTier) external onlyReferralContract {
        uint256 tokenId = userToTokenId[user];
        
        if (tokenId == 0) {
            // User doesn't have NFT yet, mint new one
            _mintNFTInternal(user, newTier);
        } else {
            // User has NFT, upgrade it
            _upgradeNFTInternal(tokenId, newTier);
        }
    }

    /**
     * @notice Internal function to mint NFT
     */
    function _mintNFTInternal(address user, uint256 tier) private {
        if (tier < TIER_2_BRONZE || tier > TIER_4_GOLD) revert InvalidTier();

        uint256 tokenId = ++_tokenIdCounter;
        
        _safeMint(user, tokenId);
        
        // Initialize metadata
        nftMetadata[tokenId] = NFTMetadata({
            tier: tier,
            mintedAt: block.timestamp,
            referralCount: 0,
            totalEarned: 0,
            stakedAmount: 0,
            isActive: true
        });

        userToTokenId[user] = tokenId;

        // Set token URI
        _setTokenURI(tokenId, _generateTokenURI(tier));

        emit NFTMinted(user, tokenId, tier, block.timestamp);
    }

    /**
     * @notice Internal function to upgrade NFT
     */
    function _upgradeNFTInternal(uint256 tokenId, uint256 newTier) private {
        if (newTier < TIER_2_BRONZE || newTier > TIER_4_GOLD) revert InvalidTier();
        
        NFTMetadata storage metadata = nftMetadata[tokenId];
        if (newTier <= metadata.tier) revert CannotDowngradeTier();

        uint256 oldTier = metadata.tier;
        metadata.tier = newTier;

        // Update token URI for new tier
        _setTokenURI(tokenId, _generateTokenURI(newTier));

        emit NFTUpgraded(tokenId, oldTier, newTier, block.timestamp);
    }

    // ============================================================================
    // View Functions
    // ============================================================================

    /**
     * @notice Get NFT metadata
     * @param tokenId The NFT token ID
     * @return NFT metadata struct
     */
    function getMetadata(uint256 tokenId) external view override returns (NFTMetadata memory) {
        return nftMetadata[tokenId];
    }

    /**
     * @notice Get user's NFT token ID
     * @param user User address
     * @return Token ID (0 if no NFT)
     */
    function getUserNFT(address user) external view override returns (uint256) {
        return userToTokenId[user];
    }

    /**
     * @notice Check if user has an NFT
     * @param user User address
     * @return True if user has NFT
     */
    function hasNFT(address user) external view override returns (bool) {
        return userToTokenId[user] != 0;
    }

    /**
     * @notice Get tier name
     * @param tier Tier number
     * @return Tier name string
     */
    function getTierName(uint256 tier) public pure returns (string memory) {
        if (tier == TIER_2_BRONZE) return "Bronze";
        if (tier == TIER_3_SILVER) return "Silver";
        if (tier == TIER_4_GOLD) return "Gold";
        return "Unknown";
    }

    // ============================================================================
    // Internal Functions
    // ============================================================================

    /**
     * @notice Generate token URI based on tier
     * @param tier Tier level
     * @return Token URI string
     */
    function _generateTokenURI(uint256 tier) internal view returns (string memory) {
        // Format: baseURI/tier.json
        // Example: ipfs://QmHash/2.json for Bronze
        return string(abi.encodePacked(baseTokenURI, tier.toString(), ".json"));
    }

    /**
     * @notice Override transfer to implement soulbound functionality
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address) {
        address from = _ownerOf(tokenId);
        
        // Allow minting (from == address(0))
        // Block transfers if soulbound (from != address(0) && to != address(0))
        if (isSoulbound && from != address(0) && to != address(0)) {
            revert SoulboundToken();
        }

        return super._update(to, tokenId, auth);
    }

    /**
     * @notice Override tokenURI to return metadata URI
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /**
     * @notice Override supportsInterface
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
