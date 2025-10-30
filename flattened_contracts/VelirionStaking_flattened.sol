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


// File contracts/interfaces/IVelirionStaking.sol

// Original license: SPDX_License_Identifier: MIT

/**
 * @title IVelirionStaking
 * @notice Interface for the Velirion Staking System
 * @dev Defines the standard interface for 4-tier staking with variable APR
 * 
 * Staking Tiers:
 * - Flexible: 6% APR, no lock, 100 VLR min
 * - Medium: 12-15% APR, 90-180 days lock, 1,000 VLR min
 * - Long: 20-22% APR, 1 year lock, 5,000 VLR min
 * - Elite: 30-32% APR, 2 years lock, 250,000 VLR min
 */
interface IVelirionStaking {
    // ============================================================================
    // Enums
    // ============================================================================

    enum StakingTier {
        Flexible,  // 0: 6% APR, no lock
        Medium,    // 1: 12-15% APR, 90-180 days
        Long,      // 2: 20-22% APR, 1 year
        Elite      // 3: 30-32% APR, 2 years
    }

    // ============================================================================
    // Structs
    // ============================================================================

    struct Stake {
        uint256 amount;           // Amount staked
        uint256 startTime;        // When stake started
        uint256 lockDuration;     // Lock period in seconds
        uint256 lastClaimTime;    // Last reward claim
        StakingTier tier;         // Staking tier
        uint16 apr;               // APR in basis points (600 = 6%)
        bool renewed;             // Has been renewed
        bool active;              // Is stake active
    }

    struct UserStakingInfo {
        uint256 totalStaked;         // Total amount staked
        uint256 totalRewardsClaimed; // Total rewards claimed
        uint256 activeStakes;        // Number of active stakes
        uint256 stakingPower;        // For DAO voting (M5)
    }

    // ============================================================================
    // Events
    // ============================================================================

    event Staked(
        address indexed user,
        uint256 indexed stakeId,
        uint256 amount,
        StakingTier tier,
        uint256 lockDuration,
        uint16 apr
    );

    event Unstaked(
        address indexed user,
        uint256 indexed stakeId,
        uint256 amount,
        uint256 penalty,
        uint256 netAmount
    );

    event RewardsClaimed(
        address indexed user,
        uint256 indexed stakeId,
        uint256 rewards,
        uint256 referralBonus
    );

    event StakeRenewed(
        address indexed user,
        uint256 indexed stakeId,
        uint16 oldApr,
        uint16 newApr
    );

    event ReferralContractUpdated(address indexed newReferralContract);

    // ============================================================================
    // Core Functions
    // ============================================================================

    /**
     * @notice Stake VLR tokens for a specific tier
     * @param amount Amount of VLR to stake
     * @param tier Staking tier (Flexible, Medium, Long, Elite)
     * @param lockDuration Lock duration in seconds (must match tier requirements)
     */
    function stake(
        uint256 amount,
        StakingTier tier,
        uint256 lockDuration
    ) external;

    /**
     * @notice Unstake tokens (with penalty if before lock period ends)
     * @param stakeId ID of the stake to unstake
     */
    function unstake(uint256 stakeId) external;

    /**
     * @notice Claim accumulated staking rewards
     * @param stakeId ID of the stake to claim rewards from
     */
    function claimRewards(uint256 stakeId) external;

    /**
     * @notice Renew a stake to get +2% APR bonus
     * @param stakeId ID of the stake to renew
     */
    function renewStake(uint256 stakeId) external;

    // ============================================================================
    // View Functions
    // ============================================================================

    /**
     * @notice Calculate pending rewards for a stake
     * @param user Address of the user
     * @param stakeId ID of the stake
     * @return Pending rewards amount
     */
    function calculateRewards(
        address user,
        uint256 stakeId
    ) external view returns (uint256);

    /**
     * @notice Get all stake IDs for a user
     * @param user Address of the user
     * @return Array of stake IDs
     */
    function getUserStakes(address user) external view returns (uint256[] memory);

    /**
     * @notice Get detailed information about a stake
     * @param user Address of the user
     * @param stakeId ID of the stake
     * @return amount Amount staked
     * @return startTime When stake started
     * @return lockDuration Lock period in seconds
     * @return tier Staking tier
     * @return apr APR in basis points
     * @return renewed Has been renewed
     * @return active Is stake active
     */
    function getStakeInfo(
        address user,
        uint256 stakeId
    )
        external
        view
        returns (
            uint256 amount,
            uint256 startTime,
            uint256 lockDuration,
            StakingTier tier,
            uint16 apr,
            bool renewed,
            bool active
        );

