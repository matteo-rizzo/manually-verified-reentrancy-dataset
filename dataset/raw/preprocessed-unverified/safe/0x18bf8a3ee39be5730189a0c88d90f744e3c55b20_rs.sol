/**
 *Submitted for verification at Etherscan.io on 2021-09-19
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.7.6;



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/Context

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

// Part: OpenZeppelin/[email protected]/EnumerableSet

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


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/AccessControl

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

// Part: Uniswap/[email protected]/IWETH9

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}

// File: LixirRegistry.sol

/**
  @notice an access control contract with roles used to handle
  permissioning throughout the `Vault` and `Strategy` contracts.
 */
contract LixirRegistry is AccessControl {
  address public immutable uniV3Factory;
  IWETH9 public immutable weth9;

  /// king
  bytes32 public constant gov_role = keccak256('v1_gov_role');
  /// same privileges as `gov_role`
  bytes32 public constant delegate_role = keccak256('v1_delegate_role');
  /// configuring options within the strategy contract & vault
  bytes32 public constant strategist_role = keccak256('v1_strategist_role');
  /// can `emergencyExit` a vault
  bytes32 public constant pauser_role = keccak256('v1_pauser_role');
  /// can `rebalance` the vault via the strategy contract
  bytes32 public constant keeper_role = keccak256('v1_keeper_role');
  /// can `createVault`s from the factory contract
  bytes32 public constant deployer_role = keccak256('v1_deployer_role');
  /// verified vault in the registry
  bytes32 public constant vault_role = keccak256('v1_vault_role');
  /// can initialize vaults
  bytes32 public constant strategy_role = keccak256('v1_strategy_role');
  bytes32 public constant vault_implementation_role =
    keccak256('v1_vault_implementation_role');
  bytes32 public constant eth_vault_implementation_role =
    keccak256('v1_eth_vault_implementation_role');
  /// verified vault factory in the registry
  bytes32 public constant factory_role = keccak256('v1_factory_role');
  /// can `setPerformanceFee` on a vault
  bytes32 public constant fee_setter_role = keccak256('fee_setter_role');

  address public feeTo;

  address public emergencyReturn;

  uint24 public constant PERFORMANCE_FEE_PRECISION = 1e6;

  event FeeToChanged(address indexed previousFeeTo, address indexed newFeeTo);

  event EmergencyReturnChanged(
    address indexed previousEmergencyReturn,
    address indexed newEmergencyReturn
  );

  constructor(
    address _governance,
    address _delegate,
    address _uniV3Factory,
    address _weth9
  ) {
    uniV3Factory = _uniV3Factory;
    weth9 = IWETH9(_weth9);
    _setupRole(gov_role, _governance);
    _setupRole(delegate_role, _delegate);
    // gov is its own admin
    _setRoleAdmin(gov_role, gov_role);
    _setRoleAdmin(delegate_role, gov_role);
    _setRoleAdmin(strategist_role, delegate_role);
    _setRoleAdmin(fee_setter_role, delegate_role);
    _setRoleAdmin(pauser_role, delegate_role);
    _setRoleAdmin(keeper_role, delegate_role);
    _setRoleAdmin(deployer_role, delegate_role);
    _setRoleAdmin(factory_role, delegate_role);
    _setRoleAdmin(strategy_role, delegate_role);
    _setRoleAdmin(vault_implementation_role, delegate_role);
    _setRoleAdmin(eth_vault_implementation_role, delegate_role);
    _setRoleAdmin(vault_role, factory_role);
  }

  function addRole(bytes32 role, bytes32 roleAdmin) public {
    require(isGovOrDelegate(msg.sender));
    require(getRoleAdmin(role) == bytes32(0) && getRoleMemberCount(role) == 0);
    _setRoleAdmin(role, roleAdmin);
  }

  function isGovOrDelegate(address account) public view returns (bool) {
    return hasRole(gov_role, account) || hasRole(delegate_role, account);
  }

  function setFeeTo(address _feeTo) external {
    require(isGovOrDelegate(msg.sender));
    address previous = feeTo;
    feeTo = _feeTo;
    emit FeeToChanged(previous, _feeTo);
  }

  function setEmergencyReturn(address _emergencyReturn) external {
    require(isGovOrDelegate(msg.sender));
    address previous = emergencyReturn;
    emergencyReturn = _emergencyReturn;
    emit EmergencyReturnChanged(previous, _emergencyReturn);
  }
}