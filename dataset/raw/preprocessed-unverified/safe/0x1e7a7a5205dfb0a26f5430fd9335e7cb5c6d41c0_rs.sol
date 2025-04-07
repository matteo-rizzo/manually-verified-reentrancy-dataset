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


// Part: LixirErrors



// Part: LixirRoles



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


// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: SafeCast

/// @title Safe casting methods
/// @notice Contains methods for safely casting between types


// Part: Uniswap/[email protected]/FixedPoint128

/// @title FixedPoint128
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)


// Part: Uniswap/[email protected]/FixedPoint96

/// @title FixedPoint96
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)
/// @dev Used in SqrtPriceMath.sol


// Part: Uniswap/[email protected]/FullMath

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits


// Part: Uniswap/[email protected]/IUniswapV3MintCallback

/// @title Callback for IUniswapV3PoolActions#mint
/// @notice Any contract that calls IUniswapV3PoolActions#mint must implement this interface


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


// Part: Uniswap/[email protected]/LowGasSafeMath

/// @title Optimized overflow and underflow safe math operations
/// @notice Contains methods for doing math operations that revert on overflow or underflow for minimal gas cost


// Part: Uniswap/[email protected]/TickMath

/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128


// Part: Uniswap/[email protected]/UnsafeMath

/// @title Math functions that do not check inputs or outputs
/// @notice Contains methods that perform common math functions but do not do any overflow or underflow checks


// Part: Uniswap/[email protected]/PoolAddress

/// @title Provides functions for deriving a pool address from the factory, tokens, and the fee


// Part: Uniswap/[email protected]/PositionKey



// Part: Uniswap/[email protected]/TransferHelper



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

// Part: OpenZeppelin/[email protected]/Initializable

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
        return !Address.isContract(address(this));
    }
}

// Part: OpenZeppelin/[email protected]/Pausable

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
    constructor () {
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
}

// Part: SqrtPriceMath

/// @title Functions based on Q64.96 sqrt price and liquidity
/// @notice Contains the math that uses square root of price as a Q64.96 and liquidity to compute deltas


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

// Part: Uniswap/[email protected]/LiquidityAmounts

/// @title Liquidity amount functions
/// @notice Provides functions for computing liquidity amounts from token amounts and prices


