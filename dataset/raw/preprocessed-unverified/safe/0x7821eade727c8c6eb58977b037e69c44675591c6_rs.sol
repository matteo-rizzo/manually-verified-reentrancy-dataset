/**
 *Submitted for verification at Etherscan.io on 2021-06-19
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.2;


// 
/**
 * @dev Collection of functions related to the address type
 */


// 
// solhint-disable-next-line compiler-version
/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

abstract contract ReentrancyGuardUpgradeable is Initializable {
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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// 
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
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */


// 
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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
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
    uint256[49] private __gap;
}

abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
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
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
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
    uint256[49] private __gap;
}

// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
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


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {
    using SafeMathUpgradeable for uint256;

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
    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
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
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
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
    function _setupDecimals(uint8 decimals_) internal virtual {
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
    uint256[44] private __gap;
}

// 
contract LiquidityPoolV3_02 is ReentrancyGuardUpgradeable, AccessControlUpgradeable, PausableUpgradeable, ERC20Upgradeable {

	using SafeMathUpgradeable for uint256;

  bytes32 constant public PAUSER_ROLE = keccak256("PAUSER_ROLE");

	uint256 constant public N_TOKENS = 5; 
	uint256 constant public NORM_BASE = 18;
	uint256 constant public CALC_PRECISION = 1e36;
	uint256 constant public PCT_PRECISION = 1e6;
	IERC20Upgradeable[N_TOKENS] public TOKENS;
	uint256[N_TOKENS] public TOKENS_MUL;
	
	uint256 public depositFee;
	uint256 public borrowFee;
	uint256 public adminFee;
	uint256 public adminBalance;
	address public adminFeeAddress;

	event SetFees(uint256 depositFee, uint256 borrowFee, uint256 adminFee);
	event SetAdminFeeAddress(address adminFeeAddress, address newAdminFeeAddress);
	event WithdrawAdminFee(address indexed addressTo, uint256[N_TOKENS] tokenAmounts, uint256 totalAmount);
	event Deposit(address indexed user, uint256[N_TOKENS] tokenAmounts, uint256 totalAmount, uint256 fee, uint256 mintedAmount);
	event Withdraw(address indexed user, uint256[N_TOKENS] tokenAmounts, uint256 burnedAmount);
	event Borrow(address indexed user, uint256[N_TOKENS] tokenAmounts, uint256 totalAmount, uint256 fee, uint256 adminFee);

	modifier onlyPauser() {
		require(hasRole(PAUSER_ROLE, msg.sender), "must have pauser role");
		_;
	}

	function initialize(
		uint256 depositFee_,
		uint256 borrowFee_,
		uint256 adminFee_
	)
		public
		initializer 
	{
		__ReentrancyGuard_init();
		__AccessControl_init();
		__Pausable_init_unchained();
		__ERC20_init_unchained('HodlTree Flash Loans LP USD Token', 'hFLP-USD');
		TOKENS = [
			IERC20Upgradeable(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51), // sUSD
			IERC20Upgradeable(0x056Fd409E1d7A124BD7017459dFEa2F387b6d5Cd), // GUSD
			IERC20Upgradeable(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48), // USDC
			IERC20Upgradeable(0x6B175474E89094C44Da98b954EedeAC495271d0F), // DAI
			IERC20Upgradeable(0x0000000000085d4780B73119b644AE5ecd22b376)  // TUSD
		];
		TOKENS_MUL = [
			uint256(1),
			uint256(1e16),
			uint256(1e12),
			uint256(1),
			uint256(1)
		];
		_setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
		_setupRole(PAUSER_ROLE, msg.sender);
		_setRoleAdmin(PAUSER_ROLE, PAUSER_ROLE);
		setFees(depositFee_, borrowFee_, adminFee_);
		setAdminFeeAddress(msg.sender);
	}
	
	/***************************************
					ADMIN
	****************************************/
	
	/**
	 * @dev Sets new fees
	 * @param depositFee_ deposit fee in ppm
	 * @param borrowFee_ borrow fee in ppm
	 * @param adminFee_ admin fee in ppm
	 */
	function setFees (
		uint256 depositFee_,
		uint256 borrowFee_,
		uint256 adminFee_
	)
		public
	{
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "must have admin role to set fees");
		depositFee = depositFee_;
		borrowFee = borrowFee_;
		adminFee = adminFee_;
		emit SetFees(depositFee_, borrowFee_, adminFee_);
	}

	/**
	 * @dev Sets admin fee address
	 * @param newAdminFeeAddress_ new admin fee address
	 */
	function setAdminFeeAddress (
		address newAdminFeeAddress_
	)
		public
	{
		require(newAdminFeeAddress_ != address(0), "admin fee address is zero");
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "must have admin role to set admin fee address");
		emit SetAdminFeeAddress(adminFeeAddress, newAdminFeeAddress_);
		adminFeeAddress = newAdminFeeAddress_;
	}

	/***************************************
					PAUSER
	****************************************/
	
	/**
	 * @dev Pause contract (disable deposit and borrow methods)
	 */
	function pause()
		external
		onlyPauser
	{
		_pause();
	}

	/**
	 * @dev Unause contract (enable deposit and borrow methods)
	 */
	function unpause()
		external
		onlyPauser
	{
		_unpause();
	}

	/***************************************
					PRIVATE
	****************************************/

	/**
	 * @dev Calculates amount to mint internal tokens
	 * @param amount_ normalised deposit amount
	 * @param totalBalance_ normalised total balance of all tokens excluding admin fees
	 * @param totalSupply_ internal token total supply
	 * @return mintAmount_ amount to mint
	 */
	function _calcMint (
		uint256 amount_,
		uint256 totalBalance_,
		uint256 totalSupply_
	) 
		internal
		pure
		returns(uint256 mintAmount_) 
	{
		mintAmount_ = amount_.mul(
			CALC_PRECISION
		).div(
			totalBalance_
		).mul(
			totalSupply_
		).div(
			CALC_PRECISION
		);
	}

	/**
	 * @dev Returns normalised total balance of all tokens including admin fees
	 * @return totalBalanceWithAdminFee_ balance
	 */	
	function _totalBalanceWithAdminFee ()
		internal
		view
		returns (uint256 totalBalanceWithAdminFee_)
	{
		for (uint256 i = 0; i < N_TOKENS; i++) {
			totalBalanceWithAdminFee_ = totalBalanceWithAdminFee_.add(
				(TOKENS[i].balanceOf(address(this))).mul(TOKENS_MUL[i])
			);
		}
	}

	/**
	 * @dev Returns non-normalised token balances including admin fees
	 * @return balancesWithAdminFee_ array of token balances
	 */		
	function _balancesWithAdminFee ()
		internal
		view
		returns (uint256[N_TOKENS] memory balancesWithAdminFee_)
	{
		for (uint256 i = 0; i < N_TOKENS; i++) {
			balancesWithAdminFee_[i] = TOKENS[i].balanceOf(address(this));
		}
	}

	/**
	 * @dev Withdraw tokens
	 * @param amount_ amount of internal token to burn
	 */	
	function _withdraw (
		uint256 amount_,
		uint256[N_TOKENS] memory outAmounts_
	)
		internal
	{
		require(amount_ != 0, "withdraw amount is zero");
		_burn(msg.sender, amount_);
		for (uint256 i = 0; i < N_TOKENS; i++) {
			if (outAmounts_[i] != 0)
				require(TOKENS[i].transfer(msg.sender, outAmounts_[i]), "token transfer failed");
		}
		emit Withdraw(msg.sender, outAmounts_, amount_);
	}

	/***************************************
					ACTIONS
	****************************************/

	function withdrawAdminFee ()
		external
		nonReentrant
		returns (uint256[N_TOKENS] memory outAmounts_)
	{
		uint256 _adminBalance = adminBalance;
		require(_adminBalance != 0, "admin balance is zero");
		uint256 _totalBalance = _totalBalanceWithAdminFee();
		uint256[N_TOKENS] memory _balances = _balancesWithAdminFee();
		for (uint256 i = 0; i < N_TOKENS; i++) {
			if(_balances[i] != 0){
				outAmounts_[i] = _adminBalance.mul(
					CALC_PRECISION
				).div(
					_totalBalance
				).mul(
					_balances[i]
				).div(
					CALC_PRECISION
				);
				require(TOKENS[i].transfer(adminFeeAddress, outAmounts_[i]));
			}
		}
		emit WithdrawAdminFee(adminFeeAddress, outAmounts_, _adminBalance);
		adminBalance = 0;
	}
	
	/**
	 * @dev Deposit tokens and mints internal tokens to sender as share in pool
	 * @param amounts_ amounts of tokens to deposit in array
	 */	
	function deposit (
		uint256[N_TOKENS] calldata amounts_
	)
		external
		nonReentrant
		whenNotPaused
		returns (uint256 mintAmount_)
	{
		uint256 _totalAmount;
		uint256 _totalBalance = totalBalance();
		for (uint256 i = 0; i < N_TOKENS; i++) {
			if (amounts_[i] != 0) {
				require(
					TOKENS[i].transferFrom(msg.sender, address(this), amounts_[i]),
					"token transfer failed"
				);
				_totalAmount = _totalAmount.add(amounts_[i].mul(TOKENS_MUL[i]));
			}
		}
		require(_totalAmount != 0, "total deposit amount is zero");
		uint256 _totalSupply = totalSupply();
		uint256 _fee;
		if(_totalSupply != 0) {
			_fee = _totalAmount.mul(depositFee).div(PCT_PRECISION);
			mintAmount_ = _calcMint(_totalAmount.sub(_fee), _totalBalance, _totalSupply);
		}else{
			mintAmount_ = _totalAmount;
		}
		_mint(msg.sender, mintAmount_);
		emit Deposit(msg.sender, amounts_, _totalAmount, _fee, mintAmount_);
	}

	/**
	 * @dev Withdraw tokens in current pool proportion
	 * @param amount_ amount of internal token to burn
	 * @return outAmounts_ array of tokens amounts that were withdrawn 
	 */	
	function withdraw (
		uint256 amount_
	)
		external
		nonReentrant
		returns (uint256[N_TOKENS] memory outAmounts_)
	{
		outAmounts_ = calcWithdraw(amount_);
		_withdraw(amount_, outAmounts_);
	}

	/**
	 * @dev Withdraw tokens in unbalanced proportion
	 * @param amount_ amount of internal token to burn
	 * @param outAmountPCTs_ array of token amount percentages to withdraw
	 * @return outAmounts_ array of tokens amounts that were withdrawn 
	 */	
	function widthdrawUnbalanced (
		uint256 amount_,
		uint256[N_TOKENS] calldata outAmountPCTs_
	)
		external
		nonReentrant
		returns (uint256[N_TOKENS] memory outAmounts_)
	{
		outAmounts_ = calcWidthdrawUnbalanced(amount_, outAmountPCTs_);
		_withdraw(amount_, outAmounts_);
	}

	/**
	 * @dev Withdraw exact tokens amounts
	 * @param outAmounts_ array of token amount to withdraw
	 * @return amount_ internal token amount burned on withdraw 
	 */	
	function widthdrawUnbalancedExactOut (		
		uint256[N_TOKENS] calldata outAmounts_
	)
		external
		nonReentrant
		returns (uint256 amount_)
	{
		amount_ = calcWidthdrawUnbalancedExactOut(outAmounts_);
		_withdraw(amount_, outAmounts_);
	}

	/**
	 * @dev Flashloans tokens to caller 
	 * @param amounts_ array of token amounts to borrow
	 * @param data_ encoded function callback to caller
	 */	
	function borrow (
		uint256[N_TOKENS] calldata amounts_,
		bytes calldata data_
	)
		external
		nonReentrant
		whenNotPaused
	{
		uint256 _totalAmount;
		uint256 _totalBalance;
		for (uint256 i = 0; i < N_TOKENS; i++) {
			_totalBalance = _totalBalance.add(
				(TOKENS[i].balanceOf(address(this))).mul(TOKENS_MUL[i])
			);
			if(amounts_[i] != 0) {
				_totalAmount = _totalAmount.add(amounts_[i].mul(TOKENS_MUL[i]));
				require(TOKENS[i].transfer(msg.sender, amounts_[i]), "token transfer failed");
			}
		}
		require(_totalAmount != 0, "flashloan total amount is zero");
		(bool _success, ) = address(msg.sender).call(data_);
		require(_success, "flashloan low-level callback failed");
		uint256 _fee = calcBorrowFee(_totalAmount);
		require(
			_totalBalanceWithAdminFee() >= _totalBalance.add(_fee),
			"flashloan is not paid back as expected"
		);
		uint256 _adminFee = _fee.mul(adminFee).div(PCT_PRECISION);
		adminBalance = adminBalance.add(_adminFee);
		emit Borrow(msg.sender, amounts_, _totalAmount, _fee.sub(_adminFee), _adminFee);
	}
	
	/***************************************
					GETTERS
	****************************************/
	
	/**
	 * @dev Returns normalised total balance of all tokens excluding admin fees
	 * @return uint256 balance
	 */	
	function totalBalance ()
		public
		view
		returns (uint256)
	{
		return (_totalBalanceWithAdminFee()).sub(adminBalance);
	}

	/**
	 * @dev Returns non-normalised token balances excluding admin fees
	 * @return balances_ array of token balances
	 */	
	function balances ()
		public
		view
		returns (uint256[N_TOKENS] memory balances_)
	{
		uint256 _totalBalance = _totalBalanceWithAdminFee();
		uint256[N_TOKENS] memory _balances = _balancesWithAdminFee();
		for (uint256 i = 0; i < N_TOKENS; i++) {
			if(_balances[i] != 0){
				balances_[i] = _balances[i].sub(
					adminBalance.mul(
						CALC_PRECISION
					).div(
						_totalBalance
					).mul(
						_balances[i]
					).div(
						CALC_PRECISION
					)
				);
			}
		}
	}

	/**
	 * @dev Returns non-normalised token balance excluding admin fees
	 * @param token_ token index
	 * @return uint256 token balance
	 */	
	function balance (uint256 token_)
		public
		view
		returns (uint256)
	{
		return balances()[token_];
	}

	/**
	 * @dev Calculates withdraw amounts of tokens in current pool proportion
	 * @param amount_ amount of internal token to burn
	 * @return outAmounts_ array of token amounts will be returned on withdraw 
	 */	
	function calcWithdraw (
		uint256 amount_
	)
		public
		view
		returns (uint256[N_TOKENS] memory outAmounts_)
	{
		uint256 _totalSupply = totalSupply();
		uint256[N_TOKENS] memory _balances = balances();
		for (uint256 i = 0; i < N_TOKENS; i++) {
			if (_balances[i] != 0) {
				outAmounts_[i] = amount_.mul(
					CALC_PRECISION
				).div(
					_totalSupply
				).mul(
					_balances[i]
				).div(
					CALC_PRECISION
				);			
			}
		}
	}

	/**
	 * @dev Calculates unbalanced withdraw tokens amounts 
	 * @param amount_ amount of internal token to burn
	 * @param outAmountPCTs_ array of token amount percentages in ppm to withdraw
	 * @return outAmounts_ array of token amounts will be returned on withdraw 
	 */	
	function calcWidthdrawUnbalanced (
		uint256 amount_,
		uint256[N_TOKENS] calldata outAmountPCTs_
	)
		public
		view
		returns (uint256[N_TOKENS] memory outAmounts_)
	{
		uint256 _amount;
		uint256 _outAmountPCT;
		uint256 _totalSupply = totalSupply();
		uint256 _totalBalance = totalBalance();
		for (uint256 i = 0; i < N_TOKENS; i++) {
			if(outAmountPCTs_[i] != 0){
				_amount = amount_.mul(outAmountPCTs_[i]).div(PCT_PRECISION);
				outAmounts_[i] = _amount.mul(
					CALC_PRECISION
				).div(
					_totalSupply
				).mul(
					_totalBalance.div(TOKENS_MUL[i])
				).div(
					CALC_PRECISION
				);
				_outAmountPCT = _outAmountPCT.add(outAmountPCTs_[i]);
			}
		}
		require(_outAmountPCT == PCT_PRECISION, "total percentage is not 100% in ppm");
	}

	/**
	 * @dev Calculates internal token amount to butn for unbalanced withdraw with exact tokens amounts
	 * @param outAmounts_ array of token amount to withdraw
	 * @return amount_ internal token amount will be burned on withdraw 
	 */	
	function calcWidthdrawUnbalancedExactOut (		
		uint256[N_TOKENS] calldata outAmounts_
	)
		public
		view
		returns (uint256 amount_)
	{
		uint256 _totalSupply = totalSupply();
		uint256 _totalBalance = totalBalance();
		for (uint256 i = 0; i < N_TOKENS; i++) {
			if(outAmounts_[i] != 0){
				amount_ = amount_.add(
					outAmounts_[i].mul(
						CALC_PRECISION
					).div(
						_totalBalance.div(TOKENS_MUL[i])
					).mul(
						_totalSupply
					).div(
						CALC_PRECISION
					)
				);
			}
		}
	}


	/**
	 * @dev Calculates fee for flashloan
	 * @param amount_ amount to borrow
	 */	
	function calcBorrowFee (
		uint256 amount_
	)
		public
		view
		returns (uint256)
	{
		return amount_.mul(borrowFee).div(PCT_PRECISION);
	}

	/**
	 * @dev The current virtual price of internal pool token
	 * @return uint256 normalised virtual price
	 */	
	function virtualPrice ()
		public
		view
		returns (uint256)
	{
		return (totalBalance()).mul(10 ** NORM_BASE).div(totalSupply());
	}

}