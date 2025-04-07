/**
 *Submitted for verification at Etherscan.io on 2020-10-01
*/

// File: localhost/Toft_Contracts/contracts/ToftToken/openzeppelin/utils/Pausable.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Collection of functions related to the address type
 */



/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
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
        require(_paused, "Pausable: not paused");
        _;
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public virtual view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public virtual view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
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
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

/**
 * @dev ERC20 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC20Pausable is ERC20, Pausable {
    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



/*
 * TransferFee 
 * Base contract for trasfer fee specification.
 */
abstract contract TransferFee is Ownable, ITST {

    address private _feeAccount;
    uint256 private _maxTransferFee;
    uint256 private _minTransferFee;
    uint256 private _transferFeePercentage;
    
    /**
     * @dev Constructor, _feeAccount that collects tranfer fee, fee percentange, maximum, minimum amount of wei for trasfer fee.
     * @param feeAccount account that collects fee.
     * @param minTransferFee Min amount of wei to be charged on trasfer.
     * @param minTransferFee Min amount of wei to be charged on trasfer.
     * @param transferFeePercentage Percent amount of wei to be charged on trasfer.
     */
    constructor (address feeAccount, uint256 maxTransferFee, uint256 minTransferFee, uint256 transferFeePercentage) public {
        require(feeAccount != address(0x0), "TransferFee: feeAccount is 0");
        
        // this also handles "minTransferFee should be less than maxTransferFee"
        // solhint-disable-next-line max-line-length
        require(maxTransferFee >= minTransferFee, "TransferFee: maxTransferFee should be greater than minTransferFee");

        _feeAccount = feeAccount;
        _maxTransferFee = maxTransferFee;
        _minTransferFee = minTransferFee;
        _transferFeePercentage = transferFeePercentage;
    }
    
    /**
     * See {ITrasnferFee-setFeeAccount}.
     * 
     * @dev sets `feeAccount` to `_feeAccount` by the caller.
     *
     * Requirements:
     *
     * - `feeAccount` cannot be the zero.
     */
    function setFeeAccount(address feeAccount) override external onlyOwner returns (bool) {
        require(feeAccount != address(0x0), "TransferFee: feeAccount is 0");
        
        emit FeeAccountUpdated(_feeAccount, feeAccount);
        _feeAccount = feeAccount;
        return true;
    }
    
    /**
     * See {ITrasnferFee-setMaxTransferFee}.
     * 
     * @dev sets `maxTransferFee` to `_maxTransferFee` by the caller.
     * 
     * Requirements:
     *
     * - `maxTransferFee` cannot be the zero.
     * - `maxTransferFee` should be greater than minTransferFee.
     */
    function setMaxTransferFee(uint256 maxTransferFee) override external onlyOwner returns (bool) {
        // solhint-disable-next-line max-line-length
        require(maxTransferFee >= _minTransferFee, "TransferFee: maxTransferFee should be greater or equal to minTransferFee");
        
        emit MaxTransferFeeUpdated(_maxTransferFee, maxTransferFee);
        _maxTransferFee = maxTransferFee;
        return true;
    }

    /**
     * See {ITrasnferFee-setMinTransferFee}.
     * 
     * @dev sets `minTransferFee` to `_minTransferFee` by the caller.
     *
     * Requirements:
     *
     * - `minTransferFee` cannot be the zero.
     * - `minTransferFee` should be less than maxTransferFee.
     */
    function setMinTransferFee(uint256 minTransferFee) override external onlyOwner returns (bool) {
        // solhint-disable-next-line max-line-length
        require(minTransferFee <= _maxTransferFee, "TransferFee: minTransferFee should be less than maxTransferFee");
        
        emit MaxTransferFeeUpdated(_minTransferFee, minTransferFee);
        _minTransferFee = minTransferFee;
        return true;
    }

    /**
     * See {ITrasnferFee-setTransferFeePercentage}.
     * 
     * @dev sets `transferFeePercentage` to `_transferFeePercentage` by the caller.
     *
     * Requirements:
     *
     * - `transferFeePercentage` cannot be the zero.
     * - `transferFeePercentage` should be less than maxTransferFee.
     */
    function setTransferFeePercentage(uint256 transferFeePercentage) override external onlyOwner returns (bool) {
        emit TransferFeePercentageUpdated(_transferFeePercentage, transferFeePercentage);
        _transferFeePercentage = transferFeePercentage;
        return true;
    }
    
    /**
     * @dev See {ITrasnferFee-feeAccount}.
     */    
    function feeAccount() override public view returns (address) {
        return _feeAccount;
    }

    /**
     * See {ITrasnferFee-maxTransferFee}.
     */
    function maxTransferFee() override public view returns (uint256) {
        return _maxTransferFee;
    }
    
    /**
     * See {ITrasnferFee-minTransferFee}.
     */
    function minTransferFee() override public view returns (uint256) {
        return _minTransferFee;
    }

    /**
     * See {ITrasnferFee-transferFeePercentage}.
     */ 
    function transferFeePercentage() override public view returns (uint256) {
        return _transferFeePercentage;
    }
}

