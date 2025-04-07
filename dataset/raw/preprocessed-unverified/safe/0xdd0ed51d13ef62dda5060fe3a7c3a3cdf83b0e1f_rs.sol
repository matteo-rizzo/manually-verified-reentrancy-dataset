/**
 *Submitted for verification at Etherscan.io on 2021-09-20
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.7.6;



// Part: IERC20Permit

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */


// Part: LixirRoles



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/Clones

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
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


// Part: Uniswap/[email protected]/IUniswapV3PoolActions

/// @title Permissionless pool actions
/// @notice Contains pool methods that can be called by anyone


// Part: Uniswap/[email protected]/IUniswapV3PoolDerivedState

/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.


// Part: Uniswap/[email protected]/IUniswapV3PoolEvents

/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool


// Part: Uniswap/[email protected]/IUniswapV3PoolImmutables

/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values


// Part: Uniswap/[email protected]/IUniswapV3PoolOwnerActions

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner


// Part: Uniswap/[email protected]/IUniswapV3PoolState

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction


// Part: ILixirVaultToken

interface ILixirVaultToken is IERC20, IERC20Permit {}

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

// Part: Uniswap/[email protected]/IUniswapV3Pool

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}

// Part: Uniswap/[email protected]/IWETH9

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}

// Part: ILixirVault

interface ILixirVault is ILixirVaultToken {
  function initialize(
    string memory name,
    string memory symbol,
    address _token0,
    address _token1,
    address _strategist,
    address _keeper,
    address _strategy
  ) external;

  function token0() external view returns (IERC20);

  function token1() external view returns (IERC20);

  function activeFee() external view returns (uint24);

  function activePool() external view returns (IUniswapV3Pool);

  function strategist() external view returns (address);

  function strategy() external view returns (address);

  function keeper() external view returns (address);

  function setKeeper(address _keeper) external;

  function setStrategist(address _strategist) external;

  function setStrategy(address _strategy) external;

  function setPerformanceFee(uint24 newFee) external;

  function emergencyExit() external;

  function unpause() external;

  function mainPosition()
    external
    view
    returns (int24 tickLower, int24 tickUpper);

  function rangePosition()
    external
    view
    returns (int24 tickLower, int24 tickUpper);

  function rebalance(
    int24 mainTickLower,
    int24 mainTickUpper,
    int24 rangeTickLower0,
    int24 rangeTickUpper0,
    int24 rangeTickLower1,
    int24 rangeTickUpper1,
    uint24 fee
  ) external;

  function withdraw(
    uint256 shares,
    uint256 amount0Min,
    uint256 amount1Min,
    address receiver,
    uint256 deadline
  ) external returns (uint256 amount0Out, uint256 amount1Out);

  function withdrawFrom(
    address withdrawer,
    uint256 shares,
    uint256 amount0Min,
    uint256 amount1Min,
    address recipient,
    uint256 deadline
  ) external returns (uint256 amount0Out, uint256 amount1Out);

  function deposit(
    uint256 amount0Desired,
    uint256 amount1Desired,
    uint256 amount0Min,
    uint256 amount1Min,
    address recipient,
    uint256 deadline
  )
    external
    returns (
      uint256 shares,
      uint256 amount0,
      uint256 amount1
    );

  function calculateTotalsFromTick(int24 virtualTick)
    external
    view
    returns (
      uint256 total0,
      uint256 total1,
      uint128 mL,
      uint128 rL
    );
}

// Part: LixirRegistry

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

// Part: ILixirStrategy



// Part: LixirBase

/**
  @notice An abstract contract that gives access to the registry
  and contains common modifiers for restricting access to
  functions based on role. 
 */
abstract contract LixirBase {
  LixirRegistry public immutable registry;

  constructor(address _registry) {
    registry = LixirRegistry(_registry);
  }

  modifier onlyRole(bytes32 role) {
    require(registry.hasRole(role, msg.sender));
    _;
  }
  modifier onlyGovOrDelegate {
    require(registry.isGovOrDelegate(msg.sender));
    _;
  }
  modifier hasRole(bytes32 role, address account) {
    require(registry.hasRole(role, account));
    _;
  }
}

// File: LixirFactory.sol

/**
  @notice Factory for creating new vaults.
 */
