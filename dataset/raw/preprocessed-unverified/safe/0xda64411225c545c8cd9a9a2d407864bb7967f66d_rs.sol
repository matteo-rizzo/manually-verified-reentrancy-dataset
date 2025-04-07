/**
 *Submitted for verification at Etherscan.io on 2021-04-12
*/

/// SPDX-License-Identifier: MIT
/*
▄▄█    ▄   ██   █▄▄▄▄ ▄█ 
██     █  █ █  █  ▄▀ ██ 
██ ██   █ █▄▄█ █▀▀▌  ██ 
▐█ █ █  █ █  █ █  █  ▐█ 
 ▐ █  █ █    █   █    ▐ 
   █   ██   █   ▀   
           ▀          */
/// Special thanks to Keno and Boring for reviewing early bridge patterns.
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

// File @boringcrypto/boring-solidity/contracts/libraries/[email protected]
/// License-Identifier: MIT

/// @notice A library for performing overflow-/underflow-safe math,
/// updated with awesomeness from of DappHub (https://github.com/dapphub/ds-math).


/// @notice Interface for SushiSwap.


// File @boringcrypto/boring-solidity/contracts/interfaces/[email protected]
/// License-Identifier: MIT



// File @boringcrypto/boring-solidity/contracts/libraries/[email protected]
/// License-Identifier: MIT



/// @notice Contract that batches SUSHI staking and DeFi strategies.
contract Inari {
    using BoringMath for uint256;
    using BoringERC20 for IERC20;
    
    address constant wETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant sushiSwapFactory = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac; // SushiSwap factory contract
    ISushiSwap constant sushiSwapSushiWethPair = ISushiSwap(0x795065dCc9f64b5614C407a6EFDC400DA6221FB0); // 
    
    function swap1() external payable {
        (uint256 reserve0, uint256 reserve1, ) = sushiSwapSushiWethPair.getReserves();
        uint256 amountInWithFee = msg.value.mul(997);
        uint256 amountOut =
            amountInWithFee.mul(reserve1) /
            reserve0.mul(1000).add(amountInWithFee);
        ISushiSwap(wETH).deposit{value: msg.value}();
        IERC20(wETH).approve(address(sushiSwapSushiWethPair), msg.value);
        IERC20(wETH).safeTransfer(address(sushiSwapSushiWethPair), msg.value);
        sushiSwapSushiWethPair.swap(0, amountOut, msg.sender, "");
    }
    
    function swap2() external payable {
        (uint256 reserve0, uint256 reserve1, ) = sushiSwapSushiWethPair.getReserves();
        uint256 amountInWithFee = msg.value.mul(997);
        uint256 amountOut =
            amountInWithFee.mul(reserve0) /
            reserve1.mul(1000).add(amountInWithFee);
        ISushiSwap(wETH).deposit{value: msg.value}();
        IERC20(wETH).approve(address(sushiSwapSushiWethPair), msg.value);
        IERC20(wETH).safeTransfer(address(sushiSwapSushiWethPair), msg.value);
        sushiSwapSushiWethPair.swap(amountOut, 0, msg.sender, "");
    }
}