/**
 * @title Toft Standard Token
 * @dev TST implementation.
 */
contract StandardToken is
    Context,
    Ownable,
    AccessControl,
    ERC20Burnable,
    ERC20Pausable,
    TransferFee
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * See {ERC20-constructor}.
     */
    constructor(
        string memory name,
        string memory symbol,
        address feeAccount,
        uint256 maxTransferFee,
        uint256 minTransferFee,
        uint256 transferFeePercentage
    )
        public
        TransferFee(
            feeAccount,
            maxTransferFee,
            minTransferFee,
            transferFeePercentage
        )
        ERC20(name, symbol)
    {
        _setupDecimals(2);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(BURNER_ROLE, _msgSender());
    }

    /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 amount) public virtual {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "TST: must have minter role to mint"
        );
        require(
            to == owner(),
            "TST: tokens can be only minted on owner address"
        );
        _mint(to, amount);
    }

    /**
     * @dev overloading burn function to enable token burn from any account
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(address account, uint256 amount) public virtual {
        require(
            hasRole(BURNER_ROLE, _msgSender()),
            "TST: must have burner role to burn"
        );
        _burn(account, amount);
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "TST: must have pauser role to pause"
        );
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "TST: must have pauser role to unpause"
        );
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @dev override IERC20-transfer to deducted transfer fee from `amount`
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override(ERC20)
        returns (bool)
    {
        require(
            recipient != address(this),
            "ERC20: transfer to the this contract"
        );
        uint256 _fee = calculateTransferFee(amount);

        // calling ERC20 transfer function to transfer tokens
        super.transfer(recipient, amount);

        // TST
        if (_fee > 0) super.transfer(feeAccount(), _fee); // transfering fee to fee account
        emit Transfer(_msgSender(), recipient, amount, _fee, "", now);
        return true;
    }

    /**
     * @dev overriding version of ${transfer} that includes message in token transfer
     *
     */
    function transfer(
        address recipient,
        uint256 amount,
        string calldata message
    ) public virtual override(ITST) returns (bool) {
        require(
            recipient != address(this),
            "ERC20: transfer to the this contract"
        );
        uint256 _fee = calculateTransferFee(amount);

        // calling ERC20 transfer function to transfer tokens
        super.transfer(recipient, amount);

        // TST
        if (_fee > 0) super.transfer(feeAccount(), _fee); // transfering fee to fee account
        emit Transfer(_msgSender(), recipient, amount, _fee, message, now);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override(ERC20) returns (bool) {
        require(
            recipient != address(this),
            "ERC20: transfer to the this contract"
        );
        uint256 _fee = calculateTransferFee(amount);

        // calling ERC20 transfer function to transfer tokens
        super.transferFrom(sender, recipient, amount);

        // TST
        if (_fee > 0) super.transferFrom(sender, feeAccount(), _fee); // transfering fee to fee account
        emit Transfer(sender, recipient, amount, _fee, "", now);
        return true;
    }

    /**
     * @dev overriding version of ${transferFrom} that includes message in token transfer
     *
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount,
        string calldata message
    ) public virtual override(ITST) returns (bool) {
        require(
            recipient != address(this),
            "ERC20: transfer to the this contract"
        );
        uint256 _fee = calculateTransferFee(amount);

        // calling ERC20 transfer function to transfer tokens
        super.transferFrom(sender, recipient, amount);

        // TST
        if (_fee > 0) super.transferFrom(sender, feeAccount(), _fee); // transfering fee to fee account
        emit Transfer(sender, recipient, amount, _fee, message, now);
        return true;
    }

    /**
     * @dev calculate transfer fee aginst `weiAmount`.
     * @param weiAmount Value in wei to be to calculate fee.
     * @return Number of tokens in wei to paid for transfer fee.
     */
    function calculateTransferFee(uint256 weiAmount)
        public
        virtual
        override(ITST)
        view
        returns (uint256)
    {
        uint256 divisor = uint256(100).mul((10**uint256(decimals())));
        uint256 _fee = (transferFeePercentage().mul(weiAmount)).div(divisor);

        if (_fee < minTransferFee()) {
            _fee = minTransferFee();
        } else if (_fee > maxTransferFee()) {
            _fee = maxTransferFee();
        }

        return _fee;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     * @return the current supply of tokens.
     *
     * Requirements:
     *
     * - the caller must have the {Owner}.
     */
    function totalSupply()
        public
        virtual
        override(ERC20)
        view
        onlyOwner
        returns (uint256)
    {
        return super.totalSupply();
    }

    // TOFT: THESE FUNCTIONS ARE ADDED TO MAKE THIS CONTRACT COMPATIBLE WITH EXISTING APPS

    function increaseSupply(address target, uint256 amount) external virtual {
        mint(target, amount);
    }

    function decreaseSupply(address target, uint256 amount) external virtual {
        burn(target, amount);
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function getName() external view returns (string memory) {
        return name();
    }

    function getFeeAccount() external view returns (address) {
        return feeAccount();
    }

    function getTotalSupply() external view returns (uint256) {
        return totalSupply();
    }

    function getMaxTransferFee() external view returns (uint256) {
        return maxTransferFee();
    }

    function getMinTransferFee() external view returns (uint256) {
        return minTransferFee();
    }

    function getTransferFeePercentage() external view returns (uint256) {
        return transferFeePercentage();
    }

    function getBalance(address balanceAddress)
        external
        virtual
        view
        returns (uint256)
    {
        return balanceOf(balanceAddress);
    }
}

abstract contract UpgradedStandardToken is StandardToken {
    // those methods are called by the legacy contract
    // and they must ensure msg.sender to be the contract address
    function transferByLegacy(
        address from,
        address recipient,
        uint256 amount
    ) public virtual returns (bool);

    function transferByLegacy(
        address from,
        address recipient,
        uint256 amount,
        string calldata message
    ) external virtual returns (bool);

    function transferFromByLegacy(
        address sender,
        address from,
        address recipient,
        uint256 amount
    ) external virtual returns (bool);

    function transferFromByLegacy(
        address sender,
        address from,
        address recipient,
        uint256 amount,
        string calldata message
    ) external virtual returns (bool);

    function approveByLegacy(
        address from,
        address spender,
        uint256 amount
    ) external virtual returns (bool);
    
    function totalSupplyByLegacy() external virtual view returns (uint256);

}

contract TST is StandardToken {
    address public upgradedAddress;
    bool public deprecated;

    // Called when contract is deprecated
    event Deprecate(address newAddress);

    constructor(
        string memory name,
        string memory symbol,
        address feeAccount,
        uint256 maxTransferFee,
        uint256 minTransferFee,
        uint256 transferFeePercentage
    )
        public
        StandardToken(
            name,
            symbol,
            feeAccount,
            maxTransferFee,
            minTransferFee,
            transferFeePercentage
        )
    {
        deprecated = false;
    }

    // Forward StandardToken methods to upgraded contract if this one is deprecated
    function mint(address to, uint256 amount) public override(StandardToken) {
        if (!deprecated) return super.mint(to, amount);
        else return UpgradedStandardToken(upgradedAddress).mint(to, amount);
    }

    // Forward StandardToken methods to upgraded contract if this one is deprecated
    function burn(address account, uint256 amount)
        public
        override(StandardToken)
    {
        if (!deprecated) return super.burn(account, amount);
        else
            return UpgradedStandardToken(upgradedAddress).burn(account, amount);
    }

    // Forward StandardToken methods to upgraded contract if this one is deprecated
    function pause() public override(StandardToken) {
        if (!deprecated) return super.pause();
        else return UpgradedStandardToken(upgradedAddress).pause();
    }

    // Forward StandardToken methods to upgraded contract if this one is deprecated
    function unpause() public override(StandardToken) {
        if (!deprecated) return super.unpause();
        else return UpgradedStandardToken(upgradedAddress).unpause();
    }

    // Forward StandardToken methods to upgraded contract if this one is deprecated
    function transfer(address recipient, uint256 amount)
        public
        override(StandardToken)
        returns (bool)
    {
        if (!deprecated) return super.transfer(recipient, amount);
        else
            return
                UpgradedStandardToken(upgradedAddress).transferByLegacy(
                    msg.sender,
                    recipient,
                    amount
                );
    }

    // Forward StandardToken methods to upgraded contract if this one is deprecated
    function transfer(
        address recipient,
        uint256 amount,
        string calldata message
    ) public override(StandardToken) returns (bool) {
        if (!deprecated) return super.transfer(recipient, amount, message);
        else
            return
                UpgradedStandardToken(upgradedAddress).transferByLegacy(
                    msg.sender,
                    recipient,
                    amount,
                    message
                );
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override(StandardToken) returns (bool) {
        if (!deprecated) return super.transferFrom(sender, recipient, amount);
        else
            return
                UpgradedStandardToken(upgradedAddress).transferFromByLegacy(
                    msg.sender,
                    sender,
                    recipient,
                    amount
                );
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount,
        string calldata message
    ) public override(StandardToken) returns (bool) {
        if (!deprecated)
            return super.transferFrom(sender, recipient, amount, message);
        else
            return
                UpgradedStandardToken(upgradedAddress).transferFromByLegacy(
                    msg.sender,
                    sender,
                    recipient,
                    amount,
                    message
                );
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function balanceOf(address account) public override view returns (uint256) {
        if (!deprecated) return super.balanceOf(account);
        else return UpgradedStandardToken(upgradedAddress).balanceOf(account);
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function totalSupply() public override view returns (uint256) {
        if (!deprecated) return super.totalSupply();
        else return UpgradedStandardToken(upgradedAddress).totalSupplyByLegacy();
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function approve(address spender, uint256 amount)
        public
        override(ERC20)
        returns (bool)
    {
        if (!deprecated) return super.approve(spender, amount);
        else
            return
                UpgradedStandardToken(upgradedAddress).approveByLegacy(
                    msg.sender,
                    spender,
                    amount
                );
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function allowance(address owner, address spender)
        public
        override(ERC20)
        view
        returns (uint256)
    {
        if (!deprecated) return super.allowance(owner, spender);
        else
            return
                UpgradedStandardToken(upgradedAddress).allowance(
                    owner,
                    spender
                );
    }

    // deprecate current contract in favour of a new one
    function deprecate(address _upgradedAddress) public onlyOwner {
        deprecated = true;
        upgradedAddress = _upgradedAddress;
        Deprecate(_upgradedAddress);
    }

    function increaseSupply(address target, uint256 amount)
        external
        override(StandardToken)
    {
        mint(target, amount);
    }

    function decreaseSupply(address target, uint256 amount)
        external
        override(StandardToken)
    {
        burn(target, amount);
    }

    function getBalance(address balanceAddress)
        external
        override
        view
        returns (uint256)
    {
        return balanceOf(balanceAddress);
    }
}