// Part: EIP712Initializable

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712Initializable is Initializable {
  /* solhint-disable var-name-mixedcase */
  bytes32 private _HASHED_NAME;
  bytes32 private immutable _HASHED_VERSION;
  bytes32 private immutable _TYPE_HASH;

  constructor(string memory version) {
    _HASHED_VERSION = keccak256(bytes(version));
    _TYPE_HASH = keccak256(
      'EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'
    );
  }

  /* solhint-enable var-name-mixedcase */

  /**
   * @dev Initializes the domain separator and parameter caches.
   *
   * The meaning of `name` and `version` is specified in
   * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
   *
   * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
   * - `version`: the current major version of the signing domain.
   *
   * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
   * contract upgrade].
   */
  function __EIP712__initialize(string memory name) internal initializer {
    _HASHED_NAME = keccak256(bytes(name));
  }

  /**
   * @dev Returns the domain separator for the current chain.
   */
  function _domainSeparatorV4() internal view virtual returns (bytes32) {
    return
      keccak256(
        abi.encode(
          _TYPE_HASH,
          _HASHED_NAME,
          _HASHED_VERSION,
          _getChainId(),
          address(this)
        )
      );
  }

  /**
   * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
   * function returns the hash of the fully encoded EIP712 message for this domain.
   *
   * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
   *
   * ```solidity
   * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
   *     keccak256("Mail(address to,string contents)"),
   *     mailTo,
   *     keccak256(bytes(mailContents))
   * )));
   * address signer = ECDSA.recover(digest, signature);
   * ```
   */
  function _hashTypedDataV4(bytes32 structHash)
    internal
    view
    virtual
    returns (bytes32)
  {
    return
      keccak256(abi.encodePacked('\x19\x01', _domainSeparatorV4(), structHash));
  }

  function _getChainId() private view returns (uint256 chainId) {
    // Silence state mutability warning without generating bytecode.
    // See https://github.com/ethereum/solidity/issues/10090#issuecomment-741789128 and
    // https://github.com/ethereum/solidity/issues/2691
    this;

    // solhint-disable-next-line no-inline-assembly
    assembly {
      chainId := chainid()
    }
  }
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

// Part: LixirVaultToken

/**
 * @title Highly opinionated token implementation
 * @author Balancer Labs
 * @dev
 * - Includes functions to increase and decrease allowance as a workaround
 *   for the well-known issue with `approve`:
 *   https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
 * - Allows for 'infinite allowance', where an allowance of 0xff..ff is not
 *   decreased by calls to transferFrom
 * - Lets a token holder use `transferFrom` to send their own tokens,
 *   without first setting allowance
 * - Emits 'Approval' events whenever allowance is changed by `transferFrom`
 */
contract LixirVaultToken is ILixirVaultToken, EIP712Initializable {
  using SafeMath for uint256;

  // State variables

  uint8 private constant _DECIMALS = 18;

  mapping(address => uint256) private _balance;
  mapping(address => mapping(address => uint256)) _allowance;
  uint256 private _totalSupply;

  string private _name;
  string private _symbol;

  mapping(address => uint256) private _nonces;

  // solhint-disable-next-line var-name-mixedcase
  bytes32 private immutable _PERMIT_TYPE_HASH =
    keccak256(
      'Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)'
    );

  constructor() EIP712Initializable('1') {}

  // Function declarations

  function __LixirVaultToken__initialize(
    string memory tokenName,
    string memory tokenSymbol
  ) internal initializer {
    __EIP712__initialize(tokenName);
    _name = tokenName;
    _symbol = tokenSymbol;
  }

  // External functions

  function allowance(address owner, address spender)
    public
    view
    override
    returns (uint256)
  {
    return _allowance[owner][spender];
  }

  function balanceOf(address account) external view override returns (uint256) {
    return _balance[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    _setAllowance(msg.sender, spender, amount);

    return true;
  }

  function increaseApproval(address spender, uint256 amount)
    external
    returns (bool)
  {
    _setAllowance(
      msg.sender,
      spender,
      _allowance[msg.sender][spender].add(amount)
    );

    return true;
  }

  function decreaseApproval(address spender, uint256 amount)
    external
    returns (bool)
  {
    uint256 currentAllowance = _allowance[msg.sender][spender];

    if (amount >= currentAllowance) {
      _setAllowance(msg.sender, spender, 0);
    } else {
      _setAllowance(msg.sender, spender, currentAllowance.sub(amount));
    }

    return true;
  }

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    _move(msg.sender, recipient, amount);

    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    uint256 currentAllowance = _allowance[sender][msg.sender];
    LixirErrors.require_INSUFFICIENT_ALLOWANCE(
      msg.sender == sender || currentAllowance >= amount
    );
    _move(sender, recipient, amount);

    if (msg.sender != sender && currentAllowance != type(uint256).max) {
      // Because of the previous require, we know that if msg.sender != sender then currentAllowance >= amount
      _setAllowance(sender, msg.sender, currentAllowance - amount);
    }

    return true;
  }

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public virtual override {
    // solhint-disable-next-line not-rely-on-time
    LixirErrors.require_PERMIT_EXPIRED(block.timestamp <= deadline);

    uint256 nonce = _nonces[owner];

    bytes32 structHash =
      keccak256(
        abi.encode(_PERMIT_TYPE_HASH, owner, spender, value, nonce, deadline)
      );

    bytes32 hash = _hashTypedDataV4(structHash);

    address signer = ecrecover(hash, v, r, s);
    LixirErrors.require_INVALID_SIGNATURE(
      signer != address(0) && signer == owner
    );

    _nonces[owner] = nonce + 1;
    _setAllowance(owner, spender, value);
  }

  // Public functions

  function name() public view returns (string memory) {
    return _name;
  }

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  function decimals() public pure returns (uint8) {
    return _DECIMALS;
  }

  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  function nonces(address owner) external view override returns (uint256) {
    return _nonces[owner];
  }

  // solhint-disable-next-line func-name-mixedcase
  function DOMAIN_SEPARATOR() external view override returns (bytes32) {
    return _domainSeparatorV4();
  }

  // Internal functions

  function _beforeMintCallback(address recipient, uint256 amount)
    internal
    virtual
  {}

  function _mintPoolTokens(address recipient, uint256 amount) internal {
    _beforeMintCallback(recipient, amount);
    _balance[recipient] = _balance[recipient].add(amount);
    _totalSupply = _totalSupply.add(amount);
    emit Transfer(address(0), recipient, amount);
  }

  function _burnPoolTokens(address sender, uint256 amount) internal {
    uint256 currentBalance = _balance[sender];
    LixirErrors.require_INSUFFICIENT_BALANCE(currentBalance >= amount);

    _balance[sender] = currentBalance - amount;
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(sender, address(0), amount);
  }

  function _move(
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    uint256 currentBalance = _balance[sender];
    LixirErrors.require_INSUFFICIENT_BALANCE(currentBalance >= amount);
    // Prohibit transfers to the zero address to avoid confusion with the
    // Transfer event emitted by `_burnPoolTokens`
    LixirErrors.require_XFER_ZERO_ADDRESS(recipient != address(0));

    _balance[sender] = currentBalance - amount;
    _balance[recipient] = _balance[recipient].add(amount);

    emit Transfer(sender, recipient, amount);
  }

  function _setAllowance(
    address owner,
    address spender,
    uint256 amount
  ) internal {
    _allowance[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}

// File: LixirVault.sol

contract LixirVault is
  ILixirVault,
  LixirVaultToken,
  LixirBase,
  IUniswapV3MintCallback,
  Pausable
{
  using LowGasSafeMath for uint256;
  using SafeCast for uint256;
  using SafeCast for int256;
  using SafeCast for uint128;

  IERC20 public override token0;
  IERC20 public override token1;

  uint24 public override activeFee;
  IUniswapV3Pool public override activePool;

  address public override strategy;
  address public override strategist;
  address public override keeper;

  Position public override mainPosition;
  Position public override rangePosition;

  uint24 public performanceFee;

  uint24 immutable PERFORMANCE_FEE_PRECISION;

  address immutable uniV3Factory;

  event Deposit(
    address indexed depositor,
    address indexed recipient,
    uint256 shares,
    uint256 amount0In,
    uint256 amount1In,
    uint256 total0,
    uint256 total1
  );

  event Withdraw(
    address indexed withdrawer,
    address indexed recipient,
    uint256 shares,
    uint256 amount0Out,
    uint256 amount1Out
  );

  event Rebalance(
    int24 mainTickLower,
    int24 mainTickUpper,
    int24 rangeTickLower,
    int24 rangeTickUpper,
    uint24 newFee,
    uint256 total0,
    uint256 total1
  );

  event PerformanceFeeSet(uint24 oldFee, uint24 newFee);

  event StrategySet(address oldStrategy, address newStrategy);

  struct DepositPositionData {
    uint128 LDelta;
    int24 tickLower;
    int24 tickUpper;
  }

  enum POSITION {MAIN, RANGE}

  // details about the uniswap position
  struct Position {
    // the tick range of the position
    int24 tickLower;
    int24 tickUpper;
  }

  constructor(address _registry) LixirBase(_registry) {
    PERFORMANCE_FEE_PRECISION = LixirRegistry(_registry)
      .PERFORMANCE_FEE_PRECISION();
    uniV3Factory = LixirRegistry(_registry).uniV3Factory();
  }

  /**
    @notice sets fields in the contract and initializes the `LixirVaultToken`
   */
  function initialize(
    string memory name,
    string memory symbol,
    address _token0,
    address _token1,
    address _strategist,
    address _keeper,
    address _strategy
  )
    public
    virtual
    override
    hasRole(LixirRoles.strategist_role, _strategist)
    hasRole(LixirRoles.keeper_role, _keeper)
    hasRole(LixirRoles.strategy_role, _strategy)
    initializer
  {
    require(_token0 < _token1);
    __LixirVaultToken__initialize(name, symbol);
    token0 = IERC20(_token0);
    token1 = IERC20(_token1);
    strategist = _strategist;
    keeper = _keeper;
    strategy = _strategy;
  }

  modifier onlyStrategist() {
    require(msg.sender == strategist);
    _;
  }

  modifier onlyStrategy() {
    require(msg.sender == strategy);
    _;
  }

  modifier notExpired(uint256 deadline) {
    require(block.timestamp <= deadline, 'Expired');
    _;
  }

  /**
    @dev calculates shares, totals, etc. to mint the proper amount of `LixirVaultToken`s
    to `recipient`
   */
  function _depositStepOne(
    uint256 amount0Desired,
    uint256 amount1Desired,
    uint256 amount0Min,
    uint256 amount1Min,
    address recipient
  )
    internal
    returns (
      DepositPositionData memory mainData,
      DepositPositionData memory rangeData,
      uint256 shares,
      uint256 amount0In,
      uint256 amount1In,
      uint256 total0,
      uint256 total1
    )
  {
    uint256 _totalSupply = totalSupply();

    mainData = DepositPositionData({
      LDelta: 0,
      tickLower: mainPosition.tickLower,
      tickUpper: mainPosition.tickUpper
    });

    rangeData = DepositPositionData({
      LDelta: 0,
      tickLower: rangePosition.tickLower,
      tickUpper: rangePosition.tickUpper
    });

    if (_totalSupply == 0) {
      (shares, mainData.LDelta, amount0In, amount1In) = calculateInitialDeposit(
        amount0Desired,
        amount1Desired
      );
      total0 = amount0In;
      total1 = amount1In;
    } else {
      uint128 mL;
      uint128 rL;
      {
        (uint160 sqrtRatioX96, int24 tick) = getSqrtRatioX96AndTick();
        (total0, total1, mL, rL) = _calculateTotals(
          sqrtRatioX96,
          tick,
          mainData,
          rangeData
        );
      }

      (shares, amount0In, amount1In) = calcSharesAndAmounts(
        amount0Desired,
        amount1Desired,
        total0,
        total1,
        _totalSupply
      );
      mainData.LDelta = uint128(FullMath.mulDiv(mL, shares, _totalSupply));
      rangeData.LDelta = uint128(FullMath.mulDiv(rL, shares, _totalSupply));
    }

    LixirErrors.require_INSUFFICIENT_OUTPUT_AMOUNT(
      amount0Min <= amount0In && amount1Min <= amount1In
    );

    _mintPoolTokens(recipient, shares);
  }

  /**
    @dev this function deposits the tokens into the UniV3 pool
   */
  function _depositStepTwo(
    DepositPositionData memory mainData,
    DepositPositionData memory rangeData,
    address recipient,
    uint256 shares,
    uint256 amount0In,
    uint256 amount1In,
    uint256 total0,
    uint256 total1
  ) internal {
    uint128 mLDelta = mainData.LDelta;
    if (0 < mLDelta) {
      activePool.mint(
        address(this),
        mainData.tickLower,
        mainData.tickUpper,
        mLDelta,
        ''
      );
    }
    uint128 rLDelta = rangeData.LDelta;
    if (0 < rLDelta) {
      activePool.mint(
        address(this),
        rangeData.tickLower,
        rangeData.tickUpper,
        rLDelta,
        ''
      );
    }
    emit Deposit(
      address(msg.sender),
      address(recipient),
      shares,
      amount0In,
      amount1In,
      total0,
      total1
    );
  }

  /**
    @notice deposit's the callers ERC20 tokens into the vault, mints them
    `LixirVaultToken`s, and adds their liquidity to the UniswapV3 pool.
    @param amount0Desired Amount of token 0 desired by user
    @param amount1Desired Amount of token 1 desired by user
    @param amount0Min Minimum amount of token 0 desired by user
    @param amount1Min Minimum amount of token 1 desired by user
    @param recipient The address for which the liquidity will be created
    @param deadline Blocktimestamp that this must execute before
    @return shares
    @return amount0In how much token0 was actually deposited
    @return amount1In how much token1 was actually deposited
   */
  function deposit(
    uint256 amount0Desired,
    uint256 amount1Desired,
    uint256 amount0Min,
    uint256 amount1Min,
    address recipient,
    uint256 deadline
  )
    external
    override
    whenNotPaused
    notExpired(deadline)
    returns (
      uint256 shares,
      uint256 amount0In,
      uint256 amount1In
    )
  {
    DepositPositionData memory mainData;
    DepositPositionData memory rangeData;
    uint256 total0;
    uint256 total1;
    (
      mainData,
      rangeData,
      shares,
      amount0In,
      amount1In,
      total0,
      total1
    ) = _depositStepOne(
      amount0Desired,
      amount1Desired,
      amount0Min,
      amount1Min,
      recipient
    );
    if (0 < amount0In) {
      // token0.transferFrom(msg.sender, address(this), amount0In);
      TransferHelper.safeTransferFrom(
        address(token0),
        msg.sender,
        address(this),
        amount0In
      );
    }
    if (0 < amount1In) {
      // token1.transferFrom(msg.sender, address(this), amount1In);
      TransferHelper.safeTransferFrom(
        address(token1),
        msg.sender,
        address(this),
        amount1In
      );
    }
    _depositStepTwo(
      mainData,
      rangeData,
      recipient,
      shares,
      amount0In,
      amount1In,
      total0,
      total1
    );
  }

  function _withdrawStep(
    address withdrawer,
    uint256 shares,
    uint256 amount0Min,
    uint256 amount1Min,
    address recipient
  ) internal returns (uint256 amount0Out, uint256 amount1Out) {
    uint256 _totalSupply = totalSupply();
    _burnPoolTokens(withdrawer, shares); // does balance check

    (, int24 tick, , , , , ) = activePool.slot0();

    // if withdrawing everything, then burn and collect the all positions
    // else, calculate their share and return it
    if (shares == _totalSupply) {
      if (!paused()) {
        burnCollectPositions();
      }
      amount0Out = token0.balanceOf(address(this));
      amount1Out = token1.balanceOf(address(this));
    } else {
      {
        uint256 e0 = token0.balanceOf(address(this));
        amount0Out = e0 > 0 ? FullMath.mulDiv(e0, shares, _totalSupply) : 0;
        uint256 e1 = token1.balanceOf(address(this));
        amount1Out = e1 > 0 ? FullMath.mulDiv(e1, shares, _totalSupply) : 0;
      }
      if (!paused()) {
        {
          (uint256 ma0Out, uint256 ma1Out) =
            burnAndCollect(mainPosition, tick, shares, _totalSupply);
          amount0Out = amount0Out.add(ma0Out);
          amount1Out = amount1Out.add(ma1Out);
        }
        {
          (uint256 ra0Out, uint256 ra1Out) =
            burnAndCollect(rangePosition, tick, shares, _totalSupply);
          amount0Out = amount0Out.add(ra0Out);
          amount1Out = amount1Out.add(ra1Out);
        }
      }
    }
    LixirErrors.require_INSUFFICIENT_OUTPUT_AMOUNT(
      amount0Min <= amount0Out && amount1Min <= amount1Out
    );
    emit Withdraw(
      address(msg.sender),
      address(recipient),
      shares,
      amount0Out,
      amount1Out
    );
  }

  modifier canSpend(address withdrawer, uint256 shares) {
    uint256 currentAllowance = _allowance[withdrawer][msg.sender];
    LixirErrors.require_INSUFFICIENT_ALLOWANCE(
      msg.sender == withdrawer || currentAllowance >= shares
    );

    if (msg.sender != withdrawer && currentAllowance != uint256(-1)) {
      // Because of the previous require, we know that if msg.sender != withdrawer then currentAllowance >= shares
      _setAllowance(withdrawer, msg.sender, currentAllowance - shares);
    }
    _;
  }

  /**
  @notice withdraws the desired shares from the vault on behalf of another account
  @dev same as `withdraw` except this can be called from an `approve`d address
  @param withdrawer the address to withdraw from
  @param shares number of shares to withdraw
  @param amount0Min Minimum amount of token 0 desired by user
  @param amount1Min Minimum amount of token 1 desired by user
  @param recipient address to recieve token0 and token1 withdrawals
  @param deadline blocktimestamp that this must execute by
  @return amount0Out how much token0 was actually withdrawn
  @return amount1Out how much token1 was actually withdrawn
  */
  function withdrawFrom(
    address withdrawer,
    uint256 shares,
    uint256 amount0Min,
    uint256 amount1Min,
    address recipient,
    uint256 deadline
  )
    external
    override
    canSpend(withdrawer, shares)
    returns (uint256 amount0Out, uint256 amount1Out)
  {
    (amount0Out, amount1Out) = _withdraw(
      withdrawer,
      shares,
      amount0Min,
      amount1Min,
      recipient,
      deadline
    );
  }

  /**
    @notice withdraws the desired shares from the vault and transfers to caller.
    @dev `_withdrawStep` calculates how much the caller is owed
    @dev `_withdraw` transfers the tokens to the caller
    @param shares number of shares to withdraw
    @param amount0Min Minimum amount of token 0 desired by user
    @param amount1Min Minimum amount of token 1 desired by user
    @param recipient address to recieve token0 and token1 withdrawals
    @param deadline blocktimestamp that this must execute by
    @return amount0Out how much token0 was actually withdrawn
    @return amount1Out how much token1 was actually withdrawn
   */
  function withdraw(
    uint256 shares,
    uint256 amount0Min,
    uint256 amount1Min,
    address recipient,
    uint256 deadline
  ) external override returns (uint256 amount0Out, uint256 amount1Out) {
    (amount0Out, amount1Out) = _withdraw(
      msg.sender,
      shares,
      amount0Min,
      amount1Min,
      recipient,
      deadline
    );
  }

  function _withdraw(
    address withdrawer,
    uint256 shares,
    uint256 amount0Min,
    uint256 amount1Min,
    address recipient,
    uint256 deadline
  )
    internal
    notExpired(deadline)
    returns (uint256 amount0Out, uint256 amount1Out)
  {
    (amount0Out, amount1Out) = _withdrawStep(
      withdrawer,
      shares,
      amount0Min,
      amount1Min,
      recipient
    );
    if (0 < amount0Out) {
      TransferHelper.safeTransfer(address(token0), recipient, amount0Out);
    }
    if (0 < amount1Out) {
      TransferHelper.safeTransfer(address(token1), recipient, amount1Out);
    }
  }

  function setPerformanceFee(uint24 newFee)
    external
    override
    onlyRole(LixirRoles.fee_setter_role)
  {
    require(newFee < PERFORMANCE_FEE_PRECISION);
    emit PerformanceFeeSet(performanceFee, newFee);
    performanceFee = newFee;
  }

  function _setPool(uint24 fee) internal {
    activePool = IUniswapV3Pool(
      PoolAddress.computeAddress(
        uniV3Factory,
        PoolAddress.getPoolKey(address(token0), address(token1), fee)
      )
    );
    require(Address.isContract(address(activePool)));
    activeFee = fee;
  }

  function setKeeper(address _keeper)
    external
    override
    onlyStrategist
    hasRole(LixirRoles.keeper_role, _keeper)
  {
    keeper = _keeper;
  }

  function setStrategy(address _strategy)
    external
    override
    onlyStrategist
    hasRole(LixirRoles.strategy_role, _strategy)
  {
    emit StrategySet(strategy, _strategy);
    strategy = _strategy;
  }

  function setStrategist(address _strategist)
    external
    override
    onlyGovOrDelegate
    hasRole(LixirRoles.strategist_role, _strategist)
  {
    strategist = _strategist;
  }

  function emergencyExit()
    external
    override
    whenNotPaused
    onlyRole(LixirRoles.pauser_role)
  {
    burnCollectPositions();
    _pause();
  }

  function unpause() external override whenPaused onlyGovOrDelegate {
    _unpause();
  }

  /**
    @notice burns all positions collects any fees accrued since last `rebalance`
    and mints new positions.
    @dev This function is not called by an external account, but instead by the
    strategy contract, which automatically calculates the proper positions to mint.
   */
  function rebalance(
    int24 mainTickLower,
    int24 mainTickUpper,
    int24 rangeTickLower0,
    int24 rangeTickUpper0,
    int24 rangeTickLower1,
    int24 rangeTickUpper1,
    uint24 fee
  ) external override onlyStrategy whenNotPaused {
    require(
      TickMath.MIN_TICK <= mainTickLower &&
        mainTickUpper <= TickMath.MAX_TICK &&
        mainTickLower < mainTickUpper &&
        TickMath.MIN_TICK <= rangeTickLower0 &&
        rangeTickUpper0 <= TickMath.MAX_TICK &&
        rangeTickLower0 < rangeTickUpper0 &&
        TickMath.MIN_TICK <= rangeTickLower1 &&
        rangeTickUpper1 <= TickMath.MAX_TICK &&
        rangeTickLower1 < rangeTickUpper1
    );
    /// if a pool has been previously set, then take the performance fee accrued since last `rebalance`
    /// and burn and collect all positions.
    if (address(activePool) != address(0)) {
      _takeFee();
      burnCollectPositions();
    }
    /// if the strategist has changed the pool fee tier (e.g. 0.05%, 0.3%, 1%), then change the pool
    if (fee != activeFee) {
      _setPool(fee);
    }
    uint256 total0 = token0.balanceOf(address(this));
    uint256 total1 = token1.balanceOf(address(this));
    Position memory mainData = Position(mainTickLower, mainTickUpper);
    Position memory rangeData0 = Position(rangeTickLower0, rangeTickUpper0);
    Position memory rangeData1 = Position(rangeTickLower1, rangeTickUpper1);

    mintPositions(total0, total1, mainData, rangeData0, rangeData1);

    emit Rebalance(
      mainTickLower,
      mainTickUpper,
      rangePosition.tickLower,
      rangePosition.tickUpper,
      fee,
      total0,
      total1
    );
  }

  function mintPositions(
    uint256 amount0,
    uint256 amount1,
    Position memory mainData,
    Position memory rangeData0,
    Position memory rangeData1
  ) internal {
    (uint160 sqrtRatioX96, ) = getSqrtRatioX96AndTick();
    mainPosition.tickLower = mainData.tickLower;
    mainPosition.tickUpper = mainData.tickUpper;

    if (0 < amount0 || 0 < amount1) {
      uint128 mL =
        LiquidityAmounts.getLiquidityForAmounts(
          sqrtRatioX96,
          TickMath.getSqrtRatioAtTick(mainData.tickLower),
          TickMath.getSqrtRatioAtTick(mainData.tickUpper),
          amount0,
          amount1
        );

      if (0 < mL) {
        activePool.mint(
          address(this),
          mainData.tickLower,
          mainData.tickUpper,
          mL,
          ''
        );
      }
    }
    amount0 = token0.balanceOf(address(this));
    amount1 = token1.balanceOf(address(this));
    uint128 rL;
    Position memory rangeData;
    if (0 < amount0 || 0 < amount1) {
      uint128 rL0 =
        LiquidityAmounts.getLiquidityForAmount0(
          TickMath.getSqrtRatioAtTick(rangeData0.tickLower),
          TickMath.getSqrtRatioAtTick(rangeData0.tickUpper),
          amount0
        );
      uint128 rL1 =
        LiquidityAmounts.getLiquidityForAmount1(
          TickMath.getSqrtRatioAtTick(rangeData1.tickLower),
          TickMath.getSqrtRatioAtTick(rangeData1.tickUpper),
          amount1
        );

      /// only one range position will ever have liquidity (if any)
      if (rL1 < rL0) {
        rL = rL0;
        rangeData = rangeData0;
      } else if (0 < rL1) {
        rangeData = rangeData1;
        rL = rL1;
      }
    } else {
      rangeData = Position(0, 0);
    }

    rangePosition.tickLower = rangeData.tickLower;
    rangePosition.tickUpper = rangeData.tickUpper;

    if (0 < rL) {
      activePool.mint(
        address(this),
        rangeData.tickLower,
        rangeData.tickUpper,
        rL,
        ''
      );
    }
  }

  function _takeFee() internal {
    uint24 _perfFee = performanceFee;
    address _feeTo = registry.feeTo();
    if (_feeTo != address(0) && 0 < _perfFee) {
      (uint160 sqrtRatioX96, int24 tick) = getSqrtRatioX96AndTick();
      (
        ,
        uint256 total0,
        uint256 total1,
        uint256 tokensOwed0,
        uint256 tokensOwed1
      ) =
        calculatePositionInfo(
          tick,
          sqrtRatioX96,
          mainPosition.tickLower,
          mainPosition.tickUpper
        );
      {
        (
          ,
          uint256 total0Range,
          uint256 total1Range,
          uint256 tokensOwed0Range,
          uint256 tokensOwed1Range
        ) =
          calculatePositionInfo(
            tick,
            sqrtRatioX96,
            rangePosition.tickLower,
            rangePosition.tickUpper
          );
        total0 = total0.add(total0Range).add(token0.balanceOf(address(this)));
        total1 = total1.add(total1Range).add(token1.balanceOf(address(this)));
        tokensOwed0 = tokensOwed0.add(tokensOwed0Range);
        tokensOwed1 = tokensOwed1.add(tokensOwed1Range);
      }

      uint256 _totalSupply = totalSupply();

      uint256 price =
        FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, FixedPoint96.Q96);

      total1 = total1.add(FullMath.mulDiv(total0, price, FixedPoint96.Q96));

      if (total1 > 0) {
        tokensOwed1 = tokensOwed1.add(
          FullMath.mulDiv(tokensOwed0, price, FixedPoint96.Q96)
        );
        uint256 shares =
          FullMath.mulDiv(
            FullMath.mulDiv(tokensOwed1, _totalSupply, total1),
            performanceFee,
            PERFORMANCE_FEE_PRECISION
          );
        if (shares > 0) {
          _mintPoolTokens(_feeTo, shares);
        }
      }
    }
  }

  /**
    @notice burns everyting (main and range positions) and collects any fees accrued in the pool.
    @dev this is called fairly frequently since compounding is not automatic: in UniV3,
    all fees must be manually withdrawn.
   */
  function burnCollectPositions() internal {
    uint128 mL = positionLiquidity(mainPosition);
    uint128 rL = positionLiquidity(rangePosition);

    if (0 < mL) {
      activePool.burn(mainPosition.tickLower, mainPosition.tickUpper, mL);
      activePool.collect(
        address(this),
        mainPosition.tickLower,
        mainPosition.tickUpper,
        type(uint128).max,
        type(uint128).max
      );
    }
    if (0 < rL) {
      activePool.burn(rangePosition.tickLower, rangePosition.tickUpper, rL);
      activePool.collect(
        address(this),
        rangePosition.tickLower,
        rangePosition.tickUpper,
        type(uint128).max,
        type(uint128).max
      );
    }
  }

  /**
    @notice in contrast to `burnCollectPositions`, this only burns a portion of liqudity,
    used for when a user withdraws tokens from the vault.
    @param position Storage pointer to position
    @param tick Current tick
    @param shares User shares to burn
    @param _totalSupply totalSupply of Lixir vault tokens
   */
  function burnAndCollect(
    Position storage position,
    int24 tick,
    uint256 shares,
    uint256 _totalSupply
  ) internal returns (uint256 amount0Out, uint256 amount1Out) {
    int24 tickLower = position.tickLower;
    int24 tickUpper = position.tickUpper;
    /*
     * N.B. that tokensOwed{0,1} here are calculated prior to burning,
     *  and so should only contain tokensOwed from fees and never tokensOwed from a burn
     */
    (uint128 liquidity, uint256 tokensOwed0, uint256 tokensOwed1) =
      liquidityAndTokensOwed(tick, tickLower, tickUpper);

    uint128 LDelta =
      FullMath.mulDiv(shares, liquidity, _totalSupply).toUint128();

    amount0Out = FullMath.mulDiv(tokensOwed0, shares, _totalSupply);
    amount1Out = FullMath.mulDiv(tokensOwed1, shares, _totalSupply);

    if (0 < LDelta) {
      (uint256 burnt0Out, uint256 burnt1Out) =
        activePool.burn(tickLower, tickUpper, LDelta);
      amount0Out = amount0Out.add(burnt0Out);
      amount1Out = amount1Out.add(burnt1Out);
    }
    if (0 < amount0Out || 0 < amount1Out) {
      activePool.collect(
        address(this),
        tickLower,
        tickUpper,
        amount0Out.toUint128(),
        amount1Out.toUint128()
      );
    }
  }

  /// @dev internal readonly getters and pure helper functions

  /**
   * @dev Calculates shares and amounts to deposit from amounts desired, TVL of vault, and totalSupply of vault tokens
   * @param amount0Desired Amount of token 0 desired by user
   * @param amount1Desired Amount of token 1 desired by user
   * @param total0 Total amount of token 0 available to activePool
   * @param total1 Total amount of token 1 available to activePool
   * @param _totalSupply Total supply of vault tokens
   * @return shares Shares of activePool to mint to user
   * @return amount0In Actual amount of token0 user should deposit into activePool
   * @return amount1In Actual amount of token1 user should deposit into activePool
   */
  function calcSharesAndAmounts(
    uint256 amount0Desired,
    uint256 amount1Desired,
    uint256 total0,
    uint256 total1,
    uint256 _totalSupply
  )
    internal
    pure
    returns (
      uint256 shares,
      uint256 amount0In,
      uint256 amount1In
    )
  {
    (bool roundedSharesFrom0, uint256 sharesFrom0) =
      0 < total0
        ? mulDivRoundingUp(amount0Desired, _totalSupply, total0)
        : (false, 0);
    (bool roundedSharesFrom1, uint256 sharesFrom1) =
      0 < total1
        ? mulDivRoundingUp(amount1Desired, _totalSupply, total1)
        : (false, 0);
    uint8 realSharesOffsetFor0 = roundedSharesFrom0 ? 1 : 2;
    uint8 realSharesOffsetFor1 = roundedSharesFrom1 ? 1 : 2;
    if (
      realSharesOffsetFor0 < sharesFrom0 &&
      (total1 == 0 || sharesFrom0 < sharesFrom1)
    ) {
      shares = sharesFrom0 - 1 - realSharesOffsetFor0;
      amount0In = amount0Desired;
      amount1In = FullMath.mulDivRoundingUp(sharesFrom0, total1, _totalSupply);
      LixirErrors.require_INSUFFICIENT_OUTPUT_AMOUNT(
        amount1In <= amount1Desired
      );
    } else {
      LixirErrors.require_INSUFFICIENT_INPUT_AMOUNT(
        realSharesOffsetFor1 < sharesFrom1
      );
      shares = sharesFrom1 - 1 - realSharesOffsetFor1;
      amount0In = FullMath.mulDivRoundingUp(sharesFrom1, total0, _totalSupply);
      LixirErrors.require_INSUFFICIENT_OUTPUT_AMOUNT(
        amount0In <= amount0Desired
      );
      amount1In = amount1Desired;
    }
  }

  function mulDivRoundingUp(
    uint256 a,
    uint256 b,
    uint256 denominator
  ) internal pure returns (bool rounded, uint256 result) {
    result = FullMath.mulDiv(a, b, denominator);
    if (mulmod(a, b, denominator) > 0) {
      require(result < type(uint256).max);
      result++;
      rounded = true;
    }
  }

  /**
   * @dev Calculates shares, liquidity deltas, and amounts in for initial deposit
   * @param amount0Desired Amount of token 0 desired by user
   * @param amount1Desired Amount of token 1 desired by user
   * @return shares Initial shares to mint
   * @return mLDelta Liquidity delta for main position
   * @return amount0In Amount of token 0 to transfer from user
   * @return amount1In Amount of token 1 to transfer from user
   */
  function calculateInitialDeposit(
    uint256 amount0Desired,
    uint256 amount1Desired
  )
    internal
    view
    returns (
      uint256 shares,
      uint128 mLDelta,
      uint256 amount0In,
      uint256 amount1In
    )
  {
    (uint160 sqrtRatioX96, int24 tick) = getSqrtRatioX96AndTick();
    uint160 sqrtRatioLowerX96 =
      TickMath.getSqrtRatioAtTick(mainPosition.tickLower);
    uint160 sqrtRatioUpperX96 =
      TickMath.getSqrtRatioAtTick(mainPosition.tickUpper);

    mLDelta = LiquidityAmounts.getLiquidityForAmounts(
      sqrtRatioX96,
      sqrtRatioLowerX96,
      sqrtRatioUpperX96,
      amount0Desired,
      amount1Desired
    );

    LixirErrors.require_INSUFFICIENT_INPUT_AMOUNT(0 < mLDelta);

    (amount0In, amount1In) = getAmountsForLiquidity(
      sqrtRatioX96,
      sqrtRatioLowerX96,
      sqrtRatioUpperX96,
      mLDelta.toInt128()
    );
    shares = mLDelta;
  }

  /**
   * @dev Queries activePool for current square root price and current tick
   * @return _sqrtRatioX96 Current square root price
   * @return _tick Current tick
   */
  function getSqrtRatioX96AndTick()
    internal
    view
    returns (uint160 _sqrtRatioX96, int24 _tick)
  {
    (_sqrtRatioX96, _tick, , , , , ) = activePool.slot0();
  }

  /**
   * @dev Calculates tokens owed for a position
   * @param realTick Current tick
   * @param tickLower Lower tick of position
   * @param tickUpper Upper tick of position
   * @param feeGrowthInside0LastX128 Last fee growth of token0 between tickLower and tickUpper
   * @param feeGrowthInside1LastX128 Last fee growth of token0 between tickLower and tickUpper
   * @param liquidity Liquidity of position for which tokens owed is being calculated
   * @param tokensOwed0Last Last tokens owed to position
   * @param tokensOwed1Last Last tokens owed to position
   * @return tokensOwed0 Amount of token0 owed to position
   * @return tokensOwed1 Amount of token1 owed to position
   */
  function calculateTokensOwed(
    int24 realTick,
    int24 tickLower,
    int24 tickUpper,
    uint256 feeGrowthInside0LastX128,
    uint256 feeGrowthInside1LastX128,
    uint128 liquidity,
    uint128 tokensOwed0Last,
    uint128 tokensOwed1Last
  ) internal view returns (uint128 tokensOwed0, uint128 tokensOwed1) {
    /*
     * V3 doesn't use SafeMath here, so we don't either
     * This could of course result in a dramatic forfeiture of fees. The reality though is
     * we rebalance far frequently enough for this to never happen in any realistic scenario.
     * This has no difference from the v3 implementation, and was copied from contracts/libraries/Position.sol
     */
    (uint256 feeGrowthInside0X128, uint256 feeGrowthInside1X128) =
      getFeeGrowthInsideTicks(realTick, tickLower, tickUpper);
    tokensOwed0 = uint128(
      tokensOwed0Last +
        FullMath.mulDiv(
          feeGrowthInside0X128 - feeGrowthInside0LastX128,
          liquidity,
          FixedPoint128.Q128
        )
    );
    tokensOwed1 = uint128(
      tokensOwed1Last +
        FullMath.mulDiv(
          feeGrowthInside1X128 - feeGrowthInside1LastX128,
          liquidity,
          FixedPoint128.Q128
        )
    );
  }

  function _positionDataHelper(
    int24 realTick,
    int24 tickLower,
    int24 tickUpper
  )
    internal
    view
    returns (
      uint128 liquidity,
      uint256 feeGrowthInside0LastX128,
      uint256 feeGrowthInside1LastX128,
      uint128 tokensOwed0,
      uint128 tokensOwed1
    )
  {
    (
      liquidity,
      feeGrowthInside0LastX128,
      feeGrowthInside1LastX128,
      tokensOwed0,
      tokensOwed1
    ) = activePool.positions(
      PositionKey.compute(address(this), tickLower, tickUpper)
    );

    if (liquidity == 0) {
      return (
        0,
        feeGrowthInside0LastX128,
        feeGrowthInside1LastX128,
        tokensOwed0,
        tokensOwed1
      );
    }

    (tokensOwed0, tokensOwed1) = calculateTokensOwed(
      realTick,
      tickLower,
      tickUpper,
      feeGrowthInside0LastX128,
      feeGrowthInside1LastX128,
      liquidity,
      tokensOwed0,
      tokensOwed1
    );
  }

  /**
   * @dev Queries and calculates liquidity and tokens owed
   * @param tick Current tick
   * @param tickLower Lower tick of position
   * @param tickUpper Upper tick of position
   * @return liquidity Liquidity of position for which tokens owed is being calculated
   * @return tokensOwed0 Amount of token0 owed to position
   * @return tokensOwed1 Amount of token1 owed to position
   */
  function liquidityAndTokensOwed(
    int24 tick,
    int24 tickLower,
    int24 tickUpper
  )
    internal
    view
    returns (
      uint128 liquidity,
      uint128 tokensOwed0,
      uint128 tokensOwed1
    )
  {
    (liquidity, , , tokensOwed0, tokensOwed1) = _positionDataHelper(
      tick,
      tickLower,
      tickUpper
    );
  }

  function calculateTotals()
    external
    view
    returns (
      uint256 total0,
      uint256 total1,
      uint128 mL,
      uint128 rL
    )
  {
    (uint160 sqrtRatioX96, int24 tick) = getSqrtRatioX96AndTick();
    return
      _calculateTotals(
        sqrtRatioX96,
        tick,
        DepositPositionData(0, mainPosition.tickLower, mainPosition.tickUpper),
        DepositPositionData(0, rangePosition.tickLower, rangePosition.tickUpper)
      );
  }

  /**
   * @notice This variant is so that tick TWAP's may be used by other protocols to calculate
   * totals, allowing them to safeguard themselves from manipulation. This would be useful if
   * Lixir vault tokens were used as collateral in a lending protocol.
   * @param virtualTick Tick at which to calculate amounts from liquidity
   */
  function calculateTotalsFromTick(int24 virtualTick)
    external
    view
    override
    returns (
      uint256 total0,
      uint256 total1,
      uint128 mL,
      uint128 rL
    )
  {
    uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(virtualTick);
    (, int24 realTick) = getSqrtRatioX96AndTick();
    return
      _calculateTotalsFromTick(
        sqrtRatioX96,
        realTick,
        DepositPositionData(0, mainPosition.tickLower, mainPosition.tickUpper),
        DepositPositionData(0, rangePosition.tickLower, rangePosition.tickUpper)
      );
  }

  /**
   * @dev Helper function for calculating totals
   * @param sqrtRatioX96 *Current or virtual* sqrtPriceX96
   * @param realTick Current tick, for calculating tokensOwed correctly
   * @param mainData Main position data
   * @param rangeData Range position data
   * N.B realTick must be provided because tokensOwed calculation needs
   * the current correct tick because the ticks are only updated upon the
   * crossing of ticks
   * sqrtRatioX96 can be a current sqrtPriceX96 *or* a sqrtPriceX96 calculated
   * from a virtual tick, for external consumption
   */
  function _calculateTotalsFromTick(
    uint160 sqrtRatioX96,
    int24 realTick,
    DepositPositionData memory mainData,
    DepositPositionData memory rangeData
  )
    internal
    view
    returns (
      uint256 total0,
      uint256 total1,
      uint128 mL,
      uint128 rL
    )
  {
    (mL, total0, total1) = calculatePositionTotals(
      realTick,
      sqrtRatioX96,
      mainData.tickLower,
      mainData.tickUpper
    );
    {
      uint256 rt0;
      uint256 rt1;
      (rL, rt0, rt1) = calculatePositionTotals(
        realTick,
        sqrtRatioX96,
        rangeData.tickLower,
        rangeData.tickUpper
      );
      total0 = total0.add(rt0);
      total1 = total1.add(rt1);
    }
    total0 = total0.add(token0.balanceOf(address(this)));
    total1 = total1.add(token1.balanceOf(address(this)));
  }

  function _calculateTotals(
    uint160 sqrtRatioX96,
    int24 tick,
    DepositPositionData memory mainData,
    DepositPositionData memory rangeData
  )
    internal
    view
    returns (
      uint256 total0,
      uint256 total1,
      uint128 mL,
      uint128 rL
    )
  {
    return _calculateTotalsFromTick(sqrtRatioX96, tick, mainData, rangeData);
  }

  /**
   * @dev Calculates total tokens obtainable and liquidity of a given position (fees + amounts in position)
   * total{0,1} is sum of tokensOwed{0,1} from each position plus sum of liquidityForAmount{0,1} for each position plus vault balance of token{0,1}
   * @param realTick Current tick (for calculating tokensOwed)
   * @param sqrtRatioX96 Current (or virtual) square root price
   * @param tickLower Lower tick of position
   * @param tickLower Upper tick of position
   * @return liquidity Liquidity of position
   * @return total0 Total amount of token0 obtainable from position
   * @return total1 Total amount of token1 obtainable from position
   */
  function calculatePositionTotals(
    int24 realTick,
    uint160 sqrtRatioX96,
    int24 tickLower,
    int24 tickUpper
  )
    internal
    view
    returns (
      uint128 liquidity,
      uint256 total0,
      uint256 total1
    )
  {
    uint256 tokensOwed0;
    uint256 tokensOwed1;
    (
      liquidity,
      total0,
      total1,
      tokensOwed0,
      tokensOwed1
    ) = calculatePositionInfo(realTick, sqrtRatioX96, tickLower, tickUpper);
    total0 = total0.add(tokensOwed0);
    total1 = total1.add(tokensOwed1);
  }

  function calculatePositionInfo(
    int24 realTick,
    uint160 sqrtRatioX96,
    int24 tickLower,
    int24 tickUpper
  )
    internal
    view
    returns (
      uint128 liquidity,
      uint256 total0,
      uint256 total1,
      uint256 tokensOwed0,
      uint256 tokensOwed1
    )
  {
    uint256 feeGrowthInside0LastX128;
    uint256 feeGrowthInside1LastX128;
    (
      liquidity,
      feeGrowthInside0LastX128,
      feeGrowthInside1LastX128,
      tokensOwed0,
      tokensOwed1
    ) = _positionDataHelper(realTick, tickLower, tickUpper);

    uint160 sqrtPriceLower = TickMath.getSqrtRatioAtTick(tickLower);
    uint160 sqrtPriceUpper = TickMath.getSqrtRatioAtTick(tickUpper);
    (uint256 amount0, uint256 amount1) =
      getAmountsForLiquidity(
        sqrtRatioX96,
        sqrtPriceLower,
        sqrtPriceUpper,
        liquidity.toInt128()
      );
  }

  /**
   * @dev Calculates fee growth between a tick range
   * @param tick Current tick
   * @param tickLower Lower tick of range
   * @param tickUpper Upper tick of range
   * @return feeGrowthInside0X128 Fee growth of token 0 inside ticks
   * @return feeGrowthInside1X128 Fee growth of token 1 inside ticks
   */
  function getFeeGrowthInsideTicks(
    int24 tick,
    int24 tickLower,
    int24 tickUpper
  )
    internal
    view
    returns (uint256 feeGrowthInside0X128, uint256 feeGrowthInside1X128)
  {
    /*
     * Underflow is Good here, actually.
     * Uniswap V3 doesn't use SafeMath here, and the cases where it does underflow,
     * it should help us get back to the rightful fee growth value of our position.
     * It would underflow only when feeGrowthGlobal{0,1}X128 has overflowed already in the V3 contract.
     * It should never underflow if feeGrowthGlobal{0,1}X128 hasn't yet overflowed.
     * Of course, if feeGrowthGlobal{0,1}X128 has overflowed twice over or more, we cannot possibly recover
     * fees from the overflow before last via underflow here, and it is possible our feeGrowthOutside values are
     * insufficently large to underflow enough to recover fees from the most recent overflow.
     * But, we rebalance frequently, so this should never be an issue.
     * This math is no different than in the v3 activePool contract and was copied from contracts/libraries/Tick.sol
     */
    uint256 feeGrowthGlobal0X128 = activePool.feeGrowthGlobal0X128();
    uint256 feeGrowthGlobal1X128 = activePool.feeGrowthGlobal1X128();
    (
      ,
      ,
      uint256 feeGrowthOutside0X128Lower,
      uint256 feeGrowthOutside1X128Lower,
      ,
      ,
      ,

    ) = activePool.ticks(tickLower);
    (
      ,
      ,
      uint256 feeGrowthOutside0X128Upper,
      uint256 feeGrowthOutside1X128Upper,
      ,
      ,
      ,

    ) = activePool.ticks(tickUpper);

    // calculate fee growth below
    uint256 feeGrowthBelow0X128;
    uint256 feeGrowthBelow1X128;
    if (tick >= tickLower) {
      feeGrowthBelow0X128 = feeGrowthOutside0X128Lower;
      feeGrowthBelow1X128 = feeGrowthOutside1X128Lower;
    } else {
      feeGrowthBelow0X128 = feeGrowthGlobal0X128 - feeGrowthOutside0X128Lower;
      feeGrowthBelow1X128 = feeGrowthGlobal1X128 - feeGrowthOutside1X128Lower;
    }

    // calculate fee growth above
    uint256 feeGrowthAbove0X128;
    uint256 feeGrowthAbove1X128;
    if (tick < tickUpper) {
      feeGrowthAbove0X128 = feeGrowthOutside0X128Upper;
      feeGrowthAbove1X128 = feeGrowthOutside1X128Upper;
    } else {
      feeGrowthAbove0X128 = feeGrowthGlobal0X128 - feeGrowthOutside0X128Upper;
      feeGrowthAbove1X128 = feeGrowthGlobal1X128 - feeGrowthOutside1X128Upper;
    }

    feeGrowthInside0X128 =
      feeGrowthGlobal0X128 -
      feeGrowthBelow0X128 -
      feeGrowthAbove0X128;
    feeGrowthInside1X128 =
      feeGrowthGlobal1X128 -
      feeGrowthBelow1X128 -
      feeGrowthAbove1X128;
  }

  /**
   * @dev Queries position liquidity
   * @param position Storage pointer to position we want to query
   */
  function positionLiquidity(Position storage position)
    internal
    view
    returns (uint128 _liquidity)
  {
    (_liquidity, , , , ) = activePool.positions(
      PositionKey.compute(address(this), position.tickLower, position.tickUpper)
    );
  }

  function getAmountsForLiquidity(
    uint160 sqrtPriceX96,
    uint160 sqrtPriceX96Lower,
    uint160 sqrtPriceX96Upper,
    int128 liquidityDelta
  ) internal pure returns (uint256 amount0, uint256 amount1) {
    if (sqrtPriceX96 <= sqrtPriceX96Lower) {
      // current tick is below the passed range; liquidity can only become in range by crossing from left to
      // right, when we'll need _more_ token0 (it's becoming more valuable) so user must provide it
      amount0 = SqrtPriceMath
        .getAmount0Delta(sqrtPriceX96Lower, sqrtPriceX96Upper, liquidityDelta)
        .abs();
    } else if (sqrtPriceX96 < sqrtPriceX96Upper) {
      amount0 = SqrtPriceMath
        .getAmount0Delta(sqrtPriceX96, sqrtPriceX96Upper, liquidityDelta)
        .abs();
      amount1 = SqrtPriceMath
        .getAmount1Delta(sqrtPriceX96Lower, sqrtPriceX96, liquidityDelta)
        .abs();
    } else {
      // current tick is above the passed range; liquidity can only become in range by crossing from right to
      // left, when we'll need _more_ token1 (it's becoming more valuable) so user must provide it
      amount1 = SqrtPriceMath
        .getAmount1Delta(sqrtPriceX96Lower, sqrtPriceX96Upper, liquidityDelta)
        .abs();
    }
  }

  /// @inheritdoc IUniswapV3MintCallback
  function uniswapV3MintCallback(
    uint256 amount0Owed,
    uint256 amount1Owed,
    bytes calldata
  ) external virtual override {
    require(msg.sender == address(activePool));
    if (amount0Owed > 0) {
      TransferHelper.safeTransfer(address(token0), msg.sender, amount0Owed);
    }
    if (amount1Owed > 0) {
      TransferHelper.safeTransfer(address(token1), msg.sender, amount1Owed);
    }
  }
}