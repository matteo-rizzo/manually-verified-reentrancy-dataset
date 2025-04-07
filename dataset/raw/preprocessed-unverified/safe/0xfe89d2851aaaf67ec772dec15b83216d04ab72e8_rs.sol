/**
 *Submitted for verification at Etherscan.io on 2021-05-11
*/

pragma solidity 0.5.0;













contract MedianOracle {
    using Decimal for Decimal.D256;
    using SafeMath for uint256;
    using FixedPoint for *;

    address internal _pair;
    uint256 internal _index;
    uint256 internal _cumulative;
    uint32 internal _timestamp;

    address internal policy;
    address internal ethUSDOracle;
    address internal owner;

    uint256 public currentPrice;

    modifier onlyPolicy() {
        require(msg.sender == policy || msg.sender == owner);
        _;
    }

    constructor() public {
        _pair = address(0xeaceAC83CEcCA6BEeBc736EDd6360d1633175b01);
        _index = 0;
        policy = address(0x7f0C14F2F72ca782Eea2835B9f63d3833B6669Ab);
        ethUSDOracle = address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        owner = msg.sender;
        Decimal.D256 memory price = updatePrice();
        currentPrice = price.value;
    }

    function getData() public onlyPolicy returns (uint256, bool) {
        Decimal.D256 memory price = updatePrice();
        currentPrice = price.value;
        uint256 ethUSD = uint256(AggregatorInterface(ethUSDOracle).latestAnswer());
        uint256 ethUSDDecimal = AggregatorInterface(ethUSDOracle).decimals();
        currentPrice = currentPrice.mul(ethUSD).div(10**ethUSDDecimal);
        return (currentPrice, true);
    }

    function updatePrice() private returns (Decimal.D256 memory) {
        (uint256 price0Cumulative, uint256 price1Cumulative, uint32 blockTimestamp) = currentCumulativePrices(_pair);
        uint32 timeElapsed = blockTimestamp - _timestamp;
        uint256 priceCumulative = _index == 0 ? price0Cumulative : price1Cumulative;
        Decimal.D256 memory price = Decimal.ratio((priceCumulative - _cumulative) / timeElapsed, 2**112);

        _timestamp = blockTimestamp;
        _cumulative = priceCumulative;

        return price.div(1e9);
    }

    function currentCumulativePrices(address pair) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        blockTimestamp = uint32(block.timestamp % 2 ** 32);
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}



