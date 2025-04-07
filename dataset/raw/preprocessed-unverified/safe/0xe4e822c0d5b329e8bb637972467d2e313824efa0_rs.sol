// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;


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
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


// 
/**
 * @dev Collection of functions related to the address type
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 
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

// 
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
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
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

    constructor () internal {
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
}

// 


// 
/**
 * XFI token extends the interface of ERC20 standard.
 */
interface IXFIToken is IERC20 {
    event VestingStartChanged(uint256 newVestingStart, uint256 newVestingEnd, uint256 newReserveFrozenUntil);
    event TransfersStarted();
    event TransfersStopped();
    event MigrationsAllowed();
    event ReserveWithdrawal(address indexed to, uint256 amount);
    event VestingBalanceMigrated(address indexed from, bytes32 to, uint256 vestingDaysLeft, uint256 vestingBalance);

    function isTransferringStopped() external view returns (bool);
    function isMigratingAllowed() external view returns (bool);
    function VESTING_DURATION() external view returns (uint256);
    function VESTING_DURATION_DAYS() external view returns (uint256);
    function RESERVE_FREEZE_DURATION() external view returns (uint256);
    function RESERVE_FREEZE_DURATION_DAYS() external view returns (uint256);
    function MAX_VESTING_TOTAL_SUPPLY() external view returns (uint256);
    function vestingStart() external view returns (uint256);
    function vestingEnd() external view returns (uint256);
    function reserveFrozenUntil() external view returns (uint256);
    function reserveAmount() external view returns (uint256);
    function vestingDaysSinceStart() external view returns (uint256);
    function vestingDaysLeft() external view returns (uint256);
    function convertAmountUsingRatio(uint256 amount) external view returns (uint256);
    function convertAmountUsingReverseRatio(uint256 amount) external view returns (uint256);
    function totalVestedBalanceOf(address account) external view returns (uint256);
    function unspentVestedBalanceOf(address account) external view returns (uint256);
    function spentVestedBalanceOf(address account) external view returns (uint256);

