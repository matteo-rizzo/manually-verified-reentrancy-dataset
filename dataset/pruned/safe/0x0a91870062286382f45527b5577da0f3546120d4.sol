/**
 *Submitted for verification at Etherscan.io on 2021-06-22
*/

// Sources flattened with hardhat v2.0.5 https://hardhat.org

// File deps/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// File deps/@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol



pragma solidity ^0.6.0;

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



// File deps/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol



pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */



// File deps/@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol



pragma solidity ^0.6.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// File deps/@openzeppelin/contracts-upgradeable/utils/EnumerableSetUpgradeable.sol



pragma solidity ^0.6.0;

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



// File interfaces/convex/IBooster.sol

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;



// File interfaces/convex/CrvDepositor.sol


pragma solidity >=0.6.0;



// File interfaces/convex/IBaseRewardsPool.sol



pragma solidity ^0.6.0;



// File interfaces/convex/ICvxRewardsPool.sol



pragma solidity ^0.6.0;



// File deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol



pragma solidity >=0.4.24 <0.7.0;


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
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}


// File deps/@openzeppelin/contracts-upgradeable/GSN/ContextUpgradeable.sol



pragma solidity ^0.6.0;

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


// File deps/@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol



pragma solidity ^0.6.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    uint256[49] private __gap;
}


// File interfaces/curve/ICurveFi.sol


pragma solidity >=0.5.0 <0.8.0;




// File contracts/badger-sett/libraries/BaseSwapper.sol



pragma solidity ^0.6.11;



/*
    Expands swapping functionality over base strategy
    - ETH in and ETH out Variants
    - Sushiswap support in addition to Uniswap
*/
contract BaseSwapper {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    /// @dev Reset approval and approve exact amount
    function _safeApproveHelper(
        address token,
        address recipient,
        uint256 amount
    ) internal {
        IERC20Upgradeable(token).safeApprove(recipient, 0);
        IERC20Upgradeable(token).safeApprove(recipient, amount);
    }
}


// File contracts/badger-sett/libraries/CurveSwapper.sol



pragma solidity ^0.6.11;







/*
    Expands swapping functionality over base strategy
    - ETH in and ETH out Variants
    - Sushiswap support in addition to Uniswap
*/
contract CurveSwapper is BaseSwapper {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    function _add_liquidity_single_coin(
        address swap,
        address pool,
        address inputToken,
        uint256 inputAmount,
        uint256 inputPosition,
        uint256 numPoolElements,
        uint256 min_mint_amount
    ) internal {
        _safeApproveHelper(inputToken, swap, inputAmount);
        if (numPoolElements == 2) {
            uint256[2] memory convertedAmounts;
            convertedAmounts[inputPosition] = inputPosition;
            ICurveFi(swap).add_liquidity(convertedAmounts, min_mint_amount);
        } else if (numPoolElements == 3) {
            uint256[3] memory convertedAmounts;
            convertedAmounts[inputPosition] = inputPosition;
            ICurveFi(swap).add_liquidity(convertedAmounts, min_mint_amount);
        } else if (numPoolElements == 4) {
            uint256[4] memory convertedAmounts;
            convertedAmounts[inputPosition] = inputPosition;
            ICurveFi(swap).add_liquidity(convertedAmounts, min_mint_amount);
        } else {
            revert("Invalidf number of amount elements");
        }
    }

    function _add_liquidity(
        address pool,
        uint256[2] memory amounts,
        uint256 min_mint_amount
    ) internal {
        ICurveFi(pool).add_liquidity(amounts, min_mint_amount);
    }

    function _add_liquidity(
        address pool,
        uint256[3] memory amounts,
        uint256 min_mint_amount
    ) internal {
        ICurveFi(pool).add_liquidity(amounts, min_mint_amount);
    }

    function _add_liquidity(
        address pool,
        uint256[4] memory amounts,
        uint256 min_mint_amount
    ) internal {
        ICurveFi(pool).add_liquidity(amounts, min_mint_amount);
    }

    function _remove_liquidity_one_coin(
        address swap,
        uint256 _token_amount,
        int128 i,
        uint256 _min_amount
    ) internal {
        ICurveFi(swap).remove_liquidity_one_coin(_token_amount, i, _min_amount);
    }
}


// File deps/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol



pragma solidity ^0.6.0;




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


// File interfaces/uniswap/IUniswapRouterV2.sol


pragma solidity >=0.5.0 <0.8.0;




