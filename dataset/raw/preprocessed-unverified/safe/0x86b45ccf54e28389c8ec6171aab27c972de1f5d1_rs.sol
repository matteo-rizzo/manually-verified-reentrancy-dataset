/**
 *Submitted for verification at Etherscan.io on 2020-11-25
*/

pragma solidity ^0.5.16;









contract FRTRebaser {
    using SafeMath for uint256;

    uint256 public constant PERIOD = 10 minutes; // will be 10 minutes in REAL CONTRACT

    IUniswapV2Pair public pair;
    FRT public token;
    FRTTreasury public treasury;

    uint256 public starttime = 1606266000; // EDIT_ME: 2020-11-25UTC:01:00+00:00
    uint256 public price0CumulativeLast = 0;
    uint32 public blockTimestampLast = 0;
    uint224 public price0RawAverage = 0;
    address public lastRebaser = 0x0000000000000000000000000000000000000000;

    uint256 public epoch = 0;

    constructor(address _pair, address _treasury) public {
        pair = IUniswapV2Pair(_pair);
        treasury = FRTTreasury(_treasury);
        token = FRT(pair.token0());
        price0CumulativeLast = pair.price0CumulativeLast();
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, blockTimestampLast) = pair.getReserves();
        require(reserve0 != 0 && reserve1 != 0, 'NO_RESERVES');
    }

    event LogRebase(uint indexed epoch, uint totalSupply, uint256 rand, address account);

    uint256 private constant MAX_INT256 = ~(uint256(1) << 255);
    
    function rebaseTime() public view returns (bool) {
       return block.timestamp % 3600 < 3 * 60;
    }

    function toInt256Safe(uint256 a) internal pure returns (int256) {
        require(a <= MAX_INT256);
        return int256(a);
    }

    //Only callers that hold FRT can rebase.
    function hasFRT() private view returns (bool) {
        if (token.balanceOf(msg.sender) > 0) {
            return true;
        } else {
            return false;
        }
    }

    function rand() private view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (now)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                            (now)) +
                        block.number
                )
            )
        );

        if ((seed - ((seed / 10) * 10)) == 0 || (seed - ((seed / 10) * 10)) > 9 ) {
            return 1;
        } else {
            return (seed - ((seed / 10) * 10));
        }
    }

    function rebase() external {
       // uint256 timestamp = block.timestamp;
        require(block.timestamp > starttime, 'REBASE IS NOT ACTIVE YET');
        require(lastRebaser != msg.sender, 'YOU_ALREADY_REBASED');
        require(rebaseTime(), 'IS_NOT_TIME_TO_REBASE'); // rebase can only happen between XX:00:00 ~ XX:02:59 of every hour
        require(hasFRT(), 'YOU_DO_NOT_HOLD_FRT'); //Only holders can rebase.
        uint256 price0Cumulative = pair.price0CumulativeLast();
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
        price0RawAverage = uint224(
            (price0Cumulative - price0CumulativeLast) / timeElapsed
        );

        price0CumulativeLast = price0Cumulative;
        blockTimestampLast = blockTimestamp;

        // compute rebase

        uint256 price = price0RawAverage;
        uint256 priceComp = 0;
        price = price.mul(10**5).div(2**112); // DAI decimals = 18, 100000 = 10^5, 18 - 18 + 5 = 5   ***Important***
        priceComp = price.mul(10**3).div(2**112);

        require(priceComp != 1000 || priceComp != 999, 'NO_NEED_TO_REBASE'); // don't rebase if price is close to 1.00000

        // rebase & sync
        uint256 random = rand();
        if (price > 100000) {
            // positive rebase
            uint256 delta = price.sub(100000);
            token.rebase(
                epoch,
                toInt256Safe(token.totalSupply().mul(delta).div(100000 * 10))
            ); // rebase using 10% of price delta
            treasury.sendReward(random, msg.sender);
        } else {
            // negative rebase
            uint256 delta = 100000;
            delta = delta.sub(price);
            token.rebase(
                epoch,
                -toInt256Safe(token.totalSupply().mul(delta).div(100000 * 2))
            ); // Use 2% of delta
            treasury.sendReward(random, msg.sender);
        }

        pair.sync();
        epoch = epoch.add(1);
        lastRebaser = msg.sender;
        emit LogRebase(epoch, token.totalSupply(), random, msg.sender);
    }
}