    /**
     * @notice Get user's total staking information
     * @param user Address of the user
     * @return info UserStakingInfo struct
     */
    function getUserStakingInfo(
        address user
    ) external view returns (UserStakingInfo memory info);

    /**
     * @notice Get minimum stake amount for a tier
     * @param tier Staking tier
     * @return Minimum stake amount
     */
    function getMinimumStake(StakingTier tier) external pure returns (uint256);

    /**
     * @notice Get minimum lock duration for a tier
     * @param tier Staking tier
     * @return Minimum lock duration in seconds
     */
    function getMinimumLock(StakingTier tier) external pure returns (uint256);

    /**
     * @notice Get maximum lock duration for a tier
     * @param tier Staking tier
     * @return Maximum lock duration in seconds
     */
    function getMaximumLock(StakingTier tier) external pure returns (uint256);

    /**
     * @notice Calculate early withdrawal penalty
     * @param user Address of the user
     * @param stakeId ID of the stake
     * @return Penalty amount
     */
    function calculatePenalty(
        address user,
        uint256 stakeId
    ) external view returns (uint256);

    /**
     * @notice Get voting power for DAO (2x for Long/Elite tiers)
     * @param user Address of the user
     * @return Total voting power
     */
    function getVotingPower(address user) external view returns (uint256);

    /**
     * @notice Check if a stake can be unstaked without penalty
     * @param user Address of the user
     * @param stakeId ID of the stake
     * @return True if can unstake without penalty
     */
    function canUnstakeWithoutPenalty(
        address user,
        uint256 stakeId
    ) external view returns (bool);

    /**
     * @notice Get total staked amount across all users
     * @return Total staked amount
     */
    function getTotalStaked() external view returns (uint256);

    /**
     * @notice Get contract statistics
     * @return totalStaked Total amount staked
     * @return totalStakers Number of unique stakers
     * @return totalRewardsDistributed Total rewards distributed
     * @return contractBalance Contract VLR balance
     */
    function getContractStats()
        external
        view
        returns (
            uint256 totalStaked,
            uint256 totalStakers,
            uint256 totalRewardsDistributed,
            uint256 contractBalance
        );
}


// File contracts/core/VelirionStaking.sol

// Original license: SPDX_License_Identifier: MIT







/**
 * @title VelirionStaking
 * @notice 4-tier staking system with variable APR and referral integration
 * 
 * Staking Tiers:
 * - Flexible: 6% APR, no lock, 100 VLR min, no penalty
 * - Medium: 12-15% APR, 90-180 days, 1K VLR min, 5% penalty
 * - Long: 20-22% APR, 1 year, 5K VLR min, 7% penalty, 2x DAO vote
 * - Elite: 30-32% APR, 2 years, 250K VLR min, 10% penalty, 2x DAO vote
 * 
 * Features:
 * - Manual reward claiming (gas efficient)
 * - Renewal bonus (+2% APR)
 * - Referral bonus integration (2%-5% to referrer)
 * - Early withdrawal penalties
 * - DAO voting weight (2x for Long/Elite)
 */