// File interfaces/uniswap/IUniswapV2Factory.sol


pragma solidity >=0.5.0 <0.8.0;




// File contracts/badger-sett/libraries/UniswapSwapper.sol



pragma solidity ^0.6.11;









/*
    Expands swapping functionality over base strategy
    - ETH in and ETH out Variants
    - Sushiswap support in addition to Uniswap
*/
contract UniswapSwapper is BaseSwapper{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    address internal constant uniswap = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Uniswap router
    address internal constant sushiswap = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F; // Sushiswap router

    function _swapExactTokensForTokens(
        address router,
        address startToken,
        uint256 balance,
        address[] memory path
    ) internal {
        _safeApproveHelper(startToken, router, balance);
        IUniswapRouterV2(router).swapExactTokensForTokens(balance, 0, path, address(this), now);
    }

    function _swapExactETHForTokens(address router, uint256 balance, address[] memory path) internal {
        IUniswapRouterV2(uniswap).swapExactETHForTokens{value: balance}(0, path, address(this), now);
    }

    function _swapExactTokensForETH(
        address router,
        address startToken,
        uint256 balance,
        address[] memory path
    ) internal {
        _safeApproveHelper(startToken, router, balance);
        IUniswapRouterV2(router).swapExactTokensForETH(balance, 0, path, address(this), now);
    }

    function _getPair(address router, address token0, address token1) internal view returns (address) {
        address factory = IUniswapRouterV2(router).factory();
        return IUniswapV2Factory(factory).getPair(token0, token1);
    }

    /// @notice Add liquidity to uniswap for specified token pair, utilizing the maximum balance possible
    function _addMaxLiquidity(address router, address token0, address token1) internal {
        uint256 _token0Balance = IERC20Upgradeable(token0).balanceOf(address(this));
        uint256 _token1Balance = IERC20Upgradeable(token1).balanceOf(address(this));

        _safeApproveHelper(token0, router, _token0Balance);
        _safeApproveHelper(token1, router, _token1Balance);

        IUniswapRouterV2(router).addLiquidity(token0, token1, _token0Balance, _token1Balance, 0, 0, address(this), block.timestamp);
    }

    function _addMaxLiquidityEth(address router, address token0) internal {
        uint256 _token0Balance = IERC20Upgradeable(token0).balanceOf(address(this));
        uint256 _ethBalance = address(this).balance;

        _safeApproveHelper(token0, router, _token0Balance);
        IUniswapRouterV2(router).addLiquidityETH{ value: address(this).balance }(token0, _token0Balance, 0, 0, address(this), block.timestamp);
    }
}


// File contracts/badger-sett/libraries/TokenSwapPathRegistry.sol



pragma solidity ^0.6.11;






/*
    Expands swapping functionality over base strategy
    - ETH in and ETH out Variants
    - Sushiswap support in addition to Uniswap
*/
contract TokenSwapPathRegistry {
    mapping(address => mapping(address => address[])) public tokenSwapPaths;

    event TokenSwapPathSet(address tokenIn, address tokenOut, address[] path);

    function getTokenSwapPath(address tokenIn, address tokenOut) public view returns (address[] memory) {
        return tokenSwapPaths[tokenIn][tokenOut];
    }
    function _setTokenSwapPath(
        address tokenIn,
        address tokenOut,
        address[] memory path
    ) internal {
        tokenSwapPaths[tokenIn][tokenOut] = path;
        emit TokenSwapPathSet(tokenIn, tokenOut, path);
    }

}


// File deps/@openzeppelin/contracts-upgradeable/math/MathUpgradeable.sol



pragma solidity ^0.6.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */



// File interfaces/badger/IController.sol


pragma solidity >=0.5.0 <0.8.0;




// File interfaces/badger/IStrategy.sol




pragma solidity >=0.5.0 <0.8.0;




// File contracts/badger-sett/SettAccessControl.sol


pragma solidity ^0.6.11;

