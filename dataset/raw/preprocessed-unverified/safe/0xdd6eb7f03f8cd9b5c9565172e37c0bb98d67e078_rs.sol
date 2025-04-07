/**
 *Submitted for verification at Etherscan.io on 2021-02-18
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
        uint cl;
    }
    
    IKeep3rV1Oracle public constant sushiswapV1Oracle = IKeep3rV1Oracle(0xf67Ab1c914deE06Ba0F264031885Ea7B276a7cDa);
    IKeep3rV1Oracle public constant uniswapV1Oracle = IKeep3rV1Oracle(0x73353801921417F465377c8d898c6f4C0270282C);
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    IChainLinkFeedsRegistry constant chainlink = IChainLinkFeedsRegistry(0x271bf4568fb737cc2e6277e9B1EE0034098cDA2a);

    function assetToUsd(address tokenIn, uint amountIn, uint granularity) public view returns (QuoteParams memory q, LiquidityParams memory l) {
        (q,) = assetToEth(tokenIn, amountIn, granularity);
        return ethToUsd(q.amountOut, granularity);
    }
    
    function assetToEth(address tokenIn, uint amountIn, uint granularity) public view returns (QuoteParams memory q, LiquidityParams memory l) {
        q.sTWAP = sushiswapV1Oracle.quote(tokenIn, amountIn, WETH, granularity);
        q.uTWAP = uniswapV1Oracle.quote(tokenIn, amountIn, WETH, granularity);
        q.sCUR = sushiswapV1Oracle.current(tokenIn, amountIn, WETH);
        q.uCUR = uniswapV1Oracle.current(tokenIn, amountIn, WETH);
        q.cl = chainlink.getPriceETH(tokenIn) * amountIn / 10 ** IERC20(tokenIn).decimals();
        l = getLiquidity(tokenIn, WETH);
        
        q.amountOut = (q.sTWAP * l.sLiquidity + q.uTWAP * l.uLiquidity) / (l.sLiquidity + l.uLiquidity);
        q.currentOut = (q.sCUR * l.sLiquidity + q.uCUR * l.uLiquidity) / (l.sLiquidity + l.uLiquidity);
        q.quoteOut = Math.min(Math.min(q.amountOut, q.currentOut), q.cl);
    }
    
    function ethToAsset(uint amountIn, address tokenOut, uint granularity) public view returns (QuoteParams memory q, LiquidityParams memory l) {
        q.sTWAP = sushiswapV1Oracle.quote(WETH, amountIn, tokenOut, granularity);
        q.uTWAP = uniswapV1Oracle.quote(WETH, amountIn, tokenOut, granularity);
        q.sCUR = sushiswapV1Oracle.current(WETH, amountIn, tokenOut);
        q.uCUR = uniswapV1Oracle.current(WETH, amountIn, tokenOut);
        q.cl = amountIn * 10 ** 18 / chainlink.getPriceETH(tokenOut);
        l = getLiquidity(WETH, tokenOut);
        
        q.amountOut = (q.sTWAP * l.sLiquidity + q.uTWAP * l.uLiquidity) / (l.sLiquidity + l.uLiquidity);
        q.currentOut = (q.sCUR * l.sLiquidity + q.uCUR * l.uLiquidity) / (l.sLiquidity + l.uLiquidity);
        q.quoteOut = Math.min(q.amountOut, q.currentOut);
        q.quoteOut = Math.min(Math.min(q.amountOut, q.currentOut), q.cl);
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
        if (tokenIn == WETH) {
            return ethToAsset(amountIn, tokenOut, granularity);
        } else if (tokenOut == WETH) {
            return assetToEth(tokenIn, amountIn, granularity);
        } else {
            (q,) = assetToEth(tokenIn, amountIn, granularity);
            return ethToAsset(q.quoteOut, tokenOut, granularity);
        }
        
    }
}