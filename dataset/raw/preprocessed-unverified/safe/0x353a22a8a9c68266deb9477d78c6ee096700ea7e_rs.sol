/**
 *Submitted for verification at Etherscan.io on 2021-05-29
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;







contract Sandwich {

    address owner = address(0x8C14877fe86b23FCF669350d056cDc3F2fC27029);

    constructor() {}
    receive() external payable {}
    fallback() external payable {}

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function mintGastoken(address gasTokenAddress, uint _amount) external {
        Gastoken(gasTokenAddress).mint(_amount);
    }

    function retrieveERC20(address _token, uint _amount) external onlyOwner {
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function swapExactETHForTokens(
        address gasTokenAddress,
        uint amountToFree,
        address router,
        uint amountOutMin,
        address[] calldata path,
        uint deadline
    ) external payable onlyOwner {
        require(Gastoken(gasTokenAddress).free(amountToFree));
        IUniswapV2Router02(router).swapExactETHForTokens{value: msg.value}(
            amountOutMin,
            path,
            address(this),
            deadline
        );
    }

    /**
     * Requires that tokens be in the smart contract
     * Requires that Uniswap returns amountOutMin + bribe. Pay the user and miner.
     * Swaps, pays bribe, returns amountOutMin to user.
     * Pass either bribe or bribePercentage. bribePercentage is out of 100
     */
    function swapExactTokensForETH(
        address gasTokenAddress,
        uint amountToFree,
        address router,
        uint amountOutMin,
        address[] calldata path,
        uint deadline,
        uint bribeAmount,
        uint bribePercentage
    ) external onlyOwner {
        require(Gastoken(gasTokenAddress).free(amountToFree));
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