/*
    Common base for permissioned roles throughout Sett ecosystem
*/
contract SettAccessControl is Initializable {
    address public governance;
    address public strategist;
    address public keeper;

    // ===== MODIFIERS =====
    function _onlyGovernance() internal view {
        require(msg.sender == governance, "onlyGovernance");
    }

    function _onlyGovernanceOrStrategist() internal view {
        require(msg.sender == strategist || msg.sender == governance, "onlyGovernanceOrStrategist");
    }

    function _onlyAuthorizedActors() internal view {
        require(msg.sender == keeper || msg.sender == governance, "onlyAuthorizedActors");
    }

    // ===== PERMISSIONED ACTIONS =====

    /// @notice Change strategist address
    /// @notice Can only be changed by governance itself
    function setStrategist(address _strategist) external {
        _onlyGovernance();
        strategist = _strategist;
    }

    /// @notice Change keeper address
    /// @notice Can only be changed by governance itself
    function setKeeper(address _keeper) external {
        _onlyGovernance();
        keeper = _keeper;
    }

    /// @notice Change governance address
    /// @notice Can only be changed by governance itself
    function setGovernance(address _governance) public {
        _onlyGovernance();
        governance = _governance;
    }

    uint256[50] private __gap;
}


// File contracts/badger-sett/strategies/BaseStrategy.sol



pragma solidity ^0.6.11;










