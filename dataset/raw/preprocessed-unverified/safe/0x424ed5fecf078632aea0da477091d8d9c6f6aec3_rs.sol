/**
 *Submitted for verification at Etherscan.io on 2021-09-16
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;



// Part: AddressUpgradeable

/**
 * @dev Collection of functions related to the address type
 */


// Part: IController



// Part: ICvxLocker



// Part: IDelegateRegistry

///@dev Snapshot Delegate registry so we can delegate voting to XYZ


// Part: IERC20Upgradeable

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: ISettV4



// Part: IUniswapRouterV2



// Part: Initializable

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
        require(
            _initializing || _isConstructor() || !_initialized,
            "Initializable: contract is already initialized"
        );

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
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }
}

// Part: MathUpgradeable

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


// Part: SafeMathUpgradeable

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


// Part: ContextUpgradeable

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

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

// Part: SafeERC20Upgradeable

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// Part: SettAccessControl

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
        require(
            msg.sender == strategist || msg.sender == governance,
            "onlyGovernanceOrStrategist"
        );
    }

    function _onlyAuthorizedActors() internal view {
        require(
            msg.sender == keeper || msg.sender == governance,
            "onlyAuthorizedActors"
        );
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

// Part: PausableUpgradeable

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

// Part: BaseStrategy

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
    address public constant uniswap =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Uniswap Dex

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
        require(
            msg.sender == keeper ||
                msg.sender == governance ||
                msg.sender == controller,
            "onlyAuthorizedActorsOrController"
        );
    }

    function _onlyAuthorizedPausers() internal view {
        require(
            msg.sender == guardian || msg.sender == governance,
            "onlyPausers"
        );
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
    function balanceOf() public view virtual returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }

    function isTendable() public view virtual returns (bool) {
        return false;
    }

    /// ===== Permissioned Actions: Governance =====

    function setGuardian(address _guardian) external {
        _onlyGovernance();
        guardian = _guardian;
    }

    function setWithdrawalFee(uint256 _withdrawalFee) external {
        _onlyGovernance();
        require(
            _withdrawalFee <= MAX_FEE,
            "base-strategy/excessive-withdrawal-fee"
        );
        withdrawalFee = _withdrawalFee;
    }

    function setPerformanceFeeStrategist(uint256 _performanceFeeStrategist)
        external
    {
        _onlyGovernance();
        require(
            _performanceFeeStrategist <= MAX_FEE,
            "base-strategy/excessive-strategist-performance-fee"
        );
        performanceFeeStrategist = _performanceFeeStrategist;
    }

    function setPerformanceFeeGovernance(uint256 _performanceFeeGovernance)
        external
    {
        _onlyGovernance();
        require(
            _performanceFeeGovernance <= MAX_FEE,
            "base-strategy/excessive-governance-performance-fee"
        );
        performanceFeeGovernance = _performanceFeeGovernance;
    }

    function setController(address _controller) external {
        _onlyGovernance();
        controller = _controller;
    }

    function setWithdrawalMaxDeviationThreshold(uint256 _threshold) external {
        _onlyGovernance();
        require(
            _threshold <= MAX_FEE,
            "base-strategy/excessive-max-deviation-threshold"
        );
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
    function withdrawAll()
        external
        virtual
        whenNotPaused
        returns (uint256 balance)
    {
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
        uint256 _postWithdraw =
            IERC20Upgradeable(want).balanceOf(address(this));

        // Sanity check: Ensure we were able to retrieve sufficent want from strategy positions
        // If we end up with less than the amount requested, make sure it does not deviate beyond a maximum threshold
        if (_postWithdraw < _amount) {
            uint256 diff = _diff(_amount, _postWithdraw);

            // Require that difference between expected and actual values is less than the deviation threshold percentage
            require(
                diff <=
                    _amount.mul(withdrawalMaxDeviationThreshold).div(MAX_FEE),
                "base-strategy/withdraw-exceed-max-deviation-threshold"
            );
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
    function withdrawOther(address _asset)
        external
        virtual
        whenNotPaused
        returns (uint256 balance)
    {
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
        IERC20Upgradeable(want).safeTransfer(
            IController(controller).rewards(),
            fee
        );
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
        IUniswapRouterV2(uniswap).swapExactTokensForTokens(
            balance,
            0,
            path,
            address(this),
            now
        );
    }

    function _swapEthIn(uint256 balance, address[] memory path) internal {
        IUniswapRouterV2(uniswap).swapExactETHForTokens{value: balance}(
            0,
            path,
            address(this),
            now
        );
    }

    function _swapEthOut(
        address startToken,
        uint256 balance,
        address[] memory path
    ) internal {
        _safeApproveHelper(startToken, uniswap, balance);
        IUniswapRouterV2(uniswap).swapExactTokensForETH(
            balance,
            0,
            path,
            address(this),
            now
        );
    }

    /// @notice Add liquidity to uniswap for specified token pair, utilizing the maximum balance possible
    function _add_max_liquidity_uniswap(address token0, address token1)
        internal
        virtual
    {
        uint256 _token0Balance =
            IERC20Upgradeable(token0).balanceOf(address(this));
        uint256 _token1Balance =
            IERC20Upgradeable(token1).balanceOf(address(this));

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

    /// @notice Utility function to diff two numbers, expects higher value in first position
    function _diff(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "diff/expected-higher-number-in-first-position");
        return a.sub(b);
    }

    // ===== Abstract Functions: To be implemented by specific Strategies =====

    /// @dev Internal deposit logic to be implemented by Stratgies
    function _deposit(uint256 _amount) internal virtual;

    function _postDeposit() internal virtual {
        //no-op by default
    }

    /// @notice Specify tokens used in yield process, should not be available to withdraw via withdrawOther()
    function _onlyNotProtectedTokens(address _asset) internal virtual;

    function getProtectedTokens()
        external
        view
        virtual
        returns (address[] memory);

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
    function getName() external pure virtual returns (string memory);

    /// @dev Balance of want currently held in strategy positions
    function balanceOfPool() public view virtual returns (uint256);

    uint256[49] private __gap;
}

// File: MyStrategy.sol

contract MyStrategy is BaseStrategy {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    uint256 public constant MAX_BPS = 10_000;

    // address public want // Inherited from BaseStrategy, the token the strategy wants, swaps into and tries to grow
    address public lpComponent; // Token we provide liquidity with
    address public reward; // Token we farm and swap to want / lpComponent

    address public constant BADGER_TREE = 0x660802Fc641b154aBA66a62137e71f331B6d787A;

    IDelegateRegistry public constant SNAPSHOT =
        IDelegateRegistry(0x469788fE6E9E9681C6ebF3bF78e7Fd26Fc015446);

    // The initial DELEGATE for the strategy // NOTE we can change it by using manualSetDelegate below
    address public constant DELEGATE =
        0x14F83fF95D4Ec5E8812DDf42DA1232b0ba1015e6;

    bytes32 public constant DELEGATED_SPACE =
        0x6376782e65746800000000000000000000000000000000000000000000000000;
    
    ISettV4 public constant CVXCRV_VAULT =
        ISettV4(0x2B5455aac8d64C14786c3a29858E43b5945819C0);

    // NOTE: At time of publishing, this contract is under audit
    ICvxLocker public constant LOCKER = ICvxLocker(0xD18140b4B819b895A3dba5442F959fA44994AF50);

    bool public withdrawalSafetyCheck = true;
    bool public harvestOnRebalance = true;
    // If nothing is unlocked, processExpiredLocks will revert
    bool public processLocksOnReinvest = true;
    bool public processLocksOnRebalance = true;

    // Used to signal to the Badger Tree that rewards where sent to it
    event TreeDistribution(
        address indexed token,
        uint256 amount,
        uint256 indexed blockNumber,
        uint256 timestamp
    );
    event PerformanceFeeGovernance(
        address indexed destination,
        address indexed token,
        uint256 amount,
        uint256 indexed blockNumber,
        uint256 timestamp
    );
    event PerformanceFeeStrategist(
        address indexed destination,
        address indexed token,
        uint256 amount,
        uint256 indexed blockNumber,
        uint256 timestamp
    );

    function initialize(
        address _governance,
        address _strategist,
        address _controller,
        address _keeper,
        address _guardian,
        address[3] memory _wantConfig,
        uint256[3] memory _feeConfig
    ) public initializer {
        __BaseStrategy_init(
            _governance,
            _strategist,
            _controller,
            _keeper,
            _guardian
        );

        /// @dev Add config here
        want = _wantConfig[0];
        lpComponent = _wantConfig[1];
        reward = _wantConfig[2];

        performanceFeeGovernance = _feeConfig[0];
        performanceFeeStrategist = _feeConfig[1];
        withdrawalFee = _feeConfig[2];

        
        IERC20Upgradeable(reward).safeApprove(address(CVXCRV_VAULT), type(uint256).max);

        /// @dev do one off approvals here
        // Permissions for Locker
        IERC20Upgradeable(want).safeApprove(address(LOCKER), type(uint256).max);

        // Delegate voting to DELEGATE
        SNAPSHOT.setDelegate(DELEGATED_SPACE, DELEGATE);
    }

    /// ===== Extra Functions =====
    /// @dev Change Delegation to another address
    function manualSetDelegate(address delegate) external {
        _onlyGovernance();
        // Set delegate is enough as it will clear previous delegate automatically
        SNAPSHOT.setDelegate(DELEGATED_SPACE, delegate);
    }

    ///@dev Should we check if the amount requested is more than what we can return on withdrawal?
    function setWithdrawalSafetyCheck(bool newWithdrawalSafetyCheck) external {
        _onlyGovernance();
        withdrawalSafetyCheck = newWithdrawalSafetyCheck;
    }

    ///@dev Should we harvest before doing manual rebalancing
    ///@notice you most likely want to skip harvest if everything is unlocked, or there's something wrong and you just want out
    function setHarvestOnRebalance(bool newHarvestOnRebalance) external {
        _onlyGovernance();
        harvestOnRebalance = newHarvestOnRebalance;
    }

    ///@dev Should we processExpiredLocks during reinvest?
    function setProcessLocksOnReinvest(bool newProcessLocksOnReinvest) external {
        _onlyGovernance();
        processLocksOnReinvest = newProcessLocksOnReinvest;
    }

    ///@dev Should we processExpiredLocks during manualRebalance?
    function setProcessLocksOnRebalance(bool newProcessLocksOnRebalance)
        external
    {
        _onlyGovernance();
        processLocksOnRebalance = newProcessLocksOnRebalance;
    }

    /// ===== View Functions =====

    function getBoostPayment() public view returns(uint256){
        uint256 maximumBoostPayment = LOCKER.maximumBoostPayment();
        require(maximumBoostPayment <= 1500, "over max payment"); //max 15%
        return maximumBoostPayment;
    }

    /// @dev Specify the name of the strategy
    function getName() external pure override returns (string memory) {
        return "veCVX Voting Strategy";
    }

    /// @dev Specify the version of the Strategy, for upgrades
    function version() external pure returns (string memory) {
        return "1.0";
    }

    /// @dev Balance of want currently held in strategy positions
    function balanceOfPool() public view override returns (uint256) {
        // Return the balance in locker
        return LOCKER.lockedBalanceOf(address(this));
    }

    /// @dev Returns true if this strategy requires tending
    function isTendable() public view override returns (bool) {
        return false;
    }

    // @dev These are the tokens that cannot be moved except by the vault
    function getProtectedTokens()
        public
        view
        override
        returns (address[] memory)
    {
        address[] memory protectedTokens = new address[](3);
        protectedTokens[0] = want;
        protectedTokens[1] = lpComponent;
        protectedTokens[2] = reward;
        return protectedTokens;
    }

    /// ===== Internal Core Implementations =====
    /// @dev security check to avoid moving tokens that would cause a rugpull, edit based on strat
    function _onlyNotProtectedTokens(address _asset) internal override {
        address[] memory protectedTokens = getProtectedTokens();

        for (uint256 x = 0; x < protectedTokens.length; x++) {
            require(
                address(protectedTokens[x]) != _asset,
                "Asset is protected"
            );
        }
    }

    /// @dev invest the amount of want
    /// @notice When this function is called, the controller has already sent want to this
    /// @notice Just get the current balance and then invest accordingly
    function _deposit(uint256 _amount) internal override {
        // Lock tokens for 16 weeks, send credit to strat, always use max boost cause why not?
        LOCKER.lock(address(this), _amount, getBoostPayment());
    }

    /// @dev utility function to withdraw all CVX that we can from the lock
    function prepareWithdrawAll() external {
        manualProcessExpiredLocks();
    }

    /// @dev utility function to withdraw everything for migration
    /// @dev NOTE: You cannot call this unless you have rebalanced to have only CVX left in the vault
    function _withdrawAll() internal override {
        //NOTE: This probably will always fail unless we have all tokens expired
        require(
            LOCKER.lockedBalanceOf(address(this)) == 0 &&
                LOCKER.balanceOf(address(this)) == 0,
            "You have to wait for unlock or have to manually rebalance out of it"
        );

        // Make sure to call prepareWithdrawAll before _withdrawAll
    }

    /// @dev withdraw the specified amount of want, liquidate from lpComponent to want, paying off any necessary debt for the conversion
    function _withdrawSome(uint256 _amount)
        internal
        override
        returns (uint256)
    {
        uint256 max = IERC20Upgradeable(want).balanceOf(address(this));

        if (withdrawalSafetyCheck) {
            require(
                max >= _amount.mul(9_980).div(MAX_BPS),
                "Withdrawal Safety Check"
            ); // 20 BP of slippage
        }

        if (max < _amount) {
            return max;
        }

        return _amount;
    }

    /// @dev Harvest from strategy mechanics, realizing increase in underlying position
    function harvest() public whenNotPaused returns (uint256) {
        _onlyAuthorizedActors();

        uint256 _beforeReward = IERC20Upgradeable(reward).balanceOf(address(this));

        // Get cvxCRV
        LOCKER.getReward(address(this), false);

        // Rewards Math
        uint256 earnedReward =
            IERC20Upgradeable(reward).balanceOf(address(this)).sub(_beforeReward);

        uint256 cvxCrvToGovernance = earnedReward.mul(performanceFeeGovernance).div(MAX_FEE);
        if(cvxCrvToGovernance > 0){
            CVXCRV_VAULT.depositFor(IController(controller).rewards(), cvxCrvToGovernance);
            emit PerformanceFeeGovernance(IController(controller).rewards(), address(CVXCRV_VAULT), cvxCrvToGovernance, block.number, block.timestamp);
        }
        uint256 cvxCrvToStrategist = earnedReward.mul(performanceFeeStrategist).div(MAX_FEE);
        if(cvxCrvToStrategist > 0){
            CVXCRV_VAULT.depositFor(strategist, cvxCrvToStrategist);
            emit PerformanceFeeStrategist(strategist, address(CVXCRV_VAULT), cvxCrvToStrategist, block.number, block.timestamp);   
        }

        // Send rest of earned to tree //We send all rest to avoid dust and avoid protecting the token
        uint256 cvxCrvToTree = IERC20Upgradeable(reward).balanceOf(address(this));
        CVXCRV_VAULT.depositFor(BADGER_TREE, cvxCrvToTree);
        emit TreeDistribution(address(CVXCRV_VAULT), cvxCrvToTree, block.number, block.timestamp);


        /// @dev Harvest event that every strategy MUST have, see BaseStrategy
        emit Harvest(earnedReward, block.number);

        /// @dev Harvest must return the amount of want increased
        return earnedReward;
    }

    /// @dev Rebalance, Compound or Pay off debt here
    function tend() external whenNotPaused {
        revert("no op"); // NOTE: For now tend is replaced by manualRebalance
    }

    /// MANUAL FUNCTIONS ///

    /// @dev manual function to reinvest all CVX that was locked
    function reinvest() external whenNotPaused returns (uint256) {
        _onlyGovernance();

        if (processLocksOnReinvest) {
            // Withdraw all we can
            LOCKER.processExpiredLocks(false);
        }

        // Redeposit all into veCVX
        uint256 toDeposit = IERC20Upgradeable(want).balanceOf(address(this));

        // Redeposit into veCVX
        _deposit(toDeposit);

        return toDeposit;
    }

    /// @dev process all locks, to redeem
    function manualProcessExpiredLocks() public whenNotPaused {
        _onlyGovernance();
        LOCKER.processExpiredLocks(false);
        // Unlock veCVX that is expired and redeem CVX back to this strat
    }

    /// @dev Send all available CVX to the Vault
    /// @notice you can do this so you can earn again (re-lock), or just to add to the redemption pool
    function manualSendCVXToVault() external whenNotPaused {
        _onlyGovernance();
        uint256 cvxAmount = IERC20Upgradeable(want).balanceOf(address(this));
        _transferToVault(cvxAmount);
    }

    /// @dev use the currently available CVX to lock
    /// @notice toLock = 0, lock nothing, deposit in CVX as much as you can
    /// @notice toLock = 10_000, lock everything (CVX) you have
    function manualRebalance(uint256 toLock) external whenNotPaused {
        _onlyGovernance();
        require(toLock <= MAX_BPS, "Max is 100%");

        if (processLocksOnRebalance) {
            // manualRebalance will revert if you have no expired locks
            LOCKER.processExpiredLocks(false);
        }

        if (harvestOnRebalance) {
            harvest();
        }

        // Token that is highly liquid
        uint256 balanceOfWant =
            IERC20Upgradeable(want).balanceOf(address(this));
        // Locked CVX in the locker
        uint256 balanceInLock = LOCKER.balanceOf(address(this));
        uint256 totalCVXBalance =
            balanceOfWant.add(balanceInLock);

        // Amount we want to have in lock
        uint256 newLockAmount = totalCVXBalance.mul(toLock).div(MAX_BPS);

        // We can't unlock enough, no-op
        if (newLockAmount <= balanceInLock) {
            return;
        }

        // If we're continuing, then we are going to lock something
        uint256 cvxToLock = newLockAmount.sub(balanceInLock);

        // We only lock up to the available CVX
        uint256 maxCVX = IERC20Upgradeable(want).balanceOf(address(this));
        if (cvxToLock > maxCVX) {
            // Just lock what we can
            LOCKER.lock(address(this), maxCVX, getBoostPayment());
        } else {
            // Lock proper
            LOCKER.lock(address(this), cvxToLock, getBoostPayment());
        }

        // If anything left, send to vault
        uint256 cvxLeft = IERC20Upgradeable(want).balanceOf(address(this));
        if(cvxLeft > 0){
            _transferToVault(cvxLeft);
        }
    }
}