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


// File @openzeppelin/contracts/interfaces/draft-IERC6093.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/draft-IERC6093.sol)

/**
 * @dev Standard ERC-20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`ΓÇÖs `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC-721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in ERC-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`ΓÇÖs approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC-1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`ΓÇÖs approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}


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


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/extensions/IERC20Metadata.sol)


/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// File @openzeppelin/contracts/token/ERC20/ERC20.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/ERC20.sol)





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC-20
 * applications.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * Both values are immutable: they can only be set once during construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /// @inheritdoc IERC20
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /// @inheritdoc IERC20
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /// @inheritdoc IERC20
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Skips emitting an {Approval} event indicating an allowance update. This is not
     * required by the ERC. See {xref-ERC20-_approve-address-address-uint256-bool-}[_approve].
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner`'s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     *
     * ```solidity
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner`'s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance < type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}


// File @openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol@v5.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC20Burnable.sol)



/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys a `value` amount of tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 value) public virtual {
        _burn(_msgSender(), value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, deducting from
     * the caller's allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `value`.
     */
    function burnFrom(address account, uint256 value) public virtual {
        _spendAllowance(account, _msgSender(), value);
        _burn(account, value);
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


// File contracts/interfaces/IVelirionDAO.sol

// Original license: SPDX_License_Identifier: MIT

/**
 * @title IVelirionDAO
 * @notice Interface for Velirion DAO governance with burn-to-vote mechanism
 * 
 * Key Features:
 * - Burn VLR tokens to gain voting power
 * - Staking multiplier: 1x (no stake), 2x (Long/Elite tier)
 * - Proposal threshold: 10,000 VLR burned
 * - Voting period: 7 days
 * - Timelock: 2 days execution delay
 * - Quorum: 100,000 VLR total votes required
 */
interface IVelirionDAO {
    // ============================================================================
    // Enums
    // ============================================================================

    enum ProposalState {
        Pending,    // Created but voting not started
        Active,     // Voting in progress
        Defeated,   // Did not pass
        Succeeded,  // Passed, awaiting execution
        Queued,     // In timelock
        Executed,   // Executed successfully
        Canceled    // Canceled by proposer
    }

    // ============================================================================
    // Structs
    // ============================================================================

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        address[] targets;          // Contracts to call
        uint256[] values;           // ETH values to send
        bytes[] calldatas;          // Function calls encoded
        uint256 startBlock;
        uint256 endBlock;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        bool executed;
        bool canceled;
    }

    struct Receipt {
        bool hasVoted;
        uint8 support;              // 0=against, 1=for, 2=abstain
        uint256 votes;              // Voting power used
        uint256 burnedAmount;       // VLR burned for this vote
    }

    // ============================================================================
    // Events
    // ============================================================================

    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        address[] targets,
        uint256[] values,
        bytes[] calldatas,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );

    event VoteCast(
        address indexed voter,
        uint256 indexed proposalId,
        uint8 support,
        uint256 votes,
        uint256 burnedAmount,
        string reason
    );

    event ProposalCanceled(uint256 indexed proposalId);
    event ProposalQueued(uint256 indexed proposalId, uint256 eta);
    event ProposalExecuted(uint256 indexed proposalId);

    // ============================================================================
    // Core Functions
    // ============================================================================

    /**
     * @notice Create a new governance proposal
     * @param targets Contract addresses to call
     * @param values ETH values to send with calls
     * @param calldatas Encoded function calls
     * @param description Proposal description
     * @return proposalId The ID of the created proposal
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256 proposalId);

    /**
     * @notice Cast a vote by burning VLR tokens
     * @param proposalId The proposal to vote on
     * @param support Vote type: 0=against, 1=for, 2=abstain
     * @param burnAmount Amount of VLR to burn for voting power
     * @param reason Optional reason for vote
     */
    function castVote(
        uint256 proposalId,
        uint8 support,
        uint256 burnAmount,
        string memory reason
    ) external;

    /**
     * @notice Queue a successful proposal for execution
     * @param proposalId The proposal to queue
     */
    function queue(uint256 proposalId) external;

    /**
     * @notice Execute a queued proposal after timelock
     * @param proposalId The proposal to execute
     */
    function execute(uint256 proposalId) external payable;

    /**
     * @notice Cancel a proposal (only by proposer)
     * @param proposalId The proposal to cancel
     */
    function cancel(uint256 proposalId) external;

    // ============================================================================
    // View Functions
    // ============================================================================

    /**
     * @notice Get the current state of a proposal
     * @param proposalId The proposal ID
     * @return Current state of the proposal
     */
    function state(uint256 proposalId) external view returns (ProposalState);

    /**
     * @notice Get proposal details
     * @param proposalId The proposal ID
     * @return Proposal struct
     */
    function getProposal(uint256 proposalId) external view returns (Proposal memory);

    /**
     * @notice Get voting receipt for an address
     * @param proposalId The proposal ID
     * @param voter The voter address
     * @return Receipt struct
     */
    function getReceipt(uint256 proposalId, address voter) external view returns (Receipt memory);

    /**
     * @notice Calculate voting power for a user
     * @param user The user address
     * @param burnAmount Amount of VLR to burn
     * @return Voting power (burn amount ├ù staking multiplier)
     */
    function getVotingPower(address user, uint256 burnAmount) external view returns (uint256);

    /**
     * @notice Get total number of proposals
     * @return Total proposal count
     */
    function proposalCount() external view returns (uint256);

    /**
     * @notice Check if quorum is reached for a proposal
     * @param proposalId The proposal ID
     * @return True if quorum reached
     */
    function quorumReached(uint256 proposalId) external view returns (bool);

    /**
     * @notice Check if a proposal has succeeded
     * @param proposalId The proposal ID
     * @return True if proposal passed
     */
    function proposalSucceeded(uint256 proposalId) external view returns (bool);
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