/*
    ===== Badger Base Strategy =====
    Common base class for all Sett strategies

    Changelog
    V1.1
    - Verify amount unrolled from strategy positions on withdraw() is within a threshold relative to the requested amount as a sanity check
    - Add version number which is displayed with baseStrategyVersion(). If a strategy does not implement this function, it can be assumed to be 1.0

    V1.2
    - Remove idle want handling from base withdraw() function. This should be handled as the strategy sees fit in _withdrawSome()
*/
abstract contract BaseStrategy is PausableUpgradeable, SettAccessControl {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    event Withdraw(uint256 amount);
    event WithdrawAll(uint256 balance);
    event WithdrawOther(address token, uint256 amount);
    event SetStrategist(address strategist);
    event SetGovernance(address governance);
    event SetController(address controller);
    event SetWithdrawalFee(uint256 withdrawalFee);
    event SetPerformanceFeeStrategist(uint256 performanceFeeStrategist);
    event SetPerformanceFeeGovernance(uint256 performanceFeeGovernance);
    event Harvest(uint256 harvested, uint256 indexed blockNumber);
    event Tend(uint256 tended);

    address public want; // Want: Curve.fi renBTC/wBTC (crvRenWBTC) LP token

    uint256 public performanceFeeGovernance;
    uint256 public performanceFeeStrategist;
    uint256 public withdrawalFee;

    uint256 public constant MAX_FEE = 10000;

    address public controller;
    address public guardian;

    uint256 public withdrawalMaxDeviationThreshold;

    function __BaseStrategy_init(
        address _governance,
        address _strategist,
        address _controller,
        address _keeper,
        address _guardian
    ) public initializer whenNotPaused {
        __Pausable_init();
        governance = _governance;
        strategist = _strategist;
        keeper = _keeper;
        controller = _controller;
        guardian = _guardian;
        withdrawalMaxDeviationThreshold = 50;
    }

    // ===== Modifiers =====

    function _onlyController() internal view {
        require(msg.sender == controller, "onlyController");
    }

    function _onlyAuthorizedActorsOrController() internal view {
        require(msg.sender == keeper || msg.sender == governance || msg.sender == controller, "onlyAuthorizedActorsOrController");
    }

    function _onlyAuthorizedPausers() internal view {
        require(msg.sender == guardian || msg.sender == governance, "onlyPausers");
    }

    /// ===== View Functions =====
    function baseStrategyVersion() public view returns (string memory) {
        return "1.2";
    }

    /// @notice Get the balance of want held idle in the Strategy
    function balanceOfWant() public view returns (uint256) {
        return IERC20Upgradeable(want).balanceOf(address(this));
    }

    /// @notice Get the total balance of want realized in the strategy, whether idle or active in Strategy positions.
    function balanceOf() public virtual view returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }

    function isTendable() public virtual view returns (bool) {
        return false;
    }
    
    function isProtectedToken(address token) public view returns (bool) {
        address[] memory protectedTokens = getProtectedTokens();
        for (uint256 i = 0; i < protectedTokens.length; i++) {
            if (token == protectedTokens[i]) {
                return true;
            }
        }
        return false;
    }
    
    /// ===== Permissioned Actions: Governance =====

    function setGuardian(address _guardian) external {
        _onlyGovernance();
        guardian = _guardian;
    }

    function setWithdrawalFee(uint256 _withdrawalFee) external {
        _onlyGovernance();
        require(_withdrawalFee <= MAX_FEE, "base-strategy/excessive-withdrawal-fee");
        withdrawalFee = _withdrawalFee;
    }

    function setPerformanceFeeStrategist(uint256 _performanceFeeStrategist) external {
        _onlyGovernance();
        require(_performanceFeeStrategist <= MAX_FEE, "base-strategy/excessive-strategist-performance-fee");
        performanceFeeStrategist = _performanceFeeStrategist;
    }

    function setPerformanceFeeGovernance(uint256 _performanceFeeGovernance) external {
        _onlyGovernance();
        require(_performanceFeeGovernance <= MAX_FEE, "base-strategy/excessive-governance-performance-fee");
        performanceFeeGovernance = _performanceFeeGovernance;
    }

    function setController(address _controller) external {
        _onlyGovernance();
        controller = _controller;
    }

    function setWithdrawalMaxDeviationThreshold(uint256 _threshold) external {
        _onlyGovernance();
        require(_threshold <= MAX_FEE, "base-strategy/excessive-max-deviation-threshold");
        withdrawalMaxDeviationThreshold = _threshold;
    }

    function deposit() public virtual whenNotPaused {
        _onlyAuthorizedActorsOrController();
        uint256 _want = IERC20Upgradeable(want).balanceOf(address(this));
        if (_want > 0) {
            _deposit(_want);
        }
        _postDeposit();
    }

    // ===== Permissioned Actions: Controller =====

    /// @notice Controller-only function to Withdraw partial funds, normally used with a vault withdrawal
    function withdrawAll() external virtual whenNotPaused returns (uint256 balance) {
        _onlyController();

        _withdrawAll();

        _transferToVault(IERC20Upgradeable(want).balanceOf(address(this)));
    }

    /// @notice Withdraw partial funds from the strategy, unrolling from strategy positions as necessary
    /// @notice Processes withdrawal fee if present
    /// @dev If it fails to recover sufficient funds (defined by withdrawalMaxDeviationThreshold), the withdrawal should fail so that this unexpected behavior can be investigated
    function withdraw(uint256 _amount) external virtual whenNotPaused {
        _onlyController();

        // Withdraw from strategy positions, typically taking from any idle want first.
        _withdrawSome(_amount);
        uint256 _postWithdraw = IERC20Upgradeable(want).balanceOf(address(this));

        // Sanity check: Ensure we were able to retrieve sufficent want from strategy positions
        // If we end up with less than the amount requested, make sure it does not deviate beyond a maximum threshold
        if (_postWithdraw < _amount) {
            uint256 diff = _diff(_amount, _postWithdraw);

            // Require that difference between expected and actual values is less than the deviation threshold percentage
            require(diff <= _amount.mul(withdrawalMaxDeviationThreshold).div(MAX_FEE), "base-strategy/withdraw-exceed-max-deviation-threshold");
        }

        // Return the amount actually withdrawn if less than amount requested
        uint256 _toWithdraw = MathUpgradeable.min(_postWithdraw, _amount);

        // Process withdrawal fee
        uint256 _fee = _processWithdrawalFee(_toWithdraw);

        // Transfer remaining to Vault to handle withdrawal
        _transferToVault(_toWithdraw.sub(_fee));
    }

    // NOTE: must exclude any tokens used in the yield
    // Controller role - withdraw should return to Controller
    function withdrawOther(address _asset) external virtual whenNotPaused returns (uint256 balance) {
        _onlyController();
        _onlyNotProtectedTokens(_asset);

        balance = IERC20Upgradeable(_asset).balanceOf(address(this));
        IERC20Upgradeable(_asset).safeTransfer(controller, balance);
    }

    /// ===== Permissioned Actions: Authoized Contract Pausers =====

    function pause() external {
        _onlyAuthorizedPausers();
        _pause();
    }

    function unpause() external {
        _onlyGovernance();
        _unpause();
    }

    /// ===== Internal Helper Functions =====

    /// @notice If withdrawal fee is active, take the appropriate amount from the given value and transfer to rewards recipient
    /// @return The withdrawal fee that was taken
    function _processWithdrawalFee(uint256 _amount) internal returns (uint256) {
        if (withdrawalFee == 0) {
            return 0;
        }

        uint256 fee = _amount.mul(withdrawalFee).div(MAX_FEE);
        IERC20Upgradeable(want).safeTransfer(IController(controller).rewards(), fee);
        return fee;
    }

    /// @dev Helper function to process an arbitrary fee
    /// @dev If the fee is active, transfers a given portion in basis points of the specified value to the recipient
    /// @return The fee that was taken
    function _processFee(
        address token,
        uint256 amount,
        uint256 feeBps,
        address recipient
    ) internal returns (uint256) {
        if (feeBps == 0) {
            return 0;
        }
        uint256 fee = amount.mul(feeBps).div(MAX_FEE);
        IERC20Upgradeable(token).safeTransfer(recipient, fee);
        return fee;
    }

    function _transferToVault(uint256 _amount) internal {
        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20Upgradeable(want).safeTransfer(_vault, _amount);
    }
    
    /// @notice Utility function to diff two numbers, expects higher value in first position
    function _diff(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "diff/expected-higher-number-in-first-position");
        return a.sub(b);
    }

    // ===== Abstract Functions: To be implemented by specific Strategies =====

    /// @dev Internal deposit logic to be implemented by Stratgies
    function _deposit(uint256 _want) internal virtual;

    function _postDeposit() internal virtual {
        //no-op by default
    }

    /// @notice Specify tokens used in yield process, should not be available to withdraw via withdrawOther()
    function _onlyNotProtectedTokens(address _asset) internal virtual;

    function getProtectedTokens() public virtual view returns (address[] memory) {
        return new address[](0);
    }

    /// @dev Internal logic for strategy migration. Should exit positions as efficiently as possible
    function _withdrawAll() internal virtual;

    /// @dev Internal logic for partial withdrawals. Should exit positions as efficiently as possible.
    /// @dev The withdraw() function shell automatically uses idle want in the strategy before attempting to withdraw more using this
    function _withdrawSome(uint256 _amount) internal virtual returns (uint256);

    /// @dev Realize returns from positions
    /// @dev Returns can be reinvested into positions, or distributed in another fashion
    /// @dev Performance fees should also be implemented in this function
    /// @dev Override function stub is removed as each strategy can have it's own return signature for STATICCALL
    // function harvest() external virtual;

    /// @dev User-friendly name for this strategy for purposes of convenient reading
    function getName() external virtual pure returns (string memory);

    /// @dev Balance of want currently held in strategy positions
    function balanceOfPool() public virtual view returns (uint256);

    uint256[49] private __gap;
}


