/**
 *Submitted for verification at Etherscan.io on 2020-03-27
*/

pragma solidity ^0.5.16;

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





contract ETHUSD {
    function read() external view returns (bytes32);
}

contract BetEthPrice {
    using SafeMath for uint256;

    struct Bet {
        uint256 betCoef;
        uint256 amountUsd;
    }

    mapping(address => Bet) public betsHighPrice;
    mapping(address => Bet) public betsLowPrice;

    bool public isExistsBetsHighPrice;
    bool public isExistsBetsLowPrice;

    ETHUSD public oracleUsd;
    TokenInterface public usdToken;

    uint256 public targetPrice;
    uint256 public endTime;

    bool public isFinalized;
    bool public isCanceled;

    bool public isHighPriceWin;

    uint256 public totalHighPriceCoef;
    uint256 public totalLowPriceCoef;

    uint256 public finalBalance;

    // TODO: params
    constructor() public {
        oracleUsd = ETHUSD(0x729D19f657BD0614b4985Cf1D82531c67569197B);  // MainNet Medianizer MakerDao (pip): 0x729D19f657BD0614b4985Cf1D82531c67569197B
        usdToken = TokenInterface(0xdAC17F958D2ee523a2206206994597C13D831ec7);  // MainNet USDT: 0xdAC17F958D2ee523a2206206994597C13D831ec7

        targetPrice = 80 * 1e18;  // equals 80.000 eth (1e18) ¨C price should multiple of 10
        endTime = 1588291200;  // 01.05.2020 @ 12:00am (UTC)
    }


    function betOnHighPrice(uint256 amount) public {
        _bet(msg.sender, amount, true);
    }

    function betOnHighPrice(address beneficiary, uint256 amount) public {
        _bet(beneficiary, amount, true);
    }


    function betOnLowPrice(uint256 amount) public {
        _bet(msg.sender, amount, false);
    }

    function betOnLowPrice(address beneficiary, uint256 amount) public {
        _bet(beneficiary, amount, false);
    }

    // finalize Betting (time is over or price is lower than targetPrice)
    function finalize() public {
        require(!isFinalized, "Have already finilized");

        bool isLowWin = (getCurPriceUsd() <= targetPrice);
        bool isHighWin = (!isLowWin && (now >= endTime));
        require(isLowWin || isHighWin, "Betting is active");

        // set win bets
        isHighPriceWin = isHighWin;

        // if no winners ¨C cancel betting
        if ((isHighWin && !isExistsBetsHighPrice)
         || (!isHighWin && !isExistsBetsLowPrice)) {
            isCanceled = true;
            return;
        }

        finalBalance = usdToken.balanceOf(address(this));
        isFinalized = true;
    }

    function withdrawPrize() public  {
        require(isFinalized, "Betting is active or cancel");

        uint256 amount = 0;
        if (isHighPriceWin) {
            amount = finalBalance.mul(betsHighPrice[msg.sender].betCoef).div(totalHighPriceCoef);

            // set user's betCoef state as 0
            betsHighPrice[msg.sender].betCoef = 0;
        } else {
            amount = finalBalance.mul(betsLowPrice[msg.sender].betCoef).div(totalLowPriceCoef);

            // set user's betCoef state as 0
            betsLowPrice[msg.sender].betCoef = 0;
        }

        // transfer prize to user
        usdToken.transfer(msg.sender, amount);
    }

    function withdrawCanceled() public {
        require(isCanceled, "Betting is not canceled");

        // transfer user's bet to user
        usdToken.transfer(msg.sender, betsLowPrice[msg.sender].amountUsd.add(betsHighPrice[msg.sender].amountUsd));
    }


    // **VIEW functions**

    function getUsdtBalance() public view returns(uint256 usdtBalance) {
        usdtBalance = usdToken.balanceOf(address(this));
    }

    function getCurPriceUsd() public view returns(uint256) {
        return uint256(oracleUsd.read());  // USD price call to MakerDao Oracles ¨C Medianizer contract
    }

    function getTimeLeft() public view returns(uint256) {
        uint256 curEndTime = endTime;
        if (curEndTime > now) {
            return curEndTime - now;
        }

        return 0;
    }


    // **INTERNAL functions**

    function _bet(address beneficiary, uint256 amount, bool isHighPrice) internal {
        require(now < endTime, "Betting time is over");
        require(amount > 0, "USD should be more than 0");

        // transfer USD from msg.sender to this contract
        usdToken.transferFrom(msg.sender, address(this), amount);

        uint256 priceUsd = getCurPriceUsd();
        uint256 timeLeft = getTimeLeft();
        uint256 curBetCoef = 0;

        if (isHighPrice) {
            curBetCoef = amount.mul(timeLeft).mul(1e21).div(priceUsd);  // amount * timeLeft / priceUsd

            // set states
            betsHighPrice[beneficiary].betCoef = betsHighPrice[beneficiary].betCoef.add(curBetCoef);
            totalHighPriceCoef = totalHighPriceCoef.add(curBetCoef);

            betsHighPrice[beneficiary].amountUsd = betsHighPrice[beneficiary].amountUsd.add(amount);
        } else {
            curBetCoef = amount.mul(timeLeft).mul(priceUsd).div(1e18);  // amount * timeLeft * priceUsd

            // set states
            betsLowPrice[beneficiary].betCoef = betsLowPrice[beneficiary].betCoef.add(curBetCoef);
            totalLowPriceCoef = totalLowPriceCoef.add(curBetCoef);

            betsLowPrice[beneficiary].amountUsd = betsLowPrice[beneficiary].amountUsd.add(amount);
        }

        // if no betters
        if (!isExistsBetsHighPrice && isHighPrice) {
            isExistsBetsHighPrice = true;
        } else if (!isExistsBetsLowPrice && !isHighPrice) {
            isExistsBetsLowPrice = true;
        }
    }
}