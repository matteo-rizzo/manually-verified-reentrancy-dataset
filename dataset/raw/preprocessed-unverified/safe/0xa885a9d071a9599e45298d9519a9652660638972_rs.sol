/**
 *Submitted for verification at Etherscan.io on 2020-10-14
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;


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
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 


// 


// 
/**
 * This staking contract allows to stake XFI and Uniswap Liquidity Pool Tokens
 * (LPT).
 */
contract Staking is IStaking, ReentrancyGuard, AccessControl {
    using SafeMath for uint256;

    IERC20 private immutable _token;
    IUniswapV2Pair private _xfiEthPair;

    bool private _isXfiUnstakingDisabled;
    bool private _isLptStakingEnabled;

    struct Account {
        bytes32 account;
        uint256 xfiBalance;
        uint256 lptBalance;
        uint256 unstakedAt;
    }

    mapping(address => Account) private _stakers;
    mapping(bytes32 => bool) private _accounts;

    /**
     * Sets {DEFAULT_ADMIN_ROLE} (alias `owner`) role for caller.
     * Initializes XFI Token and XFI-ETH Uniswap pair.
     */
    constructor(address xfiToken_, address xfiEthPair_) public {
        if (xfiEthPair_ != address(0)) {
            _checkXFIETHPair(xfiToken_, xfiEthPair_);
        }

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _token = IERC20(xfiToken_);
        _xfiEthPair = IUniswapV2Pair(xfiEthPair_);
    }

    /**
     * Connect Dfinance and Ethereum accounts.
     *
     * Emits a {Connection} event.
     *
     * Requirements:
     * - `account` is not the zero bytes.
     * - Ethereum account isn't connected.
     * - Dfinance account isn't connected.
     */
    function connect(bytes32 account) external override returns (bool) {
        require(account != bytes32(0), 'Staking: Dfinance account can not be the zero bytes');
        require(_stakers[msg.sender].account == bytes32(0), 'Staking: Ethereum account already connected');
        require(!_accounts[account], 'Staking: Dfinance account already connected');

        _accounts[account] = true;
        _stakers[msg.sender] = Account(account, 0, 0, 0);

        emit Connection(account);

        return true;
    }

    /**
     * Increase XFI stake.
     *
     * Emits a {Stake} event.
     *
     * Requirements:
     * - `amount` is greater than zero.
     * - Staking is not disabled.
     * - Dfinance account is connected.
     * - Account didn't unstake.
     */
    function addXFI(uint256 amount) external override nonReentrant returns (bool) {
        require(amount > 0, 'Staking: amount must be greater than zero');
        require(!_isXfiUnstakingDisabled, 'Staking: staking is disabled');
        require(_stakers[msg.sender].account != bytes32(0), 'Staking: Dfinance account is not connected');
        require(_stakers[msg.sender].unstakedAt == 0, 'Staking: unstaked account');

        _stakers[msg.sender].xfiBalance = _stakers[msg.sender].xfiBalance.add(amount);

        require(_token.transferFrom(msg.sender, address(this), amount), 'Staking: XFI transferFrom failed');

        emit Stake(_stakers[msg.sender].account, amount, 'XFI');

        return true;
    }

    /**
     * Increase LPT stake.
     *
     * Emits a {Stake} event.
     *
     * Requirements:
     * - `amount` is greater than zero.
     * - XFI-ETH pair must be set.
     * - LPT staking enabled.
     * - Staking is not disabled.
     * - Dfinance account is connected.
     * - Account didn't unstake.
     */
    function addLPT(uint256 amount) external override nonReentrant returns (bool) {
        require(amount > 0, 'Staking: amount must be greater than zero');
        require(address(_xfiEthPair) != address(0), 'Staking: XFI-ETH pair is not set');
        require(_isLptStakingEnabled, 'Staking: LPT staking is not enabled');
        require(!_isXfiUnstakingDisabled, 'Staking: staking is disabled');
        require(_stakers[msg.sender].account != bytes32(0), 'Staking: Dfinance account is not connected');
        require(_stakers[msg.sender].unstakedAt == 0, 'Staking: unstaked account');

        _stakers[msg.sender].lptBalance = _stakers[msg.sender].lptBalance.add(amount);

        require(_xfiEthPair.transferFrom(msg.sender, address(this), amount), 'Staking: LPT transferFrom failed');

        emit Stake(_stakers[msg.sender].account, amount, 'LPT');

        return true;
    }

    /**
     * Unstake.
     *
     * Emits an {Unstake} event.
     *
     * Requirements:
     * - Dfinance account is connected.
     * - Account didn't unstake.
     */
    function unstake() external override returns (bool) {
        require(_stakers[msg.sender].account != bytes32(0), 'Staking: Dfinance account is not connected');
        require(_stakers[msg.sender].unstakedAt == 0, 'Staking: unstaked account');

        _stakers[msg.sender].unstakedAt = block.timestamp;

        if (!_isXfiUnstakingDisabled) {
            uint256 unstakedXfiAmount = _stakers[msg.sender].xfiBalance;

            if (unstakedXfiAmount > 0) {
                _stakers[msg.sender].xfiBalance = 0;
                require(_token.transfer(msg.sender, unstakedXfiAmount), 'Staking: XFI transfer failed');
            }
        }

        uint256 unstakedLptAmount = _stakers[msg.sender].lptBalance;

        if (unstakedLptAmount > 0) {
            _stakers[msg.sender].lptBalance = 0;
            require(_xfiEthPair.transfer(msg.sender, unstakedLptAmount), 'Staking: LPT transfer failed');
        }

        emit Unstake(_stakers[msg.sender].account);

        return true;
    }

    /**
     * Disables XFI unstaking.
     *
     * Emits a {UnstakingDisabled} event.
     *
     * Requirements:
     * - Sender has the owner access role.
     * - Unstaking is not disabled.
     */
    function disableXFIUnstaking() external override returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), 'Staking: sender is not owner');
        require(!_isXfiUnstakingDisabled, 'Staking: XFI unstaking is already disabled');

        _isXfiUnstakingDisabled = true;

        emit UnstakingDisabled('XFI');

        return true;
    }

    /**
     * Migrate XFI to PegZone.
     *
     * Requirements:
     * - Sender has the owner access role.
     * - `pegZone` is not the zero address.
     * - XFI unstaking is disabled.
     * - Positive XFI balance.
     */
    function migrateXFI(address pegZone) external override returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), 'Staking: sender is not owner');
        require(pegZone != address(0), 'Staking: pegZone is the zero address');
        require(_isXfiUnstakingDisabled, 'Staking: XFI unstaking is not disabled');

        uint256 xfiBalance = _token.balanceOf(address(this));

        require(xfiBalance > 0, 'Staking: XFI balance is zero');

        require(_token.transfer(pegZone, xfiBalance), 'Staking: XFI transfer failed');

        emit Migration(xfiBalance, 'XFI');

        return true;
    }

    /**
     * Sets XFI-ETH pair (aka LPT address).
     *
     * Requirements:
     * - Sender has the owner access role.
     * - xfiEthPairAddress has XFI token.
     */
    function setXFIETHPair(address xfiEthPairAddress) external override returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), 'Staking: sender is not owner');
        _checkXFIETHPair(address(_token), xfiEthPairAddress);

        _xfiEthPair = IUniswapV2Pair(xfiEthPairAddress);

        return true;
    }

    /**
     * Enables LPT staking.
     *
     * Requirements:
     * - Sender has the owner access role.
     * - LPT staking isn't enabled.
     * - XFI-ETH pair must be set.
     */
    function enableLPTStaking() external override returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), 'Staking: sender is not owner');
        require(address(_xfiEthPair) != address(0), 'Staking: XFI-ETH pair is not set');
        require(!_isLptStakingEnabled, 'Staking: LPT staking enabled');

        _isLptStakingEnabled = true;

        return true;
    }

    /**
     * Returns the address of the XFI Token.
     */
    function token() external override view returns (address) {
        return address(_token);
    }

    /**
     * Returns the address of the Uniswap XFI-ETH pair.
     */
    function XFIETHPair() external view override returns (address) {
        return address(_xfiEthPair);
    }

    /**
     * Returns whether `account` is an existent staker.
     */
    function isStaker(bytes32 account) external override view returns (bool) {
        return _accounts[account];
    }

    /**
     * Returns properties of the staker account object using Ethereum `account` address.
     *
     * Returned tuple definition:
     * [0] - bytes32 XFI address.
     * [1] - uint256 XFI balance.
     * [2] - uint256 LPT balance.
     * [3] - uint256 unstaked at (timestamp).
     */
    function staker(address account) external view override returns (bytes32, uint256, uint256, uint256) {
        Account memory accountObject = _stakers[account];

        return (
            accountObject.account,
            accountObject.xfiBalance,
            accountObject.lptBalance,
            accountObject.unstakedAt
        );
    }

    /**
     * Returns whether XFI unstaking is disabled.
     */
    function isXFIUnstakingDisabled() external view override returns (bool) {
        return _isXfiUnstakingDisabled;
    }

    /**
     * Returns the ratio of LPT to XFI.
     *
     * Returned tuple definition:
     * - uint256 lptTotalSupply - LPT total supply.
     * - uint256 xfiReserve - XFI reserve.
     */
    function LPTToXFIRatio() external view override returns (uint256 lptTotalSupply, uint256 xfiReserve) {
        lptTotalSupply = _xfiEthPair.totalSupply();

        uint112 xfiReserve_;

        if (_xfiEthPair.token0() == address(_token)) {
            (xfiReserve_, , ) = _xfiEthPair.getReserves();
        } else {
            (, xfiReserve_, ) = _xfiEthPair.getReserves();
        }

        xfiReserve = uint256(xfiReserve_);
    }

    /**
     * Returns whether LPT staking is enabled.
     */
    function isLPTStakingEnabled() external view override returns (bool) {
        return _isLptStakingEnabled;
    }

    /**
     * Make sure the pair has XFI token reserve.
     */
    function _checkXFIETHPair(address xfiToken_, address xfiEthPairAddress) internal view {
        IUniswapV2Pair pair = IUniswapV2Pair(xfiEthPairAddress);

        require(
            (
                (pair.token0() == xfiToken_) || (pair.token1() == xfiToken_)
            ),
            'Staking: invalid XFI-ETH pair address'
            );
    }
}