contract LixirFactory is LixirBase {
  using EnumerableSet for EnumerableSet.AddressSet;
  address public immutable weth9;

  mapping(address => mapping(address => EnumerableSet.AddressSet)) _vaults;

  mapping(address => address) public vaultToImplementation;

  event VaultCreated(
    address indexed token0,
    address indexed token1,
    address indexed vault_impl,
    address vault
  );

  constructor(address _registry) LixirBase(_registry) {
    weth9 = address(LixirRegistry(_registry).weth9());
  }

  // view functions

  /**
    @notice Grab the number of vaults for the pair from `vaultsLengthForPair`
    @param token0 address of the first token
    @param token1 address of the second token
    @param index the index of the vault.
    @return the address of the vault for the token pair at the given index 
   */
  function vault(
    address token0,
    address token1,
    uint256 index
  ) public view returns (address) {
    (token0, token1) = orderTokens(token0, token1);
    return _vaults[token0][token1].at(index);
  }

  /**
    @param token0 address of the first token
    @param token1 address of the second token
    @return number of vaults for the given token pair
   */
  function vaultsLengthForPair(address token0, address token1)
    external
    view
    returns (uint256)
  {
    (token0, token1) = orderTokens(token0, token1);
    return _vaults[token0][token1].length();
  }

  // external functions

  /** 
    @notice deploys a new vault for a pair of ERC20 tokens
    @param name ERC20 metadata extension name of the vault token
    @param symbol ERC20 metadata extension symbol of the vault token
    @param token0 address of the first ERC20 token
    @param token1 address of the second ERC20 token
    @param vaultImplementation address of the vault to clone
    @param strategist external address to be granted strategist role
    @param keeper external address to be given the keeper role
    @param strategy address of the strategy contract that will
    rebalance this vault's positions
    @return the address of the newly created vault
   */
  function createVault(
    string memory name,
    string memory symbol,
    address token0,
    address token1,
    address vaultImplementation,
    address strategist,
    address keeper,
    address strategy,
    bytes memory data
  )
    external
    onlyRole(LixirRoles.deployer_role)
    hasRole(LixirRoles.strategy_role, strategy)
    hasRole(LixirRoles.vault_implementation_role, vaultImplementation)
    returns (address)
  {
    require(registry.hasRole(LixirRoles.keeper_role, keeper));
    require(registry.hasRole(LixirRoles.strategist_role, strategist));
    require(
      token0 != weth9 && token1 != weth9,
      'Use eth vault creator instead'
    );
    return
      _createVault(
        name,
        symbol,
        token0,
        token1,
        vaultImplementation,
        strategist,
        keeper,
        strategy,
        data
      );
  }

  /** 
  @notice deploys a new vault for a WETH/ERC20 pair
  @dev ERC20 pairs require a different interface from ETH/ERC20
  vaults. Otherwise this is the same as `createVault`
  @param name ERC20 metadata extension name of the vault token
  @param symbol ERC20 metadata extension symbol of the vault toke
  @param token0 address of the first ERC20 token
  @param token1 address of the second ERC20 token
  @param ethVaultImplementation address of the ethVault to clone
  @param strategist address of a (likely) user account to be granted
  the strategist role
  @param keeper address of a user to be given the keeper role
  @param strategy address of the strategy contract that uses this
  vault
  @return the address of the newly created vault
  */
  function createVaultETH(
    string memory name,
    string memory symbol,
    address token0,
    address token1,
    address ethVaultImplementation,
    address strategist,
    address keeper,
    address strategy,
    bytes memory data
  )
    external
    onlyRole(LixirRoles.deployer_role)
    hasRole(LixirRoles.strategy_role, strategy)
    hasRole(LixirRoles.eth_vault_implementation_role, ethVaultImplementation)
    returns (address)
  {
    require(registry.hasRole(LixirRoles.keeper_role, keeper));
    require(registry.hasRole(LixirRoles.strategist_role, strategist));
    require(
      token0 == weth9 || token1 == weth9,
      'No weth, use regular vault creator'
    );
    return
      _createVault(
        name,
        symbol,
        token0,
        token1,
        ethVaultImplementation,
        strategist,
        keeper,
        strategy,
        data
      );
  }

  // internal functions

  function orderTokens(address token0, address token1)
    internal
    pure
    returns (address, address)
  {
    require(token0 != token1, 'Duplicate tokens');
    (token0, token1) = token0 < token1 ? (token0, token1) : (token1, token0);
    return (token0, token1);
  }


  function _createVault(
    string memory name,
    string memory symbol,
    address token0,
    address token1,
    address vaultImplementation,
    address strategist,
    address keeper,
    address strategy,
    bytes memory data
  ) internal returns (address) {
    (token0, token1) = orderTokens(token0, token1);
    bytes32 salt =
      keccak256(
        abi.encodePacked(token0, token1, _vaults[token0][token1].length())
      );
    ILixirVault _vault =
      ILixirVault(Clones.cloneDeterministic(vaultImplementation, salt));
    _vault.initialize(
      name,
      symbol,
      token0,
      token1,
      strategist,
      keeper,
      strategy
    );
    _vaults[token0][token1].add(address(_vault));
    vaultToImplementation[address(_vault)] = vaultImplementation;
    registry.grantRole(LixirRoles.vault_role, address(_vault));
    ILixirStrategy(strategy).initializeVault(_vault, data);
    emit VaultCreated(token0, token1, vaultImplementation, address(_vault));
    return address(_vault);
  }
}