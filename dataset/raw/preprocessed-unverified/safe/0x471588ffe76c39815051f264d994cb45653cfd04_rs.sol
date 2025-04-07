/**
 *Submitted for verification at Etherscan.io on 2021-03-28
*/

// SPDX-License-Identifier: bsl-1.1

pragma solidity ^0.8.1;
pragma experimental ABIEncoderV2;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */















contract Keep3rV4OracleUSD  {
    
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
    
    IKeep3rV1Oracle private constant sushiswapV1Oracle = IKeep3rV1Oracle(0xf67Ab1c914deE06Ba0F264031885Ea7B276a7cDa);
    IKeep3rV1Oracle private constant uniswapV1Oracle = IKeep3rV1Oracle(0x73353801921417F465377c8d898c6f4C0270282C);
    
    ISwapV2Router02 private constant sushiswapV2Router = ISwapV2Router02(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
    ISwapV2Router02 private constant uniswapV2Router = ISwapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    
    uint private constant DECIMALS = 10 ** 18;
    
    IChainLinkFeedsRegistry private constant chainlink = IChainLinkFeedsRegistry(0x271bf4568fb737cc2e6277e9B1EE0034098cDA2a);

    function assetToUsd(address tokenIn, uint amountIn, uint granularity) public view returns (QuoteParams memory q) {
        q = assetToEth(tokenIn, amountIn, granularity);
        return ethToUsd(q.amountOut, granularity);
    }
    
    function ethToUsd(uint amountIn, uint granularity) public view returns (QuoteParams memory q) {
        return assetToAsset(WETH, amountIn, DAI, granularity);
    }
    
    function assetToEth(address tokenIn, uint amountIn, uint granularity) public view returns (QuoteParams memory q) {
        q.sTWAP = sushiswapV1Oracle.quote(tokenIn, amountIn, WETH, granularity);
        q.uTWAP = uniswapV1Oracle.quote(tokenIn, amountIn, WETH, granularity);
        address[] memory _path = new address[](2);
        _path[0] = tokenIn;
        _path[1] = WETH;
        uint256 _decimals = 10 ** IERC20(tokenIn).decimals();
        q.sCUR = amountIn * sushiswapV2Router.getAmountsOut(_decimals, _path)[1] / _decimals;
        q.uCUR = amountIn * uniswapV2Router.getAmountsOut(_decimals, _path)[1] / _decimals;
        q.cl = chainlink.getPriceETH(tokenIn) * amountIn / _decimals;
        
        q.amountOut = Math.min(q.sTWAP, q.uTWAP);
        q.currentOut = Math.min(q.sCUR, q.uCUR);
        q.quoteOut = Math.min(Math.min(q.amountOut, q.currentOut), q.cl);
    }
    
    function ethToAsset(uint amountIn, address tokenOut, uint granularity) public view returns (QuoteParams memory q) {
        q.sTWAP = sushiswapV1Oracle.quote(WETH, amountIn, tokenOut, granularity);
        q.uTWAP = uniswapV1Oracle.quote(WETH, amountIn, tokenOut, granularity);
        address[] memory _path = new address[](2);
        _path[0] = WETH;
        _path[1] = tokenOut;
        q.sCUR = amountIn * sushiswapV2Router.getAmountsOut(DECIMALS, _path)[1] / DECIMALS;
        q.uCUR = amountIn * uniswapV2Router.getAmountsOut(DECIMALS, _path)[1] / DECIMALS;
        q.cl = amountIn * 10 ** IERC20(tokenOut).decimals() / chainlink.getPriceETH(tokenOut);
        
        q.amountOut = Math.min(q.sTWAP, q.uTWAP);
        q.currentOut = Math.min(q.sCUR, q.uCUR);
        q.quoteOut = Math.min(Math.min(q.amountOut, q.currentOut), q.cl);
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
    
    function getLiquidity(address tokenA, address tokenB) external view returns (LiquidityParams memory l) {
        address sPair = SushiswapV2Library.sushiPairFor(tokenA, tokenB);
        address uPair = SushiswapV2Library.uniPairFor(tokenA, tokenB);
        (l.sReserveA, l.sReserveB) =  SushiswapV2Library.getReserves(sPair, tokenA, tokenB);
        (l.uReserveA, l.uReserveB) =  SushiswapV2Library.getReserves(uPair, tokenA, tokenB);
        l.sLiquidity = l.sReserveA * l.sReserveB;
        l.uLiquidity = l.uReserveA * l.uReserveB;
    }
    
    function assetToAsset(address tokenIn, uint amountIn, address tokenOut, uint granularity) public view returns (QuoteParams memory q) {
        if (tokenIn == WETH) {
            return ethToAsset(amountIn, tokenOut, granularity);
        } else if (tokenOut == WETH) {
            return assetToEth(tokenIn, amountIn, granularity);
        } else {
            q = assetToEth(tokenIn, amountIn, granularity);
            return ethToAsset(q.quoteOut, tokenOut, granularity);
        }
        
    }
}