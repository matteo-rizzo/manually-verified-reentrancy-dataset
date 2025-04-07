/**
 *Submitted for verification at Etherscan.io on 2020-12-03
*/

// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol


// pragma solidity ^0.6.0;

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



// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol


// pragma solidity ^0.6.0;

// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: /Users/present/code/brownie-sett/interfaces/uniswap/IUniswapRouterV2.sol

// pragma solidity >=0.5.0 <0.8.0;




// Dependency file: /Users/present/code/brownie-sett/interfaces/uniswap/IUniswapV2Factory.sol

// pragma solidity >=0.5.0 <0.8.0;



// Dependency file: /Users/present/code/brownie-sett/interfaces/badger/IBadgerGeyser.sol


// pragma solidity >=0.5.0 <0.8.0;




// Dependency file: /Users/present/code/brownie-sett/interfaces/curve/ICurveFi.sol

// pragma solidity >=0.5.0 <0.8.0;




// Dependency file: /Users/present/code/brownie-sett/interfaces/curve/ICurveGauge.sol

// pragma solidity >=0.5.0 <0.8.0;



// Dependency file: /Users/present/code/brownie-sett/interfaces/badger/IController.sol

// pragma solidity >=0.5.0 <0.8.0;




// Dependency file: /Users/present/code/brownie-sett/interfaces/badger/IMintr.sol


// pragma solidity >=0.5.0 <0.8.0;




// Dependency file: /Users/present/code/brownie-sett/interfaces/badger/IStrategy.sol


// pragma solidity >=0.5.0 <0.8.0;




// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol


// pragma solidity >=0.4.24 <0.7.0;


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


// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/GSN/ContextUpgradeable.sol


// pragma solidity ^0.6.0;
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

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


// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol


// pragma solidity ^0.6.0;

// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/GSN/ContextUpgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

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


// Dependency file: contracts/badger-sett/SettAccessControl.sol

// pragma solidity ^0.6.11;

// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

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
        require(msg.sender == keeper || msg.sender == strategist || msg.sender == governance, "onlyAuthorizedActors");
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


// Dependency file: contracts/badger-sett/strategies/BaseStrategy.sol


// pragma solidity ^0.6.11;

// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
// import "/Users/present/code/brownie-sett/interfaces/uniswap/IUniswapRouterV2.sol";
// import "/Users/present/code/brownie-sett/interfaces/badger/IController.sol";
// import "/Users/present/code/brownie-sett/interfaces/badger/IStrategy.sol";

