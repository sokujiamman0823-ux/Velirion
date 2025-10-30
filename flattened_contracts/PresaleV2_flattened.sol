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


// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/IERC165.sol)


/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/interfaces/IERC165.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC165.sol)



// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)


/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File @openzeppelin/contracts/interfaces/IERC20.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC20.sol)



// File @openzeppelin/contracts/interfaces/IERC1363.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC1363.sol)



/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}


// File @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.3.0) (token/ERC20/utils/SafeERC20.sol)



/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}


// File @openzeppelin/contracts/utils/Pausable.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.3.0) (utils/Pausable.sol)


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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


// File contracts/presale/PresaleContractV2.sol

// Original license: SPDX_License_Identifier: MIT





/**
 * @title VelirionPresaleV2
 * @notice Multi-phase presale with vesting, antibot, and VLR-based limits
 *
 * Key Features:
 * - 10 phases: $0.005 - $0.015 per VLR
 * - 3M VLR per phase (30M total)
 * - Vesting: 40% TGE + 30% monthly for 2 months
 * - Antibot: 5-minute delay between purchases
 * - Limits: 50k VLR per tx, 500k VLR per wallet
 * - Multi-token payments: ETH, USDT, USDC
 * - 5% referral bonus
 */
contract VelirionPresaleV2 is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ============================================================================
    // Constants
    // ============================================================================

    uint256 public constant MAX_PER_TRANSACTION = 50_000 * 10 ** 18; // 50k VLR
    uint256 public constant MAX_PER_WALLET = 500_000 * 10 ** 18; // 500k VLR
    uint256 public constant PURCHASE_DELAY = 5 minutes;
    uint256 public constant REFERRAL_BONUS_BPS = 500; // 5%
    uint256 public constant BASIS_POINTS = 10000;

    // Vesting: 40% at TGE, 30% after 30 days, 30% after 60 days
    uint256 public constant TGE_PERCENT = 4000; // 40%
    uint256 public constant MONTH_1_PERCENT = 3000; // 30%
    uint256 public constant MONTH_2_PERCENT = 3000; // 30%
    uint256 public constant VESTING_INTERVAL = 30 days;

    // ============================================================================
    // State Variables
    // ============================================================================

    IERC20 public immutable vlrToken;
    IERC20 public immutable usdtToken;
    IERC20 public immutable usdcToken;

    uint256 public currentPhase;
    uint256 public ethUsdPrice;
    uint256 public totalRaisedUSD;
    uint256 public presaleStartTime;
    bool public presaleFinalized;

    // ============================================================================
    // Structs
    // ============================================================================

    struct Phase {
        uint256 startTime;
        uint256 endTime;
        uint256 pricePerToken; // USD with 18 decimals
        uint256 maxTokens; // Total tokens for phase
        uint256 soldTokens; // Tokens sold
        bool isActive;
    }

    struct VestingSchedule {
        uint256 totalAmount; // Total tokens purchased
        uint256 claimedAmount; // Amount already claimed
        uint256 tgeAmount; // 40% released at TGE
        uint256 month1Amount; // 30% after 30 days
        uint256 month2Amount; // 30% after 60 days
    }

    struct Purchase {
        uint256 phaseId;
        uint256 amount;
        uint256 tokenAmount;
        address paymentToken;
        uint256 timestamp;
    }

    struct Referral {
        address referrer;
        uint256 totalReferred;
        uint256 totalEarned;
        uint256 totalVolume;
    }

    // ============================================================================
    // Mappings
    // ============================================================================

    mapping(uint256 => Phase) public phases;
    mapping(address => VestingSchedule) public vestingSchedules;
    mapping(address => Purchase[]) public userPurchases;
    mapping(address => uint256) public totalPurchasedVLR; // Total VLR per wallet
    mapping(address => uint256) public lastPurchaseTime; // For 5-min delay
    mapping(address => Referral) public referrals;
    mapping(address => bool) public hasBeenReferred;

    // ============================================================================
    // Events
    // ============================================================================

    event PhaseInitialized(
        uint256 indexed phaseId,
        uint256 pricePerToken,
        uint256 maxTokens
    );
    event PhaseStarted(uint256 indexed phaseId, uint256 startTime);
    event PhaseEnded(uint256 indexed phaseId, uint256 endTime);
    event TokensPurchased(
        address indexed buyer,
        uint256 indexed phaseId,
        uint256 amountPaid,
        uint256 tokenAmount,
        address paymentToken,
        address referrer
    );
    event TokensClaimed(address indexed user, uint256 amount);
    event ReferralBonus(
        address indexed referrer,
        address indexed referee,
        uint256 bonusAmount
    );
    event FundsWithdrawn(address indexed token, uint256 amount);
    event EthPriceUpdated(uint256 newPrice);
    event PresaleFinalized(uint256 unsoldTokens);

    // ============================================================================
    // Errors
    // ============================================================================

    error InvalidPhase();
    error PhaseNotActive();
    error InsufficientTokens();
    error ExceedsMaxPerTransaction();
    error ExceedsMaxPerWallet();
    error PurchaseDelayNotMet();
    error InvalidAmount();
    error InvalidPrice();
    error TransferFailed();
    error AlreadyReferred();
    error CannotReferSelf();
    error PresaleNotStarted();
    error PresaleAlreadyFinalized();
    error NothingToClaim();

    // ============================================================================
    // Constructor
    // ============================================================================

    constructor(
        address _vlrToken,
        address _usdtToken,
        address _usdcToken,
        uint256 _initialEthPrice
    ) Ownable(msg.sender) {
        require(_vlrToken != address(0), "Invalid VLR token");
        require(_usdtToken != address(0), "Invalid USDT token");
        require(_usdcToken != address(0), "Invalid USDC token");
        require(_initialEthPrice > 0, "Invalid ETH price");

        vlrToken = IERC20(_vlrToken);
        usdtToken = IERC20(_usdtToken);
        usdcToken = IERC20(_usdcToken);
        ethUsdPrice = _initialEthPrice;
    }

    // ============================================================================
    // Owner Functions
    // ============================================================================

    /**
     * @notice Initialize all 10 presale phases per specification
     * @dev Prices: $0.005 to $0.015, 3M tokens per phase
     */
    function initializePhases() external onlyOwner {
        // Phase 0: $0.005 per token, 3M tokens
        _initializePhase(0, 0.005 ether, 3_000_000 ether);

        // Phase 1: $0.006 per token, 3M tokens
        _initializePhase(1, 0.006 ether, 3_000_000 ether);

        // Phase 2: $0.007 per token, 3M tokens
        _initializePhase(2, 0.007 ether, 3_000_000 ether);

        // Phase 3: $0.008 per token, 3M tokens
        _initializePhase(3, 0.008 ether, 3_000_000 ether);

        // Phase 4: $0.009 per token, 3M tokens
        _initializePhase(4, 0.009 ether, 3_000_000 ether);

        // Phase 5: $0.010 per token, 3M tokens
        _initializePhase(5, 0.010 ether, 3_000_000 ether);

        // Phase 6: $0.011 per token, 3M tokens
        _initializePhase(6, 0.011 ether, 3_000_000 ether);

        // Phase 7: $0.012 per token, 3M tokens
        _initializePhase(7, 0.012 ether, 3_000_000 ether);

        // Phase 8: $0.013 per token, 3M tokens
        _initializePhase(8, 0.013 ether, 3_000_000 ether);

        // Phase 9: $0.015 per token, 3M tokens
        _initializePhase(9, 0.015 ether, 3_000_000 ether);
    }

    /**
     * @notice Start the presale and activate first phase
     * @param duration Duration for phase 0 in seconds
     */
    function startPresale(uint256 duration) external onlyOwner {
        require(presaleStartTime == 0, "Presale already started");
        presaleStartTime = block.timestamp;
        _startPhase(0, duration);
    }

    /**
     * @notice Start a specific phase
     */
    function startPhase(uint256 phaseId, uint256 duration) external onlyOwner {
        _startPhase(phaseId, duration);
    }

    /**
     * @notice End current phase
     */
    function endCurrentPhase() external onlyOwner {
        Phase storage phase = phases[currentPhase];
        phase.isActive = false;
        phase.endTime = block.timestamp;
        emit PhaseEnded(currentPhase, block.timestamp);
    }

    /**
     * @notice Finalize presale and burn unsold tokens
     */
    function finalizePresale() external onlyOwner {
        if (presaleFinalized) revert PresaleAlreadyFinalized();

        // Calculate unsold tokens
        uint256 totalSold = 0;
        for (uint256 i = 0; i < 10; i++) {
            totalSold += phases[i].soldTokens;
        }

        uint256 contractBalance = vlrToken.balanceOf(address(this));
        uint256 unsoldTokens = contractBalance - _calculateTotalVested();

        if (unsoldTokens > 0) {
            // Burn unsold tokens
            vlrToken.safeTransfer(address(0xdead), unsoldTokens);
        }

        presaleFinalized = true;
        emit PresaleFinalized(unsoldTokens);
    }

    /**
     * @notice Update ETH/USD price
     */
    function setEthUsdPrice(uint256 _price) external onlyOwner {
        if (_price == 0) revert InvalidPrice();
        ethUsdPrice = _price;
        emit EthPriceUpdated(_price);
    }

    /**
     * @notice Withdraw collected funds
     */
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) revert InvalidAmount();
        (bool success, ) = owner().call{value: balance}("");
        if (!success) revert TransferFailed();
        emit FundsWithdrawn(address(0), balance);
    }

    function withdrawUSDT() external onlyOwner {
        uint256 balance = usdtToken.balanceOf(address(this));
        if (balance == 0) revert InvalidAmount();
        usdtToken.safeTransfer(owner(), balance);
        emit FundsWithdrawn(address(usdtToken), balance);
    }

    function withdrawUSDC() external onlyOwner {
        uint256 balance = usdcToken.balanceOf(address(this));
        if (balance == 0) revert InvalidAmount();
        usdcToken.safeTransfer(owner(), balance);
        emit FundsWithdrawn(address(usdcToken), balance);
    }

    function pause() external onlyOwner {
        _pause();
    }
    function unpause() external onlyOwner {
        _unpause();
    }

    // ============================================================================
    // Public Purchase Functions
    // ============================================================================

    /**
     * @notice Buy tokens with ETH
     * @param referrer Referrer address (address(0) if none)
     */
    function buyWithETH(
        address referrer
    ) external payable nonReentrant whenNotPaused {
        if (msg.value == 0) revert InvalidAmount();

        uint256 usdValue = (msg.value * ethUsdPrice) / 1 ether;
        uint256 tokenAmount = _processPurchase(
            msg.sender,
            usdValue,
            address(0),
            referrer
        );

        emit TokensPurchased(
            msg.sender,
            currentPhase,
            msg.value,
            tokenAmount,
            address(0),
            referrer
        );
    }

    /**
     * @notice Buy tokens with USDT
     */
    function buyWithUSDT(
        uint256 amount,
        address referrer
    ) external nonReentrant whenNotPaused {
        if (amount == 0) revert InvalidAmount();

        uint256 usdValue = amount * 10 ** 12; // Convert 6 decimals to 18
        usdtToken.safeTransferFrom(msg.sender, address(this), amount);

        uint256 tokenAmount = _processPurchase(
            msg.sender,
            usdValue,
            address(usdtToken),
            referrer
        );

        emit TokensPurchased(
            msg.sender,
            currentPhase,
            amount,
            tokenAmount,
            address(usdtToken),
            referrer
        );
    }

    /**
     * @notice Buy tokens with USDC
     */
    function buyWithUSDC(
        uint256 amount,
        address referrer
    ) external nonReentrant whenNotPaused {
        if (amount == 0) revert InvalidAmount();

        uint256 usdValue = amount * 10 ** 12; // Convert 6 decimals to 18
        usdcToken.safeTransferFrom(msg.sender, address(this), amount);

        uint256 tokenAmount = _processPurchase(
            msg.sender,
            usdValue,
            address(usdcToken),
            referrer
        );

        emit TokensPurchased(
            msg.sender,
            currentPhase,
            amount,
            tokenAmount,
            address(usdcToken),
            referrer
        );
    }

    /**
     * @notice Claim vested tokens
     */
    function claimTokens() external nonReentrant {
        if (presaleStartTime == 0) revert PresaleNotStarted();

        VestingSchedule storage schedule = vestingSchedules[msg.sender];
        if (schedule.totalAmount == 0) revert NothingToClaim();

        uint256 claimable = _calculateClaimable(msg.sender);
        if (claimable == 0) revert NothingToClaim();

        schedule.claimedAmount += claimable;
        vlrToken.safeTransfer(msg.sender, claimable);

        emit TokensClaimed(msg.sender, claimable);
    }

    // ============================================================================
    // Internal Functions
    // ============================================================================

    function _initializePhase(
        uint256 phaseId,
        uint256 pricePerToken,
        uint256 maxTokens
    ) internal {
        phases[phaseId] = Phase({
            startTime: 0,
            endTime: 0,
            pricePerToken: pricePerToken,
            maxTokens: maxTokens,
            soldTokens: 0,
            isActive: false
        });
        emit PhaseInitialized(phaseId, pricePerToken, maxTokens);
    }

    function _startPhase(uint256 phaseId, uint256 duration) internal {
        if (phaseId > 9) revert InvalidPhase();

        Phase storage phase = phases[phaseId];
        phase.startTime = block.timestamp;
        phase.endTime = block.timestamp + duration;
        phase.isActive = true;
        currentPhase = phaseId;

        emit PhaseStarted(phaseId, phase.startTime);
    }

    function _processPurchase(
        address buyer,
        uint256 usdValue,
        address paymentToken,
        address referrer
    ) internal returns (uint256) {
        Phase storage phase = phases[currentPhase];

        // Validate phase
        if (!phase.isActive) revert PhaseNotActive();
        if (
            block.timestamp < phase.startTime || block.timestamp > phase.endTime
        ) {
            revert PhaseNotActive();
        }

        // Check 5-minute delay
        if (lastPurchaseTime[buyer] != 0) {
            if (block.timestamp < lastPurchaseTime[buyer] + PURCHASE_DELAY) {
                revert PurchaseDelayNotMet();
            }
        }

        // Calculate token amount
        uint256 tokenAmount = (usdValue * 1 ether) / phase.pricePerToken;

        // Check limits
        if (tokenAmount > MAX_PER_TRANSACTION)
            revert ExceedsMaxPerTransaction();
        if (totalPurchasedVLR[buyer] + tokenAmount > MAX_PER_WALLET)
            revert ExceedsMaxPerWallet();
        if (phase.soldTokens + tokenAmount > phase.maxTokens)
            revert InsufficientTokens();

        // Update state
        phase.soldTokens += tokenAmount;
        totalPurchasedVLR[buyer] += tokenAmount;
        lastPurchaseTime[buyer] = block.timestamp;
        totalRaisedUSD += usdValue;

        // Record purchase
        userPurchases[buyer].push(
            Purchase({
                phaseId: currentPhase,
                amount: usdValue,
                tokenAmount: tokenAmount,
                paymentToken: paymentToken,
                timestamp: block.timestamp
            })
        );

        // Setup vesting
        _setupVesting(buyer, tokenAmount);

        // Process referral
        if (referrer != address(0) && referrer != buyer) {
            _processReferral(buyer, referrer, tokenAmount);
        }

        return tokenAmount;
    }

    function _setupVesting(address user, uint256 amount) internal {
        VestingSchedule storage schedule = vestingSchedules[user];

        uint256 tgeAmount = (amount * TGE_PERCENT) / BASIS_POINTS;
        uint256 month1Amount = (amount * MONTH_1_PERCENT) / BASIS_POINTS;
        uint256 month2Amount = amount - tgeAmount - month1Amount; // Remaining

        schedule.totalAmount += amount;
        schedule.tgeAmount += tgeAmount;
        schedule.month1Amount += month1Amount;
        schedule.month2Amount += month2Amount;
    }

    function _processReferral(
        address buyer,
        address referrer,
        uint256 tokenAmount
    ) internal {
        if (referrer == buyer) revert CannotReferSelf();
        if (hasBeenReferred[buyer]) revert AlreadyReferred();

        uint256 bonusAmount = (tokenAmount * REFERRAL_BONUS_BPS) / BASIS_POINTS;

        uint256 contractBalance = vlrToken.balanceOf(address(this));
        if (contractBalance < bonusAmount) return;

        if (referrals[buyer].referrer == address(0)) {
            referrals[buyer].referrer = referrer;
            hasBeenReferred[buyer] = true;
        }

        referrals[referrer].totalReferred += 1;
        referrals[referrer].totalEarned += bonusAmount;
        referrals[referrer].totalVolume += tokenAmount;

        vlrToken.safeTransfer(referrer, bonusAmount);
        emit ReferralBonus(referrer, buyer, bonusAmount);
    }

    function _calculateClaimable(address user) internal view returns (uint256) {
        VestingSchedule memory schedule = vestingSchedules[user];
        if (schedule.totalAmount == 0) return 0;

        uint256 claimable = schedule.tgeAmount; // 40% at TGE

        uint256 timeSinceTGE = block.timestamp - presaleStartTime;

        if (timeSinceTGE >= VESTING_INTERVAL) {
            claimable += schedule.month1Amount; // +30% after 30 days
        }

        if (timeSinceTGE >= VESTING_INTERVAL * 2) {
            claimable += schedule.month2Amount; // +30% after 60 days
        }

        return claimable - schedule.claimedAmount;
    }

    function _calculateTotalVested() internal pure returns (uint256) {
        // This would need to track all users - simplified for now
        return 0;
    }

    // ============================================================================
    // View Functions
    // ============================================================================

    function getCurrentPhaseInfo() external view returns (Phase memory) {
        return phases[currentPhase];
    }

    function getPhaseInfo(
        uint256 phaseId
    ) external view returns (Phase memory) {
        return phases[phaseId];
    }

    function calculateTokenAmount(
        uint256 usdValue
    ) external view returns (uint256) {
        Phase memory phase = phases[currentPhase];
        return (usdValue * 1 ether) / phase.pricePerToken;
    }

    function calculateTokenAmountForETH(
        uint256 ethAmount
    ) external view returns (uint256) {
        uint256 usdValue = (ethAmount * ethUsdPrice) / 1 ether;
        Phase memory phase = phases[currentPhase];
        return (usdValue * 1 ether) / phase.pricePerToken;
    }

    function getUserPurchases(
        address user
    ) external view returns (Purchase[] memory) {
        return userPurchases[user];
    }

    function getVestingSchedule(
        address user
    ) external view returns (VestingSchedule memory) {
        return vestingSchedules[user];
    }

    function getClaimableAmount(address user) external view returns (uint256) {
        return _calculateClaimable(user);
    }

    function getReferralInfo(
        address user
    ) external view returns (Referral memory) {
        return referrals[user];
    }

    function isPhaseActive() external view returns (bool) {
        Phase memory phase = phases[currentPhase];
        return
            phase.isActive &&
            block.timestamp >= phase.startTime &&
            block.timestamp <= phase.endTime;
    }

    function getTotalTokensSold() external view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < 10; i++) {
            total += phases[i].soldTokens;
        }
        return total;
    }

    function canPurchase(
        address user
    ) external view returns (bool, string memory) {
        if (lastPurchaseTime[user] == 0) return (true, "");

        if (block.timestamp < lastPurchaseTime[user] + PURCHASE_DELAY) {
            uint256 timeLeft = (lastPurchaseTime[user] + PURCHASE_DELAY) -
                block.timestamp;
            return (
                false,
                string(
                    abi.encodePacked("Wait ", _toString(timeLeft), " seconds")
                )
            );
        }

        return (true, "");
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    receive() external payable {
        revert("Use buyWithETH function");
    }
}
