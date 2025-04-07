/**
 *Submitted for verification at Etherscan.io on 2020-10-10
*/

//   _    _ _   _                __ _                            
//  | |  (_) | | |              / _(_)                           
//  | | ___| |_| |_ ___ _ __   | |_ _ _ __   __ _ _ __   ___ ___ 
//  | |/ / | __| __/ _ \ '_ \  |  _| | '_ \ / _` | '_ \ / __/ _ \
//  |   <| | |_| ||  __/ | | |_| | | | | | | (_| | | | | (_|  __/
//  |_|\_\_|\__|\__\___|_| |_(_)_| |_|_| |_|\__,_|_| |_|\___\___|
//
//  AlphaSwap v0 contract (AlphaDex)
//
//  https://www.AlphaSwap.org
//
pragma solidity ^0.5.16;











contract AlphaSwapV0 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    struct MARKET_EPOCH {
        uint timestamp;
        uint accuPrice;
        uint32 pairTimestamp;
        mapping (address => mapping(uint => mapping (address => uint))) stake;
        mapping (address => mapping(uint => uint)) totalStake;
    }

    mapping (address => mapping(uint => MARKET_EPOCH)) public market;
    mapping (address => uint) public marketEpoch;
    mapping (address => uint) public marketEpochPeriod;
    
    mapping (address => uint) public marketWhitelist;
    mapping (address => uint) public tokenWhitelist;

    event STAKE(address indexed user, address indexed market, uint opinion, address indexed token, uint amt);
    event SYNC(address indexed market, uint epoch);
    event PAYOFF(address indexed user, address indexed market, uint opinion, address indexed token, uint amt);
    
    event MARKET_PERIOD(address indexed market, uint period);
    event MARKET_WHITELIST(address indexed market, uint status);
    event TOKEN_WHITELIST(address indexed token, uint status);
    event FEE_CHANGE(address indexed market, address indexed token, uint BP);
    
    //====================================================================
    
    address public govAddr;
    address public devAddr;
    
    mapping (address => mapping(address => uint)) public devFeeBP; // in terms of basis points (1 bp = 0.01%)
    mapping (address => uint) public devFeeAmt;
    
    constructor () public {
        govAddr = msg.sender;
        devAddr = msg.sender;
    }
    
    modifier govOnly() {
    	require(msg.sender == govAddr, "!gov");
    	_;
    }
    function govTransferAddr(address newAddr) external govOnly {
    	require(newAddr != address(0), "!addr");
    	govAddr = newAddr;
    }
    function govSetEpochPeriod(address xMarket, uint newPeriod) external govOnly {
        require (newPeriod > 0, "!period");
        marketEpochPeriod[xMarket] = newPeriod;
        emit MARKET_PERIOD(xMarket, newPeriod);
    }
    function govMarketWhitelist(address xMarket, uint status) external govOnly {
        require (status <= 1, "!status");
        marketWhitelist[xMarket] = status;
        emit MARKET_WHITELIST(xMarket, status);
    }
    function govTokenWhitelist(address xToken, uint status) external govOnly {
        require (status <= 1, "!status");
        tokenWhitelist[xToken] = status;
        emit TOKEN_WHITELIST(xToken, status);
    }
    function govSetDevFee(address xMarket, address xToken, uint newBP) external govOnly {
        require (newBP <= 10); // max fee = 10 basis points = 0.1%
    	devFeeBP[xMarket][xToken] = newBP;
    	emit FEE_CHANGE(xMarket, xToken, newBP);
    }
    
    modifier devOnly() {
    	require(msg.sender == devAddr, "!dev");
    	_;
    }
    function devTransferAddr(address newAddr) external devOnly {
    	require(newAddr != address(0), "!addr");
    	devAddr = newAddr;
    }
    function devWithdrawFee(address xToken, uint256 amt) external devOnly {
        require (amt <= devFeeAmt[xToken]);
        devFeeAmt[xToken] = devFeeAmt[xToken].sub(amt);
        IERC20(xToken).safeTransfer(devAddr, amt);
    }
    
    //====================================================================

    function readStake(address user, address xMarket, uint xEpoch, uint xOpinion, address xToken) external view returns (uint) {
        return market[xMarket][xEpoch].stake[xToken][xOpinion][user];
    }
    function readTotalStake(address xMarket, uint xEpoch, uint xOpinion, address xToken) external view returns (uint) {
        return market[xMarket][xEpoch].totalStake[xToken][xOpinion];
    }
    
    //====================================================================
    
    function Stake(address xMarket, uint xEpoch, uint xOpinion, address xToken, uint xAmt) external {
        require (xAmt > 0, "!amt");
        require (xOpinion <= 1, "!opinion");
        require (marketWhitelist[xMarket] > 0, "!market");
        require (tokenWhitelist[xToken] > 0, "!token");

        uint thisEpoch = marketEpoch[xMarket];
        require (xEpoch == thisEpoch, "!epoch");
        MARKET_EPOCH storage m = market[xMarket][thisEpoch];

        if (m.timestamp == 0) { // new market
            m.timestamp = block.timestamp;
            
            IUniswapV2Pair pair = IUniswapV2Pair(xMarket);
            uint112 reserve0;
            uint112 reserve1;
            uint32 pairTimestamp;
            (reserve0, reserve1, pairTimestamp) = pair.getReserves();
        
            m.pairTimestamp = pairTimestamp;
            m.accuPrice = pair.price0CumulativeLast();
        }

        address user = msg.sender;
        IERC20(xToken).safeTransferFrom(user, address(this), xAmt);
        
        m.stake[xToken][xOpinion][user] = m.stake[xToken][xOpinion][user].add(xAmt);
        m.totalStake[xToken][xOpinion] = m.totalStake[xToken][xOpinion].add(xAmt);
        
        emit STAKE(user, xMarket, xOpinion, xToken, xAmt);
    }
    
    function _Sync(address xMarket) private {
        uint epochPeriod = marketEpochPeriod[xMarket];
        uint thisPeriod = (block.timestamp).div(epochPeriod);
        
        MARKET_EPOCH memory mmm = market[xMarket][marketEpoch[xMarket]];
        uint marketPeriod = (mmm.timestamp).div(epochPeriod);
        
        if (thisPeriod <= marketPeriod)
            return;

        IUniswapV2Pair pair = IUniswapV2Pair(xMarket);
        uint112 reserve0;
        uint112 reserve1;
        uint32 pairTimestamp;
        (reserve0, reserve1, pairTimestamp) = pair.getReserves();
        if (pairTimestamp <= mmm.pairTimestamp)
            return;
            
        MARKET_EPOCH memory m;
        m.timestamp = block.timestamp;
        m.pairTimestamp = pairTimestamp;
        m.accuPrice = pair.price0CumulativeLast();
        
        uint newEpoch = marketEpoch[xMarket].add(1);
        marketEpoch[xMarket] = newEpoch;
        market[xMarket][newEpoch] = m;
        
        emit SYNC(xMarket, newEpoch);
    }
    
    function Sync(address xMarket) external {
        uint epochPeriod = marketEpochPeriod[xMarket];
        uint thisPeriod = (block.timestamp).div(epochPeriod);
        
        MARKET_EPOCH memory mmm = market[xMarket][marketEpoch[xMarket]];
        uint marketPeriod = (mmm.timestamp).div(epochPeriod);
        require (marketPeriod > 0, "!marketPeriod");
        require (thisPeriod > marketPeriod, "!thisPeriod");

        IUniswapV2Pair pair = IUniswapV2Pair(xMarket);
        uint112 reserve0;
        uint112 reserve1;
        uint32 pairTimestamp;
        (reserve0, reserve1, pairTimestamp) = pair.getReserves();
        require (pairTimestamp > mmm.pairTimestamp, "!no-trade");

        MARKET_EPOCH memory m;
        m.timestamp = block.timestamp;
        m.pairTimestamp = pairTimestamp;
        m.accuPrice = pair.price0CumulativeLast();
        
        uint newEpoch = marketEpoch[xMarket].add(1);
        marketEpoch[xMarket] = newEpoch;
        market[xMarket][newEpoch] = m;
        
        emit SYNC(xMarket, newEpoch);
    }
    
    function Payoff(address xMarket, uint xEpoch, uint xOpinion, address xToken) external {
        require (xOpinion <= 1, "!opinion");
        
        uint thisEpoch = marketEpoch[xMarket];
        require (thisEpoch >= 1, "!marketEpoch");
        _Sync(xMarket);
        
        thisEpoch = marketEpoch[xMarket];
        require (xEpoch <= thisEpoch.sub(2), "!epoch");

        address user = msg.sender;
        uint amtOut = 0;
        
        MARKET_EPOCH storage m0 = market[xMarket][xEpoch];
        {
            uint224 p01 = 0;
            uint224 p12 = 0;
            {
                MARKET_EPOCH memory m1 = market[xMarket][xEpoch.add(1)];
                MARKET_EPOCH memory m2 = market[xMarket][xEpoch.add(2)];
                
                // overflow is desired
                uint32 t01 = m1.pairTimestamp - m0.pairTimestamp;
                if (t01 > 0)
                    p01 = uint224((m1.accuPrice - m0.accuPrice) / t01);
                
                uint32 t12 = m2.pairTimestamp - m1.pairTimestamp;
                if (t12 > 0)
                    p12 = uint224((m2.accuPrice - m1.accuPrice) / t12);
            }
            
            uint userStake = m0.stake[xToken][xOpinion][user];
            if ((p01 == p12) || (p01 == 0) || (p12 == 0)) {
                amtOut = userStake;
            }
            else {
                uint sameOpinionStake = m0.totalStake[xToken][xOpinion];
                uint allStake = sameOpinionStake.add(m0.totalStake[xToken][1-xOpinion]);
                if (sameOpinionStake == allStake) {
                    amtOut = userStake;
                } 
                else {
                    if (
                        ((p12 > p01) && (xOpinion == 1))
                        ||
                        ((p12 < p01) && (xOpinion == 0))
                    )
                    {
                        amtOut = userStake.mul(allStake).div(sameOpinionStake);
                    }
                }
            }
        }
        
        require (amtOut > 0, "!zeroAmt");
        
        uint devFee = amtOut.mul(devFeeBP[xMarket][xToken]).div(10000);
        devFeeAmt[xToken] = devFeeAmt[xToken].add(devFee);

        amtOut = amtOut.sub(devFee);
        
        m0.stake[xToken][xOpinion][user] = 0;
        IERC20(xToken).safeTransfer(user, amtOut);
        
        emit PAYOFF(user, xMarket, xOpinion, xToken, amtOut);
    }
}