// File contracts/badger-sett/strategies/convex/StrategyCvxCrvHelper.sol



pragma solidity ^0.6.11;











/*
    1. Stake cvxCrv
    2. Sell earned rewards into cvxCrv position and restake
*/
contract StrategyCvxCrvHelper is BaseStrategy, CurveSwapper, UniswapSwapper, TokenSwapPathRegistry {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    // ===== Token Registry =====
    address public constant wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant crv = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address public constant cvx = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    address public constant cvxCrv = 0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7;
    address public constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant threeCrv = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;

    IERC20Upgradeable public constant crvToken = IERC20Upgradeable(0xD533a949740bb3306d119CC777fa900bA034cd52);
    IERC20Upgradeable public constant cvxToken = IERC20Upgradeable(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
    IERC20Upgradeable public constant cvxCrvToken = IERC20Upgradeable(0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7);
    IERC20Upgradeable public constant usdcToken = IERC20Upgradeable(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20Upgradeable public constant threeCrvToken = IERC20Upgradeable(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);

    address public constant threeCrvSwap = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;

    // ===== Convex Registry =====
    CrvDepositor public constant crvDepositor = CrvDepositor(0x8014595F2AB54cD7c604B00E9fb932176fDc86Ae); // Convert CRV -> cvxCRV/ETH SLP
    IBooster public constant booster = IBooster(0xF403C135812408BFbE8713b5A23a04b3D48AAE31);
    IBaseRewardsPool public constant cvxCrvRewardsPool = IBaseRewardsPool(0x3Fe65692bfCD0e6CF84cB1E7d24108E434A7587e);
    uint256 public constant MAX_UINT_256 = uint256(-1);

    event HarvestState(uint256 timestamp, uint256 blockNumber);

    event WithdrawState(uint256 toWithdraw, uint256 preWant, uint256 postWant, uint256 withdrawn);

    struct TokenSwapData {
        address tokenIn;
        uint256 totalSold;
        uint256 wantGained;
    }

    event TendState(uint256 crvTended, uint256 cvxTended, uint256 cvxCrvHarvested);

    function initialize(
        address _governance,
        address _strategist,
        address _controller,
        address _keeper,
        address _guardian,
        uint256[3] memory _feeConfig
    ) public initializer whenNotPaused {
        __BaseStrategy_init(_governance, _strategist, _controller, _keeper, _guardian);

        want = cvxCrv;

        performanceFeeGovernance = _feeConfig[0];
        performanceFeeStrategist = _feeConfig[1];
        withdrawalFee = _feeConfig[2];

        // Set Swap Paths
        address[] memory path = new address[](3);
        path[0] = cvx;
        path[1] = weth;
        path[2] = cvxCrv;
        _setTokenSwapPath(cvx, cvxCrv, path);

        path = new address[](3);
        path[0] = usdc;
        path[1] = weth;
        path[2] = cvxCrv;
        _setTokenSwapPath(usdc, cvxCrv, path);

        // Approvals: Staking Pool
        cvxCrvToken.approve(address(cvxCrvRewardsPool), MAX_UINT_256);
    }

    /// ===== View Functions =====
    function version() external pure returns (string memory) {
        return "1.0";
    }

    function getName() external pure override returns (string memory) {
        return "StrategyCvxCrvHelper";
    }

    function balanceOfPool() public view override returns (uint256) {
        return cvxCrvRewardsPool.balanceOf(address(this));
    }

    function getProtectedTokens() public view override returns (address[] memory) {
        address[] memory protectedTokens = new address[](2);
        protectedTokens[0] = want;
        protectedTokens[1] = cvxCrv;
        return protectedTokens;
    }

    function isTendable() public view override returns (bool) {
        return false;
    }

    /// ===== Internal Core Implementations =====
    function _onlyNotProtectedTokens(address _asset) internal override {
        require(!isProtectedToken(_asset));
    }

    /// @dev Deposit Badger into the staking contract
    function _deposit(uint256 _want) internal override {
        // Deposit all want in core staking pool
        cvxCrvRewardsPool.stake(_want);
    }

    /// @dev Unroll from all strategy positions, and transfer non-core tokens to controller rewards
    function _withdrawAll() internal override {
        // TODO: Functionality not required for initial migration
        // Note: All want is automatically withdrawn outside this "inner hook" in base strategy function
    }

    /// @dev Withdraw want from staking rewards, using earnings first
    function _withdrawSome(uint256 _amount) internal override returns (uint256) {
        // Get idle want in the strategy
        uint256 _preWant = IERC20Upgradeable(want).balanceOf(address(this));

        // If we lack sufficient idle want, withdraw the difference from the strategy position
        if (_preWant < _amount) {
            uint256 _toWithdraw = _amount.sub(_preWant);
            cvxCrvRewardsPool.withdraw(_toWithdraw, false);
            // Note: Withdrawl process will earn sushi, this will be deposited into SushiBar on next tend()
        }

        // Confirm how much want we actually end up with
        uint256 _postWant = IERC20Upgradeable(want).balanceOf(address(this));

        // Return the actual amount withdrawn if less than requested
        uint256 _withdrawn = MathUpgradeable.min(_postWant, _amount);
        emit WithdrawState(_amount, _preWant, _postWant, _withdrawn);

        return _withdrawn;
    }

    function _tendGainsFromPositions() internal {
        if (cvxCrvRewardsPool.earned(address(this)) > 0) {
            cvxCrvRewardsPool.getReward(address(this), true);
        }
    }

    function harvest() external whenNotPaused returns (uint256 cvxCrvHarvested) {
        _onlyAuthorizedActors();
        // 1. Harvest gains from positions
        _tendGainsFromPositions();

        // 2. Sell 3Crv (withdraw to USDC -> swap to CRV)
        uint256 threeCrvBalance = threeCrvToken.balanceOf(address(this));

        if (threeCrvBalance > 0) {      
            _remove_liquidity_one_coin(threeCrvSwap, threeCrvBalance, 1, 0);
            uint256 usdcBalance = usdcToken.balanceOf(address(this));
            require(usdcBalance > 0, "window-tint");
            if (usdcBalance > 0) {
                _swapExactTokensForTokens(sushiswap, usdc, usdcBalance, getTokenSwapPath(usdc, cvxCrv));
            }
            
        }

        // 3. Sell CVX
        uint256 cvxTokenBalance = cvxToken.balanceOf(address(this));
        if (cvxTokenBalance > 0) {
            _swapExactTokensForTokens(sushiswap, cvx, cvxTokenBalance, getTokenSwapPath(cvx, cvxCrv));
        }
        
        // Track harvested + converted coin balance of want
        cvxCrvHarvested = cvxCrvToken.balanceOf(address(this));

        // 4. Stake all cvxCRV
        if (cvxCrvHarvested > 0) {
            cvxCrvRewardsPool.stake(cvxCrvHarvested);
        }

        emit Tend(cvxCrvHarvested);
        return cvxCrvHarvested;
    }
}