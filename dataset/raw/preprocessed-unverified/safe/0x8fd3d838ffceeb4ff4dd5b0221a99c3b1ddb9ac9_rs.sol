// SPDX-License-Identifier: UNLICENSED
// https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol
pragma solidity ^0.7.0;


// https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol



// Copyright 2017 Loopring Technology Limited.



/// @title Utility Functions for uint
/// @author Daniel Wang - <daniel@loopring.org>


// Copyright 2017 Loopring Technology Limited.



/// @title PriceOracle

// Copyright 2017 Loopring Technology Limited.








/// @title Uniswap2PriceOracle
/// @dev Returns the value in Ether for any given ERC20 token.
contract UniswapV2PriceOracle is PriceOracle
{
    using MathUint   for uint;

    IUniswapV2Factory factory;
    address wethAddress;

    constructor(
        IUniswapV2Factory _factory,
        address           _wethAddress
        )
    {
        factory = _factory;
        wethAddress = _wethAddress;
        require(_wethAddress != address(0), "INVALID_WETH_ADDRESS");
    }

    function tokenValue(address token, uint amount)
        external
        view
        override
        returns (uint)
    {
        if (amount == 0) return 0;
        if (token == address(0) || token == wethAddress) return amount;

        address pair = factory.getPair(token, wethAddress);
        if (pair == address(0)) {
            return 0;
        }

        (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(pair).getReserves();

        if (reserve0 == 0 || reserve1 == 0) {
            return 0;
        }

        if (token < wethAddress) {
            return amount.mul(reserve1) / reserve0;
        } else {
            return amount.mul(reserve0) / reserve1;
        }
    }
}