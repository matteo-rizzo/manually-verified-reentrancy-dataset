/**
 *Submitted for verification at Etherscan.io on 2021-04-22
*/

/**
 *Submitted for verification at Etherscan.io on 2021-04-14
*/

// File contracts/swappers/SushiSwapMultiSwapper.sol
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

// solhint-disable avoid-low-level-calls

// File @boringcrypto/boring-solidity/contracts/interfaces/[email protected]
// License-Identifier: MIT


// File @boringcrypto/boring-solidity/contracts/libraries/[email protected]
// License-Identifier: MIT



// File @boringcrypto/boring-solidity/contracts/libraries/[email protected]
// License-Identifier: MIT

/// @notice A library for performing overflow-/underflow-safe math,
/// updated with awesomeness from of DappHub (https://github.com/dapphub/ds-math).


// File @sushiswap/core/contracts/uniswapv2/interfaces/[email protected]
// License-Identifier: GPL-3.0



// File contracts/libraries/UniswapV2Library.sol
// License-Identifier: GPL-3.0



// File @sushiswap/bentobox-sdk/contracts/[email protected]
// License-Identifier: MIT



// File contracts/swappers/SushiSwapMultiSwapper.sol
// License-Identifier: GPL-3.0

contract SushiSwapMultiSwapper {
    using BoringERC20 for IERC20;
    using BoringMath for uint256;

    address private immutable factory;
    IBentoBoxV1 private immutable bentoBox;
    bytes32 private immutable pairCodeHash;

    constructor (address _factory, IBentoBoxV1 _bentoBox, bytes32 _pairCodeHash) public {
        factory = _factory;
        bentoBox = _bentoBox;
        pairCodeHash = _pairCodeHash;
    }

    function getOutputAmount (IERC20 tokenIn, address[] calldata path, uint256 shareIn) external view returns (uint256 amountOut){
        uint256 amountIn = bentoBox.toAmount(tokenIn, shareIn, false);
        uint256[] memory amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path, pairCodeHash);
        amountOut = amounts[amounts.length - 1];
    }

    function swap (IERC20 tokenIn, IERC20 tokenOut, uint256 amountMinOut, address path1, address path2, address to, uint256 baseShare, uint256 shareIn) external returns (uint256) {
        address[] memory path;
        if (path2 == address(0)) {
            if (path1 == address(0)) {
                path = new address[](2);
                path[1] = address(tokenOut);
            } else {
                path = new address[](3);
                path[1] = path1;
                path[2] = address(tokenOut);
            }
        } else {
            path = new address[](4);
            path[1] = path1;
            path[2] = path2;
            path[3] = address(tokenOut);
        }
        path[0] = address(tokenIn);
        (uint256 amountIn, ) = bentoBox.withdraw(tokenIn, address(this), address(this), 0, shareIn);
        uint256 amount = _swapExactTokensForTokens(amountIn, amountMinOut, path, address(bentoBox));
        (, uint256 share) = bentoBox.deposit(tokenOut, address(bentoBox), to, amount, 0);
        return baseShare.add(share);
    }

    // Swaps an exact amount of tokens for another token through the path passed as an argument
    // Returns the amount of the final token
    function _swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to
    ) internal returns (uint256 amountOut) {
        uint256[] memory amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path, pairCodeHash);
        amountOut = amounts[amounts.length - 1];
        require(amountOut >= amountOutMin, "insufficient-amount-out");
        IERC20(path[0]).safeTransfer(UniswapV2Library.pairFor(factory, path[0], path[1], pairCodeHash), amountIn);
        _swap(amounts, path, to);
    }

    // requires the initial amount to have already been sent to the first pair
    function _swap(
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = UniswapV2Library.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2], pairCodeHash) : _to;
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output, pairCodeHash)).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }
    }
}