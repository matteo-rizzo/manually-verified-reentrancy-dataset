/**
 *Submitted for verification at Etherscan.io on 2021-02-17
*/

// SPDX-License-Identifier: bsl-1.1

pragma solidity ^0.8.1;
pragma experimental ABIEncoderV2;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */









contract Keep3rV1OracleUSD  {
    
    struct LiquidityParams {
        uint sReserveA;
        uint sReserveB;
        uint uReserveA;
        uint uReserveB;
        uint sLiquidity;
        uint uLiquidity;
    }
    
    struct QuoteParams {
        uint quoteOut;
        uint amountOut;
        uint currentOut;
        uint sTWAP;
        uint uTWAP;
        uint sCUR;
        uint uCUR;
    }
    
    IKeep3rV1Oracle public constant sushiswapV1Oracle = IKeep3rV1Oracle(0xf67Ab1c914deE06Ba0F264031885Ea7B276a7cDa);
    IKeep3rV1Oracle public constant uniswapV1Oracle = IKeep3rV1Oracle(0x73353801921417F465377c8d898c6f4C0270282C);
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;


    function assetToUsd(address tokenIn, uint amountIn, uint granularity) public view returns (QuoteParams memory q, LiquidityParams memory l) {
        (q,) = assetToEth(tokenIn, amountIn, granularity);
        return ethToUsd(q.amountOut, granularity);
    }
    
    function assetToEth(address tokenIn, uint amountIn, uint granularity) public view returns (QuoteParams memory q, LiquidityParams memory l) {
        return assetToAsset(tokenIn, amountIn, WETH, granularity);
    }
    
    function ethToUsd(uint amountIn, uint granularity) public view returns (QuoteParams memory q, LiquidityParams memory l) {
        return assetToAsset(WETH, amountIn, DAI, granularity);
    }
    
    function pairFor(address tokenA, address tokenB) external pure returns (address sPair, address uPair) {
        sPair = SushiswapV2Library.sushiPairFor(tokenA, tokenB);
        uPair = SushiswapV2Library.uniPairFor(tokenA, tokenB);
    }
    
    function sPairFor(address tokenA, address tokenB) external pure returns (address sPair) {
        sPair = SushiswapV2Library.sushiPairFor(tokenA, tokenB);
    }
    
    function uPairFor(address tokenA, address tokenB) external pure returns (address uPair) {
        uPair = SushiswapV2Library.uniPairFor(tokenA, tokenB);
    }
    
    function getLiquidity(address tokenA, address tokenB) public view returns (LiquidityParams memory l) {
        address sPair = SushiswapV2Library.sushiPairFor(tokenA, tokenB);
        address uPair = SushiswapV2Library.uniPairFor(tokenA, tokenB);
        (l.sReserveA, l.sReserveB) =  SushiswapV2Library.getReserves(sPair, tokenA, tokenB);
        (l.uReserveA, l.uReserveB) =  SushiswapV2Library.getReserves(uPair, tokenA, tokenB);
        l.sLiquidity = l.sReserveA * l.sReserveB;
        l.uLiquidity = l.uReserveA * l.uReserveB;
    }
    
    function assetToAsset(address tokenIn, uint amountIn, address tokenOut, uint granularity) public view returns (QuoteParams memory q, LiquidityParams memory l) {
        q.sTWAP = sushiswapV1Oracle.quote(tokenIn, amountIn, tokenOut, granularity);
        q.uTWAP = uniswapV1Oracle.quote(tokenIn, amountIn, tokenOut, granularity);
        q.sCUR = sushiswapV1Oracle.current(tokenIn, amountIn, tokenOut);
        q.uCUR = uniswapV1Oracle.current(tokenIn, amountIn, tokenOut);
        l = getLiquidity(tokenIn, tokenOut);
        
        q.amountOut = (q.sTWAP * l.sLiquidity + q.uTWAP * l.uLiquidity) / (l.sLiquidity + l.uLiquidity);
        q.currentOut = (q.sCUR * l.sLiquidity + q.uCUR * l.uLiquidity) / (l.sLiquidity + l.uLiquidity);
        q.quoteOut = Math.min(q.amountOut, q.currentOut);
    }
}