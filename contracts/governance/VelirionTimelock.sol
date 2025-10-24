// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title VelirionTimelock
 * @notice Timelock controller for DAO proposal execution
 * 
 * Features:
 * - 2-day minimum delay before execution
 * - Queue proposals after voting succeeds
 * - Execute proposals after delay
 * - Cancel queued proposals (admin only)
 * - Prevents immediate execution for security
 */
contract VelirionTimelock is Ownable, ReentrancyGuard {
    // ============================================================================
    // Constants
    // ============================================================================

    uint256 public constant MINIMUM_DELAY = 2 days;
    uint256 public constant MAXIMUM_DELAY = 30 days;
    uint256 public constant GRACE_PERIOD = 14 days;

    // ============================================================================
    // State Variables
    // ============================================================================

    uint256 public delay;
    mapping(bytes32 => bool) public queuedTransactions;

    // ============================================================================
    // Events
    // ============================================================================

    event QueueTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        bytes data,
        uint256 eta
    );

    event ExecuteTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        bytes data,
        uint256 eta
    );

    event CancelTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        bytes data,
        uint256 eta
    );

    event NewDelay(uint256 indexed newDelay);

    // ============================================================================
    // Errors
    // ============================================================================

    error DelayBelowMinimum();
    error DelayAboveMaximum();
    error TransactionAlreadyQueued();
    error TransactionNotQueued();
    error TimelockNotMet();
    error TransactionStale();
    error ExecutionReverted();

    // ============================================================================
    // Constructor
    // ============================================================================

    constructor(address _admin) Ownable(_admin) {
        delay = MINIMUM_DELAY;
    }

    // ============================================================================
    // Admin Functions
    // ============================================================================

    /**
     * @notice Set the timelock delay
     * @param _delay New delay in seconds
     */
    function setDelay(uint256 _delay) external onlyOwner {
        if (_delay < MINIMUM_DELAY) revert DelayBelowMinimum();
        if (_delay > MAXIMUM_DELAY) revert DelayAboveMaximum();
        
        delay = _delay;
        emit NewDelay(_delay);
    }

    // ============================================================================
    // Core Functions
    // ============================================================================

    /**
     * @notice Queue a transaction for execution
     * @param target Contract to call
     * @param value ETH value to send
     * @param data Encoded function call
     * @param eta Estimated time of execution
     */
    function queueTransaction(
        address target,
        uint256 value,
        bytes memory data,
        uint256 eta
    ) external onlyOwner returns (bytes32) {
        if (eta < block.timestamp + delay) revert TimelockNotMet();

        bytes32 txHash = keccak256(abi.encode(target, value, data, eta));
        
        if (queuedTransactions[txHash]) revert TransactionAlreadyQueued();
        
        queuedTransactions[txHash] = true;
        
        emit QueueTransaction(txHash, target, value, data, eta);
        
        return txHash;
    }

    /**
     * @notice Execute a queued transaction
     * @param target Contract to call
     * @param value ETH value to send
     * @param data Encoded function call
     * @param eta Estimated time of execution
     */
    function executeTransaction(
        address target,
        uint256 value,
        bytes memory data,
        uint256 eta
    ) external payable onlyOwner nonReentrant returns (bytes memory) {
        bytes32 txHash = keccak256(abi.encode(target, value, data, eta));
        
        if (!queuedTransactions[txHash]) revert TransactionNotQueued();
        if (block.timestamp < eta) revert TimelockNotMet();
        if (block.timestamp > eta + GRACE_PERIOD) revert TransactionStale();

        queuedTransactions[txHash] = false;

        (bool success, bytes memory returnData) = target.call{value: value}(data);
        if (!success) revert ExecutionReverted();

        emit ExecuteTransaction(txHash, target, value, data, eta);

        return returnData;
    }

    /**
     * @notice Cancel a queued transaction
     * @param target Contract to call
     * @param value ETH value to send
     * @param data Encoded function call
     * @param eta Estimated time of execution
     */
    function cancelTransaction(
        address target,
        uint256 value,
        bytes memory data,
        uint256 eta
    ) external onlyOwner {
        bytes32 txHash = keccak256(abi.encode(target, value, data, eta));
        
        if (!queuedTransactions[txHash]) revert TransactionNotQueued();
        
        queuedTransactions[txHash] = false;
        
        emit CancelTransaction(txHash, target, value, data, eta);
    }

    /**
     * @notice Queue multiple transactions
     * @param targets Contracts to call
     * @param values ETH values to send
     * @param datas Encoded function calls
     * @param eta Estimated time of execution
     */
    function queueTransactions(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory datas,
        uint256 eta
    ) external onlyOwner returns (bytes32[] memory) {
        require(
            targets.length == values.length && values.length == datas.length,
            "Length mismatch"
        );

        bytes32[] memory txHashes = new bytes32[](targets.length);

        for (uint256 i = 0; i < targets.length; i++) {
            if (eta < block.timestamp + delay) revert TimelockNotMet();

            bytes32 txHash = keccak256(abi.encode(targets[i], values[i], datas[i], eta));
            
            if (queuedTransactions[txHash]) revert TransactionAlreadyQueued();
            
            queuedTransactions[txHash] = true;
            txHashes[i] = txHash;
            
            emit QueueTransaction(txHash, targets[i], values[i], datas[i], eta);
        }

        return txHashes;
    }

    /**
     * @notice Execute multiple queued transactions
     * @param targets Contracts to call
     * @param values ETH values to send
     * @param datas Encoded function calls
     * @param eta Estimated time of execution
     */
    function executeTransactions(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory datas,
        uint256 eta
    ) external payable onlyOwner nonReentrant {
        require(
            targets.length == values.length && values.length == datas.length,
            "Length mismatch"
        );

        for (uint256 i = 0; i < targets.length; i++) {
            bytes32 txHash = keccak256(abi.encode(targets[i], values[i], datas[i], eta));
            
            if (!queuedTransactions[txHash]) revert TransactionNotQueued();
            if (block.timestamp < eta) revert TimelockNotMet();
            if (block.timestamp > eta + GRACE_PERIOD) revert TransactionStale();

            queuedTransactions[txHash] = false;

            (bool success, ) = targets[i].call{value: values[i]}(datas[i]);
            if (!success) revert ExecutionReverted();

            emit ExecuteTransaction(txHash, targets[i], values[i], datas[i], eta);
        }
    }

    // ============================================================================
    // View Functions
    // ============================================================================

    /**
     * @notice Check if a transaction is queued
     * @param target Contract to call
     * @param value ETH value to send
     * @param data Encoded function call
     * @param eta Estimated time of execution
     */
    function isQueued(
        address target,
        uint256 value,
        bytes memory data,
        uint256 eta
    ) external view returns (bool) {
        bytes32 txHash = keccak256(abi.encode(target, value, data, eta));
        return queuedTransactions[txHash];
    }

    /**
     * @notice Get transaction hash
     * @param target Contract to call
     * @param value ETH value to send
     * @param data Encoded function call
     * @param eta Estimated time of execution
     */
    function getTransactionHash(
        address target,
        uint256 value,
        bytes memory data,
        uint256 eta
    ) external pure returns (bytes32) {
        return keccak256(abi.encode(target, value, data, eta));
    }

    // ============================================================================
    // Receive Function
    // ============================================================================

    receive() external payable {}
}