    function mint(address account, uint256 amount) external returns (bool);
    function mintWithoutVesting(address account, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
    function burnFrom(address account, uint256 amount) external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function startTransfers() external returns (bool);
    function stopTransfers() external returns (bool);
    function allowMigrations() external returns (bool);
    function changeVestingStart(uint256 newVestingStart) external returns (bool);
    function withdrawReserve(address to) external returns (bool);
    function migrateVestingBalance(bytes32 to) external returns (bool);
}

// 
/**
 * Implementation of the {IXFIToken} interface.
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
 * allowances.
 */
contract XFIToken is AccessControl, ReentrancyGuard, IXFIToken {
    using SafeMath for uint256;
    using Address for address;

    string private constant _name = 'dfinance';

    string private constant _symbol = 'XFI';

    uint8 private constant _decimals = 18;

    bytes32 public constant MINTER_ROLE = keccak256('minter');

    uint256 public constant override MAX_VESTING_TOTAL_SUPPLY = 1e26; // 100 million XFI.

    uint256 public constant override VESTING_DURATION_DAYS = 182;
    uint256 public constant override VESTING_DURATION = 182 days;

    /**
     * @dev Reserve is the final amount of tokens that weren't distributed
     * during the vesting.
     */
    uint256 public constant override RESERVE_FREEZE_DURATION_DAYS = 730; // Around 2 years.
    uint256 public constant override RESERVE_FREEZE_DURATION = 730 days;

    mapping (address => uint256) private _vestingBalances;

    mapping (address => uint256) private _balances;

    mapping (address => uint256) private _spentVestedBalances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _vestingTotalSupply;

    uint256 private _totalSupply;

    uint256 private _spentVestedTotalSupply;

    uint256 private _vestingStart;

    uint256 private _vestingEnd;

    uint256 private _reserveFrozenUntil;

    bool private _stopped = false;

    bool private _migratingAllowed = false;

    uint256 private _reserveAmount;

    /**
     * Sets {DEFAULT_ADMIN_ROLE} (alias `owner`) role for caller.
     * Assigns vesting and freeze period dates.
     */
    constructor (uint256 vestingStart_) public {
        require(vestingStart_ > block.timestamp, 'XFIToken: vesting start must be greater than current timestamp');
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _vestingStart = vestingStart_;
        _vestingEnd = vestingStart_.add(VESTING_DURATION);
        _reserveFrozenUntil = vestingStart_.add(RESERVE_FREEZE_DURATION);
        _reserveAmount = MAX_VESTING_TOTAL_SUPPLY;
    }

    /**
     * Transfers `amount` tokens to `recipient`.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);

        return true;
    }

    /**
     * Approves `spender` to spend `amount` of caller's tokens.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);

        return true;
    }

    /**
     * Transfers `amount` tokens from `sender` to `recipient`.
     *
     * Emits a {Transfer} event.
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, 'XFIToken: transfer amount exceeds allowance'));

        return true;
    }

    /**
     * Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) external override returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));

        return true;
    }

    /**
     * Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) external override returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, 'XFIToken: decreased allowance below zero'));

        return true;
    }

    /**
     * Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     * - Caller must have minter role.
     * - `account` cannot be the zero address.
     */
    function mint(address account, uint256 amount) external override returns (bool) {
        require(hasRole(MINTER_ROLE, msg.sender), 'XFIToken: sender is not minter');

        _mint(account, amount);

        return true;
    }

    /**
     * Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply without vesting.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     * - Caller must have minter role.
     * - `account` cannot be the zero address.
     */
    function mintWithoutVesting(address account, uint256 amount) external override returns (bool) {
        require(hasRole(MINTER_ROLE, msg.sender), 'XFIToken: sender is not minter');

        _mintWithoutVesting(account, amount);

        return true;
    }

    /**
     * Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     * - Caller must have minter role.
     */
    function burnFrom(address account, uint256 amount) external override returns (bool) {
        require(hasRole(MINTER_ROLE, msg.sender), 'XFIToken: sender is not minter');

        _burn(account, amount);

        return true;
    }

    /**
     * Destroys `amount` tokens from sender, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     */
    function burn(uint256 amount) external override returns (bool) {
        _burn(msg.sender, amount);

        return true;
    }

    /**
     * Change vesting start and end timestamps.
     *
     * Emits a {VestingStartChanged} event.
     *
     * Requirements:
     * - Caller must have owner role.
     * - Vesting must be pending.
     * - `vestingStart_` must be greater than the current timestamp.
     */
    function changeVestingStart(uint256 vestingStart_) external override returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'XFIToken: sender is not owner');
        require(_vestingStart > block.timestamp, 'XFIToken: vesting has started');
        require(vestingStart_ > block.timestamp, 'XFIToken: vesting start must be greater than current timestamp');

        _vestingStart = vestingStart_;
        _vestingEnd = vestingStart_.add(VESTING_DURATION);
        _reserveFrozenUntil = vestingStart_.add(RESERVE_FREEZE_DURATION);

        emit VestingStartChanged(vestingStart_, _vestingEnd, _reserveFrozenUntil);

