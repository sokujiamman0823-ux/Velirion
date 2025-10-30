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


// File contracts/interfaces/IVelirionReferral.sol

// Original license: SPDX_License_Identifier: MIT

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


// File contracts/core/VelirionReferral.sol

// Original license: SPDX_License_Identifier: MIT






/**
 * @title VelirionReferral
 * @notice 4-tier referral system with purchase and staking bonuses
 * 
 * Tier Structure:
 * - Tier 1 (Starter): 0 referrals   ΓåÆ 5% purchase, 2% staking
 * - Tier 2 (Bronze):  10+ referrals ΓåÆ 7% purchase, 3% staking + NFT
 * - Tier 3 (Silver):  25+ referrals ΓåÆ 10% purchase, 4% staking + Bonuses
 * - Tier 4 (Gold):    50+ referrals ΓåÆ 12% purchase, 5% staking + Pool Access
 * 
 * Features:
 * - Automatic tier upgrades based on referral count
 * - Dual bonus system (purchase + staking)
 * - Manual reward claiming
 * - Anti-gaming protections
 * - Full referral tree tracking
 */
contract VelirionReferral is
    IVelirionReferral,
    Ownable,
    Pausable,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;

    // ============================================================================
    // Constants
    // ============================================================================

    uint256 public constant BASIS_POINTS = 10000;
    uint256 public constant MAX_TIER = 4;

    // Tier thresholds
    uint256 public constant TIER_2_THRESHOLD = 10; // Bronze
    uint256 public constant TIER_3_THRESHOLD = 25; // Silver
    uint256 public constant TIER_4_THRESHOLD = 50; // Gold

    // Tier 1 bonuses (Starter)
    uint256 public constant TIER_1_PURCHASE_BONUS = 500; // 5%
    uint256 public constant TIER_1_STAKING_BONUS = 200; // 2%

    // Tier 2 bonuses (Bronze)
    uint256 public constant TIER_2_PURCHASE_BONUS = 700; // 7%
    uint256 public constant TIER_2_STAKING_BONUS = 300; // 3%

    // Tier 3 bonuses (Silver)
    uint256 public constant TIER_3_PURCHASE_BONUS = 1000; // 10%
    uint256 public constant TIER_3_STAKING_BONUS = 400; // 4%

    // Tier 4 bonuses (Gold)
    uint256 public constant TIER_4_PURCHASE_BONUS = 1200; // 12%
    uint256 public constant TIER_4_STAKING_BONUS = 500; // 5%

    // ============================================================================
    // State Variables
    // ============================================================================

    IERC20 public immutable vlrToken;

    // Referral relationships
    mapping(address => address) public referredBy;
    mapping(address => Referrer) public referrers;
    mapping(address => ReferralStats) private referralStats;
    mapping(address => uint256) public pendingRewards;

    // Authorized contracts (presale, staking)
    mapping(address => bool) public authorizedContracts;

    // Statistics
    uint256 public totalReferrers;
    uint256 public totalBonusesDistributed;
    uint256 public totalRewardsClaimed;

    // ============================================================================
    // Errors
    // ============================================================================

    error InvalidReferrer();
    error CannotReferSelf();
    error AlreadyReferred();
    error ReferrerNotActive();
    error NotAuthorized();
    error NoRewardsToClaim();
    error InsufficientContractBalance();
    error InvalidTier();
    error InvalidAmount();

    // ============================================================================
    // Modifiers
    // ============================================================================

    modifier onlyAuthorized() {
        if (!authorizedContracts[msg.sender] && msg.sender != owner()) {
            revert NotAuthorized();
        }
        _;
    }

    // ============================================================================
    // Constructor
    // ============================================================================

    constructor(address _vlrToken) Ownable(msg.sender) {
        require(_vlrToken != address(0), "Invalid VLR token");
        vlrToken = IERC20(_vlrToken);

        // Initialize owner as active referrer (for first users)
        referrers[msg.sender] = Referrer({
            addr: msg.sender,
            level: MAX_TIER,
            directReferrals: 0,
            totalEarned: 0,
            purchaseBonusEarned: 0,
            stakingBonusEarned: 0,
            registrationTime: block.timestamp,
            isActive: true
        });
        totalReferrers = 1;
    }

    // ============================================================================
    // Core Functions
    // ============================================================================

    /**
     * @notice Register a user with a referrer
     * @param referrer Address of the referrer
     */
    function register(address referrer) external override whenNotPaused {
        if (referrer == address(0)) revert InvalidReferrer();
        if (referrer == msg.sender) revert CannotReferSelf();
        if (referredBy[msg.sender] != address(0)) revert AlreadyReferred();
        if (!referrers[referrer].isActive) revert ReferrerNotActive();

        // Set referral relationship
        referredBy[msg.sender] = referrer;

        // Initialize user as referrer if first time
        if (!referrers[msg.sender].isActive) {
            referrers[msg.sender] = Referrer({
                addr: msg.sender,
                level: 1,
                directReferrals: 0,
                totalEarned: 0,
                purchaseBonusEarned: 0,
                stakingBonusEarned: 0,
                registrationTime: block.timestamp,
                isActive: true
            });
            totalReferrers++;
        }

        // Update referrer stats
        referrers[referrer].directReferrals++;
        referralStats[referrer].directReferrals.push(msg.sender);

        // Check for tier upgrade
        _checkAndUpgradeTier(referrer);

        emit ReferralRegistered(msg.sender, referrer);
    }

    /**
     * @notice Distribute purchase bonus to referrer
     * @param buyer Address of the buyer
     * @param tokenAmount Amount of tokens purchased
     */
    function distributePurchaseBonus(
        address buyer,
        uint256 tokenAmount
    ) external override onlyAuthorized whenNotPaused {
        if (tokenAmount == 0) revert InvalidAmount();

        address referrer = referredBy[buyer];
        if (referrer == address(0)) return; // No referrer, skip

        Referrer storage ref = referrers[referrer];
        (uint256 purchaseBonus, ) = getTierBonuses(ref.level);

        uint256 bonusAmount = (tokenAmount * purchaseBonus) / BASIS_POINTS;

        // Add to pending rewards
        pendingRewards[referrer] += bonusAmount;
        ref.totalEarned += bonusAmount;
        ref.purchaseBonusEarned += bonusAmount;

        // Update stats
        referralStats[referrer].totalVolume += tokenAmount;
        totalBonusesDistributed += bonusAmount;

        emit PurchaseBonusDistributed(referrer, buyer, bonusAmount);
    }

    /**
     * @notice Distribute staking bonus to referrer
     * @param staker Address of the staker
     * @param rewardAmount Amount of staking rewards
     */
    function distributeStakingBonus(
        address staker,
        uint256 rewardAmount
    ) external override onlyAuthorized whenNotPaused {
        if (rewardAmount == 0) revert InvalidAmount();

        address referrer = referredBy[staker];
        if (referrer == address(0)) return; // No referrer, skip

        Referrer storage ref = referrers[referrer];
        (, uint256 stakingBonus) = getTierBonuses(ref.level);

        uint256 bonusAmount = (rewardAmount * stakingBonus) / BASIS_POINTS;

        // Add to pending rewards
        pendingRewards[referrer] += bonusAmount;
        ref.totalEarned += bonusAmount;
        ref.stakingBonusEarned += bonusAmount;

        // Update stats
        referralStats[referrer].totalStakingVolume += rewardAmount;
        totalBonusesDistributed += bonusAmount;

        emit StakingBonusDistributed(referrer, staker, bonusAmount);
    }

    /**
     * @notice Claim accumulated rewards
     */
    function claimRewards() external override nonReentrant whenNotPaused {
        uint256 amount = pendingRewards[msg.sender];
        if (amount == 0) revert NoRewardsToClaim();

        uint256 contractBalance = vlrToken.balanceOf(address(this));
        if (contractBalance < amount) revert InsufficientContractBalance();

        // Reset pending rewards
        pendingRewards[msg.sender] = 0;
        totalRewardsClaimed += amount;

        // Transfer tokens
        vlrToken.safeTransfer(msg.sender, amount);

        emit RewardsClaimed(msg.sender, amount);
    }

    // ============================================================================
    // Internal Functions
    // ============================================================================

    /**
     * @notice Check and upgrade tier if threshold met
     * @param user Address to check
     */
    function _checkAndUpgradeTier(address user) internal {
        Referrer storage ref = referrers[user];
        uint256 referralCount = ref.directReferrals;
        uint256 currentTier = ref.level;
        uint256 newTier = currentTier;

        // Determine new tier based on referral count
        if (referralCount >= TIER_4_THRESHOLD && currentTier < 4) {
            newTier = 4; // Gold
        } else if (referralCount >= TIER_3_THRESHOLD && currentTier < 3) {
            newTier = 3; // Silver
        } else if (referralCount >= TIER_2_THRESHOLD && currentTier < 2) {
            newTier = 2; // Bronze
        }

        // Upgrade if tier changed
        if (newTier > currentTier) {
            ref.level = newTier;
            emit TierUpgraded(user, currentTier, newTier);
        }
    }

    // ============================================================================
    // Owner Functions
    // ============================================================================

    /**
     * @notice Set authorized contract status
     * @param contractAddress Address of the contract
     * @param status Authorization status
     */
    function setAuthorizedContract(
        address contractAddress,
        bool status
    ) external onlyOwner {
        require(contractAddress != address(0), "Invalid address");
        authorizedContracts[contractAddress] = status;
        emit AuthorizedContractUpdated(contractAddress, status);
    }

    /**
     * @notice Manually upgrade a user's tier (emergency only)
     * @param user Address of the user
     * @param newTier New tier level
     */
    function manualTierUpgrade(
        address user,
        uint256 newTier
    ) external onlyOwner {
        if (newTier == 0 || newTier > MAX_TIER) revert InvalidTier();

        Referrer storage ref = referrers[user];
        uint256 oldTier = ref.level;
        ref.level = newTier;

        emit TierUpgraded(user, oldTier, newTier);
    }

    /**
     * @notice Emergency withdrawal (only unsold/unallocated tokens)
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        require(amount > 0, "Invalid amount");
        uint256 contractBalance = vlrToken.balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient balance");

        vlrToken.safeTransfer(owner(), amount);
    }

    /**
     * @notice Pause contract
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    // ============================================================================
    // View Functions
    // ============================================================================

    /**
     * @notice Get the referrer of a user
     * @param user Address of the user
     * @return Address of the referrer
     */
    function getReferrer(address user) external view override returns (address) {
        return referredBy[user];
    }

    /**
     * @notice Get tier bonuses
     * @param tier Tier level (1-4)
     * @return purchaseBonus Purchase bonus in basis points
     * @return stakingBonus Staking bonus in basis points
     */
    function getTierBonuses(
        uint256 tier
    ) public pure override returns (uint256 purchaseBonus, uint256 stakingBonus) {
        if (tier == 1) {
            return (TIER_1_PURCHASE_BONUS, TIER_1_STAKING_BONUS);
        } else if (tier == 2) {
            return (TIER_2_PURCHASE_BONUS, TIER_2_STAKING_BONUS);
        } else if (tier == 3) {
            return (TIER_3_PURCHASE_BONUS, TIER_3_STAKING_BONUS);
        } else if (tier == 4) {
            return (TIER_4_PURCHASE_BONUS, TIER_4_STAKING_BONUS);
        } else {
            return (0, 0);
        }
    }

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
        override
        returns (uint256 level, uint256 directReferrals, uint256 totalEarned)
    {
        Referrer memory ref = referrers[user];
        return (ref.level, ref.directReferrals, ref.totalEarned);
    }

    /**
     * @notice Get complete referrer data
     * @param user Address of the referrer
     * @return Referrer struct with all data
     */
    function getReferrerData(
        address user
    ) external view override returns (Referrer memory) {
        return referrers[user];
    }

    /**
     * @notice Get referral statistics
     * @param user Address of the referrer
     * @return ReferralStats struct with statistics
     */
    function getReferralStats(
        address user
    ) external view override returns (ReferralStats memory) {
        return referralStats[user];
    }

    /**
     * @notice Get pending rewards for a referrer
     * @param user Address of the referrer
     * @return Amount of pending rewards
     */
    function getPendingRewards(
        address user
    ) external view override returns (uint256) {
        return pendingRewards[user];
    }

    /**
     * @notice Check if an address is an authorized contract
     * @param contractAddress Address to check
     * @return True if authorized
     */
    function isAuthorizedContract(
        address contractAddress
    ) external view override returns (bool) {
        return authorizedContracts[contractAddress];
    }

    /**
     * @notice Get tier name
     * @param tier Tier level
     * @return Tier name as string
     */
    function getTierName(uint256 tier) external pure returns (string memory) {
        if (tier == 1) return "Starter";
        if (tier == 2) return "Bronze";
        if (tier == 3) return "Silver";
        if (tier == 4) return "Gold";
        return "Unknown";
    }

    /**
     * @notice Get next tier threshold
     * @param currentTier Current tier level
     * @return Next tier threshold (0 if max tier)
     */
    function getNextTierThreshold(
        uint256 currentTier
    ) external pure returns (uint256) {
        if (currentTier == 1) return TIER_2_THRESHOLD;
        if (currentTier == 2) return TIER_3_THRESHOLD;
        if (currentTier == 3) return TIER_4_THRESHOLD;
        return 0; // Max tier reached
    }

    /**
     * @notice Get all direct referrals of a user
     * @param user Address of the referrer
     * @return Array of direct referral addresses
     */
    function getDirectReferrals(
        address user
    ) external view returns (address[] memory) {
        return referralStats[user].directReferrals;
    }

    /**
     * @notice Get contract statistics
     * @return totalReferrers_ Total number of referrers
     * @return totalBonusesDistributed_ Total bonuses distributed
     * @return totalRewardsClaimed_ Total rewards claimed
     * @return contractBalance Contract VLR balance
     */
    function getContractStats()
        external
        view
        returns (
            uint256 totalReferrers_,
            uint256 totalBonusesDistributed_,
            uint256 totalRewardsClaimed_,
            uint256 contractBalance
        )
    {
        return (
            totalReferrers,
            totalBonusesDistributed,
            totalRewardsClaimed,
            vlrToken.balanceOf(address(this))
        );
    }
}
