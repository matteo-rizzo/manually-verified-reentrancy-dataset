/**
 *Submitted for verification at Etherscan.io on 2020-10-20
*/

pragma solidity ^0.6.12;






/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 */







contract UniswapZAP {

    using SafeMath for uint256;

    address public _token;
    address public _tokenWETHPair;
    IWETH public _WETH;
    bool private initialized;

    function initUniswapZAP(address token, address WETH, address tokenWethPair) public  {
        require(!initialized);
        _token = token;
        _WETH = IWETH(WETH);
        _tokenWETHPair = tokenWethPair;
        initialized = true;
    }

    fallback() external payable {
        if(msg.sender != address(_WETH)){
             addLiquidityETHOnly(msg.sender);
        }
    }
    receive() external payable {
        if(msg.sender != address(_WETH)){
             addLiquidityETHOnly(msg.sender);
        }
    }


    function addLiquidityETHOnly(address payable to) public payable {
        require(to != address(0), "Invalid address");

        uint256 buyAmount = msg.value.div(2);
        require(buyAmount > 0, "Insufficient ETH amount");
        _WETH.deposit{value : msg.value}();

        (uint256 reserveWeth, uint256 reserveTokens) = getPairReserves();
        uint256 outTokens = UniswapV2Library.getAmountOut(buyAmount, reserveWeth, reserveTokens);
        
        _WETH.transfer(_tokenWETHPair, buyAmount);

        (address token0, address token1) = UniswapV2Library.sortTokens(address(_WETH), _token);
        IUniswapV2Pair(_tokenWETHPair).swap(_token == token0 ? outTokens : 0, _token == token1 ? outTokens : 0, address(this), "");

        _addLiquidity(outTokens, buyAmount, to);

    }

    function _addLiquidity(uint256 tokenAmount, uint256 wethAmount, address payable to) internal {
        (uint256 wethReserve, uint256 tokenReserve) = getPairReserves();

        uint256 optimalTokenAmount = UniswapV2Library.quote(wethAmount, wethReserve, tokenReserve);

        uint256 optimalWETHAmount;
        if (optimalTokenAmount > tokenAmount) {
            optimalWETHAmount = UniswapV2Library.quote(tokenAmount, tokenReserve, wethReserve);
            optimalTokenAmount = tokenAmount;
        }
        else
            optimalWETHAmount = wethAmount;

        assert(_WETH.transfer(_tokenWETHPair, optimalWETHAmount));
        assert(IERC20(_token).transfer(_tokenWETHPair, optimalTokenAmount));

        IUniswapV2Pair(_tokenWETHPair).mint(to);
        
        //refund dust
        if (tokenAmount > optimalTokenAmount)
            IERC20(_token).transfer(to, tokenAmount.sub(optimalTokenAmount));

        if (wethAmount > optimalWETHAmount) {
            uint256 withdrawAmount = wethAmount.sub(optimalWETHAmount);
            _WETH.withdraw(withdrawAmount);
            to.transfer(withdrawAmount);
        }
    }


    function getLPTokenPerEthUnit(uint ethAmt) public view  returns (uint liquidity){
        (uint256 reserveWeth, uint256 reserveTokens) = getPairReserves();
        uint256 outTokens = UniswapV2Library.getAmountOut(ethAmt.div(2), reserveWeth, reserveTokens);
        uint _totalSupply =  IUniswapV2Pair(_tokenWETHPair).totalSupply();

        (address token0, ) = UniswapV2Library.sortTokens(address(_WETH), _token);
        (uint256 amount0, uint256 amount1) = token0 == _token ? (outTokens, ethAmt.div(2)) : (ethAmt.div(2), outTokens);
        (uint256 _reserve0, uint256 _reserve1) = token0 == _token ? (reserveTokens, reserveWeth) : (reserveWeth, reserveTokens);
        liquidity = SafeMath.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
    }

    function getPairReserves() internal view returns (uint256 wethReserves, uint256 tokenReserves) {
        (address token0,) = UniswapV2Library.sortTokens(address(_WETH), _token);
        (uint256 reserve0, uint reserve1,) = IUniswapV2Pair(_tokenWETHPair).getReserves();
        (wethReserves, tokenReserves) = token0 == _token ? (reserve1, reserve0) : (reserve0, reserve1);
    }

}