// File contracts/governance/VelirionDAO.sol

// Original license: SPDX_License_Identifier: MIT








/**
 * @title VelirionDAO
 * @notice Decentralized governance with burn-to-vote mechanism
 * 
 * Key Features:
 * - Burn VLR tokens to gain voting power
 * - Staking multiplier: 1x (no stake), 2x (Long/Elite tier)
 * - Proposal threshold: 10,000 VLR burned to create proposal
 * - Voting period: 7 days
 * - Timelock: 2 days execution delay
 * - Quorum: 100,000 VLR total votes required
 * 
 * Governance Flow:
 * 1. User burns 10K+ VLR to create proposal
 * 2. 1-day delay before voting starts
 * 3. 7-day voting period (users burn VLR to vote)
 * 4. If passed, proposal queued in timelock
 * 5. After 2-day delay, proposal can be executed
 */
contract VelirionDAO is IVelirionDAO, Ownable, Pausable, ReentrancyGuard {
    // ============================================================================
    // Constants - Governance Parameters
    // ============================================================================

    uint256 public constant PROPOSAL_THRESHOLD = 10000 * 10**18;   // 10K VLR to propose
    uint256 public constant VOTING_PERIOD = 7 days;
    uint256 public constant VOTING_DELAY = 1 days;
    uint256 public constant QUORUM_VOTES = 100000 * 10**18;        // 100K VLR quorum

    // Voting multipliers based on staking tier
    uint256 public constant NO_STAKE_MULTIPLIER = 1;               // 1x
    uint256 public constant LONG_STAKE_MULTIPLIER = 2;             // 2x
    uint256 public constant ELITE_STAKE_MULTIPLIER = 2;            // 2x

    // ============================================================================
    // State Variables
    // ============================================================================

    ERC20Burnable public immutable vlrToken;
    IVelirionStaking public stakingContract;
    VelirionTimelock public timelock;

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => Receipt)) public receipts;
    mapping(uint256 => uint256) public proposalEta;  // Execution time after timelock

    // ============================================================================
    // Errors
    // ============================================================================

    error BelowProposalThreshold();
    error InvalidProposalData();
    error ProposalNotActive();
    error AlreadyVoted();
    error InvalidVoteType();
    error ProposalNotSucceeded();
    error ProposalNotQueued();
    error OnlyProposer();
    error ProposalAlreadyExecuted();

    // ============================================================================
    // Constructor
    // ============================================================================

    constructor(
        address _vlrToken,
        address _timelock,
        address _admin
    ) Ownable(_admin) {
        vlrToken = ERC20Burnable(_vlrToken);
        timelock = VelirionTimelock(payable(_timelock));
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
        stakingContract = IVelirionStaking(_stakingContract);
    }

    /**
     * @notice Pause the DAO (emergency only)
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause the DAO
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    // ============================================================================
    // Core Governance Functions
    // ============================================================================

    /**
     * @notice Create a new governance proposal
     * @param targets Contract addresses to call
     * @param values ETH values to send with calls
     * @param calldatas Encoded function calls
     * @param description Proposal description
     * @return proposalId The ID of the created proposal
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external override whenNotPaused nonReentrant returns (uint256 proposalId) {
        // Validate proposal data
        if (
            targets.length == 0 ||
            targets.length != values.length ||
            targets.length != calldatas.length
        ) revert InvalidProposalData();

        // Burn tokens to create proposal
        vlrToken.burnFrom(msg.sender, PROPOSAL_THRESHOLD);

        // Create proposal
        proposalId = ++proposalCount;
        Proposal storage newProposal = proposals[proposalId];
        
        newProposal.id = proposalId;
        newProposal.proposer = msg.sender;
        newProposal.description = description;
        newProposal.targets = targets;
        newProposal.values = values;
        newProposal.calldatas = calldatas;
        newProposal.startBlock = block.number + (VOTING_DELAY / 12); // ~12s per block
        newProposal.endBlock = newProposal.startBlock + (VOTING_PERIOD / 12);
        newProposal.executed = false;
        newProposal.canceled = false;

        emit ProposalCreated(
            proposalId,
            msg.sender,
            targets,
            values,
            calldatas,
            newProposal.startBlock,
            newProposal.endBlock,
            description
        );

        return proposalId;
    }

    /**
     * @notice Cast a vote by burning VLR tokens
     * @param proposalId The proposal to vote on
     * @param support Vote type: 0=against, 1=for, 2=abstain
     * @param burnAmount Amount of VLR to burn for voting power
     * @param reason Optional reason for vote
     */
    function castVote(
        uint256 proposalId,
        uint8 support,
        uint256 burnAmount,
        string memory reason
    ) external override whenNotPaused nonReentrant {
        if (state(proposalId) != ProposalState.Active) revert ProposalNotActive();
        if (support > 2) revert InvalidVoteType();
        
        Receipt storage receipt = receipts[proposalId][msg.sender];
        if (receipt.hasVoted) revert AlreadyVoted();

        // Burn tokens and calculate voting power
        vlrToken.burnFrom(msg.sender, burnAmount);
        uint256 votes = getVotingPower(msg.sender, burnAmount);

        // Record vote
        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;
        receipt.burnedAmount = burnAmount;

        // Update proposal vote counts
        Proposal storage proposal = proposals[proposalId];
        if (support == 0) {
            proposal.againstVotes += votes;
        } else if (support == 1) {
            proposal.forVotes += votes;
        } else {
            proposal.abstainVotes += votes;
        }

        emit VoteCast(msg.sender, proposalId, support, votes, burnAmount, reason);
    }

    /**
     * @notice Queue a successful proposal for execution
     * @param proposalId The proposal to queue
     */
    function queue(uint256 proposalId) external override nonReentrant {
        if (state(proposalId) != ProposalState.Succeeded) revert ProposalNotSucceeded();

        Proposal storage proposal = proposals[proposalId];
        uint256 eta = block.timestamp + timelock.delay();
        proposalEta[proposalId] = eta;

        // Queue all transactions in the timelock
        for (uint256 i = 0; i < proposal.targets.length; i++) {
            timelock.queueTransaction(
                proposal.targets[i],
                proposal.values[i],
                proposal.calldatas[i],
                eta
            );
        }

        emit ProposalQueued(proposalId, eta);
    }

    /**
     * @notice Execute a queued proposal after timelock
     * @param proposalId The proposal to execute
     */
    function execute(uint256 proposalId) external payable override nonReentrant {
        if (state(proposalId) != ProposalState.Queued) revert ProposalNotQueued();

        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;

        uint256 eta = proposalEta[proposalId];

        // Execute all transactions through timelock
        for (uint256 i = 0; i < proposal.targets.length; i++) {
            timelock.executeTransaction{value: proposal.values[i]}(
                proposal.targets[i],
                proposal.values[i],
                proposal.calldatas[i],
                eta
            );
        }

        emit ProposalExecuted(proposalId);
    }

    /**
     * @notice Cancel a proposal (only by proposer)
     * @param proposalId The proposal to cancel
     */
    function cancel(uint256 proposalId) external override {
        Proposal storage proposal = proposals[proposalId];
        
        if (msg.sender != proposal.proposer) revert OnlyProposer();
        if (proposal.executed) revert ProposalAlreadyExecuted();

        proposal.canceled = true;

        emit ProposalCanceled(proposalId);
    }

    // ============================================================================
    // View Functions
    // ============================================================================

    /**
     * @notice Get the current state of a proposal
     * @param proposalId The proposal ID
     * @return Current state of the proposal
     */
    function state(uint256 proposalId) public view override returns (ProposalState) {
        Proposal storage proposal = proposals[proposalId];
        
        if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else if (block.number < proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
        } else if (proposalEta[proposalId] != 0) {
            return ProposalState.Queued;
        } else if (proposalSucceeded(proposalId)) {
            return ProposalState.Succeeded;
        } else {
            return ProposalState.Defeated;
        }
    }

    /**
     * @notice Get proposal details
     * @param proposalId The proposal ID
     * @return Proposal struct
     */
    function getProposal(uint256 proposalId) external view override returns (Proposal memory) {
        return proposals[proposalId];
    }

    /**
     * @notice Get voting receipt for an address
     * @param proposalId The proposal ID
     * @param voter The voter address
     * @return Receipt struct
     */
    function getReceipt(uint256 proposalId, address voter) 
        external 
        view 
        override 
        returns (Receipt memory) 
    {
        return receipts[proposalId][voter];
    }

    /**
     * @notice Calculate voting power for a user
     * @param user The user address
     * @param burnAmount Amount of VLR to burn
     * @return Voting power (burn amount ├ù staking multiplier)
     */
    function getVotingPower(address user, uint256 burnAmount) 
        public 
        view 
        override 
        returns (uint256) 
    {
        if (address(stakingContract) == address(0)) {
            return burnAmount * NO_STAKE_MULTIPLIER;
        }

        // Get user's stake IDs
        uint256[] memory stakeIds = stakingContract.getUserStakes(user);
        
        // Check if user has Long or Elite tier stake
        bool hasLongOrElite = false;
        for (uint256 i = 0; i < stakeIds.length; i++) {
            (
                ,  // amount
                ,  // startTime
                ,  // lockDuration
                IVelirionStaking.StakingTier tier,
                ,  // apr
                ,  // renewed
                bool active
            ) = stakingContract.getStakeInfo(user, stakeIds[i]);
            
            if (
                active &&
                (tier == IVelirionStaking.StakingTier.Long ||
                 tier == IVelirionStaking.StakingTier.Elite)
            ) {
                hasLongOrElite = true;
                break;
            }
        }

        // Apply multiplier
        if (hasLongOrElite) {
            return burnAmount * LONG_STAKE_MULTIPLIER;  // 2x for Long/Elite
        } else {
            return burnAmount * NO_STAKE_MULTIPLIER;    // 1x for others
        }
    }

    /**
     * @notice Check if quorum is reached for a proposal
     * @param proposalId The proposal ID
     * @return True if quorum reached
     */
    function quorumReached(uint256 proposalId) public view override returns (bool) {
        Proposal storage proposal = proposals[proposalId];
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes + proposal.abstainVotes;
        return totalVotes >= QUORUM_VOTES;
    }

    /**
     * @notice Check if a proposal has succeeded
     * @param proposalId The proposal ID
     * @return True if proposal passed
     */
    function proposalSucceeded(uint256 proposalId) public view override returns (bool) {
        Proposal storage proposal = proposals[proposalId];
        
        // Must reach quorum
        if (!quorumReached(proposalId)) {
            return false;
        }

        // For votes must exceed against votes
        return proposal.forVotes > proposal.againstVotes;
    }
}
