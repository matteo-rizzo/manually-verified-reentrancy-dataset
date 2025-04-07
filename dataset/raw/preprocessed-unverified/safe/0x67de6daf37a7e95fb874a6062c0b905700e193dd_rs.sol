/**
 *Submitted for verification at Etherscan.io on 2021-07-24
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;









contract Sandwich {

    // No sstore or sload

    constructor() {}
    receive() external payable {}
    fallback() external payable {}

    modifier onlyOwner {
        require(msg.sender == address(0x8C14877fe86b23FCF669350d056cDc3F2fC27029));
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

    function _swapExactWETHToTokens(
        uint amountToFree,
        uint256 inputAmount,
        uint256 outputAmount,
        IUniswapV2Pair p,
        bool whichToken
    ) external onlyOwner {
        // require(IERC20(inputToken).transfer(address(p), inputAmount), "Transfer to pair failed");
        // inputToken.call(abi.encodeWithSelector(0xa9059cbb, address(p), inputAmount)); // transfer()
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).call(abi.encodeWithSelector(0xa9059cbb, address(p), inputAmount)); // WETH.transfer()
        // Last trade, check for slippage here
        if (whichToken) { // Check what token are we buying, 0 or 1 ?
            // 1
            // p.swap(0, outputAmount, recipient, "");
            address(p).call(abi.encodeWithSelector(0x0902f1ac, 0, outputAmount, address(this), "")); // Pair.swap() - this brought gas down from 86k to 42k. What's happening?
        } else {
            // 0
            // p.swap(outputAmount, 0, recipient, "");
            address(p).call(abi.encodeWithSelector(0x0902f1ac, outputAmount, 0, address(this), "")); // Pair.swap() - this brought gas down from 86k to 42k. What's happening?
        }
        if(amountToFree > 0) {
            // require(Gastoken(0x0000000000b3F879cb30FE243b4Dfee438691c04).free(amountToFree));
            address(0x0000000000b3F879cb30FE243b4Dfee438691c04).call(abi.encodeWithSelector(0xd8ccd0f3, amountToFree)); // GST2.free()
        }
    }

    function _swapExactTokensToWETHAndBribe(
        uint amountToFree,
        address inputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 minOutAmount, // only used if outputAmount is zero
        IUniswapV2Pair p,
        bool whichToken,
        uint bribeAmount,
        uint bribePercentage
    ) external {
        if(amountToFree > 0) {
            address(0x0000000000b3F879cb30FE243b4Dfee438691c04).call(abi.encodeWithSelector(0xd8ccd0f3, amountToFree)); // GST2.free()
        }
        // uint startBalance = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).balanceOf(address(this));
        (, bytes memory data) = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).call(abi.encodeWithSelector(0x70a08231, address(this))); // WETH.balanceOf(address);
        uint startBalance = abi.decode(data, (uint256));
        // Last trade, check for slippage here
        if(inputAmount == 0) {
            // inputAmount = IERC20(inputToken).balanceOf(address(this)) - 1; // Leave 1 token in wallet to prevent storage refund
            (, data) = inputToken.call(abi.encodeWithSelector(0x70a08231, address(this))); // inputToken.balanceOf(address);
            inputAmount = abi.decode(data, (uint256)) - 1;
        } // Might be unexpected if it's a deflationary token. But leave this option
        // require(IERC20(inputToken).transfer(address(p), inputAmount), "Transfer to pair failed");
        // inputToken.call(abi.encodeWithSelector(0x23b872dd, address(this), address(p), inputAmount));
        inputToken.call(abi.encodeWithSelector(0xa9059cbb, address(p), inputAmount)); // inputToken.transfer(address,uint256)

        if(outputAmount == 0) {
            if (whichToken) { // Check what token are we buying, 0 or 1 ?
                // 1
                // (uint256 reserveIn, uint256 reserveOut,) = p.getReserves();
                (, data) = address(p).call(abi.encodeWithSelector(0x0902f1ac));
                (uint256 reserveIn, uint256 reserveOut,) = abi.decode(data, (uint256, uint256, uint32));
                inputAmount = inputAmount * 997; // Calculate after fee
                inputAmount = (inputAmount * reserveOut)/(reserveIn * 1000 + inputAmount); // Calculate outputNeeded
                // p.swap(0, inputAmount, recipient, ""); // Swapping
                address(p).call(abi.encodeWithSelector(0x0902f1ac, 0, inputAmount, address(this), ""));
            } else {
                // 0
                // (uint256 reserveOut, uint256 reserveIn,) = p.getReserves();
                (, data) = address(p).call(abi.encodeWithSelector(0x0902f1ac));
                (uint256 reserveOut, uint256 reserveIn,) = abi.decode(data, (uint256, uint256, uint32));
                inputAmount = inputAmount * 997; // Calculate after fee
                inputAmount = (inputAmount * reserveOut)/(reserveIn * 1000 + inputAmount); // Calculate outputNeeded
                // p.swap(inputAmount, 0, recipient, ""); // Swapping
                address(p).call(abi.encodeWithSelector(0x0902f1ac, inputAmount, 0, address(this), ""));
            }
        } else {
            if (whichToken) {
                // p.swap(0, outputAmount, recipient, "");
                address(p).call(abi.encodeWithSelector(0x0902f1ac, 0, outputAmount, address(this), ""));
            } else {
                // p.swap(outputAmount, 0, recipient, "");
                address(p).call(abi.encodeWithSelector(0x0902f1ac, outputAmount, 0, address(this), ""));
            }
        }

        // uint balance = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).balanceOf(address(this));
        (, data) = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).call(abi.encodeWithSelector(0x70a08231, address(this))); // WETH.balanceOf(address);
        uint balance = abi.decode(data, (uint256));
        // uint balance = abi.decode(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).call(abi.encodeWithSelector(0x70a08231, address(this)))[1], (uint256));
        uint profit = balance - startBalance - minOutAmount; // This reverts if not profitable
        if (bribeAmount == 0) {
            bribeAmount = profit * bribePercentage / 100;
        }

        // Should remove this equals sign, but helpful for testing when there's nothing to sandwich
        require(profit >= bribeAmount, "Not enough money to pay bribe"); // however, we may not have enough for the bribe
        // IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).withdraw(bribeAmount);
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2).call(abi.encodeWithSelector(0x2e1a7d4d, bribeAmount)); // WETH.withdraw(uint256);
        block.coinbase.call{value: bribeAmount}(new bytes(0));
    }
}