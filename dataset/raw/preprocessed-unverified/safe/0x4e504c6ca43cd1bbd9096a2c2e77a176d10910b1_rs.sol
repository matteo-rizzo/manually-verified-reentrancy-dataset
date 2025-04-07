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

// 
// inspired by & thanks to https://macarse.medium.com/the-keep3r-network-experiment-bb1c5182bda3
contract GenericKeep3rV2 is Keep3r, IMMStrategyHarvestKp3r {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet internal availableStrategies;
    // required gas cost on harvest
    mapping(address => uint256) public requiredHarvest;
	// last harvest timestamp for strategy
    mapping(address => uint256) public strategyLastHarvest;
    address public keep3rHelper;
    address public slidingOracle;

    address public constant KP3R = address(0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44);
    address public constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public constant CRV = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public constant COMP = address(0xc00e94Cb662C3520282E6f5717214004A7f26888);

    // for curve strategy
    address public constant THREE_CRV_STRATEGY = address(0x1f11055EB66F2bBa647FB1ADc64B0DD4E0018dE7);
    address public constant RENBTC_CRV_STRATEGY = address(0x5A709Dfa094273795B787CaAfC6855a120B2bEbd);

	// for compound strategy
    address public constant DAI_STRATEGY = address(0xf0BA303fd2CE5eBbb22d0d6590463D7549A08388);
    address public constant USDC_STRATEGY = address(0x8F288A56A6c06ffc75994a2d46E84F8bDa1a0744);

    // The minimum number of seconds between harvest calls, once half a day
    uint256 public minHarvestInterval = 43200;

    // The minimum multiple that `callCost` must be above the profit to be "justifiable"
    uint256 public profitFactor = 88;

    address public governor;

    constructor(
        address _keep3r,
        address _keep3rHelper,
        address _slidingOracle
    ) public Keep3r(_keep3r) {
        keep3rHelper = _keep3rHelper;
        slidingOracle = _slidingOracle;
        governor = msg.sender;
    }

    modifier onlyGovernor {
        require(msg.sender == governor, "governable::only-governor");
        _;
    }

    function _setGovernor(address _governor) external onlyGovernor {
        require(_governor != address(0), "governable::governor-should-not-be-zero-addres");
        governor = _governor;
    }

    // Unique method to add a strategy with specified gas cost to the system
    function addStrategy(address _strategy, uint256 _requiredHarvest) external override onlyGovernor {
        _addHarvestStrategy(_strategy, _requiredHarvest);
        availableStrategies.add(_strategy);
    }

    function _addHarvestStrategy(address _strategy, uint256 _requiredHarvest) internal {
        require(requiredHarvest[_strategy] == 0, "generic-keep3r-v2::add-harvest-strategy:strategy-already-added");
        _setRequiredHarvest(_strategy, _requiredHarvest);
        emit HarvestStrategyAdded(_strategy, _requiredHarvest);
    }

    // Unique method to update a strategy with specified gas cost
    function updateRequiredHarvestAmount(address _strategy, uint256 _requiredHarvest) external override onlyGovernor {
        require(requiredHarvest[_strategy] > 0, "generic-keep3r-v2::update-required-harvest:strategy-not-added");
        _setRequiredHarvest(_strategy, _requiredHarvest);
        emit HarvestStrategyModified(_strategy, _requiredHarvest);
    }

    function removeHarvestStrategy(address _strategy) external override onlyGovernor {
        require(requiredHarvest[_strategy] > 0, "generic-keep3r-v2::remove-harvest-strategy:strategy-not-added");
        requiredHarvest[_strategy] = 0;
        emit HarvestStrategyRemoved(_strategy);
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

    function _setRequiredHarvest(address _strategy, uint256 _requiredHarvest) internal {
        require(_requiredHarvest > 0, "generic-keep3r-v2::set-required-harvest:should-not-be-zero");
        requiredHarvest[_strategy] = _requiredHarvest;
    }

    // Getters
    function name() external pure override returns (string memory) {
        return "Generic Strategy Keep3r for Mushrooms harvest";
    }

    function strategies() public view override returns (address[] memory _strategies) {
        _strategies = new address[](availableStrategies.length());
        for (uint256 i; i < availableStrategies.length(); i++) {
            _strategies[i] = availableStrategies.at(i);
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
        uint256 ethCallCost = IUniswapV2SlidingOracle(slidingOracle).current(KP3R, kp3rCallCost, WETH);

        // estimate yield profit to harvest
        uint256 profitInEther = 0;
        uint256 profitTokenAmount = 0;
        if(_strategy == DAI_STRATEGY || _strategy == USDC_STRATEGY){
            profitTokenAmount = ICompStrategy(_strategy).getCompAccrued();
            profitInEther = IUniswapV2SlidingOracle(slidingOracle).current(COMP, profitTokenAmount, WETH);
        }else{
            profitTokenAmount = ICrvStrategy(_strategy).getHarvestable();
            profitInEther = IUniswapV2SlidingOracle(slidingOracle).current(CRV, profitTokenAmount, WETH);
        }
		
        emit HarvestableCheck(_strategy, profitTokenAmount, profitFactor, profitInEther, ethCallCost);

        // Only trigger if it "makes sense" economically (gas cost * profitFactor no bigger than profit to be harvested)
        return (profitInEther >= profitFactor.mul(ethCallCost));
    }

    // harvest actions for Keep3r
    function harvest(address _strategy) external override paysKeeper {
        require(harvestable(_strategy), "generic-keep3r-v2::harvest:not-workable");
        _harvest(_strategy);
        emit HarvestedByKeeper(_strategy);
    }

    // harvest actions for free
    function harvestForFree(address _strategy) external override {
        require(harvestable(_strategy), "generic-keep3r-v2::harvest:not-workable");
        _harvest(_strategy);
    }

    function _harvest(address _strategy) internal {
        IStrategy(_strategy).harvest();
        strategyLastHarvest[_strategy] = block.timestamp;
    }
}