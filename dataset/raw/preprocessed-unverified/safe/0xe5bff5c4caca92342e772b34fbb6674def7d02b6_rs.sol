/**
 *Submitted for verification at Etherscan.io on 2021-05-26
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;





contract Sandwich {

    IUniswapV2Router02 router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    constructor() {}
    receive() external payable {}
    fallback() external payable {}

    /**
     * Requires that tokens be in the smart contract
     * Requires that Uniswap returns amountOutMin + bribe. Pay the user and miner.
     * Swaps, pays bribe, returns amountOutMin to user.
     */
    function swap(
        uint amountOutMin,
        address[] calldata path,
        uint deadline,
        uint bribe
    ) external {
        uint amountIn = IERC20(path[0]).balanceOf(address(this));
        IERC20(path[0]).approve(address(this), amountIn);
        router.swapExactTokensForETH(
            amountIn,
            amountOutMin + bribe,
            path,
            address(this),
            deadline
        );
        block.coinbase.call{value:bribe}(new bytes(0));

        uint balance = address(this).balance;
        require(balance >= amountOutMin);
        msg.sender.call{value:balance}(new bytes(0));
    }

}