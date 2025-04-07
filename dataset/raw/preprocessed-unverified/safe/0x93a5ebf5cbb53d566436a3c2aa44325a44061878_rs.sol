/**
 *Submitted for verification at Etherscan.io on 2020-11-30
*/

// SPDX-License-Identifier: MIT


/**
 * KEEPERFI.COM
 * Optimized Dapp
 * Clean & tested code
 */


pragma solidity ^0.6.12;











// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)







contract UniswapV2Oracle {
    using FixedPoint for *;
    using SafeMath for uint;

    struct Observation {
        uint timestamp;
        uint price0Cumulative;
        uint price1Cumulative;
    }
    
    modifier keeper() {
        require(KFI.isKeeper(msg.sender), "::isKeeper: keeper is not registered");
        _;
    }
    
    modifier upkeep() {
        require(KFI.isKeeper(msg.sender), "::isKeeper: keeper is not registered");
        _;
        KFI.worked(msg.sender);
    }
    
    address public governance;
    address public pendingGovernance;
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "setGovernance: !gov");
        pendingGovernance = _governance;
    }

    function acceptGovernance() external {
        require(msg.sender == pendingGovernance, "acceptGovernance: !pendingGov");
        governance = pendingGovernance;
    }
    
    function setKeeperFi(address _keeperfi) external {
        require(msg.sender == governance, "setKeeperFi: !gov");
        KFI = IKeeperFi(_keeperfi);
    }
    
    IKeeperFi public KFI;

    address public immutable factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    uint public immutable windowSize = 14400;
    uint8 public immutable granularity = 8;
    uint public immutable periodSize = 1800;
    
    address[] internal _pairs;
    mapping(address => bool) internal _known;
    mapping(address => uint) public lastUpdated;
    
    function pairs() external view returns (address[] memory) {
        return _pairs;
    }
    mapping(address => Observation[]) public pairObservations;

    constructor(address _keeperfi) public {
        governance = msg.sender;
        KFI = IKeeperFi(_keeperfi);
    }

    // returns the index of the observation corresponding to the given timestamp
    function observationIndexOf(uint timestamp) public view returns (uint8 index) {
        uint epochPeriod = timestamp / periodSize;
        return uint8(epochPeriod % granularity);
    }

    // returns the observation from the oldest epoch (at the beginning of the window) relative to the current time
    function getFirstObservationInWindow(address pair) private view returns (Observation storage firstObservation) {
        uint8 observationIndex = observationIndexOf(block.timestamp);
        // no overflow issue. if observationIndex + 1 overflows, result is still zero.
        uint8 firstObservationIndex = (observationIndex + 1) % granularity;
        firstObservation = pairObservations[pair][firstObservationIndex];
    }
    
    function updatePair(address pair) external keeper returns (bool) {
        return _update(pair);
    }

    // update the cumulative price for the observation at the current timestamp. each observation is updated at most
    // once per epoch period.
    function update(address tokenA, address tokenB) external keeper returns (bool) {
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        return _update(pair);
    }
    
    function add(address tokenA, address tokenB) external {
        require(msg.sender == governance, "UniswapV2Oracle::add: !gov");
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        require(!_known[pair], "known");
        _known[pair] = true;
        _pairs.push(pair);
    }
    
    function work() public upkeep {
        bool worked = _updateAll();
        require(worked, "UniswapV2Oracle: !work");
    }
    
    function _updateAll() internal returns (bool updated) {
        for (uint i = 0; i < _pairs.length; i++) {
            if (_update(_pairs[i])) {
                updated = true;
            }
        }
    }
    
    function updateFor(uint i, uint length) external keeper returns (bool updated) {
        for (; i < length; i++) {
            if (_update(_pairs[i])) {
                updated = true;
            }
        }
    }
    
    function updateableList() external view returns (address[] memory list) {
        uint _index = 0;
        for (uint i = 0; i < _pairs.length; i++) {
            if (updateable(_pairs[i])) {
               list[_index++] = _pairs[i];
            }
        }
    }
    
    function updateable(address pair) public view returns (bool) {
        return (block.timestamp - lastUpdated[pair]) > periodSize;
    }
    
    function updateable() external view returns (bool) {
        for (uint i = 0; i < _pairs.length; i++) {
            if (updateable(_pairs[i])) {
                return true;
            }
        }
        return false;
    }
    
    function updateableFor(uint i, uint length) external view returns (bool) {
        for (; i < length; i++) {
            if (updateable(_pairs[i])) {
                return true;
            }
        }
        return false;
    }
    
    function _update(address pair) internal returns (bool) {
        // populate the array with empty observations (first call only)
        for (uint i = pairObservations[pair].length; i < granularity; i++) {
            pairObservations[pair].push();
        }

        // get the observation for the current period
        uint8 observationIndex = observationIndexOf(block.timestamp);
        Observation storage observation = pairObservations[pair][observationIndex];

        // we only want to commit updates once per period (i.e. windowSize / granularity)
        uint timeElapsed = block.timestamp - observation.timestamp;
        if (timeElapsed > periodSize) {
            (uint price0Cumulative, uint price1Cumulative,) = UniswapV2OracleLibrary.currentCumulativePrices(pair);
            observation.timestamp = block.timestamp;
            lastUpdated[pair] = block.timestamp;
            observation.price0Cumulative = price0Cumulative;
            observation.price1Cumulative = price1Cumulative;
            return true;
        }
        
        return false;
    }

    // given the cumulative prices of the start and end of a period, and the length of the period, compute the average
    // price in terms of how much amount out is received for the amount in
    function computeAmountOut(
        uint priceCumulativeStart, uint priceCumulativeEnd,
        uint timeElapsed, uint amountIn
    ) private pure returns (uint amountOut) {
        // overflow is desired.
        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
            uint224((priceCumulativeEnd - priceCumulativeStart) / timeElapsed)
        );
        amountOut = priceAverage.mul(amountIn).decode144();
    }

    function consult(address tokenIn, uint amountIn, address tokenOut) external view returns (uint amountOut) {
        address pair = UniswapV2Library.pairFor(factory, tokenIn, tokenOut);
        Observation storage firstObservation = getFirstObservationInWindow(pair);

        uint timeElapsed = block.timestamp - firstObservation.timestamp;
        require(timeElapsed <= windowSize, 'SlidingWindowOracle: MISSING_HISTORICAL_OBSERVATION');
        // should never happen.
        require(timeElapsed >= windowSize - periodSize * 2, 'SlidingWindowOracle: UNEXPECTED_TIME_ELAPSED');

        (uint price0Cumulative, uint price1Cumulative,) = UniswapV2OracleLibrary.currentCumulativePrices(pair);
        (address token0,) = UniswapV2Library.sortTokens(tokenIn, tokenOut);

        if (token0 == tokenIn) {
            return computeAmountOut(firstObservation.price0Cumulative, price0Cumulative, timeElapsed, amountIn);
        } else {
            return computeAmountOut(firstObservation.price1Cumulative, price1Cumulative, timeElapsed, amountIn);
        }
    }
}