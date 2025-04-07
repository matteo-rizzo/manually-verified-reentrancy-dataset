/**
 *Submitted for verification at Etherscan.io on 2021-02-26
*/

/**
 *Submitted for verification at Etherscan.io on 2020-12-03
*/

pragma solidity >=0.6.8;


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


// 


// 
abstract contract Keep3r {
    IKeep3rV1 public keep3r;

    constructor(address _keep3r) public {
        _setKeep3r(_keep3r);
    }

    function _setKeep3r(address _keep3r) internal {
        keep3r = IKeep3rV1(_keep3r);
    }

    function _isKeeper() internal {
        require(tx.origin == msg.sender, "keep3r::isKeeper:keeper-is-a-smart-contract");
        require(keep3r.isKeeper(msg.sender), "keep3r::isKeeper:keeper-is-not-registered");
    }

    // Only checks if caller is a valid keeper, payment should be handled manually
    modifier onlyKeeper() {
        _isKeeper();
        _;
    }

    // Checks if caller is a valid keeper, handles default payment after execution
    modifier paysKeeper() {
        _isKeeper();
        _;
        keep3r.worked(msg.sender);
    }
}

// 


// 


// 


// 
interface ICrvStrategy is IStrategy {
    function getHarvestable() external returns (uint256);
}

// 
interface ICompStrategy is IStrategy {
    function getCompAccrued() external returns (uint256);
}

interface ICollateralizedStrategy is IStrategy {
    function keepMinRatio() external;
    function currentRatio() external view returns (uint256);
    function minRatio() external view returns (uint256);
    function setMinRatio(uint256 _minRatio) external;
}

interface ILeveragedStrategy is IStrategy {
    function leverageToMax() external;
}