contract VelirionStaking is
    IVelirionStaking,
    Ownable,
    Pausable,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;

    // ============================================================================
    // Constants - Minimum Stake Amounts
    // ============================================================================

    uint256 public constant MIN_FLEXIBLE_STAKE = 100 * 10**18;      // 100 VLR
    uint256 public constant MIN_MEDIUM_STAKE = 1000 * 10**18;       // 1,000 VLR
    uint256 public constant MIN_LONG_STAKE = 5000 * 10**18;         // 5,000 VLR
    uint256 public constant MIN_ELITE_STAKE = 250000 * 10**18;      // 250,000 VLR

    // ============================================================================
    // Constants - Lock Durations
    // ============================================================================

    uint256 public constant FLEXIBLE_LOCK = 0;                      // No lock
    uint256 public constant MEDIUM_MIN_LOCK = 90 days;              // 90 days
    uint256 public constant MEDIUM_MAX_LOCK = 180 days;             // 180 days
    uint256 public constant LONG_LOCK = 365 days;                   // 1 year
    uint256 public constant ELITE_LOCK = 730 days;                  // 2 years

    // ============================================================================
    // Constants - APR (in basis points, 10000 = 100%)
    // ============================================================================

    uint16 public constant FLEXIBLE_APR = 600;                      // 6%
    uint16 public constant MEDIUM_MIN_APR = 1200;                   // 12%
    uint16 public constant MEDIUM_MAX_APR = 1500;                   // 15%
    uint16 public constant LONG_APR = 2000;                         // 20%
    uint16 public constant LONG_RENEWED_APR = 2200;                 // 22%
    uint16 public constant ELITE_APR = 3000;                        // 30%
    uint16 public constant ELITE_RENEWED_APR = 3200;                // 32%

    // ============================================================================
    // Constants - Penalties (in basis points)
    // ============================================================================

    uint16 public constant MEDIUM_PENALTY = 500;                    // 5%
    uint16 public constant LONG_PENALTY = 700;                      // 7%
    uint16 public constant ELITE_PENALTY = 1000;                    // 10%

    // ============================================================================
    // Constants - Other
    // ============================================================================

    uint16 public constant RENEWAL_BONUS = 200;                     // +2%
    uint256 public constant BASIS_POINTS = 10000;                   // 100%
    uint256 public constant SECONDS_PER_YEAR = 365 days;

    // ============================================================================
    // State Variables
    // ============================================================================

    IERC20 public immutable vlrToken;
    IVelirionReferral public referralContract;

    // User stakes: user => stakeId => Stake
    mapping(address => mapping(uint256 => Stake)) public stakes;
    
    // User stake IDs: user => array of stake IDs
    mapping(address => uint256[]) private userStakeIds;
    
    // User staking info: user => UserStakingInfo
    mapping(address => UserStakingInfo) public userStakingInfo;
    
    // Next stake ID for each user
    mapping(address => uint256) public nextStakeId;

    // Global statistics
    uint256 public totalStaked;
    uint256 public totalStakers;
    uint256 public totalRewardsDistributed;

    // Track unique stakers
    mapping(address => bool) private hasStaked;

    // ============================================================================
    // Errors
    // ============================================================================

    error InvalidAmount();
    error InvalidTier();
    error InvalidLockDuration();
    error BelowMinimumStake();
    error StakeNotFound();
    error StakeNotActive();
    error InsufficientContractBalance();
    error NoRewardsToClaim();
    error CannotRenewFlexible();
    error AlreadyRenewed();
    error CannotRenewBeforeLockEnd();

    // ============================================================================
    // Constructor
    // ============================================================================

    constructor(address _vlrToken) Ownable(msg.sender) {
        require(_vlrToken != address(0), "Invalid VLR token");
        vlrToken = IERC20(_vlrToken);
    }

    // ============================================================================
    // Core Functions
    // ============================================================================

    /**
     * @notice Stake VLR tokens for a specific tier
     * @param amount Amount of VLR to stake
     * @param tier Staking tier (Flexible, Medium, Long, Elite)
     * @param lockDuration Lock duration in seconds (must match tier requirements)
     */
    function stake(
        uint256 amount,
        StakingTier tier,
        uint256 lockDuration
    ) external override nonReentrant whenNotPaused {
        if (amount == 0) revert InvalidAmount();
        if (uint8(tier) > 3) revert InvalidTier();

        // Validate minimum stake amount
        uint256 minStake = getMinimumStake(tier);
        if (amount < minStake) revert BelowMinimumStake();

        // Validate lock duration
        uint256 minLock = getMinimumLock(tier);
        uint256 maxLock = getMaximumLock(tier);
        if (lockDuration < minLock || lockDuration > maxLock) {
            revert InvalidLockDuration();
        }

        // Calculate APR for this stake
        uint16 apr = _calculateAPR(tier, lockDuration, false);

        // Get next stake ID for user
        uint256 stakeId = nextStakeId[msg.sender];
        nextStakeId[msg.sender]++;

        // Create stake
        stakes[msg.sender][stakeId] = Stake({
            amount: amount,
            startTime: block.timestamp,
            lockDuration: lockDuration,
            lastClaimTime: block.timestamp,
            tier: tier,
            apr: apr,
            renewed: false,
            active: true
        });

        // Update user stake IDs
        userStakeIds[msg.sender].push(stakeId);

        // Update user staking info
        UserStakingInfo storage info = userStakingInfo[msg.sender];
        info.totalStaked += amount;
        info.activeStakes++;
        info.stakingPower += _calculateStakingPower(amount, tier);

        // Update global statistics
        totalStaked += amount;
        if (!hasStaked[msg.sender]) {
            hasStaked[msg.sender] = true;
            totalStakers++;
        }

        // Transfer tokens from user
        vlrToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, stakeId, amount, tier, lockDuration, apr);
    }

    /**
     * @notice Unstake tokens (with penalty if before lock period ends)
     * @param stakeId ID of the stake to unstake
     */
    function unstake(uint256 stakeId) external override nonReentrant whenNotPaused {
        Stake storage userStake = stakes[msg.sender][stakeId];
        
        if (userStake.amount == 0) revert StakeNotFound();
        if (!userStake.active) revert StakeNotActive();

        uint256 amount = userStake.amount;
        uint256 penalty = _calculatePenaltyInternal(userStake);
        uint256 netAmount = amount - penalty;

        // Claim any pending rewards first
        uint256 rewards = _calculateRewardsInternal(userStake);
        if (rewards > 0) {
            _claimRewardsInternal(msg.sender, stakeId, userStake, rewards);
        }

        // Mark stake as inactive
        userStake.active = false;

        // Update user staking info
        UserStakingInfo storage info = userStakingInfo[msg.sender];
        info.totalStaked -= amount;
        info.activeStakes--;
        info.stakingPower -= _calculateStakingPower(amount, userStake.tier);

        // Update global statistics
        totalStaked -= amount;

        // Transfer tokens back to user (minus penalty)
        vlrToken.safeTransfer(msg.sender, netAmount);

        // Penalty stays in contract for rewards pool
        
        emit Unstaked(msg.sender, stakeId, amount, penalty, netAmount);
    }

    /**
     * @notice Claim accumulated staking rewards
     * @param stakeId ID of the stake to claim rewards from
     */
    function claimRewards(uint256 stakeId) external override nonReentrant whenNotPaused {
        Stake storage userStake = stakes[msg.sender][stakeId];
        
        if (userStake.amount == 0) revert StakeNotFound();
        if (!userStake.active) revert StakeNotActive();

        uint256 rewards = _calculateRewardsInternal(userStake);
        if (rewards == 0) revert NoRewardsToClaim();

        _claimRewardsInternal(msg.sender, stakeId, userStake, rewards);
    }

    /**
     * @notice Renew a stake to get +2% APR bonus
     * @param stakeId ID of the stake to renew
     */
    function renewStake(uint256 stakeId) external override nonReentrant whenNotPaused {
        Stake storage userStake = stakes[msg.sender][stakeId];
        
        if (userStake.amount == 0) revert StakeNotFound();
        if (!userStake.active) revert StakeNotActive();
        if (userStake.tier == StakingTier.Flexible) revert CannotRenewFlexible();
        if (userStake.renewed) revert AlreadyRenewed();

        // Can only renew after lock period ends
        uint256 unlockTime = userStake.startTime + userStake.lockDuration;
        if (block.timestamp < unlockTime) revert CannotRenewBeforeLockEnd();

        uint16 oldApr = userStake.apr;
        uint16 newApr = oldApr + RENEWAL_BONUS;

        userStake.apr = newApr;
        userStake.renewed = true;
        userStake.startTime = block.timestamp; // Reset start time
        userStake.lastClaimTime = block.timestamp;

        emit StakeRenewed(msg.sender, stakeId, oldApr, newApr);
    }

    // ============================================================================
    // Internal Functions
    // ============================================================================

    /**
     * @notice Internal function to claim rewards
     */
    function _claimRewardsInternal(
        address user,
        uint256 stakeId,
        Stake storage userStake,
        uint256 rewards
    ) internal {
        uint256 contractBalance = vlrToken.balanceOf(address(this));
        uint256 availableBalance = contractBalance - totalStaked;
        
        if (availableBalance < rewards) revert InsufficientContractBalance();

        // Update last claim time
        userStake.lastClaimTime = block.timestamp;

        // Update statistics
        userStakingInfo[user].totalRewardsClaimed += rewards;
        totalRewardsDistributed += rewards;

        // Distribute referral bonus (2%-5% based on referrer tier)
        uint256 referralBonus = 0;
        if (address(referralContract) != address(0)) {
            try referralContract.distributeStakingBonus(user, rewards) {
                // Get referrer info to calculate actual bonus
                try referralContract.getReferrerInfo(
                    referralContract.getReferrer(user)
                ) returns (uint256 level, uint256, uint256) {
                    (, uint256 stakingBonusBps) = referralContract.getTierBonuses(level);
                    referralBonus = (rewards * stakingBonusBps) / BASIS_POINTS;
                } catch {}
            } catch {
                // Failed silently, don't revert user's claim
            }
        }

        // Transfer rewards to user
        vlrToken.safeTransfer(user, rewards);

        emit RewardsClaimed(user, stakeId, rewards, referralBonus);
    }

    /**
     * @notice Calculate APR based on tier, lock duration, and renewal status
     */
    function _calculateAPR(
        StakingTier tier,
        uint256 lockDuration,
        bool renewed
    ) internal pure returns (uint16) {
        if (tier == StakingTier.Flexible) {
            return FLEXIBLE_APR; // 6%
        }
        
        if (tier == StakingTier.Medium) {
            // Linear interpolation between 12% and 15%
            if (lockDuration <= MEDIUM_MIN_LOCK) return MEDIUM_MIN_APR;
            if (lockDuration >= MEDIUM_MAX_LOCK) return MEDIUM_MAX_APR;
            
            uint256 range = MEDIUM_MAX_LOCK - MEDIUM_MIN_LOCK;
            uint256 position = lockDuration - MEDIUM_MIN_LOCK;
            uint256 aprRange = MEDIUM_MAX_APR - MEDIUM_MIN_APR;
            
            return uint16(MEDIUM_MIN_APR + (aprRange * position) / range);
        }
        
        if (tier == StakingTier.Long) {
            return renewed ? LONG_RENEWED_APR : LONG_APR; // 20% or 22%
        }
        
        if (tier == StakingTier.Elite) {
            return renewed ? ELITE_RENEWED_APR : ELITE_APR; // 30% or 32%
        }
        
        revert InvalidTier();
    }

    /**
     * @notice Calculate rewards for a stake
     */
    function _calculateRewardsInternal(
        Stake memory userStake
    ) internal view returns (uint256) {
        if (!userStake.active) return 0;
        
        uint256 stakingDuration = block.timestamp - userStake.lastClaimTime;
        
        // rewards = (amount * APR * time) / (BASIS_POINTS * SECONDS_PER_YEAR)
        uint256 rewards = (userStake.amount * userStake.apr * stakingDuration) 
                         / (BASIS_POINTS * SECONDS_PER_YEAR);
        
        return rewards;
    }

    /**
     * @notice Calculate early withdrawal penalty
     */
    function _calculatePenaltyInternal(
        Stake memory userStake
    ) internal view returns (uint256) {
        // Flexible tier has no penalty
        if (userStake.tier == StakingTier.Flexible) {
            return 0;
        }
        
        uint256 unlockTime = userStake.startTime + userStake.lockDuration;
        
        // No penalty if lock period completed
        if (block.timestamp >= unlockTime) {
            return 0;
        }
        
        // Calculate penalty based on tier
        uint16 penaltyRate;
        if (userStake.tier == StakingTier.Medium) {
            penaltyRate = MEDIUM_PENALTY; // 5%
        } else if (userStake.tier == StakingTier.Long) {
            penaltyRate = LONG_PENALTY; // 7%
        } else if (userStake.tier == StakingTier.Elite) {
            penaltyRate = ELITE_PENALTY; // 10%
        }
        
        return (userStake.amount * penaltyRate) / BASIS_POINTS;
    }

    /**
     * @notice Calculate staking power for DAO voting (2x for Long/Elite)
     */
    function _calculateStakingPower(
        uint256 amount,
        StakingTier tier
    ) internal pure returns (uint256) {
        // Long and Elite tiers get 2x voting power
        if (tier == StakingTier.Long || tier == StakingTier.Elite) {
            return amount * 2;
        }
        return amount;
    }

    // ============================================================================
    // View Functions
    // ============================================================================

    /**
     * @notice Calculate pending rewards for a stake
     */
    function calculateRewards(
        address user,
        uint256 stakeId
    ) external view override returns (uint256) {
        Stake memory userStake = stakes[user][stakeId];
        return _calculateRewardsInternal(userStake);
    }

    /**
     * @notice Get all stake IDs for a user
     */
    function getUserStakes(
        address user
    ) external view override returns (uint256[] memory) {
        return userStakeIds[user];
    }

    /**
     * @notice Get detailed information about a stake
     */
    function getStakeInfo(
        address user,
        uint256 stakeId
    )
        external
        view
        override
        returns (
            uint256 amount,
            uint256 startTime,
            uint256 lockDuration,
            StakingTier tier,
            uint16 apr,
            bool renewed,
            bool active
        )
    {
        Stake memory userStake = stakes[user][stakeId];
        return (
            userStake.amount,
            userStake.startTime,
            userStake.lockDuration,
            userStake.tier,
            userStake.apr,
            userStake.renewed,
            userStake.active
        );
    }

    /**
     * @notice Get user's total staking information
     */
    function getUserStakingInfo(
        address user
    ) external view override returns (UserStakingInfo memory) {
        return userStakingInfo[user];
    }

    /**
     * @notice Get minimum stake amount for a tier
     */
    function getMinimumStake(
        StakingTier tier
    ) public pure override returns (uint256) {
        if (tier == StakingTier.Flexible) return MIN_FLEXIBLE_STAKE;
        if (tier == StakingTier.Medium) return MIN_MEDIUM_STAKE;
        if (tier == StakingTier.Long) return MIN_LONG_STAKE;
        if (tier == StakingTier.Elite) return MIN_ELITE_STAKE;
        revert InvalidTier();
    }

    /**
     * @notice Get minimum lock duration for a tier
     */
    function getMinimumLock(
        StakingTier tier
    ) public pure override returns (uint256) {
        if (tier == StakingTier.Flexible) return FLEXIBLE_LOCK;
        if (tier == StakingTier.Medium) return MEDIUM_MIN_LOCK;
        if (tier == StakingTier.Long) return LONG_LOCK;
        if (tier == StakingTier.Elite) return ELITE_LOCK;
        revert InvalidTier();
    }

    /**
     * @notice Get maximum lock duration for a tier
     */
    function getMaximumLock(
        StakingTier tier
    ) public pure override returns (uint256) {
        if (tier == StakingTier.Flexible) return FLEXIBLE_LOCK;
        if (tier == StakingTier.Medium) return MEDIUM_MAX_LOCK;
        if (tier == StakingTier.Long) return LONG_LOCK;
        if (tier == StakingTier.Elite) return ELITE_LOCK;
        revert InvalidTier();
    }

    /**
     * @notice Calculate early withdrawal penalty
     */
    function calculatePenalty(
        address user,
        uint256 stakeId
    ) external view override returns (uint256) {
        Stake memory userStake = stakes[user][stakeId];
        return _calculatePenaltyInternal(userStake);
    }

    /**
     * @notice Get voting power for DAO (2x for Long/Elite tiers)
     */
    function getVotingPower(
        address user
    ) external view override returns (uint256) {
        return userStakingInfo[user].stakingPower;
    }

    /**
     * @notice Check if a stake can be unstaked without penalty
     */
    function canUnstakeWithoutPenalty(
        address user,
        uint256 stakeId
    ) external view override returns (bool) {
        Stake memory userStake = stakes[user][stakeId];
        
        if (!userStake.active) return false;
        if (userStake.tier == StakingTier.Flexible) return true;
        
        uint256 unlockTime = userStake.startTime + userStake.lockDuration;
        return block.timestamp >= unlockTime;
    }

    /**
     * @notice Get total staked amount across all users
     */
    function getTotalStaked() external view override returns (uint256) {
        return totalStaked;
    }

    /**
     * @notice Get contract statistics
     */
    function getContractStats()
        external
        view
        override
        returns (
            uint256 _totalStaked,
            uint256 _totalStakers,
            uint256 _totalRewardsDistributed,
            uint256 contractBalance
        )
    {
        return (
            totalStaked,
            totalStakers,
            totalRewardsDistributed,
            vlrToken.balanceOf(address(this))
        );
    }

    // ============================================================================
    // Owner Functions
    // ============================================================================

    /**
     * @notice Set referral contract address
     * @param _referralContract Address of the referral contract
     */
    function setReferralContract(
        address _referralContract
    ) external onlyOwner {
        require(_referralContract != address(0), "Invalid address");
        referralContract = IVelirionReferral(_referralContract);
        emit ReferralContractUpdated(_referralContract);
    }

    /**
     * @notice Emergency withdrawal (only unstaked tokens)
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        require(amount > 0, "Invalid amount");
        uint256 contractBalance = vlrToken.balanceOf(address(this));
        uint256 availableBalance = contractBalance - totalStaked;
        require(availableBalance >= amount, "Insufficient available balance");
        
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
}
