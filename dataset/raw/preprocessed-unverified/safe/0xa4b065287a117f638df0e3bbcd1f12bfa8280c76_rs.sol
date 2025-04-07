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
    
    ISwapV2Router02 public constant sushiswapV2Router = ISwapV2Router02(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
    ISwapV2Router02 public constant uniswapV2Router = ISwapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant sushiswapV2Factory = address(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac);
    address public constant uniswapV2Factory = address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    
    IChainLinkFeedsRegistry constant chainlink = IChainLinkFeedsRegistry(0x271bf4568fb737cc2e6277e9B1EE0034098cDA2a);

    function assetToUsd(address tokenIn, uint amountIn, uint granularity) public view returns (QuoteParams memory q, LiquidityParams memory l) {
        (q,) = assetToEth(tokenIn, amountIn, granularity);
        return ethToUsd(q.amountOut, granularity);
    }
    
    function assetToEth(address tokenIn, uint amountIn, uint granularity) public view returns (QuoteParams memory q, LiquidityParams memory l) {
        q.sTWAP = sushiswapV1Oracle.quote(tokenIn, amountIn, WETH, granularity);
        q.uTWAP = uniswapV1Oracle.quote(tokenIn, amountIn, WETH, granularity);
        address[] memory _path = new address[](2);
        _path[0] = tokenIn;
        _path[1] = WETH;
        q.sCUR = amountIn * sushiswapV2Router.getAmountsOut(sushiswapV2Factory, 10 ** IERC20(tokenIn).decimals(), _path)[1] / 10 ** IERC20(tokenIn).decimals();
        q.uCUR = amountIn * uniswapV2Router.getAmountsOut(uniswapV2Factory, 10 ** IERC20(tokenIn).decimals(), _path)[1] / 10 ** IERC20(tokenIn).decimals();
        q.cl = chainlink.getPriceETH(tokenIn) * amountIn / 10 ** IERC20(tokenIn).decimals();
        l = getLiquidity(tokenIn, WETH);
        
        q.amountOut = (q.sTWAP * l.sLiquidity + q.uTWAP * l.uLiquidity) / (l.sLiquidity + l.uLiquidity);
        q.currentOut = (q.sCUR * l.sLiquidity + q.uCUR * l.uLiquidity) / (l.sLiquidity + l.uLiquidity);
        q.quoteOut = Math.min(Math.min(q.amountOut, q.currentOut), q.cl);
    }
    
    function ethToAsset(uint amountIn, address tokenOut, uint granularity) public view returns (QuoteParams memory q, LiquidityParams memory l) {
        q.sTWAP = sushiswapV1Oracle.quote(WETH, amountIn, tokenOut, granularity);
        q.uTWAP = uniswapV1Oracle.quote(WETH, amountIn, tokenOut, granularity);
        address[] memory _path = new address[](2);
        _path[0] = WETH;
        _path[1] = tokenOut;
        q.sCUR = amountIn * sushiswapV2Router.getAmountsOut(sushiswapV2Factory, 10 ** 18, _path)[1] / 10 ** 18;
        q.uCUR = amountIn * uniswapV2Router.getAmountsOut(uniswapV2Factory, 10 ** 18, _path)[1] / 10 ** 18;
        
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