/**
 *Submitted for verification at Etherscan.io on 2020-10-12
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
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








contract CynMaker {
    using SafeMath for uint256;

    IUniswapV2Factory public factory;
    address public bar;
    address public cyn;
    address public weth;
    // Dev address.
    address public devaddr;

    constructor(IUniswapV2Factory _factory, address _cyn, address _bar, address _weth, address _devaddr) public {
        factory = _factory;
        cyn = _cyn;
        bar = _bar;
        weth = _weth;
        devaddr = _devaddr;
    }

    function convert(address token0, address token1) public {
        // At least we try to make front-running harder to do.
        require(msg.sender == tx.origin, "do not convert from contract");
        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(token0, token1));
        if (pair.balanceOf(address(this)) == 0) {
            return;
        }
        pair.transfer(address(pair), pair.balanceOf(address(this)));
        pair.burn(address(this)); 
        uint256 wethAmount = _toWETH(token0) + _toWETH(token1);
        _toCYN(wethAmount);
        _DistributedCYN();
    }

    function _toWETH(address token) internal returns (uint256) {
        if (token == cyn) {
            //uint amount = IERC20(token).balanceOf(address(this));
            //IERC20(token).transfer(bar, amount);
            return 0;
        }
        if (token == weth) {
            uint amount = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(factory.getPair(weth, cyn), amount);
            return amount;
        }
        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(token, weth));
        if (address(pair) == address(0)) {
            return 0;
        }
        (uint reserve0, uint reserve1,) = pair.getReserves();
        address token0 = pair.token0();
        (uint reserveIn, uint reserveOut) = token0 == token ? (reserve0, reserve1) : (reserve1, reserve0);
        uint amountIn = IERC20(token).balanceOf(address(this));
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        uint amountOut = numerator / denominator;
        (uint amount0Out, uint amount1Out) = token0 == token ? (uint(0), amountOut) : (amountOut, uint(0));
        IERC20(token).transfer(address(pair), amountIn);
        pair.swap(amount0Out, amount1Out, factory.getPair(weth, cyn), new bytes(0));
        return amountOut;
    }

    function _toCYN(uint256 amountIn) internal {
        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(weth, cyn));
        (uint reserve0, uint reserve1,) = pair.getReserves();
        address token0 = pair.token0();
        (uint reserveIn, uint reserveOut) = token0 == weth ? (reserve0, reserve1) : (reserve1, reserve0);
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        uint amountOut = numerator / denominator;
        (uint amount0Out, uint amount1Out) = token0 == weth ? (uint(0), amountOut) : (amountOut, uint(0));
        // maker collects all the cyn
        pair.swap(amount0Out, amount1Out, address(this), new bytes(0));
    }
    function _DistributedCYN() internal {
        // 10% of fee for devaddr (0.005% for swap amount)
        // 90% of fee for bar (0.045% for swap amount)
        uint amount = IERC20(cyn).balanceOf(address(this));
        uint bar_amount = amount.mul(90) /100;
        uint dev_amount = amount.sub(bar_amount);
        IERC20(cyn).transfer(bar, bar_amount);
        IERC20(cyn).transfer(devaddr, dev_amount);
    }
}