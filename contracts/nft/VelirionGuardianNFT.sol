// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/IVelirionNFT.sol";

/**
 * @title VelirionGuardianNFT
 * @notice Exclusive NFT for Elite tier stakers (250K+ VLR, 2-year lock)
 * 
 * Features:
 * - Minted for Elite tier stakers only
 * - Represents 2-year commitment
 * - Enhanced DAO voting weight indicator
 * - Exclusive artwork and traits
 * - Soulbound (non-transferable)
 * - Tracks staking commitment
 */
contract VelirionGuardianNFT is ERC721, ERC721URIStorage, Ownable, IVelirionNFT {
    using Strings for uint256;

    // ============================================================================
    // Constants
    // ============================================================================

    uint256 public constant GUARDIAN_TIER = 5;  // Elite tier = 5
    uint256 public constant MIN_STAKE_AMOUNT = 250000 * 10**18;  // 250K VLR

    // ============================================================================
    // State Variables
    // ============================================================================

    uint256 private _tokenIdCounter;
    address public stakingContract;
    string public baseTokenURI;

    mapping(uint256 => NFTMetadata) public nftMetadata;
    mapping(address => uint256) public userToTokenId;

    // ============================================================================
    // Errors
    // ============================================================================

    error OnlyStakingContract();
    error UserAlreadyHasNFT();
    error InsufficientStakeAmount();
    error SoulboundToken();

    // ============================================================================
    // Modifiers
    // ============================================================================

    modifier onlyStakingContract() {
        if (msg.sender != stakingContract) revert OnlyStakingContract();
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
    }

    // ============================================================================
    // Admin Functions
    // ============================================================================

    /**
     * @notice Set the staking contract address
     * @param _stakingContract Address of staking contract
     */
    function setStakingContract(address _stakingContract) external onlyOwner {
        require(_stakingContract != address(0), "Invalid address");
        stakingContract = _stakingContract;
    }

    /**
     * @notice Set base token URI for metadata
     * @param _baseTokenURI New base URI
     */
    function setBaseTokenURI(string memory _baseTokenURI) external onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    // ============================================================================
    // Core NFT Functions
    // ============================================================================

    /**
     * @notice Mint Guardian NFT for Elite staker
     * @param user Address to mint NFT to
     * @param tier Tier level (must be 5 for Guardian)
     */
    function mintNFT(address user, uint256 tier) external override onlyStakingContract {
        require(tier == GUARDIAN_TIER, "Invalid tier for Guardian NFT");
        if (userToTokenId[user] != 0) revert UserAlreadyHasNFT();

        uint256 tokenId = ++_tokenIdCounter;
        
        _safeMint(user, tokenId);
        
        // Initialize metadata
        nftMetadata[tokenId] = NFTMetadata({
            tier: GUARDIAN_TIER,
            mintedAt: block.timestamp,
            referralCount: 0,
            totalEarned: 0,
            stakedAmount: 0,  // Will be updated by staking contract
            isActive: true
        });

        userToTokenId[user] = tokenId;

        // Set token URI
        _setTokenURI(tokenId, _generateTokenURI(tokenId));

        emit NFTMinted(user, tokenId, GUARDIAN_TIER, block.timestamp);
    }

    /**
     * @notice Upgrade NFT (not applicable for Guardian NFT)
     * @dev Guardian NFT is already max tier, this is a no-op
     */
    function upgradeNFT(uint256, uint256) external pure override {
        // Guardian NFT cannot be upgraded (already max tier)
        revert("Guardian NFT is max tier");
    }

    /**
     * @notice Update NFT metadata with staking info
     * @param tokenId The NFT token ID
     * @param referralCount Not used for Guardian NFT
     * @param totalEarned Total staking rewards earned
     */
    function updateMetadata(
        uint256 tokenId,
        uint256 referralCount,
        uint256 totalEarned
    ) external override onlyStakingContract {
        NFTMetadata storage metadata = nftMetadata[tokenId];
        metadata.referralCount = referralCount;  // Can track if user also has referrals
        metadata.totalEarned = totalEarned;

        emit MetadataUpdated(tokenId, referralCount, totalEarned);
    }

    /**
     * @notice Update staked amount in metadata
     * @param user User address
     * @param stakedAmount Amount staked
     */
    function updateStakedAmount(address user, uint256 stakedAmount) external onlyStakingContract {
        uint256 tokenId = userToTokenId[user];
        require(tokenId != 0, "User has no Guardian NFT");

        NFTMetadata storage metadata = nftMetadata[tokenId];
        metadata.stakedAmount = stakedAmount;
    }

    /**
     * @notice Deactivate Guardian NFT when stake is withdrawn
     * @param user User address
     */
    function deactivateNFT(address user) external onlyStakingContract {
        uint256 tokenId = userToTokenId[user];
        require(tokenId != 0, "User has no Guardian NFT");

        NFTMetadata storage metadata = nftMetadata[tokenId];
        metadata.isActive = false;
    }

    /**
     * @notice Reactivate Guardian NFT when user stakes again
     * @param user User address
     */
    function reactivateNFT(address user) external onlyStakingContract {
        uint256 tokenId = userToTokenId[user];
        require(tokenId != 0, "User has no Guardian NFT");

        NFTMetadata storage metadata = nftMetadata[tokenId];
        metadata.isActive = true;
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
     * @notice Check if Guardian NFT is active
     * @param user User address
     * @return True if NFT is active
     */
    function isActive(address user) external view returns (bool) {
        uint256 tokenId = userToTokenId[user];
        if (tokenId == 0) return false;
        return nftMetadata[tokenId].isActive;
    }

    /**
     * @notice Get total Guardian NFTs minted
     * @return Total count
     */
    function totalGuardians() external view returns (uint256) {
        return _tokenIdCounter;
    }

    // ============================================================================
    // Internal Functions
    // ============================================================================

    /**
     * @notice Generate token URI
     * @param tokenId Token ID
     * @return Token URI string
     */
    function _generateTokenURI(uint256 tokenId) internal view returns (string memory) {
        // Format: baseURI/tokenId.json
        // Example: ipfs://QmHash/1.json
        return string(abi.encodePacked(baseTokenURI, tokenId.toString(), ".json"));
    }

    /**
     * @notice Override transfer to make NFT soulbound (non-transferable)
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address) {
        address from = _ownerOf(tokenId);
        
        // Allow minting (from == address(0))
        // Block all transfers (soulbound)
        if (from != address(0) && to != address(0)) {
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
