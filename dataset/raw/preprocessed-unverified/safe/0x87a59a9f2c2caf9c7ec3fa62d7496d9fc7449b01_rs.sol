/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

pragma solidity 0.5.16;








contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

contract InitializableModuleKeys {

    // Governance                             // Phases
    bytes32 internal KEY_GOVERNANCE;          // 2.x
    bytes32 internal KEY_STAKING;             // 1.2
    bytes32 internal KEY_PROXY_ADMIN;         // 1.0

    // mStable
    bytes32 internal KEY_ORACLE_HUB;          // 1.2
    bytes32 internal KEY_MANAGER;             // 1.2
    bytes32 internal KEY_RECOLLATERALISER;    // 2.x
    bytes32 internal KEY_META_TOKEN;          // 1.1
    bytes32 internal KEY_SAVINGS_MANAGER;     // 1.0

    /**
     * @dev Initialize function for upgradable proxy contracts. This function should be called
     *      via Proxy to initialize constants in the Proxy contract.
     */
    function _initialize() internal {
        // keccak256() values are evaluated only once at the time of this function call.
        // Hence, no need to assign hard-coded values to these variables.
        KEY_GOVERNANCE = keccak256("Governance");
        KEY_STAKING = keccak256("Staking");
        KEY_PROXY_ADMIN = keccak256("ProxyAdmin");

        KEY_ORACLE_HUB = keccak256("OracleHub");
        KEY_MANAGER = keccak256("Manager");
        KEY_RECOLLATERALISER = keccak256("Recollateraliser");
        KEY_META_TOKEN = keccak256("MetaToken");
        KEY_SAVINGS_MANAGER = keccak256("SavingsManager");
    }
}



contract InitializableModule is InitializableModuleKeys {

    INexus public nexus;

    /**
     * @dev Modifier to allow function calls only from the Governor.
     */
    modifier onlyGovernor() {
        require(msg.sender == _governor(), "Only governor can execute");
        _;
    }

    /**
     * @dev Modifier to allow function calls only from the Governance.
     *      Governance is either Governor address or Governance address.
     */
    modifier onlyGovernance() {
        require(
            msg.sender == _governor() || msg.sender == _governance(),
            "Only governance can execute"
        );
        _;
    }

    /**
     * @dev Modifier to allow function calls only from the ProxyAdmin.
     */
    modifier onlyProxyAdmin() {
        require(
            msg.sender == _proxyAdmin(), "Only ProxyAdmin can execute"
        );
        _;
    }

    /**
     * @dev Modifier to allow function calls only from the Manager.
     */
    modifier onlyManager() {
        require(msg.sender == _manager(), "Only manager can execute");
        _;
    }

    /**
     * @dev Initialization function for upgradable proxy contracts
     * @param _nexus Nexus contract address
     */
    function _initialize(address _nexus) internal {
        require(_nexus != address(0), "Nexus address is zero");
        nexus = INexus(_nexus);
        InitializableModuleKeys._initialize();
    }

    /**
     * @dev Returns Governor address from the Nexus
     * @return Address of Governor Contract
     */
    function _governor() internal view returns (address) {
        return nexus.governor();
    }

    /**
     * @dev Returns Governance Module address from the Nexus
     * @return Address of the Governance (Phase 2)
     */
    function _governance() internal view returns (address) {
        return nexus.getModule(KEY_GOVERNANCE);
    }

    /**
     * @dev Return Staking Module address from the Nexus
     * @return Address of the Staking Module contract
     */
    function _staking() internal view returns (address) {
        return nexus.getModule(KEY_STAKING);
    }

    /**
     * @dev Return ProxyAdmin Module address from the Nexus
     * @return Address of the ProxyAdmin Module contract
     */
    function _proxyAdmin() internal view returns (address) {
        return nexus.getModule(KEY_PROXY_ADMIN);
    }

    /**
     * @dev Return MetaToken Module address from the Nexus
     * @return Address of the MetaToken Module contract
     */
    function _metaToken() internal view returns (address) {
        return nexus.getModule(KEY_META_TOKEN);
    }

    /**
     * @dev Return OracleHub Module address from the Nexus
     * @return Address of the OracleHub Module contract
     */
    function _oracleHub() internal view returns (address) {
        return nexus.getModule(KEY_ORACLE_HUB);
    }

    /**
     * @dev Return Manager Module address from the Nexus
     * @return Address of the Manager Module contract
     */
    function _manager() internal view returns (address) {
        return nexus.getModule(KEY_MANAGER);
    }

    /**
     * @dev Return SavingsManager Module address from the Nexus
     * @return Address of the SavingsManager Module contract
     */
    function _savingsManager() internal view returns (address) {
        return nexus.getModule(KEY_SAVINGS_MANAGER);
    }

    /**
     * @dev Return Recollateraliser Module address from the Nexus
     * @return  Address of the Recollateraliser Module contract (Phase 2)
     */
    function _recollateraliser() internal view returns (address) {
        return nexus.getModule(KEY_RECOLLATERALISER);
    }
}