// 
// inspired by & thanks to https://macarse.medium.com/the-keep3r-network-experiment-bb1c5182bda3
// 
contract GenericKeep3rV2 is Keep3r, IMMStrategyHarvestKp3r {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet internal availableStrategies;
    EnumerableSet.AddressSet internal leveragedStrategies;
    EnumerableSet.AddressSet internal collateralizedStrategies;
    EnumerableSet.AddressSet internal availableVaults;
    
    // one-to-one mapping from vault to strategy
    mapping(address => address) public vaultStrategies;
    // required gas cost on strategy harvest()
    mapping(address => uint256) public requiredHarvest;
    // last harvest timestamp for strategy
    mapping(address => uint256) public strategyLastHarvest;
    // profit token yield by strategy harvest()
    mapping(address => address) public stratagyYieldTokens;
    // oracles used in harvest() for strategy: 
    //    0 : slidingOracle 
    //    1 : sushiSlidingOracle 
    //    anything > 1 : simply use token number instead price oracle
    mapping(address => uint256) public stratagyYieldTokenOracles;
    // required minimum token available for vault earn(), may subject to change to make this job reasonable
    mapping(address => uint256) public requiredEarnBalance;
    
    address public keep3rHelper;
    address public slidingOracle;
    address public sushiSlidingOracle;
    address public mmController;

    address public constant KP3R = address(0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44);
    address public constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public constant CRV = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public constant COMP = address(0xc00e94Cb662C3520282E6f5717214004A7f26888);
    address public constant MIR = address(0x09a3EcAFa817268f77BE1283176B946C4ff2E608);
    address public constant THREECRV = address(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);
    address public constant CRVRENWBTC = address(0x49849C98ae39Fff122806C06791Fa73784FB3675);
    address public constant DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F );
    address public constant USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 );
    address public constant MIRUSTLP = address(0x87dA823B6fC8EB8575a235A824690fda94674c88 );
    address public constant WBTC = address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    address public constant LINK = address(0x514910771AF9Ca656af840dff83E8264EcF986CA);
    address public constant ZRX = address(0xE41d2489571d322189246DaFA5ebDe1F4699F498);
    uint256 public constant UNISWAP_ORACLE = 0;
    uint256 public constant SUSHISWAP_ORACLE = 1;

    // The minimum number of seconds between harvest calls, once half a day
    uint256 public minHarvestInterval = 43200;

    // The minimum multiple that `callCost` must be above the profit to be "justifiable"
    uint256 public profitFactor = 1;

    address public governor;

    constructor(
        address _keep3r,
        address _keep3rHelper,
        address _slidingOracle,
        address _sushiSlidingOracle,
        address _mmController
    ) public Keep3r(_keep3r) {
        
        keep3rHelper = _keep3rHelper;
        slidingOracle = _slidingOracle;
        sushiSlidingOracle = _sushiSlidingOracle;
        governor = msg.sender;
		mmController = _mmController;
    
        // add exisitng vaults         
        addVault(MMController(_mmController).vaults(THREECRV), 10000 * 1e18);    // Matsutake Field   3CRV
        addVault(MMController(_mmController).vaults(CRVRENWBTC), 1 * 1e18);      // Boletus Field     crvRENWBTC
        addVault(MMController(_mmController).vaults(DAI), 10000 * 1e18);         // Kikurage Field    DAI
        addVault(MMController(_mmController).vaults(USDC), 10000 * 1e6);         // Lentinula Field   USDC
        addVault(MMController(_mmController).vaults(MIRUSTLP), 1000 * 1e18);     // Agaricus Field    MIR-UST LP
        addVault(MMController(_mmController).vaults(WETH), 10 * 1e18);           // Russula Field     WETH
        addVault(MMController(_mmController).vaults(WBTC), 1 * 1e18);            // Pleurotus Field   WBTC
        addVault(MMController(_mmController).vaults(LINK), 400 * 1e18);          // Calvatia Field    LINK
        addVault(MMController(_mmController).vaults(ZRX), 10000 * 1e18);         // Helvella Field    ZRX
        
        // add exisitng strategies
        addStrategy(MMController(_mmController).vaults(THREECRV), MMController(_mmController).strategies(THREECRV), 1000000, false, false, CRV, SUSHISWAP_ORACLE);      // 3CRV              Yield $CRV
        addStrategy(MMController(_mmController).vaults(CRVRENWBTC), MMController(_mmController).strategies(CRVRENWBTC), 1000000, false, false, CRV, SUSHISWAP_ORACLE);  // crvRENWBTC        Yield $CRV
        addStrategy(MMController(_mmController).vaults(DAI), MMController(_mmController).strategies(DAI), 700000, false, true, COMP, SUSHISWAP_ORACLE);                 // DAI               Leveraged Yield $COMP
        addStrategy(MMController(_mmController).vaults(USDC), MMController(_mmController).strategies(USDC), 700000, false, true, COMP, SUSHISWAP_ORACLE);               // USDC              Leveraged Yield $COMP
        addStrategy(MMController(_mmController).vaults(MIRUSTLP), MMController(_mmController).strategies(MIRUSTLP), 850000, false, false, MIR, 1000 * 1e18);            // MIR-UST LP        Yield $MIR
        addStrategy(MMController(_mmController).vaults(WETH), MMController(_mmController).strategies(WETH), 1100000, true, true, COMP, SUSHISWAP_ORACLE);               // WETH              Collateralized & Leveraged Yield $COMP
        addStrategy(MMController(_mmController).vaults(WBTC), MMController(_mmController).strategies(WBTC), 700000, false, true, COMP, SUSHISWAP_ORACLE);               // WBTC              Leveraged Yield $COMP
        addStrategy(MMController(_mmController).vaults(LINK), MMController(_mmController).strategies(LINK), 1100000, true, true, COMP, SUSHISWAP_ORACLE);               // LINK              Collateralized & Leveraged Yield $COMP
        addStrategy(MMController(_mmController).vaults(ZRX), MMController(_mmController).strategies(ZRX), 1100000, true, true, COMP, SUSHISWAP_ORACLE);                 // ZRX               Collateralized & Leveraged Yield $COMP
    }

    modifier onlyGovernor {
        require(msg.sender == governor, "governable::only-governor");
        _;
    }

    function _setGovernor(address _governor) external onlyGovernor {
        require(_governor != address(0), "governable::governor-should-not-be-zero-addres");
        governor = _governor;
    }

    // Unique method to add a strategy with specified parameters to the system
    function addStrategy(address _vault, address _strategy, uint256 _requiredHarvest, bool _requiredKeepMinRatio, bool _requiredLeverageToMax, address yieldToken, uint256 yieldTokenOracle) public override onlyGovernor {
        _addHarvestStrategy(_vault, _strategy, _requiredHarvest);
        availableStrategies.add(_strategy);
        stratagyYieldTokens[_strategy] = yieldToken;
        stratagyYieldTokenOracles[_strategy] = yieldTokenOracle;
        if (_requiredKeepMinRatio){
            collateralizedStrategies.add(_strategy);
        }
        if (_requiredLeverageToMax){
            leveragedStrategies.add(_strategy);
        }
        emit HarvestStrategyAdded(_vault, _strategy, _requiredHarvest, _requiredKeepMinRatio, _requiredLeverageToMax, yieldToken, yieldTokenOracle);
    }

    function _addHarvestStrategy(address _vault, address _strategy, uint256 _requiredHarvest) internal {
        require(availableVaults.contains(_vault), "generic-keep3r-v2:!availableVaults");
        require(requiredHarvest[_strategy] == 0 && !availableStrategies.contains(_strategy), "generic-keep3r-v2:!requiredHarvest:strategy-already-added");
        _setRequiredHarvest(_strategy, _requiredHarvest);
        vaultStrategies[_vault] = _strategy;
    }
    
    // Unique method to add a vault with specified parameters to the system
    function addVault(address _vault, uint256 _requiredEarnBalance) public override onlyGovernor {
        require(!availableVaults.contains(_vault), "generic-keep3r-v2:!requiredEarn:vault-already-added");
        availableVaults.add(_vault);
        _setRequiredEarn(_vault, _requiredEarnBalance);
        emit EarnVaultAdded(_vault, _requiredEarnBalance);
    }

    // Unique method to update a strategy with specified gas cost
    function updateRequiredHarvestAmount(address _strategy, uint256 _requiredHarvest) external override onlyGovernor {
        require(requiredHarvest[_strategy] > 0 && availableStrategies.contains(_strategy), "generic-keep3r-v2::update-required-harvest:strategy-not-added");
        _setRequiredHarvest(_strategy, _requiredHarvest);
        emit HarvestStrategyModified(_strategy, _requiredHarvest);
    }

    // Unique method to update a strategy with specified yield token oracle type
    function updateYieldTokenOracle(address _strategy, uint256 _yieldTokenOracle) external override onlyGovernor {
        require(requiredHarvest[_strategy] > 0 && availableStrategies.contains(_strategy), "generic-keep3r-v2::update-yield-token-oracle:strategy-not-added");
        stratagyYieldTokenOracles[_strategy] = _yieldTokenOracle;
    }

    // Unique method to update a vault with specified required want token number for earn()
    function updateRequiredEarn(address _vault, uint256 _requiredEarnBalance) external override onlyGovernor {
        require(availableVaults.contains(_vault), "generic-keep3r-v2::update-required-earn:vault-not-added");
        _setRequiredEarn(_vault, _requiredEarnBalance);
        emit EarnVaultModified(_vault, _requiredEarnBalance);
    }

    function removeHarvestStrategy(address _strategy) public override onlyGovernor {
        require(requiredHarvest[_strategy] > 0 && availableStrategies.contains(_strategy), "generic-keep3r-v2::remove-harvest-strategy:strategy-not-added");
        
        delete requiredHarvest[_strategy];
        availableStrategies.remove(_strategy);
        
        if (collateralizedStrategies.contains(_strategy)){
            collateralizedStrategies.remove(_strategy);
        }
        
        if (leveragedStrategies.contains(_strategy)){
            leveragedStrategies.remove(_strategy);
        }
        
        emit HarvestStrategyRemoved(_strategy);
    }

    function removeEarnVault(address _vault) external override onlyGovernor {
        require(availableVaults.contains(_vault), "generic-keep3r-v2::remove-earn-vault:vault-not-added");
        
        address _strategy = vaultStrategies[_vault];
        if (_strategy != address(0) && requiredHarvest[_strategy] > 0 && availableStrategies.contains(_strategy)){
            removeHarvestStrategy(_strategy);
            delete vaultStrategies[_vault];
        }
        
        delete requiredEarnBalance[_vault];
        availableVaults.remove(_vault);
        
        emit EarnVaultRemoved(_vault);
    }

    function setMinHarvestInterval(uint256 _interval) external override onlyGovernor {
        require(_interval > 0, "!_interval");
        minHarvestInterval = _interval;
    }

    function setProfitFactor(uint256 _profitFactor) external override onlyGovernor {
        require(_profitFactor > 0, "!_profitFactor");
        profitFactor = _profitFactor;
    }

    function setKeep3r(address _keep3r) external override onlyGovernor {
        _setKeep3r(_keep3r);
        emit Keep3rSet(_keep3r);
    }

    function setKeep3rHelper(address _keep3rHelper) external override onlyGovernor {
        keep3rHelper = _keep3rHelper;
        emit Keep3rHelperSet(_keep3rHelper);
    }

    function setSlidingOracle(address _slidingOracle) external override onlyGovernor {
        slidingOracle = _slidingOracle;
        emit SlidingOracleSet(_slidingOracle);
    }

    function setSushiSlidingOracle(address _sushiSlidingOracle) external override onlyGovernor {
        sushiSlidingOracle = _sushiSlidingOracle;
    }

    function _setRequiredEarn(address _vault, uint256 _requiredEarnBalance) internal {
        if (_requiredEarnBalance > 0){
            requiredEarnBalance[_vault] = _requiredEarnBalance;
        }
    }

    function _setRequiredHarvest(address _strategy, uint256 _requiredHarvest) internal {
        if (_requiredHarvest > 0){
            requiredHarvest[_strategy] = _requiredHarvest;
        }
    }

    // Getters
    function name() external pure override returns (string memory) {
        return "Generic Keep3r for Mushrooms Finance";
    }

    function getStrategies() public view override returns (address[] memory _strategies) {
        _strategies = new address[](availableStrategies.length());
        for (uint256 i; i < availableStrategies.length(); i++) {
            _strategies[i] = availableStrategies.at(i);
        }
    }

    function getCollateralizedStrategies() public view override returns (address[] memory _strategies) {
        _strategies = new address[](collateralizedStrategies.length());
        for (uint256 i; i < collateralizedStrategies.length(); i++) {
            _strategies[i] = collateralizedStrategies.at(i);
        }
    }

    function getVaults() public view override returns (address[] memory _vaults) {
        _vaults = new address[](availableVaults.length());
        for (uint256 i; i < availableVaults.length(); i++) {
            _vaults[i] = availableVaults.at(i);
        }
    }

    // this method is not specified as view since some strategy maybe not able to return accurate underlying profit in snapshot,
	// please use something similar to below tool to query
	// https://docs.ethers.io/v5/api/contract/contract/#contract-callStatic
    function harvestable(address _strategy) public override returns (bool) {
        require(requiredHarvest[_strategy] > 0, "generic-keep3r-v2::harvestable:strategy-not-added");

        // Should not trigger if had been called recently
        if (strategyLastHarvest[_strategy] > 0 && block.timestamp.sub(strategyLastHarvest[_strategy]) <= minHarvestInterval){
            return false;
        }

        // quote from keep3r network for specified workload
        uint256 kp3rCallCost = IKeep3rV1Helper(keep3rHelper).getQuoteLimit(requiredHarvest[_strategy]);
        // get ETH gas cost by querying uniswap sliding oracle
        uint256 ethCallCost = IUniswapV2SlidingOracle(sushiSlidingOracle).current(KP3R, kp3rCallCost, WETH);
        
        // estimate yield profit to harvest
        uint256 profitTokenAmount = 0;
        address yieldToken = stratagyYieldTokens[_strategy];
        uint256 yieldTokenOracle = stratagyYieldTokenOracles[_strategy];
        if (yieldToken == COMP){
            profitTokenAmount = ICompStrategy(_strategy).getCompAccrued();
        } else{
            profitTokenAmount = ICrvStrategy(_strategy).getHarvestable();
        }
            
        if (yieldTokenOracle > SUSHISWAP_ORACLE){ // no oracle to use, just use token number
            emit HarvestableCheck(_strategy, profitTokenAmount, profitFactor, 0, ethCallCost);
            return (profitTokenAmount >= yieldTokenOracle);
        } else{
            address oracle = yieldTokenOracle == UNISWAP_ORACLE? slidingOracle : sushiSlidingOracle;
            uint256 profitInEther = IUniswapV2SlidingOracle(oracle).current(yieldToken, profitTokenAmount, WETH);
            emit HarvestableCheck(_strategy, profitTokenAmount, profitFactor, profitInEther, ethCallCost);
            return (profitInEther >= profitFactor.mul(ethCallCost));
        }
    }
    
    function earnable(address _vault) public view override returns (bool) {
        require(availableVaults.contains(_vault), "generic-keep3r-v2::earnable:vault-not-added");
        return (IERC20(IVault(_vault).token()).balanceOf(_vault) >= requiredEarnBalance[_vault]);
    }
    
    function keepMinRatioMayday(address _strategy) public view override returns (bool) {
        require(collateralizedStrategies.contains(_strategy), "generic-keep3r-v2::keepMinRatioMayday:strategy-not-added");
        return ICollateralizedStrategy(_strategy).currentRatio() <= (ICollateralizedStrategy(_strategy).minRatio() * 9000 / 10000);
    }

    // harvest() actions for Keep3r
    function harvest(address _strategy) external override paysKeeper {
        require(harvestable(_strategy), "generic-keep3r-v2::harvest:not-workable");
        IStrategy(_strategy).harvest();
        strategyLastHarvest[_strategy] = block.timestamp;
        emit HarvestedByKeeper(_strategy);
    }

    // earn() actions for Keep3r
    function earn(address _vault) external override paysKeeper {
        require(earnable(_vault), "generic-keep3r-v2::earn:not-workable");
        IVault(_vault).earn();
        address _strategy = vaultStrategies[_vault];
        if (_strategy != address(0) && requiredHarvest[_strategy] > 0 && leveragedStrategies.contains(_strategy)){
            ILeveragedStrategy(_strategy).leverageToMax();
        }
    }

    // keepMinRatio() actions for Keep3r
    function keepMinRatio(address _strategy) external override paysKeeper {
        require(keepMinRatioMayday(_strategy), "generic-keep3r-v2::keepMinRatio:not-workable");
        ICollateralizedStrategy(_strategy).keepMinRatio();
    }
}