// import "contracts/badger-sett/SettAccessControl.sol";

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

    address public want; // Want: Curve.fi renBTC/wBTC (crvRenWBTC) LP token

    uint256 public performanceFeeGovernance;
    uint256 public performanceFeeStrategist;
    uint256 public withdrawalFee;

    uint256 public constant MAX_FEE = 10000;
    address public constant uniswap = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Uniswap Dex

    address public controller;
    address public guardian;

    function __BaseStrategy_init(
        address _governance,
        address _strategist,
        address _controller,
        address _keeper,
        address _guardian
    ) public initializer {
        __Pausable_init();
        governance = _governance;
        strategist = _strategist;
        keeper = _keeper;
        controller = _controller;
        guardian = _guardian;
    }

    // ===== Modifiers =====

    function _onlyController() internal view {
        require(msg.sender == controller, "onlyController");
    }

    function _onlyAuthorizedActorsOrController() internal view {
        require(
            msg.sender == keeper || msg.sender == strategist || msg.sender == governance || msg.sender == controller,
            "onlyAuthorizedActorsOrController"
        );
    }

    function _onlyAuthorizedPausers() internal view {
        require(msg.sender == guardian || msg.sender == strategist || msg.sender == governance, "onlyPausers");
    }

    /// ===== View Functions =====

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

    /// ===== Permissioned Actions: Governance =====

    function setGuardian(address _guardian) external {
        _onlyGovernance();
        guardian = _guardian;
    }

    function setWithdrawalFee(uint256 _withdrawalFee) external {
        _onlyGovernance();
        withdrawalFee = _withdrawalFee;
    }

    function setPerformanceFeeStrategist(uint256 _performanceFeeStrategist) external {
        _onlyGovernance();
        performanceFeeStrategist = _performanceFeeStrategist;
    }

    function setPerformanceFeeGovernance(uint256 _performanceFeeGovernance) external {
        _onlyGovernance();
        performanceFeeGovernance = _performanceFeeGovernance;
    }

    function setController(address _controller) external {
        _onlyGovernance();
        controller = _controller;
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

    /// @notice Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external virtual whenNotPaused returns (uint256 balance)
     {
        _onlyController();

        _withdrawAll();

        _transferToVault(IERC20Upgradeable(want).balanceOf(address(this)));
    }

    /// @notice Controller-only function to Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint256 _amount) external virtual whenNotPaused {
        _onlyController();

        uint256 _balance = IERC20Upgradeable(want).balanceOf(address(this));

        // Withdraw some from activities if idle want is not sufficient to cover withdrawal
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }

        // Process withdrawal fee
        uint256 _fee = _processWithdrawalFee(_amount);

        // Transfer remaining to Vault to handle withdrawal
        _transferToVault(_amount.sub(_fee));
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
        _onlyAuthorizedPausers();
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

    /// @dev Reset approval and approve exact amount
    function _safeApproveHelper(
        address token,
        address recipient,
        uint256 amount
    ) internal {
        IERC20Upgradeable(token).safeApprove(recipient, 0);
        IERC20Upgradeable(token).safeApprove(recipient, amount);
    }

    function _transferToVault(uint256 _amount) internal {
        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20Upgradeable(want).safeTransfer(_vault, _amount);
    }

    /// @notice Swap specified balance of given token on Uniswap with given path
    function _swap(
        address startToken,
        uint256 balance,
        address[] memory path
    ) internal {
        _safeApproveHelper(startToken, uniswap, balance);
        IUniswapRouterV2(uniswap).swapExactTokensForTokens(balance, 0, path, address(this), now);
    }

    function _swapEthIn(
        uint256 balance,
        address[] memory path
    ) internal {
        IUniswapRouterV2(uniswap).swapExactETHForTokens{value: balance}(0, path, address(this), now);
    }

    function _swapEthOut(
        address startToken,
        uint256 balance,
        address[] memory path
    ) internal {
        _safeApproveHelper(startToken, uniswap, balance);
        IUniswapRouterV2(uniswap).swapExactTokensForETH(balance, 0, path, address(this), now);
    }

    /// @notice Add liquidity to uniswap for specified token pair, utilizing the maximum balance possible
    function _add_max_liquidity_uniswap(address token0, address token1) internal {
        uint256 _token0Balance = IERC20Upgradeable(token0).balanceOf(address(this));
        uint256 _token1Balance = IERC20Upgradeable(token1).balanceOf(address(this));

        _safeApproveHelper(token0, uniswap, _token0Balance);
        _safeApproveHelper(token1, uniswap, _token1Balance);

        IUniswapRouterV2(uniswap).addLiquidity(
            token0,
            token1,
            _token0Balance,
            _token1Balance,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    // ===== Abstract Functions: To be implemented by specific Strategies =====

    /// @dev Internal deposit logic to be implemented by Stratgies
    function _deposit(uint256 _want) internal virtual;

    function _postDeposit() internal virtual {
        //no-op by default
    }

    /// @notice Specify tokens used in yield process, should not be available to withdraw via withdrawOther()
    function _onlyNotProtectedTokens(address _asset) internal virtual;

    function getProtectedTokens() external view virtual returns (address[] memory);

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

    uint256[50] private __gap;
}


// Dependency file: /Users/present/code/brownie-sett/interfaces/uniswap/IStakingRewards.sol

// pragma solidity >=0.5.0 <0.8.0;




// Root file: contracts/badger-sett/strategies/native/StrategyBadgerLpMetaFarm.sol


pragma solidity ^0.6.11;
pragma experimental ABIEncoderV2;

// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
// import "/Users/present/code/brownie-sett/interfaces/uniswap/IUniswapRouterV2.sol";
// import "/Users/present/code/brownie-sett/interfaces/uniswap/IUniswapV2Factory.sol";
// import "/Users/present/code/brownie-sett/interfaces/badger/IBadgerGeyser.sol";

// import "/Users/present/code/brownie-sett/interfaces/curve/ICurveFi.sol";
// import "/Users/present/code/brownie-sett/interfaces/curve/ICurveGauge.sol";
// import "/Users/present/code/brownie-sett/interfaces/uniswap/IUniswapRouterV2.sol";

// import "/Users/present/code/brownie-sett/interfaces/badger/IController.sol";
// import "/Users/present/code/brownie-sett/interfaces/badger/IMintr.sol";
// import "/Users/present/code/brownie-sett/interfaces/badger/IStrategy.sol";

// import "contracts/badger-sett/strategies/BaseStrategy.sol";
// import "/Users/present/code/brownie-sett/interfaces/uniswap/IStakingRewards.sol";

/*
    Strategy to compound badger rewards
    - Deposit Badger into the vault to receive more from a special rewards pool
*/
contract StrategyBadgerLpMetaFarm is BaseStrategy {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    address public geyser;
    address public badger; // Badger Token
    address public constant wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599; // wBTC Token
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Weth Token, used for crv <> weth <> wbtc route

    event HarvestLpMetaFarm(
        uint256 badgerHarvested,
        uint256 totalBadger,
        uint256 badgerConvertedToWbtc,
        uint256 wtbcFromConversion,
        uint256 lpGained,
        uint256 lpDeposited,
        uint256 timestamp,
        uint256 blockNumber
    );

    struct HarvestData {
        uint256 badgerHarvested;
        uint256 totalBadger;
        uint256 badgerConvertedToWbtc;
        uint256 wtbcFromConversion;
        uint256 lpGained;
        uint256 lpDeposited;
    }

    function initialize(
        address _governance,
        address _strategist,
        address _controller,
        address _keeper,
        address _guardian,
        address[3] memory _wantConfig,
        uint256[3] memory _feeConfig
    ) public initializer {
        __BaseStrategy_init(_governance, _strategist, _controller, _keeper, _guardian);

        want = _wantConfig[0];
        geyser = _wantConfig[1];
        badger = _wantConfig[2];

        performanceFeeGovernance = _feeConfig[0];
        performanceFeeStrategist = _feeConfig[1];
        withdrawalFee = _feeConfig[2];
    }

    /// ===== View Functions =====
    function getName() external override pure returns (string memory) {
        return "StrategyBadgerLpMetaFarm";
    }

    function balanceOfPool() public override view returns (uint256) {
        return IStakingRewards(geyser).balanceOf(address(this));
    }

    function getProtectedTokens() external view override returns (address[] memory) {
        address[] memory protectedTokens = new address[](3);
        protectedTokens[0] = want;
        protectedTokens[1] = geyser;
        protectedTokens[2] = badger;
        return protectedTokens;
    }

    /// ===== Internal Core Implementations =====

    function _onlyNotProtectedTokens(address _asset) internal override {
        require(address(want) != _asset, "want");
        require(address(geyser) != _asset, "geyser");
        require(address(badger) != _asset, "geyser");
    }

    /// @dev Deposit Badger into the staking contract
    function _deposit(uint256 _want) internal override {
        _safeApproveHelper(want, geyser, _want);
        IStakingRewards(geyser).stake(_want);
    }

    /// @dev Exit stakingRewards position
    /// @dev Harvest all Badger and sent to controller
    function _withdrawAll() internal override {
        IStakingRewards(geyser).exit();

        // Send non-native rewards to controller
        uint256 _badger = IERC20Upgradeable(badger).balanceOf(address(this));
        IERC20Upgradeable(badger).safeTransfer(IController(controller).rewards(), _badger);
    }

    /// @dev Withdraw from staking rewards, using earnings first
    function _withdrawSome(uint256 _amount) internal override returns (uint256) {
        uint256 _want = IERC20Upgradeable(want).balanceOf(address(this));

        if (_want < _amount) {
            uint256 _toWithdraw = _amount.sub(_want);
            IStakingRewards(geyser).withdraw(_toWithdraw);
        }

        return _amount;
    }

    /// @dev Harvest accumulated badger rewards and convert them to LP tokens
    /// @dev Restake the gained LP tokens in the Geyser
    function harvest() external whenNotPaused returns (HarvestData memory) {
        _onlyAuthorizedActors();

        HarvestData memory harvestData;

        uint256 _beforeBadger = IERC20Upgradeable(badger).balanceOf(address(this));
        uint256 _beforeLp = IERC20Upgradeable(want).balanceOf(address(this));

        // Harvest rewards from Geyser
        IStakingRewards(geyser).getReward();

        harvestData.totalBadger = IERC20Upgradeable(badger).balanceOf(address(this));
        harvestData.badgerHarvested = harvestData.totalBadger.sub(_beforeBadger);

        // Swap half of harvested badger for wBTC in liquidity pool
        if (harvestData.totalBadger > 0) {
            harvestData.badgerConvertedToWbtc = harvestData.badgerHarvested.div(2);
            if (harvestData.badgerConvertedToWbtc > 0) {
                address[] memory path = new address[](2);
                path[0] = badger; // Badger
                path[1] = wbtc;

                _swap(badger, harvestData.badgerConvertedToWbtc, path);

                // Add Badger and wBTC as liquidity if any to add
                _add_max_liquidity_uniswap(badger, wbtc);
            }
        }

        // Deposit gained LP position into staking rewards
        harvestData.lpDeposited = IERC20Upgradeable(want).balanceOf(address(this));
        harvestData.lpGained = harvestData.lpDeposited.sub(_beforeLp);
        if (harvestData.lpGained > 0) {
            _deposit(harvestData.lpGained);
        }

        emit HarvestLpMetaFarm(
            harvestData.badgerHarvested,
            harvestData.totalBadger,
            harvestData.badgerConvertedToWbtc,
            harvestData.wtbcFromConversion,
            harvestData.lpGained,
            harvestData.lpDeposited,
            block.timestamp,
            block.number
        );
        emit Harvest(harvestData.lpGained, block.number);

        return harvestData;
    }
}