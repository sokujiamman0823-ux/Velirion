// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title VelirionTreasury
 * @notice Treasury management for DAO-controlled funds
 * 
 * Features:
 * - Holds DAO treasury funds (5% of supply)
 * - DAO-controlled fund allocation
 * - Multi-wallet management (Marketing, Team, Liquidity)
 * - Transparent fund tracking
 * - Emergency withdrawal (owner only)
 */
contract VelirionTreasury is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ============================================================================
    // State Variables
    // ============================================================================

    IERC20 public immutable vlrToken;
    address public daoContract;

    // Multi-sig wallet addresses
    address public marketingWallet;
    address public teamWallet;
    address public liquidityWallet;

    // Fund allocation tracking
    mapping(address => uint256) public allocatedFunds;
    uint256 public totalAllocated;

    // ============================================================================
    // Events
    // ============================================================================

    event FundsAllocated(
        address indexed wallet,
        uint256 amount,
        string purpose,
        uint256 timestamp
    );

    event FundsWithdrawn(
        address indexed wallet,
        uint256 amount,
        uint256 timestamp
    );

    event WalletUpdated(
        string walletType,
        address indexed oldWallet,
        address indexed newWallet
    );

    event DAOContractUpdated(
        address indexed oldDAO,
        address indexed newDAO
    );

    event EmergencyWithdrawal(
        address indexed token,
        address indexed to,
        uint256 amount
    );

    // ============================================================================
    // Errors
    // ============================================================================

    error OnlyDAO();
    error InvalidAddress();
    error InsufficientBalance();
    error AllocationExceedsBalance();

    // ============================================================================
    // Modifiers
    // ============================================================================

    modifier onlyDAO() {
        if (msg.sender != daoContract) revert OnlyDAO();
        _;
    }

    // ============================================================================
    // Constructor
    // ============================================================================

    constructor(
        address _vlrToken,
        address _marketingWallet,
        address _teamWallet,
        address _liquidityWallet,
        address _admin
    ) Ownable(_admin) {
        if (
            _vlrToken == address(0) ||
            _marketingWallet == address(0) ||
            _teamWallet == address(0) ||
            _liquidityWallet == address(0)
        ) revert InvalidAddress();

        vlrToken = IERC20(_vlrToken);
        marketingWallet = _marketingWallet;
        teamWallet = _teamWallet;
        liquidityWallet = _liquidityWallet;
    }

    // ============================================================================
    // Admin Functions
    // ============================================================================

    /**
     * @notice Set the DAO contract address
     * @param _daoContract Address of DAO contract
     */
    function setDAOContract(address _daoContract) external onlyOwner {
        if (_daoContract == address(0)) revert InvalidAddress();
        
        address oldDAO = daoContract;
        daoContract = _daoContract;
        
        emit DAOContractUpdated(oldDAO, _daoContract);
    }

    /**
     * @notice Update marketing wallet address
     * @param _newWallet New marketing wallet address
     */
    function setMarketingWallet(address _newWallet) external onlyOwner {
        if (_newWallet == address(0)) revert InvalidAddress();
        
        address oldWallet = marketingWallet;
        marketingWallet = _newWallet;
        
        emit WalletUpdated("Marketing", oldWallet, _newWallet);
    }

    /**
     * @notice Update team wallet address
     * @param _newWallet New team wallet address
     */
    function setTeamWallet(address _newWallet) external onlyOwner {
        if (_newWallet == address(0)) revert InvalidAddress();
        
        address oldWallet = teamWallet;
        teamWallet = _newWallet;
        
        emit WalletUpdated("Team", oldWallet, _newWallet);
    }

    /**
     * @notice Update liquidity wallet address
     * @param _newWallet New liquidity wallet address
     */
    function setLiquidityWallet(address _newWallet) external onlyOwner {
        if (_newWallet == address(0)) revert InvalidAddress();
        
        address oldWallet = liquidityWallet;
        liquidityWallet = _newWallet;
        
        emit WalletUpdated("Liquidity", oldWallet, _newWallet);
    }

    // ============================================================================
    // DAO Functions
    // ============================================================================

    /**
     * @notice Allocate funds to a wallet (DAO only)
     * @param wallet Recipient wallet address
     * @param amount Amount to allocate
     * @param purpose Purpose of allocation
     */
    function allocateFunds(
        address wallet,
        uint256 amount,
        string memory purpose
    ) external onlyDAO nonReentrant {
        if (wallet == address(0)) revert InvalidAddress();
        
        uint256 balance = vlrToken.balanceOf(address(this));
        if (amount > balance) revert InsufficientBalance();

        allocatedFunds[wallet] += amount;
        totalAllocated += amount;

        vlrToken.safeTransfer(wallet, amount);

        emit FundsAllocated(wallet, amount, purpose, block.timestamp);
    }

    /**
     * @notice Batch allocate funds to multiple wallets
     * @param wallets Array of recipient addresses
     * @param amounts Array of amounts to allocate
     * @param purposes Array of purposes
     */
    function batchAllocateFunds(
        address[] memory wallets,
        uint256[] memory amounts,
        string[] memory purposes
    ) external onlyDAO nonReentrant {
        require(
            wallets.length == amounts.length && amounts.length == purposes.length,
            "Length mismatch"
        );

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        uint256 balance = vlrToken.balanceOf(address(this));
        if (totalAmount > balance) revert InsufficientBalance();

        for (uint256 i = 0; i < wallets.length; i++) {
            if (wallets[i] == address(0)) revert InvalidAddress();
            
            allocatedFunds[wallets[i]] += amounts[i];
            totalAllocated += amounts[i];

            vlrToken.safeTransfer(wallets[i], amounts[i]);

            emit FundsAllocated(wallets[i], amounts[i], purposes[i], block.timestamp);
        }
    }

    // ============================================================================
    // Emergency Functions
    // ============================================================================

    /**
     * @notice Emergency withdrawal (owner only)
     * @param token Token address (address(0) for ETH)
     * @param to Recipient address
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner nonReentrant {
        if (to == address(0)) revert InvalidAddress();

        if (token == address(0)) {
            // Withdraw ETH
            (bool success, ) = to.call{value: amount}("");
            require(success, "ETH transfer failed");
        } else {
            // Withdraw ERC20
            IERC20(token).safeTransfer(to, amount);
        }

        emit EmergencyWithdrawal(token, to, amount);
    }

    // ============================================================================
    // View Functions
    // ============================================================================

    /**
     * @notice Get treasury balance
     * @return VLR token balance
     */
    function getTreasuryBalance() external view returns (uint256) {
        return vlrToken.balanceOf(address(this));
    }

    /**
     * @notice Get allocated funds for a wallet
     * @param wallet Wallet address
     * @return Total allocated amount
     */
    function getAllocatedFunds(address wallet) external view returns (uint256) {
        return allocatedFunds[wallet];
    }

    /**
     * @notice Get all wallet addresses
     * @return marketing Marketing wallet
     * @return team Team wallet
     * @return liquidity Liquidity wallet
     */
    function getWallets() external view returns (
        address marketing,
        address team,
        address liquidity
    ) {
        return (marketingWallet, teamWallet, liquidityWallet);
    }

    /**
     * @notice Get treasury statistics
     * @return balance Current VLR balance
     * @return allocated Total allocated funds
     * @return available Available funds (balance - allocated)
     */
    function getTreasuryStats() external view returns (
        uint256 balance,
        uint256 allocated,
        uint256 available
    ) {
        balance = vlrToken.balanceOf(address(this));
        allocated = totalAllocated;
        available = balance;  // All balance is available for DAO allocation
        return (balance, allocated, available);
    }

    // ============================================================================
    // Receive Function
    // ============================================================================

    receive() external payable {}
}
