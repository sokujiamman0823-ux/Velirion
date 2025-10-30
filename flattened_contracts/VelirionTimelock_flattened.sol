// Sources flattened with hardhat v2.26.3 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/utils/ReentrancyGuard.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}


// File contracts/governance/VelirionTimelock.sol

// Original license: SPDX_License_Identifier: MIT


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
