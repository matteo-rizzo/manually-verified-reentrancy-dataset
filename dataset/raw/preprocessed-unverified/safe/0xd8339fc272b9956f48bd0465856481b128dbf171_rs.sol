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
 * Implementation of the {IExchange} interface.
 *
 * Ethereum XFI Exchange allows Ethereum accounts to convert their WINGS or ETH
 * to XFI and vice versa.
 *
 * Swap between WINGS and XFI happens with a 1:1 ratio.
 *
 * To enable swap the Exchange plays a role of a storage for WINGS tokens as
 * well as a minter of XFI Tokens.
 */
contract Exchange is AccessControl, ReentrancyGuard, IExchange {
    using SafeMath for uint256;

    IERC20 private immutable _wingsToken;
    IXFIToken private immutable _xfiToken;

    bool private _stopped = false;
    uint256 private _maxGasPrice;

    /**
     * Sets {DEFAULT_ADMIN_ROLE} (alias `owner`) role for caller.
     * Initializes Wings Token, XFI Token.
     */
    constructor (address wingsToken_, address xfiToken_) public {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _wingsToken = IERC20(wingsToken_);
        _xfiToken = IXFIToken(xfiToken_);
    }

    /**
     * Executes swap of WINGS-XFI pair.
     *
     * Emits a {SwapWINGSForXFI} event.
     *
     * Returns:
     * - `amounts` the input token amount and all subsequent output token amounts.
     *
     * Requirements:
     * - Contract is approved to spend `amountIn` of WINGS tokens.
     */
    function swapWINGSForXFI(uint256 amountIn) external override nonReentrant returns (uint256[] memory amounts) {
        _beforeSwap();

        uint256 amountOut = _calculateSwapAmount(amountIn);

        amounts = new uint256[](2);
        amounts[0] = amountIn;

        amounts[1] = amountOut;

        require(_wingsToken.transferFrom(msg.sender, address(this), amounts[0]), 'Exchange: WINGS transferFrom failed');
        require(_xfiToken.mint(msg.sender, amounts[amounts.length - 1]), 'Exchange: XFI mint failed');

        emit SwapWINGSForXFI(msg.sender, amounts[0], amounts[amounts.length - 1]);
    }

    /**
     * Starts all swaps.
     *
     * Emits a {SwapsStarted} event.
     *
     * Requirements:
     * - Caller must have owner role.
     * - Contract is stopped.
     */
    function startSwaps() external override returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Exchange: sender is not owner');
        require(_stopped, 'Exchange: swapping is not stopped');

        _stopped = false;

        emit SwapsStarted();

        return true;
    }

    /**
     * Stops all swaps.
     *
     * Emits a {SwapsStopped} event.
     *
     * Requirements:
     * - Caller must have owner role.
     * - Contract is not stopped.
     */
    function stopSwaps() external override returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Exchange: sender is not owner');
        require(!_stopped, 'Exchange: swapping is stopped');

        _stopped = true;

        emit SwapsStopped();

        return true;
    }

     /**
      * Withdraws `amount` of locked WINGS to a destination specified as `to`.
      *
      * Emits a {WINGSWithdrawal} event.
      *
      * Requirements:
      * - `to` cannot be the zero address.
      * - Caller must have owner role.
      * - Swapping has ended.
      */
    function withdrawWINGS(address to, uint256 amount) external override nonReentrant returns (bool) {
        require(to != address(0), 'Exchange: withdraw to the zero address');
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Exchange: sender is not owner');
        require(block.timestamp > _xfiToken.vestingEnd(), 'Exchange: swapping has not ended');

        require(_wingsToken.transfer(to, amount), 'Exchange: WINGS transfer failed');

        emit WINGSWithdrawal(to, amount);

        return true;
    }

    /**
     * Sets maximum gas price for swap to `maxGasPrice_`.
     *
     * Emits a {MaxGasPriceUpdated} event.
     *
     * Requirements:
     * - Caller must have owner role.
     */
    function setMaxGasPrice(uint256 maxGasPrice_) external override returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Exchange: sender is not owner');

        _maxGasPrice = maxGasPrice_;

        emit MaxGasPriceChanged(maxGasPrice_);

        return true;
    }

    /**
     * Returns the address of the Wings Token.
     */
    function wingsToken() external view override returns (address) {
        return address(_wingsToken);
    }

    /**
     * Returns the address of the XFI Token.
     */
    function xfiToken() external view override returns (address) {
        return address(_xfiToken);
    }

    /**
     * Returns `amount` XFI estimation that user will receive per day after the swap of WINGS-XFI pair.
     */
    function estimateSwapWINGSForXFIPerDay(uint256 amountIn) external view override returns (uint256 amount) {
        uint256[] memory amounts = estimateSwapWINGSForXFI(amountIn);

        amount = amounts[1].div(_xfiToken.VESTING_DURATION_DAYS());
    }


    /**
     * Returns whether swapping is stopped.
     */
    function isSwappingStopped() external view override returns (bool) {
        return _stopped;
    }

    /**
     * Returns maximum gas price for swap. If set, any swap transaction that has
     * a gas price exceeding this limit will be reverted.
     */
    function maxGasPrice() external view override returns (uint256) {
        return _maxGasPrice;
    }

    /**
     * Returns `amounts` estimation for swap of WINGS-XFI pair.
     */
    function estimateSwapWINGSForXFI(uint256 amountIn) public view override returns (uint256[] memory amounts) {
        amounts = new uint256[](2);
        amounts[0] = amountIn;

        uint256 amountOut = _calculateSwapAmount(amounts[0]);

        amounts[1] = amountOut;
    }

    /**
     * Executes before swap hook.
     *
     * Requirements:
     * - Contract is not stopped.
     * - Swapping has started.
     * - Swapping hasn't ended.
     * - Gas price doesn't exceed the limit (if set).
     */
    function _beforeSwap() internal view {
        require(!_stopped, 'Exchange: swapping is stopped');
        require(block.timestamp >= _xfiToken.vestingStart(), 'Exchange: swapping has not started');
        require(block.timestamp <= _xfiToken.vestingEnd(), 'Exchange: swapping has ended');

        if (_maxGasPrice > 0) {
            require(tx.gasprice <= _maxGasPrice, 'Exchange: gas price exceeds the limit');
        }
    }

    /**
     * Convert input amount to the output XFI amount using timed swap ratio.
     */
    function _calculateSwapAmount(uint256 amount) internal view returns (uint256) {
        require(amount >= 182, 'Exchange: minimum XFI swap output amount is 182 * 10 ** -18');

        if (block.timestamp < _xfiToken.vestingEnd()) {
            uint256 amountOut = _xfiToken.convertAmountUsingReverseRatio(amount);

            return amountOut;
        } else {
            return 0;
        }
    }
}