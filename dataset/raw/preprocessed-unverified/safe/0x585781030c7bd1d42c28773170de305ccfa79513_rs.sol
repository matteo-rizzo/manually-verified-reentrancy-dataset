/**
 *Submitted for verification at Etherscan.io on 2021-06-02
*/

pragma solidity 0.8.2;








struct BassetPersonal {
    // Address of the bAsset
    address addr;
    // Address of the bAsset
    address integrator;
    // An ERC20 can charge transfer fee, for example USDT, DGX tokens.
    bool hasTxFee; // takes a byte in storage
    // Status of the bAsset
    BassetStatus status;
}

// Status of the Basset - has it broken its peg?
enum BassetStatus {
    Default,
    Normal,
    BrokenBelowPeg,
    BrokenAbovePeg,
    Blacklisted,
    Liquidating,
    Liquidated,
    Failed
}

struct BassetData {
    // 1 Basset * ratio / ratioScale == x Masset (relative value)
    // If ratio == 10e8 then 1 bAsset = 10 mAssets
    // A ratio is divised as 10^(18-tokenDecimals) * measurementMultiple(relative value of 1 base unit)
    uint128 ratio;
    // Amount of the Basset that is held in Collateral
    uint128 vaultBalance;
}

abstract contract IMasset {
    // Mint
    function mint(
        address _input,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 mintOutput);

    function mintMulti(
        address[] calldata _inputs,
        uint256[] calldata _inputQuantities,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 mintOutput);

    function getMintOutput(address _input, uint256 _inputQuantity)
        external
        view
        virtual
        returns (uint256 mintOutput);

    function getMintMultiOutput(address[] calldata _inputs, uint256[] calldata _inputQuantities)
        external
        view
        virtual
        returns (uint256 mintOutput);

    // Swaps
    function swap(
        address _input,
        address _output,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 swapOutput);

    function getSwapOutput(
        address _input,
        address _output,
        uint256 _inputQuantity
    ) external view virtual returns (uint256 swapOutput);

    // Redemption
    function redeem(
        address _output,
        uint256 _mAssetQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 outputQuantity);

    function redeemMasset(
        uint256 _mAssetQuantity,
        uint256[] calldata _minOutputQuantities,
        address _recipient
    ) external virtual returns (uint256[] memory outputQuantities);

    function redeemExactBassets(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities,
        uint256 _maxMassetQuantity,
        address _recipient
    ) external virtual returns (uint256 mAssetRedeemed);

    function getRedeemOutput(address _output, uint256 _mAssetQuantity)
        external
        view
        virtual
        returns (uint256 bAssetOutput);

    function getRedeemExactBassetsOutput(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities
    ) external view virtual returns (uint256 mAssetAmount);

    // Views
    function getBasket() external view virtual returns (bool, bool);

    function getBasset(address _token)
        external
        view
        virtual
        returns (BassetPersonal memory personal, BassetData memory data);

    function getBassets()
        external
        view
        virtual
        returns (BassetPersonal[] memory personal, BassetData[] memory data);

    function bAssetIndexes(address) external view virtual returns (uint8);

    function getPrice() external view virtual returns (uint256 price, uint256 k);

    // SavingsManager
    function collectInterest() external virtual returns (uint256 swapFeesGained, uint256 newSupply);

    function collectPlatformInterest()
        external
        virtual
        returns (uint256 mintAmount, uint256 newSupply);

    // Admin
    function setCacheSize(uint256 _cacheSize) external virtual;

    function setFees(uint256 _swapFee, uint256 _redemptionFee) external virtual;

    function setTransferFeesFlag(address _bAsset, bool _flag) external virtual;

    function migrateBassets(address[] calldata _bAssets, address _newIntegration) external virtual;
}











/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Collection of functions related to the address type
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

contract ModuleKeys {
    // Governance
    // ===========
    // keccak256("Governance");
    bytes32 internal constant KEY_GOVERNANCE =
        0x9409903de1e6fd852dfc61c9dacb48196c48535b60e25abf92acc92dd689078d;
    //keccak256("Staking");
    bytes32 internal constant KEY_STAKING =
        0x1df41cd916959d1163dc8f0671a666ea8a3e434c13e40faef527133b5d167034;
    //keccak256("ProxyAdmin");
    bytes32 internal constant KEY_PROXY_ADMIN =
        0x96ed0203eb7e975a4cbcaa23951943fa35c5d8288117d50c12b3d48b0fab48d1;

    // mStable
    // =======
    // keccak256("OracleHub");
    bytes32 internal constant KEY_ORACLE_HUB =
        0x8ae3a082c61a7379e2280f3356a5131507d9829d222d853bfa7c9fe1200dd040;
    // keccak256("Manager");
    bytes32 internal constant KEY_MANAGER =
        0x6d439300980e333f0256d64be2c9f67e86f4493ce25f82498d6db7f4be3d9e6f;
    //keccak256("Recollateraliser");
    bytes32 internal constant KEY_RECOLLATERALISER =
        0x39e3ed1fc335ce346a8cbe3e64dd525cf22b37f1e2104a755e761c3c1eb4734f;
    //keccak256("MetaToken");
    bytes32 internal constant KEY_META_TOKEN =
        0xea7469b14936af748ee93c53b2fe510b9928edbdccac3963321efca7eb1a57a2;
    // keccak256("SavingsManager");
    bytes32 internal constant KEY_SAVINGS_MANAGER =
        0x12fe936c77a1e196473c4314f3bed8eeac1d757b319abb85bdda70df35511bf1;
    // keccak256("Liquidator");
    bytes32 internal constant KEY_LIQUIDATOR =
        0x1e9cb14d7560734a61fa5ff9273953e971ff3cd9283c03d8346e3264617933d4;
    // keccak256("InterestValidator");
    bytes32 internal constant KEY_INTEREST_VALIDATOR =
        0xc10a28f028c7f7282a03c90608e38a4a646e136e614e4b07d119280c5f7f839f;
}