contract ILiquidator {

    function createLiquidation(
        address _integration,
        address _sellToken,
        address _bAsset,
        int128 _curvePosition,
        address[] calldata _uniswapPath,
        uint256 _trancheAmount,
        uint256 _minReturn
    )
        external;

    function updateBasset(
        address _integration,
        address _bAsset,
        int128 _curvePosition,
        address[] calldata _uniswapPath,
        uint256 _trancheAmount,
        uint256 _minReturn
    )
        external;
        
    function deleteLiquidation(address _integration) external;

    function triggerLiquidation(address _integration) external;
}





/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


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

/**
 * @dev Collection of functions related to the address type
 */








/**
 * @title   Liquidator
 * @author  Stability Labs Pty. Ltd.
 * @notice  The Liquidator allows rewards to be swapped for another token
 *          and returned to a calling contract
 * @dev     VERSION: 1.0
 *          DATE:    2020-10-13
 */
contract Liquidator is
    ILiquidator,
    Initializable,
    InitializableModule
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event LiquidationModified(address indexed integration);
    event LiquidationEnded(address indexed integration);
    event Liquidated(address indexed sellToken, address mUSD, uint256 mUSDAmount, address buyToken);

    address public mUSD;
    ICurveMetaPool public curve;
    IUniswapV2Router02 public uniswap;

    mapping(address => Liquidation) public liquidations;
    mapping(address => uint256) public minReturn;

    struct Liquidation {
        address sellToken;

        address bAsset;
        int128 curvePosition;
        address[] uniswapPath;

        uint256 lastTriggered;
        uint256 trancheAmount;   // The amount of bAsset units to buy each week, with token decimals
    }

    function initialize(
        address _nexus,
        address _uniswap,
        address _curve,
        address _mUSD
    )
        external
        initializer
    {
        InitializableModule._initialize(_nexus);

        require(_uniswap != address(0), "Invalid uniswap address");
        uniswap = IUniswapV2Router02(_uniswap);

        require(_curve != address(0), "Invalid curve address");
        curve = ICurveMetaPool(_curve);

        require(_mUSD != address(0), "Invalid mUSD address");
        mUSD = _mUSD;
    }

    /***************************************
                    GOVERNANCE
    ****************************************/

    /**
    * @dev Create a liquidation
    * @param _integration The integration contract address from which to receive sellToken
    * @param _sellToken Token harvested from the integration contract
    * @param _bAsset The asset to buy on Uniswap
    * @param _curvePosition Position of the bAsset in Curves MetaPool
    * @param _uniswapPath The Uniswap path as an array of addresses e.g. [COMP, WETH, DAI]
    * @param _trancheAmount The amount of bAsset units to buy in each weekly tranche
    * @param _minReturn Minimum exact amount of bAsset to get for each (whole) sellToken unit
    */
    function createLiquidation(
        address _integration,
        address _sellToken,
        address _bAsset,
        int128 _curvePosition,
        address[] calldata _uniswapPath,
        uint256 _trancheAmount,
        uint256 _minReturn
    )
        external
        onlyGovernance
    {
        require(liquidations[_integration].sellToken == address(0), "Liquidation exists for this bAsset");

        require(
            _integration != address(0) &&
            _sellToken != address(0) &&
            _bAsset != address(0) &&
            _uniswapPath.length >= 2 &&
            _minReturn > 0,
            "Invalid inputs"
        );
        require(_validUniswapPath(_sellToken, _bAsset, _uniswapPath), "Invalid uniswap path");

        liquidations[_integration] = Liquidation({
            sellToken: _sellToken,
            bAsset: _bAsset,
            curvePosition: _curvePosition,
            uniswapPath: _uniswapPath,
            lastTriggered: 0,
            trancheAmount: _trancheAmount
        });
        minReturn[_integration] = _minReturn;

        emit LiquidationModified(_integration);
    }

    /**
    * @dev Update a liquidation
    * @param _integration The integration contract in question
    * @param _bAsset New asset to buy on Uniswap
    * @param _curvePosition Position of the bAsset in Curves MetaPool
    * @param _uniswapPath The Uniswap path as an array of addresses e.g. [COMP, WETH, DAI]
    * @param _trancheAmount The amount of bAsset units to buy in each weekly tranche
    * @param _minReturn Minimum exact amount of bAsset to get for each (whole) sellToken unit
    */
    function updateBasset(
        address _integration,
        address _bAsset,
        int128 _curvePosition,
        address[] calldata _uniswapPath,
        uint256 _trancheAmount,
        uint256 _minReturn
    )
        external
        onlyGovernance
    {
        Liquidation memory liquidation = liquidations[_integration];

        address oldBasset = liquidation.bAsset;
        require(oldBasset != address(0), "Liquidation does not exist");

        require(_minReturn > 0, "Must set some minimum value");
        require(_bAsset != address(0), "Invalid bAsset");
        require(_validUniswapPath(liquidation.sellToken, _bAsset, _uniswapPath), "Invalid uniswap path");

        liquidations[_integration].bAsset = _bAsset;
        liquidations[_integration].curvePosition = _curvePosition;
        liquidations[_integration].uniswapPath = _uniswapPath;
        liquidations[_integration].trancheAmount = _trancheAmount;
        minReturn[_integration] = _minReturn;

        emit LiquidationModified(_integration);
    }

    /**
    * @dev Validates a given uniswap path - valid if sellToken at position 0 and bAsset at end
    * @param _sellToken Token harvested from the integration contract
    * @param _bAsset New asset to buy on Uniswap
    * @param _uniswapPath The Uniswap path as an array of addresses e.g. [COMP, WETH, DAI]
    */
    function _validUniswapPath(address _sellToken, address _bAsset, address[] memory _uniswapPath)
        internal
        pure
        returns (bool)
    {
        uint256 len = _uniswapPath.length;
        return _sellToken == _uniswapPath[0] && _bAsset == _uniswapPath[len-1];
    }

    /**
    * @dev Delete a liquidation
    */
    function deleteLiquidation(address _integration)
        external
        onlyGovernance
    {
        Liquidation memory liquidation = liquidations[_integration];
        require(liquidation.bAsset != address(0), "Liquidation does not exist");

        delete liquidations[_integration];
        delete minReturn[_integration];

        emit LiquidationEnded(_integration);
    }

    /***************************************
                    LIQUIDATION
    ****************************************/

    /**
    * @dev Triggers a liquidation, flow (once per week):
    *    - Sells $COMP for $USDC (or other) on Uniswap (up to trancheAmount)
    *    - Sell USDC for mUSD on Curve
    *    - Send to SavingsManager
    * @param _integration Integration for which to trigger liquidation
    */
    function triggerLiquidation(address _integration)
        external
    {
        // solium-disable-next-line security/no-tx-origin
        require(tx.origin == msg.sender, "Must be EOA");

        Liquidation memory liquidation = liquidations[_integration];

        address bAsset = liquidation.bAsset;
        require(bAsset != address(0), "Liquidation does not exist");

        require(block.timestamp > liquidation.lastTriggered.add(7 days), "Must wait for interval");
        liquidations[_integration].lastTriggered = block.timestamp;

        // Cache variables
        address sellToken = liquidation.sellToken;
        address[] memory uniswapPath = liquidation.uniswapPath;

        // 1. Transfer sellTokens from integration contract if there are some
        //    Assumes infinite approval
        uint256 integrationBal = IERC20(sellToken).balanceOf(_integration);
        if (integrationBal > 0) {
            IERC20(sellToken).safeTransferFrom(_integration, address(this), integrationBal);
        }

        // 2. Get the amount to sell based on the tranche amount we want to buy
        //    Check contract balance
        uint256 sellTokenBal = IERC20(sellToken).balanceOf(address(this));
        require(sellTokenBal > 0, "No sell tokens to liquidate");
        require(liquidation.trancheAmount > 0, "Liquidation has been paused");
        //    Calc amounts for max tranche
        uint[] memory amountsIn = uniswap.getAmountsIn(liquidation.trancheAmount, uniswapPath);
        uint256 sellAmount = amountsIn[0];

        if (sellTokenBal < sellAmount) {
            sellAmount = sellTokenBal;
        }

        // 3. Make the swap
        // 3.1 Approve Uniswap and make the swap
        IERC20(sellToken).safeApprove(address(uniswap), 0);
        IERC20(sellToken).safeApprove(address(uniswap), sellAmount);
        // 3.2. Make the sale > https://uniswap.org/docs/v2/smart-contracts/router02/#swapexacttokensfortokens

        // min amount out = sellAmount * priceFloor / 1e18
        // e.g. 1e18 * 100e6 / 1e18 = 100e6
        // e.g. 30e8 * 100e6 / 1e8 = 3000e6
        // e.g. 30e18 * 100e18 / 1e18 = 3000e18
        uint256 sellTokenDec = IBasicToken(sellToken).decimals();
        uint256 minOut = sellAmount.mul(minReturn[_integration]).div(10 ** sellTokenDec);
        require(minOut > 0, "Must have some price floor");
        uniswap.swapExactTokensForTokens(
            sellAmount,
            minOut,
            uniswapPath,
            address(this),
            block.timestamp.add(1800)
        );

        // 3.3. Trade on Curve
        uint256 purchased = _sellOnCrv(bAsset, liquidation.curvePosition);

        // 4.0. Send to SavingsManager
        address savings = _savingsManager();
        IERC20(mUSD).safeApprove(savings, 0);
        IERC20(mUSD).safeApprove(savings, purchased);
        ISavingsManager(savings).depositLiquidation(mUSD, purchased);

        emit Liquidated(sellToken, mUSD, purchased, bAsset);
    }

    function _sellOnCrv(address _bAsset, int128 _curvePosition) internal returns (uint256 purchased) {
        uint256 bAssetBal = IERC20(_bAsset).balanceOf(address(this));

        IERC20(_bAsset).safeApprove(address(curve), 0);
        IERC20(_bAsset).safeApprove(address(curve), bAssetBal);
        uint256 bAssetDec = IBasicToken(_bAsset).decimals();
        // e.g. 100e6 * 95e16 / 1e6 = 100e18
        uint256 minOutCrv = bAssetBal.mul(95e16).div(10 ** bAssetDec);
        purchased = curve.exchange_underlying(_curvePosition, 0, bAssetBal, minOutCrv);
    }
}