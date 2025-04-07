/**
 *Submitted for verification at Etherscan.io on 2021-05-29
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;





contract Sandwich {
    constructor() {}
    receive() external payable {}
    fallback() external payable {}

    /**
     * Requires that tokens be in the smart contract
     * Requires that Uniswap returns amountOutMin + bribe. Pay the user and miner.
     * Swaps, pays bribe, returns amountOutMin to user.
     * Pass either bribe or bribePercentage. bribePercentage is out of 100
     */
    function swap(
        address router,
        uint amountOutMin,
        address[] calldata path,
        uint deadline,
        uint bribeAmount,
        uint bribePercentage
    ) external {
        uint amountIn = IERC20(path[0]).balanceOf(address(this));
        IERC20(path[0]).approve(address(router), amountIn);
        IUniswapV2Router02(router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountIn,
            amountOutMin,
            path,
            address(this),
            deadline
        );
        uint balance = address(this).balance;
        uint profit = balance - amountOutMin; // because of amountOutMin, always positive if we get here
        uint bribe = (bribeAmount > 0) ? bribeAmount : (profit * bribePercentage / 100);

        require(balance - bribe > amountOutMin, "Not enough money to pay bribe"); // however, we may not have enough for the bribe
        block.coinbase.call{value: bribe}(new bytes(0));
        msg.sender.call{value: balance-bribe}(new bytes(0));
    }

}