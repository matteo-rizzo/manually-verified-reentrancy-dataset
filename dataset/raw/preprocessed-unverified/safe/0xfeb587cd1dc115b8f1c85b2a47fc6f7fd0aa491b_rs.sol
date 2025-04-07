/**
 *Submitted for verification at Etherscan.io on 2020-11-16
*/

pragma solidity ^0.6.12;


//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//
// LiquidityZAP - BcdcZAP
//   Copyright (c) 2020 deepyr.com
//
// BcdcZAP takes ETH and converts to a Uniswap liquidity tokens. 
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  
// If not, see <https://github.com/apguerrera/LiquidityZAP/>.
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// ---------------------------------------------------------------------
// SPDX-License-Identifier: GPL-3.0-or-later                        
// ---------------------------------------------------------------------








/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 */






contract BcdcZAP {

    using SafeMath for uint256;

    address public _token;
    address public _tokenWETHPair;
    IWETH public _WETH;
    ITokenPool public _tokenPool;
    bool private initialized;

    function initZAP(address token, address WETH, address tokenWethPair, address tokenPool) public  {
        require(!initialized);
        _token = token;
        _WETH = IWETH(WETH);
        _tokenWETHPair = tokenWethPair;
        _tokenPool = ITokenPool(tokenPool);
        initialized = true;
    }

    fallback() external payable {
        if(msg.sender != address(_WETH)){
             addLiquidityETHOnly(msg.sender, false, 0);
        }
    }

    function addLiquidityETHOnly(address payable to, bool autoStake, uint256 pid) public payable {
        require(to != address(0), "Invalid address");

        uint256 buyAmount = msg.value.div(2);
        require(buyAmount > 0, "Insufficient ETH amount");
        _WETH.deposit{value : msg.value}();

        (uint256 reserveWeth, uint256 reserveTokens) = getPairReserves();
        uint256 outTokens = UniswapV2Library.getAmountOut(buyAmount, reserveWeth, reserveTokens);

        _WETH.transfer(_tokenWETHPair, buyAmount);

        (address token0, address token1) = UniswapV2Library.sortTokens(address(_WETH), _token);
        IUniswapV2Pair(_tokenWETHPair).swap(_token == token0 ? outTokens : 0, _token == token1 ? outTokens : 0, address(this), "");

        _addLiquidity(outTokens, buyAmount, to, autoStake, pid);
	
    }

    function _addLiquidity(uint256 tokenAmount, uint256 wethAmount, address payable to, bool autoStake, uint256 pid) internal {
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

        if (autoStake) {
            IUniswapV2Pair(_tokenWETHPair).mint(address(this));
            _tokenPool.depositFor(to, pid, IUniswapV2Pair(_tokenWETHPair).balanceOf(address(this)));
        }
        else
            IUniswapV2Pair(_tokenWETHPair).mint(to);


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