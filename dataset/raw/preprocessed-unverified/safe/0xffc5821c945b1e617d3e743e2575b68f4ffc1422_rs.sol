//   _    _ _   _                __ _                            
//  | |  (_) | | |              / _(_)                           
//  | | ___| |_| |_ ___ _ __   | |_ _ _ __   __ _ _ __   ___ ___ 
//  | |/ / | __| __/ _ \ '_ \  |  _| | '_ \ / _` | '_ \ / __/ _ \
//  |   <| | |_| ||  __/ | | |_| | | | | | | (_| | | | | (_|  __/
//  |_|\_\_|\__|\__\___|_| |_(_)_| |_|_| |_|\__,_|_| |_|\___\___|
//
pragma solidity ^0.5.16;







contract kBASEPolicyV0 {
    using SafeMath for uint;

    uint public constant PERIOD = 10 minutes; // will be 10 minutes in REAL CONTRACT

    IUniswapV2Pair public pair;
    kBASEv0 public token;

    uint    public price0CumulativeLast = 0;
    uint32  public blockTimestampLast = 0;
    uint224 public price0RawAverage = 0;
    
    uint    public epoch = 0;

    constructor(address _pair) public {
        pair = IUniswapV2Pair(_pair);
        token = kBASEv0(pair.token0());
        price0CumulativeLast = pair.price0CumulativeLast();
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, blockTimestampLast) = pair.getReserves();
        require(reserve0 != 0 && reserve1 != 0, 'NO_RESERVES');
    }
    
    uint private constant MAX_INT256 = ~(uint(1) << 255);
    function toInt256Safe(uint a) internal pure returns (int) {
        require(a <= MAX_INT256);
        return int(a);
    }

    function rebase() external {
        uint timestamp = block.timestamp;
        require(timestamp % 3600 < 3 * 60); // rebase can only happen between XX:00:00 ~ XX:02:59 of every hour
        
        uint price0Cumulative = pair.price0CumulativeLast();
        uint112 reserve0;
        uint112 reserve1;
        uint32 blockTimestamp;
        (reserve0, reserve1, blockTimestamp) = pair.getReserves();
        require(reserve0 != 0 && reserve1 != 0, 'NO_RESERVES');
        
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        // ensure that at least one full period has passed since the last update
        require(timeElapsed >= PERIOD, 'PERIOD_NOT_ELAPSED');

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        price0RawAverage = uint224((price0Cumulative - price0CumulativeLast) / timeElapsed);

        price0CumulativeLast = price0Cumulative;
        blockTimestampLast = blockTimestamp;
        
        // compute rebase
        
        uint price = price0RawAverage;
        price = price.mul(10 ** 17).div(2 ** 112); // USDC decimals = 6, 100000 = 10^5, 18 - 6 + 5 = 17
 
        require(price != 100000, 'NO_NEED_TO_REBASE'); // don't rebase if price = 1.00000
        
        // rebase & sync
        
        if (price > 100000) { // positive rebase
            uint delta = price.sub(100000);
            token.rebase(epoch, toInt256Safe(token.totalSupply().mul(delta).div(100000 * 10))); // rebase using 10% of price delta
        } 
        else { // negative rebase
            uint delta = 100000;
            delta = delta.sub(price);
            token.rebase(epoch, -toInt256Safe(token.totalSupply().mul(delta).div(100000 * 2))); // get out of "death spiral" ASAP
        }
        
        pair.sync();
        epoch = epoch.add(1);
    }
}