        return true;
    }

    /**
     * Starts all transfers.
     *
     * Emits a {TransfersStarted} event.
     *
     * Requirements:
     * - Caller must have owner role.
     * - Transferring is stopped.
     */
    function startTransfers() external override returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), 'XFIToken: sender is not owner');
        require(_stopped, 'XFIToken: transferring is not stopped');

        _stopped = false;

        emit TransfersStarted();

        return true;
    }

    /**
     * Stops all transfers.
     *
     * Emits a {TransfersStopped} event.
     *
     * Requirements:
     * - Caller must have owner role.
     * - Transferring isn't stopped.
     */
    function stopTransfers() external override returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), 'XFIToken: sender is not owner');
        require(!_stopped, 'XFIToken: transferring is stopped');

        _stopped = true;

        emit TransfersStopped();

        return true;
    }

    /**
     * Start migrations.
     *
     * Emits a {MigrationsStarted} event.
     *
     * Requirements:
     * - Caller must have owner role.
     * - Migrating isn't allowed.
     */
    function allowMigrations() external override returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), 'XFIToken: sender is not owner');
        require(!_migratingAllowed, 'XFIToken: migrating is allowed');

        _migratingAllowed = true;

        emit MigrationsAllowed();

        return true;
    }

    /**
     * Withdraws reserve amount to a destination specified as `to`.
     *
     * Emits a {ReserveWithdrawal} event.
     *
     * Requirements:
     * - `to` cannot be the zero address.
     * - Caller must have owner role.
     * - Reserve has unfrozen.
     */
    function withdrawReserve(address to) external override nonReentrant returns (bool) {
        require(to != address(0), 'XFIToken: withdraw to the zero address');
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), 'XFIToken: sender is not owner');
        require(block.timestamp > _reserveFrozenUntil, 'XFIToken: reserve is frozen');

        uint256 amount = reserveAmount();

        _mintWithoutVesting(to, amount);

        _reserveAmount = 0;

        emit ReserveWithdrawal(to, amount);

        return true;
    }

    /**
     * Migrate vesting balance to the Dfinance blockchain.
     *
     * Emits a {VestingBalanceMigrated} event.
     *
     * Requirements:
     * - `to` is not the zero bytes.
     * - Vesting balance is greater than zero.
     * - Vesting hasn't ended.
     */
    function migrateVestingBalance(bytes32 to) external override nonReentrant returns (bool) {
        require(to != bytes32(0), 'XFIToken: migrate to the zero bytes');
        require(_migratingAllowed, 'XFIToken: migrating is disallowed');
        require(block.timestamp < _vestingEnd, 'XFIToken: vesting has ended');

        uint256 vestingBalance = _vestingBalances[msg.sender];

        require(vestingBalance > 0, 'XFIToken: vesting balance is zero');

        uint256 spentVestedBalance = spentVestedBalanceOf(msg.sender);
        uint256 unspentVestedBalance = unspentVestedBalanceOf(msg.sender);

        // Subtract the vesting balance from total supply.
        _vestingTotalSupply = _vestingTotalSupply.sub(vestingBalance);

        // Add the unspent vesting balance to total supply.
        _totalSupply = _totalSupply.add(unspentVestedBalance);

        // Subtract the spent vested balance from total supply.
        _spentVestedTotalSupply = _spentVestedTotalSupply.sub(spentVestedBalance);

        // Make unspent vested balance persistent.
        _balances[msg.sender] = _balances[msg.sender].add(unspentVestedBalance);

        // Reset the account's vesting.
        _vestingBalances[msg.sender] = 0;
        _spentVestedBalances[msg.sender] = 0;

        emit VestingBalanceMigrated(msg.sender, to, vestingDaysLeft(), vestingBalance);

        return true;
    }

    /**
     * Returns name of the token.
     */
    function name() external view override returns (string memory) {
        return _name;
    }

    /**
     * Returns symbol of the token.
     */
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    /**
     * Returns number of decimals of the token.
     */
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    /**
     * Returnes amount of `owner`'s tokens that `spender` is allowed to transfer.
     */
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * Returns the vesting start.
     */
    function vestingStart() external view override returns (uint256) {
        return _vestingStart;
    }

    /**
     * Returns the vesting end.
     */
    function vestingEnd() external view override returns (uint256) {
        return _vestingEnd;
    }

    /**
     * Returns the date when freeze of the reserve XFI amount.
     */
    function reserveFrozenUntil() external view override returns (uint256) {
        return _reserveFrozenUntil;
    }

    /**
     * Returns whether transfering is stopped.
     */
    function isTransferringStopped() external view override returns (bool) {
        return _stopped;
    }

    /**
     * Returns whether migrating is allowed.
     */
    function isMigratingAllowed() external view override returns (bool) {
        return _migratingAllowed;
    }

    /**
     * Convert input amount to the output amount using the vesting ratio
     * (days since vesting start / vesting duration).
     */
    function convertAmountUsingRatio(uint256 amount) public view override returns (uint256) {
        uint256 convertedAmount = amount
            .mul(vestingDaysSinceStart())
            .div(VESTING_DURATION_DAYS);

        return (convertedAmount < amount)
            ? convertedAmount
            : amount;
    }

    /**
     * Convert input amount to the output amount using the vesting reverse
     * ratio (days until vesting end / vesting duration).
     */
    function convertAmountUsingReverseRatio(uint256 amount) public view override returns (uint256) {
        if (vestingDaysSinceStart() > 0) {
            return amount
                .mul(vestingDaysLeft().add(1))
                .div(VESTING_DURATION_DAYS);
        } else {
            return amount;
        }
    }

    /**
     * Returns days since the vesting start.
     */
    function vestingDaysSinceStart() public view override returns (uint256) {
        if (block.timestamp > _vestingStart) {
            return block.timestamp
                .sub(_vestingStart)
                .div(1 days)
                .add(1);
        } else {
            return 0;
        }
    }

    /**
     * Returns vesting days left.
     */
    function vestingDaysLeft() public view override returns (uint256) {
        if (block.timestamp < _vestingEnd) {
            return VESTING_DURATION_DAYS
                .sub(vestingDaysSinceStart());
        } else {
            return 0;
        }
    }

    /**
     * Returns total supply of the token.
     */
    function totalSupply() public view override returns (uint256) {
        return convertAmountUsingRatio(_vestingTotalSupply)
            .add(_totalSupply)
            .sub(_spentVestedTotalSupply);
    }

    /**
     * Returns total vested balance of the `account`.
     */
    function totalVestedBalanceOf(address account) public view override returns (uint256) {
        return convertAmountUsingRatio(_vestingBalances[account]);
    }

    /**
     * Returns unspent vested balance of the `account`.
     */
    function unspentVestedBalanceOf(address account) public view override returns (uint256) {
        return totalVestedBalanceOf(account)
            .sub(_spentVestedBalances[account]);
    }

    /**
     * Returns spent vested balance of the `account`.
     */
    function spentVestedBalanceOf(address account) public view override returns (uint256) {
        return _spentVestedBalances[account];
    }

    /**
     * Returns token balance of the `account`.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return unspentVestedBalanceOf(account)
            .add(_balances[account]);
    }

    /**
     * Returns reserve amount.
     */
    function reserveAmount() public view override returns (uint256) {
        return _reserveAmount;
    }

    /**
     * Moves tokens `amount` from `sender` to `recipient`.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - Transferring is not stopped.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), 'XFIToken: transfer from the zero address');
        require(recipient != address(0), 'XFIToken: transfer to the zero address');
        require(!_stopped, 'XFIToken: transferring is stopped');

        _decreaseAccountBalance(sender, amount);

        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    /**
     * Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     * - `account` cannot be the zero address.
     * - Transferring is not stopped.
     * - `amount` doesn't exceed reserve amount.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'XFIToken: mint to the zero address');
        require(!_stopped, 'XFIToken: transferring is stopped');
        require(_reserveAmount >= amount, 'XFIToken: mint amount exceeds reserve amount');

        _vestingTotalSupply = _vestingTotalSupply.add(amount);

        _vestingBalances[account] = _vestingBalances[account].add(amount);

        _reserveAmount = _reserveAmount.sub(amount);

        emit Transfer(address(0), account, amount);
    }

    /**
     * Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply without vesting.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     * - `account` cannot be the zero address.
     * - Transferring is not stopped.
     */
    function _mintWithoutVesting(address account, uint256 amount) internal {
        require(account != address(0), 'XFIToken: mint to the zero address');
        require(!_stopped, 'XFIToken: transferring is stopped');

        _totalSupply = _totalSupply.add(amount);

        _balances[account] = _balances[account].add(amount);

        emit Transfer(address(0), account, amount);
    }

    /**
     * Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     * - `account` cannot be the zero address.
     * - Transferring is not stopped.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'XFIToken: burn from the zero address');
        require(!_stopped, 'XFIToken: transferring is stopped');
        require(balanceOf(account) >= amount, 'XFIToken: burn amount exceeds balance');

        _decreaseAccountBalance(account, amount);

        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(account, address(0), amount);
    }

    /**
     * Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), 'XFIToken: approve from the zero address');
        require(spender != address(0), 'XFIToken: approve to the zero address');

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    /**
     * Decrease balance of the `account`.
     *
     * The use of vested balance is in priority. Otherwise, the normal balance
     * will be used.
     */
    function _decreaseAccountBalance(address account, uint256 amount) internal {
        uint256 accountBalance = balanceOf(account);

        require(accountBalance >= amount, 'XFIToken: transfer amount exceeds balance');

        uint256 accountVestedBalance = unspentVestedBalanceOf(account);
        uint256 usedVestedBalance = 0;
        uint256 usedBalance = 0;

        if (accountVestedBalance >= amount) {
            usedVestedBalance = amount;
        } else {
            usedVestedBalance = accountVestedBalance;
            usedBalance = amount.sub(usedVestedBalance);
        }

        _balances[account] = _balances[account].sub(usedBalance);
        _spentVestedBalances[account] = _spentVestedBalances[account].add(usedVestedBalance);

        _totalSupply = _totalSupply.add(usedVestedBalance);
        _spentVestedTotalSupply = _spentVestedTotalSupply.add(usedVestedBalance);
    }
}