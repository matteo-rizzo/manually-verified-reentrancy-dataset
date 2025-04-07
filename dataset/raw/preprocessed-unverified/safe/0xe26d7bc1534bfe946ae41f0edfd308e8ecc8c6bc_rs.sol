/**
 *Submitted for verification at Etherscan.io on 2021-04-18
*/

//SPDX-License-Identifier: MIT 
pragma solidity 0.6.11; 
pragma experimental ABIEncoderV2;

// ====================================================================
//     ________                   _______                           
//    / ____/ /__  ____  ____ _  / ____(_)___  ____ _____  ________ 
//   / __/ / / _ \/ __ \/ __ `/ / /_  / / __ \/ __ `/ __ \/ ___/ _ \
//  / /___/ /  __/ / / / /_/ / / __/ / / / / / /_/ / / / / /__/  __/
// /_____/_/\___/_/ /_/\__,_(_)_/   /_/_/ /_/\__,_/_/ /_/\___/\___/                                                                                                                     
//                                                                        
// ====================================================================
// ====================== Elena Protocol (USE) ========================
// ====================================================================

// Dapp    :  https://elena.finance
// Twitter :  https://twitter.com/ElenaProtocol
// Telegram:  https://t.me/ElenaFinance
// ====================================================================

// File: contracts\Uniswap\Interfaces\IUniswapV2Factory.sol
// License: MIT



// File: contracts\Uniswap\Interfaces\IUniswapV2Pair.sol
// License: MIT



// File: contracts\Common\Babylonian.sol
// License: MIT

// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method


// File: contracts\Common\FixedPoint.sol
// License: MIT


// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))


// File: contracts\Uniswap\UniswapV2OracleLibrary.sol
// License: MIT



// library with helper methods for oracles that are concerned with computing average prices


// File: contracts\Oracle\UniswapPairOracle.sol
// License: MIT

// Fixed window oracle that recomputes the average price for the entire period once every period
// Note that the price average is only guaranteed to be over at least 1 period, but may be over a longer period
contract UniswapPairOracle {
    using FixedPoint for *;
    address owner_address;
    address timelock_address;
    uint public PERIOD = 3600; // 1 hour TWAP (time-weighted average price)
    uint public CONSULT_LENIENCY = 120; // Used for being able to consult past the period end
    bool public ALLOW_STALE_CONSULTS = true; // If false, consult() will fail if the TWAP is stale
    IUniswapV2Pair public  pair;
    address public  token0;
    address public  token1;
    uint    public price0CumulativeLast;
    uint    public price1CumulativeLast;
    uint32  public blockTimestampLast;
    FixedPoint.uq112x112 public price0Average;
    FixedPoint.uq112x112 public price1Average;
    modifier onlyByOwnerOrGovernance() {
        require(msg.sender == owner_address || msg.sender == timelock_address, "You are not an owner or the governance timelock");
        _;
    }
    constructor(address _pair) public { 
        pair = IUniswapV2Pair(_pair);
        token0 = pair.token0();
        token1 = pair.token1();
        price0CumulativeLast = pair.price0CumulativeLast(); // Fetch the current accumulated price value (1 / 0)
        price1CumulativeLast = pair.price1CumulativeLast(); // Fetch the current accumulated price value (0 / 1)
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, blockTimestampLast) = pair.getReserves();
        require(reserve0 != 0 && reserve1 != 0, 'UniswapPairOracle: NO_RESERVES'); // Ensure that there's liquidity in the pair
        owner_address = msg.sender;
        timelock_address = msg.sender;
    }
    function setOwner(address _owner_address) external onlyByOwnerOrGovernance {
        owner_address = _owner_address;
    }
    function setTimelock(address _timelock_address) external onlyByOwnerOrGovernance {
        timelock_address = _timelock_address;
    }
    function setPeriod(uint _period) external onlyByOwnerOrGovernance {
        PERIOD = _period;
    }
    function setConsultLeniency(uint _consult_leniency) external onlyByOwnerOrGovernance {
        CONSULT_LENIENCY = _consult_leniency;
    }
    function setAllowStaleConsults(bool _allow_stale_consults) external onlyByOwnerOrGovernance {
        ALLOW_STALE_CONSULTS = _allow_stale_consults;
    }
    // Check if update() can be called instead of wasting gas calling it
    function canUpdate() public view returns (bool) {
        uint32 blockTimestamp = UniswapV2OracleLibrary.currentBlockTimestamp();
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // Overflow is desired
        return (timeElapsed >= PERIOD);
    }
    //get other token
    function getPairToken(address token) external view returns(address){
        return token == token0 ? token1 : token0;
    }
    function containsToken(address token) external view returns(bool){
        return token == token0 || token == token1;
    }
    function getSwapTokenReserve(address token) external view returns(uint256){
         (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
         if(token == token0) return reserve0;
         if(token == token1) return reserve1;
         return 0;
    }
    function getTimeElapsed() public view returns(uint256){
        (, , uint32 blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(address(pair));
        return blockTimestamp - blockTimestampLast; // Overflow is desired
    }
    function update() external returns(bool){
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) =
              UniswapV2OracleLibrary.currentCumulativePrices(address(pair));
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // Overflow is desired
        // Ensure that at least one full period has passed since the last update
        //require(timeElapsed >= PERIOD, 'UniswapPairOracle: PERIOD_NOT_ELAPSED');
        if(timeElapsed >= PERIOD){
            // Overflow is desired, casting never truncates
            // Cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
            price0Average = FixedPoint.uq112x112(uint224((price0Cumulative - price0CumulativeLast) / timeElapsed));
            price1Average = FixedPoint.uq112x112(uint224((price1Cumulative - price1CumulativeLast) / timeElapsed));
            price0CumulativeLast = price0Cumulative;
            price1CumulativeLast = price1Cumulative;
            blockTimestampLast = blockTimestamp;
            return true;
        }
        return false;
    }
    // Note this will always return 0 before update has been called successfully for the first time.
    function consult(address tokenIn, uint amountIn) external view returns (uint amountOut) {
        uint32 blockTimestamp = UniswapV2OracleLibrary.currentBlockTimestamp();
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // Overflow is desired
        // Ensure that the price is not stale
        require((timeElapsed < (PERIOD + CONSULT_LENIENCY)) || ALLOW_STALE_CONSULTS, 'UniswapPairOracle: PRICE_IS_STALE_NEED_TO_CALL_UPDATE');
        if (tokenIn == token0) {
            amountOut = price1Average.mul(amountIn).decode144();
        } else {
            require(tokenIn == token1, 'UniswapPairOracle: INVALID_TOKEN');
            amountOut = price0Average.mul(amountIn).decode144();
        }
    }
}