/**
 *Submitted for verification at Etherscan.io on 2020-10-16
*/

pragma solidity =0.6.6;













contract UniswapInsuranceQuote {
    using SafeMath for uint;
    UniswapOracleProxy constant ORACLE = UniswapOracleProxy(0x0b5A6b318c39b60e7D8462F888e7fbA89f75D02F);
    UniswapRouter constant ROUTER = UniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    
    function getReserves(IUniswapV2Pair pair, address tokenOut) public view returns (uint, uint) {
        (uint _reserve0, uint _reserve1,) = pair.getReserves();
        if (tokenOut == pair.token1()) {
            return (_reserve0, _reserve1);
        } else {
            return (_reserve1, _reserve0);
        }
    }
    
    function oracleQuoteOnly(IUniswapV2Pair pair, address tokenOut, uint amountIn) external view returns (uint) {
        (uint _amountIn, uint _baseOut, address _tokenIn) = calculateReturn(pair, amountIn);
        
        if (_tokenIn == tokenOut) {
            _tokenIn = pair.token1();
            uint _temp = _amountIn;
            _amountIn = _baseOut;
            _baseOut = _temp;
        }
        return ORACLE.quote(_tokenIn, tokenOut, _amountIn);
    }
    
    function routerQuoteOnly(IUniswapV2Pair pair, address tokenOut, uint amountIn) external view returns (uint) {
        (uint _amountIn, uint _baseOut, address _tokenIn) = calculateReturn(pair, amountIn);
        (uint _reserveA, uint _reserveB) = getReserves(pair, tokenOut);
        
        if (_tokenIn == tokenOut) {
            _tokenIn = pair.token1();
            uint _temp = _amountIn;
            _amountIn = _baseOut;
            _baseOut = _temp;
        }
        return ROUTER.quote(_amountIn, _reserveA, _reserveB);
    }
    
    function calculateReturn(IUniswapV2Pair pair, uint amountIn) public view returns (uint balanceA, uint balanceB, address tokenA) {
        tokenA = pair.token0();
        address _tokenB = pair.token1();
        balanceA = IERC20(tokenA).balanceOf(address(pair));
        balanceB = IERC20(_tokenB).balanceOf(address(pair));
        uint _totalSupply = pair.totalSupply();
        
        balanceA = balanceA.mul(amountIn).div(_totalSupply);
        balanceB = balanceB.mul(amountIn).div(_totalSupply);
    }
    
    function quote(IUniswapV2Pair pair, address tokenOut, uint amountIn) external view returns (uint) {
        (uint _amountIn, uint _baseOut, address _tokenIn) = calculateReturn(pair, amountIn);
        (uint _reserveA, uint _reserveB) = getReserves(pair, tokenOut);
        
        if (_tokenIn == tokenOut) {
            _tokenIn = pair.token1();
            uint _temp = _amountIn;
            _amountIn = _baseOut;
            _baseOut = _temp;
        }
        uint _quote1 = ORACLE.quote(_tokenIn, tokenOut, _amountIn);
        uint _quote2 = ROUTER.quote(_amountIn, _reserveA, _reserveB);
        uint _quote = Math.max(_quote1, _quote2);
        return _baseOut.add(_quote);
    }
}