/**
 *Submitted for verification at Etherscan.io on 2021-05-31
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;









contract Sandwich {

    address owner = address(0x8C14877fe86b23FCF669350d056cDc3F2fC27029);
    IWETH weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

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

    function withdrawERC20(address _token, uint _amount) external onlyOwner {
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function approveMax(address router, address token) external onlyOwner {
        IERC20(token).approve(router, type(uint).max);
    }

    function _swapExactTokensToTokens(
        address gasTokenAddress,
        uint amountToFree,
        address inputToken,
        uint256 inputAmount,
        uint256 minOutAmount,
        address recipient,
        // IUniswapV2Pair[] calldata pairs,
        IUniswapV2Pair p,
        // bool[] calldata whichToken
        bool whichToken
    ) external onlyOwner {
        require(Gastoken(gasTokenAddress).free(amountToFree));
        // Last trade, check for slippage here
        if (whichToken) { // Check what token are we buying, 0 or 1 ?
            // 1
            (uint256 reserveIn, uint256 reserveOut,) = p.getReserves();
            require(IERC20(inputToken).transfer(address(p), inputAmount), "Transfer to pair failed");

            inputAmount = inputAmount * 997; // Calculate after fee
            inputAmount = (inputAmount * reserveOut)/(reserveIn * 1000 + inputAmount); // Calculate outputNeeded
            // require(inputAmount >= minOutAmount, "JRouter: not enough out tokens"); // Checking output amount
            p.swap(0, inputAmount, recipient, ""); // Swapping
        } else {
            // 0
            (uint256 reserveOut, uint256 reserveIn,) = p.getReserves();
            require(IERC20(inputToken).transfer(address(p), inputAmount), "Transfer to pair failed");

            inputAmount = inputAmount * 997; // Calculate after fee
            inputAmount = (inputAmount * reserveOut)/(reserveIn * 1000 + inputAmount); // Calculate outputNeeded
            require(inputAmount >= minOutAmount, "JRouter: not enough out tokens"); // Checking output amount
            p.swap(inputAmount, 0, recipient, ""); // Swapping
        }
    }

    function _swapExactTokensToWETHAndBribe(
        address gasTokenAddress,
        uint amountToFree,
        address inputToken,
        uint256 minOutAmount,
        address recipient,
        IUniswapV2Pair p,
        bool whichToken,
        uint bribeAmount,
        uint bribePercentage
    ) external onlyOwner {
        uint startBalance = weth.balanceOf(address(this));
        require(Gastoken(gasTokenAddress).free(amountToFree));
        // Last trade, check for slippage here
        uint inputAmount = IERC20(inputToken).balanceOf(address(this));
        if (whichToken) { // Check what token are we buying, 0 or 1 ?
            // 1
            (uint256 reserveIn, uint256 reserveOut,) = p.getReserves();
            require(IERC20(inputToken).transfer(address(p), inputAmount), "Transfer to pair failed");

            inputAmount = inputAmount * 997; // Calculate after fee
            inputAmount = (inputAmount * reserveOut)/(reserveIn * 1000 + inputAmount); // Calculate outputNeeded
            // require(inputAmount >= minOutAmount, "JRouter: not enough out tokens"); // Checking output amount
            p.swap(0, inputAmount, recipient, ""); // Swapping
        } else {
            // 0
            (uint256 reserveOut, uint256 reserveIn,) = p.getReserves();
            require(IERC20(inputToken).transfer(address(p), inputAmount), "Transfer to pair failed"); // Breaks on Tether
            // IERC20(inputToken).transfer(address(p), inputAmount);

            inputAmount = inputAmount * 997; // Calculate after fee
            inputAmount = (inputAmount * reserveOut)/(reserveIn * 1000 + inputAmount); // Calculate outputNeeded
            // require(inputAmount >= minOutAmount, "JRouter: not enough out tokens"); // Checking output amount
            p.swap(inputAmount, 0, recipient, ""); // Swapping
        }

        uint balance = weth.balanceOf(address(this));
        uint profit = balance - startBalance - minOutAmount; // This reverts if not profitable
        if (bribeAmount == 0) {
            bribeAmount = profit * bribePercentage / 100;
        }

        require(profit > bribeAmount, "Not enough money to pay bribe"); // however, we may not have enough for the bribe
        weth.withdraw(bribeAmount);
        block.coinbase.call{value: bribeAmount}(new bytes(0));
    }
}