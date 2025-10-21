// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title VelirionToken
 * @dev ERC-20 token with burning capabilities and deflationary tokenomics
 * @notice This contract implements the Velirion (VLR) token with advanced features
 * including burning mechanisms, pausability, and allocation tracking
 */
contract VelirionToken is ERC20, ERC20Burnable, Ownable, Pausable {
    /// @notice Total initial supply: 100 million tokens
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10**18;
    
    /// @notice Tracks token allocations by category
    mapping(string => uint256) public allocationTracking;
    
    /// @notice Tracks total allocated tokens
    uint256 public totalAllocated;
    
    // Events
    event TokensAllocated(string indexed category, address indexed recipient, uint256 amount);
    event UnsoldTokensBurned(uint256 amount);
    event EmergencyPause(address indexed by);
    event EmergencyUnpause(address indexed by);
    
    /**
     * @dev Constructor mints initial supply to deployer
     * @notice Sets the deployer as the initial owner (OpenZeppelin v5 requirement)
     */
    constructor() ERC20("Velirion", "VLR") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
    
    /**
     * @notice Allocate tokens to specific addresses for different purposes
     * @dev Only owner can allocate tokens
     * @param category The allocation category (e.g., "presale", "staking", "team")
     * @param recipient The address receiving the tokens
     * @param amount The amount of tokens to allocate
     */
    function allocate(
        string memory category,
        address recipient,
        uint256 amount
    ) external onlyOwner {
        require(recipient != address(0), "VelirionToken: Invalid recipient address");
        require(amount > 0, "VelirionToken: Amount must be greater than zero");
        require(balanceOf(owner()) >= amount, "VelirionToken: Insufficient balance");
        
        allocationTracking[category] += amount;
        totalAllocated += amount;
        
        _transfer(owner(), recipient, amount);
        
        emit TokensAllocated(category, recipient, amount);
    }
    
    /**
     * @notice Burn unsold tokens (typically after presale)
     * @dev Only owner can burn unsold tokens
     * @param amount The amount of tokens to burn
     */
    function burnUnsold(uint256 amount) external onlyOwner {
        require(amount > 0, "VelirionToken: Amount must be greater than zero");
        require(balanceOf(owner()) >= amount, "VelirionToken: Insufficient balance to burn");
        
        _burn(owner(), amount);
        
        emit UnsoldTokensBurned(amount);
    }
    
    /**
     * @notice Pause all token transfers
     * @dev Only owner can pause. Used in emergency situations
     */
    function pause() external onlyOwner {
        _pause();
        emit EmergencyPause(msg.sender);
    }
    
    /**
     * @notice Unpause token transfers
     * @dev Only owner can unpause
     */
    function unpause() external onlyOwner {
        _unpause();
        emit EmergencyUnpause(msg.sender);
    }
    
    /**
     * @notice Get allocation amount for a specific category
     * @param category The allocation category to query
     * @return The total amount allocated to this category
     */
    function getAllocation(string memory category) external view returns (uint256) {
        return allocationTracking[category];
    }
    
    /**
     * @dev Hook that is called before any transfer of tokens
     * @notice Implements pausability - transfers are blocked when paused
     * @dev Updated for OpenZeppelin v5 - uses _update instead of _beforeTokenTransfer
     */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._update(from, to, amount);
    }
}