abstract contract ImmutableModule is ModuleKeys {
    INexus public immutable nexus;

    /**
     * @dev Initialization function for upgradable proxy contracts
     * @param _nexus Nexus contract address
     */
    constructor(address _nexus) {
        require(_nexus != address(0), "Nexus address is zero");
        nexus = INexus(_nexus);
    }

    /**
     * @dev Modifier to allow function calls only from the Governor.
     */
    modifier onlyGovernor() {
        _onlyGovernor();
        _;
    }

    function _onlyGovernor() internal view {
        require(msg.sender == _governor(), "Only governor can execute");
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

    /**
     * @dev Return Recollateraliser Module address from the Nexus
     * @return  Address of the Recollateraliser Module contract (Phase 2)
     */
    function _liquidator() internal view returns (address) {
        return nexus.getModule(KEY_LIQUIDATOR);
    }

    /**
     * @dev Return ProxyAdmin Module address from the Nexus
     * @return Address of the ProxyAdmin Module contract
     */
    function _proxyAdmin() internal view returns (address) {
        return nexus.getModule(KEY_PROXY_ADMIN);
    }
}

abstract contract ReentrancyGuard {
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

    constructor () {
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

abstract contract AbstractIntegration is
    IPlatformIntegration,
    Initializable,
    ImmutableModule,
    ReentrancyGuard
{
    event PTokenAdded(address indexed _bAsset, address _pToken);

    event Deposit(address indexed _bAsset, address _pToken, uint256 _amount);
    event Withdrawal(address indexed _bAsset, address _pToken, uint256 _amount);
    event PlatformWithdrawal(
        address indexed bAsset,
        address pToken,
        uint256 totalAmount,
        uint256 userAmount
    );

    // LP has write access
    address public immutable lpAddress;

    // bAsset => pToken (Platform Specific Token Address)
    mapping(address => address) public override bAssetToPToken;
    // Full list of all bAssets supported here
    address[] internal bAssetsMapped;

    /**
     * @param _nexus     Address of the Nexus
     * @param _lp        Address of LP
     */
    constructor(address _nexus, address _lp) ReentrancyGuard() ImmutableModule(_nexus) {
        require(_lp != address(0), "Invalid LP address");
        lpAddress = _lp;
    }

    /**
     * @dev Simple initializer to set first bAsset/pTokens
     */
    function initialize(address[] calldata _bAssets, address[] calldata _pTokens)
        public
        initializer
    {
        uint256 len = _bAssets.length;
        require(len == _pTokens.length, "Invalid inputs");
        for (uint256 i = 0; i < len; i++) {
            _setPTokenAddress(_bAssets[i], _pTokens[i]);
        }
    }

    /**
     * @dev Modifier to allow function calls only from the Governor.
     */
    modifier onlyLP() {
        require(msg.sender == lpAddress, "Only the LP can execute");
        _;
    }

    /***************************************
                    CONFIG
    ****************************************/

    /**
     * @dev Provide support for bAsset by passing its pToken address.
     * This method can only be called by the system Governor
     * @param _bAsset   Address for the bAsset
     * @param _pToken   Address for the corresponding platform token
     */
    function setPTokenAddress(address _bAsset, address _pToken) external onlyGovernor {
        _setPTokenAddress(_bAsset, _pToken);
    }

    /**
     * @dev Provide support for bAsset by passing its pToken address.
     * Add to internal mappings and execute the platform specific,
     * abstract method `_abstractSetPToken`
     * @param _bAsset   Address for the bAsset
     * @param _pToken   Address for the corresponding platform token
     */
    function _setPTokenAddress(address _bAsset, address _pToken) internal {
        require(bAssetToPToken[_bAsset] == address(0), "pToken already set");
        require(_bAsset != address(0) && _pToken != address(0), "Invalid addresses");

        bAssetToPToken[_bAsset] = _pToken;
        bAssetsMapped.push(_bAsset);

        emit PTokenAdded(_bAsset, _pToken);

        _abstractSetPToken(_bAsset, _pToken);
    }

    function _abstractSetPToken(address _bAsset, address _pToken) internal virtual;

    /**
     * @dev Simple helper func to get the min of two values
     */
    function _min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x > y ? y : x;
    }
}

contract AaveV2Integration is AbstractIntegration {
    using SafeERC20 for IERC20;

    // Core address for the given platform */
    address public immutable platformAddress;
    address public immutable rewardToken;

    event RewardTokenApproved(address rewardToken, address account);

    /**
     * @param _nexus            Address of the Nexus
     * @param _lp               Address of LP
     * @param _platformAddress  Generic platform address
     * @param _rewardToken      Reward token, if any
     */
    constructor(
        address _nexus,
        address _lp,
        address _platformAddress,
        address _rewardToken
    ) AbstractIntegration(_nexus, _lp) {
        require(_platformAddress != address(0), "Invalid platform address");

        platformAddress = _platformAddress;

        rewardToken = _rewardToken;
    }

    /***************************************
                    ADMIN
    ****************************************/

    /**
     * @dev Approves Liquidator to spend reward tokens
     */
    function approveRewardToken() external onlyGovernor {
        address liquidator = nexus.getModule(keccak256("Liquidator"));
        require(liquidator != address(0), "Liquidator address cannot be zero");

        MassetHelpers.safeInfiniteApprove(rewardToken, liquidator);

        emit RewardTokenApproved(rewardToken, liquidator);
    }

    /***************************************
                    CORE
    ****************************************/

    /**
     * @dev Deposit a quantity of bAsset into the platform. Credited aTokens
     *      remain here in the vault. Can only be called by whitelisted addresses
     *      (mAsset and corresponding BasketManager)
     * @param _bAsset              Address for the bAsset
     * @param _amount              Units of bAsset to deposit
     * @param _hasTxFee            Is the bAsset known to have a tx fee?
     * @return quantityDeposited   Quantity of bAsset that entered the platform
     */
    function deposit(
        address _bAsset,
        uint256 _amount,
        bool _hasTxFee
    ) external override onlyLP nonReentrant returns (uint256 quantityDeposited) {
        require(_amount > 0, "Must deposit something");

        IAaveATokenV2 aToken = _getATokenFor(_bAsset);

        quantityDeposited = _amount;

        if (_hasTxFee) {
            // If we charge a fee, account for it
            uint256 prevBal = _checkBalance(aToken);
            _getLendingPool().deposit(_bAsset, _amount, address(this), 36);
            uint256 newBal = _checkBalance(aToken);
            quantityDeposited = _min(quantityDeposited, newBal - prevBal);
        } else {
            _getLendingPool().deposit(_bAsset, _amount, address(this), 36);
        }

        emit Deposit(_bAsset, address(aToken), quantityDeposited);
    }

    /**
     * @dev Withdraw a quantity of bAsset from the platform
     * @param _receiver     Address to which the bAsset should be sent
     * @param _bAsset       Address of the bAsset
     * @param _amount       Units of bAsset to withdraw
     * @param _hasTxFee     Is the bAsset known to have a tx fee?
     */
    function withdraw(
        address _receiver,
        address _bAsset,
        uint256 _amount,
        bool _hasTxFee
    ) external override onlyLP nonReentrant {
        _withdraw(_receiver, _bAsset, _amount, _amount, _hasTxFee);
    }

    /**
     * @dev Withdraw a quantity of bAsset from the platform
     * @param _receiver     Address to which the bAsset should be sent
     * @param _bAsset       Address of the bAsset
     * @param _amount       Units of bAsset to send to recipient
     * @param _totalAmount  Total units to pull from lending platform
     * @param _hasTxFee     Is the bAsset known to have a tx fee?
     */
    function withdraw(
        address _receiver,
        address _bAsset,
        uint256 _amount,
        uint256 _totalAmount,
        bool _hasTxFee
    ) external override onlyLP nonReentrant {
        _withdraw(_receiver, _bAsset, _amount, _totalAmount, _hasTxFee);
    }

    /** @dev Withdraws _totalAmount from the lending pool, sending _amount to user */
    function _withdraw(
        address _receiver,
        address _bAsset,
        uint256 _amount,
        uint256 _totalAmount,
        bool _hasTxFee
    ) internal {
        require(_totalAmount > 0, "Must withdraw something");

        IAaveATokenV2 aToken = _getATokenFor(_bAsset);

        if (_hasTxFee) {
            require(_amount == _totalAmount, "Cache inactive for assets with fee");
            _getLendingPool().withdraw(_bAsset, _amount, _receiver);
        } else {
            _getLendingPool().withdraw(_bAsset, _totalAmount, address(this));
            // Send redeemed bAsset to the receiver
            IERC20(_bAsset).safeTransfer(_receiver, _amount);
        }

        emit PlatformWithdrawal(_bAsset, address(aToken), _totalAmount, _amount);
    }

    /**
     * @dev Withdraw a quantity of bAsset from the cache.
     * @param _receiver     Address to which the bAsset should be sent
     * @param _bAsset       Address of the bAsset
     * @param _amount       Units of bAsset to withdraw
     */
    function withdrawRaw(
        address _receiver,
        address _bAsset,
        uint256 _amount
    ) external override onlyLP nonReentrant {
        require(_amount > 0, "Must withdraw something");
        require(_receiver != address(0), "Must specify recipient");

        IERC20(_bAsset).safeTransfer(_receiver, _amount);

        emit Withdrawal(_bAsset, address(0), _amount);
    }

    /**
     * @dev Get the total bAsset value held in the platform
     *      This includes any interest that was generated since depositing
     *      Aave gradually increases the balances of all aToken holders, as the interest grows
     * @param _bAsset     Address of the bAsset
     * @return balance    Total value of the bAsset in the platform
     */
    function checkBalance(address _bAsset) external override returns (uint256 balance) {
        // balance is always with token aToken decimals
        IAaveATokenV2 aToken = _getATokenFor(_bAsset);
        return _checkBalance(aToken);
    }

    /***************************************
                    APPROVALS
    ****************************************/

    /**
     * @dev Internal method to respond to the addition of new bAsset / pTokens
     *      We need to approve the Aave lending pool core conrtact and give it permission
     *      to spend the bAsset
     * @param _bAsset Address of the bAsset to approve
     */
    function _abstractSetPToken(
        address _bAsset,
        address /*_pToken*/
    ) internal override {
        address lendingPool = address(_getLendingPool());
        // approve the pool to spend the bAsset
        MassetHelpers.safeInfiniteApprove(_bAsset, lendingPool);
    }

    /***************************************
                    HELPERS
    ****************************************/

    /**
     * @dev Get the current address of the Aave lending pool, which is the gateway to
     *      depositing.
     * @return Current lending pool implementation
     */
    function _getLendingPool() internal view returns (IAaveLendingPoolV2) {
        address lendingPool = ILendingPoolAddressesProviderV2(platformAddress).getLendingPool();
        require(lendingPool != address(0), "Lending pool does not exist");
        return IAaveLendingPoolV2(lendingPool);
    }

    /**
     * @dev Get the pToken wrapped in the IAaveAToken interface for this bAsset, to use
     *      for withdrawing or balance checking. Fails if the pToken doesn't exist in our mappings.
     * @param _bAsset  Address of the bAsset
     * @return aToken  Corresponding to this bAsset
     */
    function _getATokenFor(address _bAsset) internal view returns (IAaveATokenV2) {
        address aToken = bAssetToPToken[_bAsset];
        require(aToken != address(0), "aToken does not exist");
        return IAaveATokenV2(aToken);
    }

    /**
     * @dev Get the total bAsset value held in the platform
     * @param _aToken     aToken for which to check balance
     * @return balance    Total value of the bAsset in the platform
     */
    function _checkBalance(IAaveATokenV2 _aToken) internal view returns (uint256 balance) {
        return _aToken.balanceOf(address(this));
    }
}



contract PAaveIntegration is AaveV2Integration {
    event RewardsClaimed(address[] assets, uint256 amount);

    IAaveIncentivesController public immutable rewardController;

    /**
     * @param _nexus            Address of the Nexus
     * @param _lp               Address of LP
     * @param _platformAddress  Generic platform address
     * @param _rewardToken      Reward token, if any
     * @param _rewardController AaveIncentivesController
     */
    constructor(
        address _nexus,
        address _lp,
        address _platformAddress,
        address _rewardToken,
        address _rewardController
    ) AaveV2Integration(_nexus, _lp, _platformAddress, _rewardToken) {
        require(_rewardController != address(0), "Invalid controller address");

        rewardController = IAaveIncentivesController(_rewardController);
    }

    /**
     * @dev Claims outstanding rewards from market
     */
    function claimRewards() external {
        uint256 len = bAssetsMapped.length;
        address[] memory pTokens = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            pTokens[i] = bAssetToPToken[bAssetsMapped[i]];
        }
        uint256 rewards = rewardController.claimRewards(pTokens, type(uint256).max, address(this));

        emit RewardsClaimed(pTokens, rewards);
    }
}

contract InitializableOld {

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

contract ModuleKeysStorage {
    // Deprecated stotage variables, but kept around to mirror storage layout
    bytes32 private DEPRECATED_KEY_GOVERNANCE;
    bytes32 private DEPRECATED_KEY_STAKING;
    bytes32 private DEPRECATED_KEY_PROXY_ADMIN;
    bytes32 private DEPRECATED_KEY_ORACLE_HUB;
    bytes32 private DEPRECATED_KEY_MANAGER;
    bytes32 private DEPRECATED_KEY_RECOLLATERALISER;
    bytes32 private DEPRECATED_KEY_META_TOKEN;
    bytes32 private DEPRECATED_KEY_SAVINGS_MANAGER;
}



// SPDX-License-Identifier: AGPL-3.0-or-later
// Need to use the old OZ Initializable as it reserved the first 50 slots of storage
/**
 * @title   Liquidator
 * @author  mStable
 * @notice  The Liquidator allows rewards to be swapped for another token
 *          and returned to a calling contract
 * @dev     VERSION: 1.3
 *          DATE:    2021-05-28
 */
contract Liquidator is InitializableOld, ModuleKeysStorage, ImmutableModule {
    using SafeERC20 for IERC20;

    event LiquidationModified(address indexed integration);
    event LiquidationEnded(address indexed integration);
    event Liquidated(address indexed sellToken, address mUSD, uint256 mUSDAmount, address buyToken);
    event ClaimedStakedAave(uint256 rewardsAmount);
    event RedeemedAave(uint256 redeemedAmount);

    // Deprecated stotage variables, but kept around to mirror storage layout
    address private deprecated_nexus;
    address public deprecated_mUSD;
    address public deprecated_curve;
    address public deprecated_uniswap;
    uint256 private deprecated_interval = 7 days;
    mapping(address => DeprecatedLiquidation) public deprecated_liquidations;
    mapping(address => uint256) public deprecated_minReturn;

    /// @notice mapping of integration addresses to liquidation data
    mapping(address => Liquidation) public liquidations;
    /// @notice Array of integration contracts used to loop through the Aave balances
    address[] public aaveIntegrations;
    /// @notice The total amount of stkAave that was claimed from all the Aave integration contracts.
    /// This can then be redeemed for Aave after the 10 day cooldown period.
    uint256 public totalAaveBalance;

    // Immutable variables set in the constructor
    /// @notice Staked AAVE token (stkAAVE) address
    address public immutable stkAave;
    /// @notice Aave Token (AAVE) address
    address public immutable aaveToken;
    /// @notice Uniswap V3 Router address
    IUniswapV3SwapRouter public immutable uniswapRouter;
    /// @notice Uniswap V3 Quoter address
    IUniswapV3Quoter public immutable uniswapQuoter;
    /// @notice Compound Token (COMP) address
    address public immutable compToken;

    // No longer used
    struct DeprecatedLiquidation {
        address sellToken;
        address bAsset;
        int128 curvePosition;
        address[] uniswapPath;
        uint256 lastTriggered;
        uint256 trancheAmount;
    }

    struct Liquidation {
        address sellToken;
        address bAsset;
        bytes uniswapPath;
        bytes uniswapPathReversed;
        uint256 lastTriggered;
        uint256 trancheAmount; // The max amount of bAsset units to buy each week, with token decimals
        uint256 minReturn;
        address mAsset;
        uint256 aaveBalance;
    }

    constructor(
        address _nexus,
        address _stkAave,
        address _aaveToken,
        address _uniswapRouter,
        address _uniswapQuoter,
        address _compToken
    ) ImmutableModule(_nexus) {
        require(_stkAave != address(0), "Invalid stkAAVE address");
        stkAave = _stkAave;

        require(_aaveToken != address(0), "Invalid AAVE address");
        aaveToken = _aaveToken;

        require(_uniswapRouter != address(0), "Invalid Uniswap Router address");
        uniswapRouter = IUniswapV3SwapRouter(_uniswapRouter);

        require(_uniswapQuoter != address(0), "Invalid Uniswap Quoter address");
        uniswapQuoter = IUniswapV3Quoter(_uniswapQuoter);

        require(_compToken != address(0), "Invalid COMP address");
        compToken = _compToken;
    }

    /**
     * @notice Liquidator approves Uniswap to transfer Aave and COMP tokens
     * @dev to be called via the proxy proposeUpgrade function, not the constructor.
     */
    function upgrade() external {
        IERC20(aaveToken).safeApprove(address(uniswapRouter), type(uint256).max);
        IERC20(compToken).safeApprove(address(uniswapRouter), type(uint256).max);
    }

    /***************************************
                    GOVERNANCE
    ****************************************/

    /**
     * @notice Create a liquidation
     * @param _integration The integration contract address from which to receive sellToken
     * @param _sellToken Token harvested from the integration contract. eg COMP or stkAave.
     * @param _bAsset The asset to buy on Uniswap. eg USDC or WBTC
     * @param _uniswapPath The Uniswap V3 bytes encoded path.
     * @param _trancheAmount The max amount of bAsset units to buy in each weekly tranche.
     * @param _minReturn Minimum exact amount of bAsset to get for each (whole) sellToken unit
     * @param _mAsset optional address of the mAsset. eg mUSD or mBTC. Use zero address if from a Feeder Pool.
     * @param _useAave flag if integration is with Aave
     */
    function createLiquidation(
        address _integration,
        address _sellToken,
        address _bAsset,
        bytes calldata _uniswapPath,
        bytes calldata _uniswapPathReversed,
        uint256 _trancheAmount,
        uint256 _minReturn,
        address _mAsset,
        bool _useAave
    ) external onlyGovernance {
        require(liquidations[_integration].sellToken == address(0), "Liquidation already exists");

        require(
            _integration != address(0) &&
                _sellToken != address(0) &&
                _bAsset != address(0) &&
                _minReturn > 0,
            "Invalid inputs"
        );
        require(_validUniswapPath(_sellToken, _bAsset, _uniswapPath), "Invalid uniswap path");
        require(
            _validUniswapPath(_bAsset, _sellToken, _uniswapPathReversed),
            "Invalid uniswap path reversed"
        );

        liquidations[_integration] = Liquidation({
            sellToken: _sellToken,
            bAsset: _bAsset,
            uniswapPath: _uniswapPath,
            uniswapPathReversed: _uniswapPathReversed,
            lastTriggered: 0,
            trancheAmount: _trancheAmount,
            minReturn: _minReturn,
            mAsset: _mAsset,
            aaveBalance: 0
        });
        if (_useAave) {
            aaveIntegrations.push(_integration);
        }

        if (_mAsset != address(0)) {
            // This Liquidator contract approves the mAsset to transfer bAssets for mint.
            // eg USDC in mUSD or WBTC in mBTC
            IERC20(_bAsset).safeApprove(_mAsset, 0);
            IERC20(_bAsset).safeApprove(_mAsset, type(uint256).max);

            // This Liquidator contract approves the Savings Manager to transfer mAssets
            // for depositLiquidation. eg mUSD
            // If the Savings Manager address was to change then
            // this liquidation would have to be deleted and a new one created.
            // Alternatively, a new liquidation contract could be deployed and proxy upgraded.
            address savings = _savingsManager();
            IERC20(_mAsset).safeApprove(savings, 0);
            IERC20(_mAsset).safeApprove(savings, type(uint256).max);
        } else {
            // This Liquidator contract approves the integration contract to transfer bAssets for deposits.
            // eg GUSD as part of the GUSD Feeder Pool.
            IERC20(_bAsset).safeApprove(_integration, 0);
            IERC20(_bAsset).safeApprove(_integration, type(uint256).max);
        }

        emit LiquidationModified(_integration);
    }

    /**
     * @notice Update a liquidation
     * @param _integration The integration contract in question
     * @param _bAsset New asset to buy on Uniswap
     * @param _uniswapPath The Uniswap V3 bytes encoded path.
     * @param _trancheAmount The max amount of bAsset units to buy in each weekly tranche.
     * @param _minReturn Minimum exact amount of bAsset to get for each (whole) sellToken unit
     */
    function updateBasset(
        address _integration,
        address _bAsset,
        bytes calldata _uniswapPath,
        bytes calldata _uniswapPathReversed,
        uint256 _trancheAmount,
        uint256 _minReturn
    ) external onlyGovernance {
        Liquidation memory liquidation = liquidations[_integration];

        address oldBasset = liquidation.bAsset;
        require(oldBasset != address(0), "Liquidation does not exist");

        require(_minReturn > 0, "Must set some minimum value");
        require(_bAsset != address(0), "Invalid bAsset");
        require(
            _validUniswapPath(liquidation.sellToken, _bAsset, _uniswapPath),
            "Invalid uniswap path"
        );
        require(
            _validUniswapPath(_bAsset, liquidation.sellToken, _uniswapPathReversed),
            "Invalid uniswap path reversed"
        );

        liquidations[_integration].bAsset = _bAsset;
        liquidations[_integration].uniswapPath = _uniswapPath;
        liquidations[_integration].trancheAmount = _trancheAmount;
        liquidations[_integration].minReturn = _minReturn;

        emit LiquidationModified(_integration);
    }

    /**
     * @notice Validates a given uniswap path - valid if sellToken at position 0 and bAsset at end
     * @param _sellToken Token harvested from the integration contract
     * @param _bAsset New asset to buy on Uniswap
     * @param _uniswapPath The Uniswap V3 bytes encoded path.
     */
    function _validUniswapPath(
        address _sellToken,
        address _bAsset,
        bytes calldata _uniswapPath
    ) internal pure returns (bool) {
        uint256 len = _uniswapPath.length;
        require(_uniswapPath.length >= 43, "Uniswap path too short");
        // check sellToken is first 20 bytes and bAsset is the last 20 bytes of the uniswap path
        return
            keccak256(abi.encodePacked(_sellToken)) ==
            keccak256(abi.encodePacked(_uniswapPath[0:20])) &&
            keccak256(abi.encodePacked(_bAsset)) ==
            keccak256(abi.encodePacked(_uniswapPath[len - 20:len]));
    }

    /**
     * @notice Delete a liquidation
     */
    function deleteLiquidation(address _integration) external onlyGovernance {
        Liquidation memory liquidation = liquidations[_integration];
        require(liquidation.bAsset != address(0), "Liquidation does not exist");

        delete liquidations[_integration];

        emit LiquidationEnded(_integration);
    }

    /***************************************
                    LIQUIDATION
    ****************************************/

    /**
     * @notice Triggers a liquidation, flow (once per week):
     *    - Sells $COMP for $USDC (or other) on Uniswap (up to trancheAmount)
     *    - Mint mUSD using USDC
     *    - Send to SavingsManager
     * @param _integration Integration for which to trigger liquidation
     */
    function triggerLiquidation(address _integration) external {
        // solium-disable-next-line security/no-tx-origin
        require(tx.origin == msg.sender, "Must be EOA");

        Liquidation memory liquidation = liquidations[_integration];

        address bAsset = liquidation.bAsset;
        require(bAsset != address(0), "Liquidation does not exist");

        require(block.timestamp > liquidation.lastTriggered + 7 days, "Must wait for interval");
        liquidations[_integration].lastTriggered = block.timestamp;

        address sellToken = liquidation.sellToken;

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
        uint256 sellAmount =
            uniswapQuoter.quoteExactOutput(
                liquidation.uniswapPathReversed,
                liquidation.trancheAmount
            );

        if (sellTokenBal < sellAmount) {
            sellAmount = sellTokenBal;
        }

        // 3. Make the swap
        // Uniswap V2 > https://docs.uniswap.org/reference/periphery/interfaces/ISwapRouter#exactinput
        // min amount out = sellAmount * priceFloor / 1e18
        // e.g. 1e18 * 100e6 / 1e18 = 100e6
        // e.g. 30e8 * 100e6 / 1e8 = 3000e6
        // e.g. 30e18 * 100e18 / 1e18 = 3000e18
        uint256 sellTokenDec = IBasicToken(sellToken).decimals();
        uint256 minOut = (sellAmount * liquidation.minReturn) / (10**sellTokenDec);
        require(minOut > 0, "Must have some price floor");
        IUniswapV3SwapRouter.ExactInputParams memory param =
            IUniswapV3SwapRouter.ExactInputParams(
                liquidation.uniswapPath,
                address(this),
                block.timestamp,
                sellAmount,
                minOut
            );
        uniswapRouter.exactInput(param);

        // 4. Mint mAsset using purchased bAsset
        address mAsset = liquidation.mAsset;
        uint256 minted = _mint(bAsset, mAsset);

        // 5. Send to SavingsManager
        address savings = _savingsManager();
        ISavingsManager(savings).depositLiquidation(mAsset, minted);

        emit Liquidated(sellToken, mAsset, minted, bAsset);
    }

    /**
     * @notice Claims stake Aave token rewards from each Aave integration contract
     * and then transfers all reward tokens to the liquidator contract.
     * Can only claim more stkAave if the last claim's unstake window has ended.
     */
    function claimStakedAave() external {
        // solium-disable-next-line security/no-tx-origin
        require(tx.origin == msg.sender, "Must be EOA");

        // If the last claim has not yet been liquidated
        uint256 totalAaveBalanceMemory = totalAaveBalance;
        if (totalAaveBalanceMemory > 0) {
            // Check unstake period has expired for this liquidator contract
            IStakedAave stkAaveContract = IStakedAave(stkAave);
            uint256 cooldownStartTime = stkAaveContract.stakersCooldowns(address(this));
            uint256 cooldownPeriod = stkAaveContract.COOLDOWN_SECONDS();
            uint256 unstakeWindow = stkAaveContract.UNSTAKE_WINDOW();

            // Can not claim more stkAave rewards if the last unstake window has not ended
            // Wait until the cooldown ends and liquidate
            require(
                block.timestamp > cooldownStartTime + cooldownPeriod,
                "Last claim cooldown not ended"
            );
            // or liquidate now as currently in the
            require(
                block.timestamp > cooldownStartTime + cooldownPeriod + unstakeWindow,
                "Must liquidate last claim"
            );
            // else the current time is past the unstake window so claim more stkAave and reactivate the cool down
        }

        // 1. For each Aave integration contract
        uint256 len = aaveIntegrations.length;
        for (uint256 i = 0; i < len; i++) {
            address integrationAdddress = aaveIntegrations[i];

            // 2. Claim the platform rewards on the integration contract. eg stkAave
            PAaveIntegration(integrationAdddress).claimRewards();

            // 3. Transfer sell token from integration contract if there are some
            //    Assumes the integration contract has already given infinite approval to this liquidator contract.
            uint256 integrationBal = IERC20(stkAave).balanceOf(integrationAdddress);
            if (integrationBal > 0) {
                IERC20(stkAave).safeTransferFrom(
                    integrationAdddress,
                    address(this),
                    integrationBal
                );
            }
            // Increate the integration contract's staked Aave balance.
            liquidations[integrationAdddress].aaveBalance += integrationBal;
            totalAaveBalanceMemory += integrationBal;
        }

        // Store the final total Aave balance in memory to storage variable.
        totalAaveBalance = totalAaveBalanceMemory;

        // 4. Restart the cool down as the start timestamp would have been reset to zero after the last redeem
        IStakedAave(stkAave).cooldown();

        emit ClaimedStakedAave(totalAaveBalanceMemory);
    }

    /**
     * @notice liquidates stkAave rewards earned by the Aave integration contracts:
     *      - Redeems Aave for stkAave rewards
     *      - swaps Aave for bAsset using Uniswap V2. eg Aave for USDC
     *      - for each Aave integration contract
     *        - if from a mAsset
     *          - mints mAssets using bAssets. eg mUSD for USDC
     *          - deposits mAssets to Savings Manager. eg mUSD
     *        - else from a Feeder Pool
     *          - transfer bAssets to integration contract. eg GUSD
     */
    function triggerLiquidationAave() external {
        // solium-disable-next-line security/no-tx-origin
        require(tx.origin == msg.sender, "Must be EOA");
        // Can not liquidate stkAave rewards if not already claimed by the integration contracts.
        require(totalAaveBalance > 0, "Must claim before liquidation");

        // 1. Redeem as many stkAave as we can for Aave
        // This will fail if the 10 day cooldown period has not passed
        // which is triggered in claimStakedAave().
        IStakedAave(stkAave).redeem(address(this), type(uint256).max);

        // 2. Get the amount of Aave tokens to sell
        uint256 totalAaveToLiquidate = IERC20(aaveToken).balanceOf(address(this));
        require(totalAaveToLiquidate > 0, "No Aave redeemed from stkAave");

        // for each Aave integration
        uint256 len = aaveIntegrations.length;
        for (uint256 i = 0; i < len; i++) {
            address _integration = aaveIntegrations[i];
            Liquidation memory liquidation = liquidations[_integration];

            // 3. Get the proportional amount of Aave tokens for this integration contract to liquidate
            // Amount of Aave to sell for this integration = total Aave to liquidate * integration's Aave balance / total of all integration Aave balances
            uint256 aaveSellAmount =
                (liquidation.aaveBalance * totalAaveToLiquidate) / totalAaveBalance;
            address bAsset = liquidation.bAsset;
            // If there's no Aave tokens to liquidate for this integration contract
            // or the liquidation has been deleted for the integration
            // then just move to the next integration contract.
            if (aaveSellAmount == 0 || bAsset == address(0)) {
                continue;
            }

            // Reset integration's Aave balance in storage
            liquidations[_integration].aaveBalance = 0;

            // 4. Make the swap of Aave for the bAsset
            // Make the sale > https://docs.uniswap.org/reference/periphery/interfaces/ISwapRouter#exactinput
            // min bAsset amount out = Aave sell amount * priceFloor / 1e18
            // e.g. 1e18 * 100e6 / 1e18 = 100e6
            // e.g. 30e8 * 100e6 / 1e8 = 3000e6
            // e.g. 30e18 * 100e18 / 1e18 = 3000e18
            uint256 minBassetsOut = (aaveSellAmount * liquidation.minReturn) / 1e18;
            require(minBassetsOut > 0, "Must have some price floor");
            IUniswapV3SwapRouter.ExactInputParams memory param =
                IUniswapV3SwapRouter.ExactInputParams(
                    liquidation.uniswapPath,
                    address(this),
                    block.timestamp + 1,
                    aaveSellAmount,
                    minBassetsOut
                );
            uniswapRouter.exactInput(param);

            address mAsset = liquidation.mAsset;
            // If the integration contract is connected to a mAsset like mUSD or mBTC
            if (mAsset != address(0)) {
                // 5a. Mint mAsset using bAsset from the Uniswap swap
                uint256 minted = _mint(bAsset, mAsset);

                // 6a. Send to SavingsManager to streamed to the savings vault. eg imUSD or imBTC
                address savings = _savingsManager();
                ISavingsManager(savings).depositLiquidation(mAsset, minted);

                emit Liquidated(aaveToken, mAsset, minted, bAsset);
            } else {
                // If a feeder pool like GUSD
                // 5b. transfer bAsset directly to the integration contract.
                // this will then increase the boosted savings vault price.
                IERC20 bAssetToken = IERC20(bAsset);
                uint256 bAssetBal = bAssetToken.balanceOf(address(this));
                bAssetToken.transfer(_integration, bAssetBal);

                emit Liquidated(aaveToken, mAsset, bAssetBal, bAsset);
            }
        }

        totalAaveBalance = 0;
    }

    function _mint(address _bAsset, address _mAsset) internal returns (uint256 minted) {
        uint256 bAssetBal = IERC20(_bAsset).balanceOf(address(this));

        uint256 bAssetDec = IBasicToken(_bAsset).decimals();
        // e.g. 100e6 * 95e16 / 1e6 = 100e18
        uint256 minOut = (bAssetBal * 90e16) / (10**bAssetDec);
        minted = IMasset(_mAsset).mint(_bAsset, bAssetBal, minOut, address(this));
    }
}