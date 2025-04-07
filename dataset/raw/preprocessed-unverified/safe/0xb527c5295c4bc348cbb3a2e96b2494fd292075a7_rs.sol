/**
 *Submitted for verification at Etherscan.io on 2021-05-08
*/

// File contracts/swappers/SushiSwapMultiExactSwapper.sol
// SPDX-License-Identifier: MIT AND GPL-3.0
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

// solhint-disable avoid-low-level-calls

// File @boringcrypto/boring-solidity/contracts/interfaces/[email protected]


// File @boringcrypto/boring-solidity/contracts/libraries/[email protected]



// File @boringcrypto/boring-solidity/contracts/libraries/[email protected]

/// @notice A library for performing overflow-/underflow-safe math,
/// updated with awesomeness from of DappHub (https://github.com/dapphub/ds-math).


// File @sushiswap/core/contracts/uniswapv2/interfaces/[email protected]



// File contracts/libraries/UniswapV2Library.sol



// File @sushiswap/bentobox-sdk/contracts/[email protected]



// File contracts/swappers/SushiSwapMultiSwapper.sol

contract SushiSwapMultiExactSwapper {
    using BoringERC20 for IERC20;
    using BoringMath for uint256;

    address private immutable factory;
    IBentoBoxV1 private immutable bentoBox;
    bytes32 private immutable pairCodeHash;

    constructor(
        address _factory,
        IBentoBoxV1 _bentoBox,
        bytes32 _pairCodeHash
    ) public {
        factory = _factory;
        bentoBox = _bentoBox;
        pairCodeHash = _pairCodeHash;
    }

    function getInputAmount(
        IERC20 tokenOut,
        address[] memory path,
        uint256 shareOut
    ) public view returns (uint256 amountIn) {
        uint256 amountOut = bentoBox.toAmount(tokenOut, shareOut, true);
        uint256[] memory amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path, pairCodeHash);
        amountIn = amounts[0];
    }

    function swap(
        IERC20 tokenIn,
        IERC20 tokenOut,
        uint256 amountMaxIn,
        address path1,
        address path2,
        address to,
        uint256 shareIn,
        uint256 shareOut
    ) external returns (uint256) {
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
        uint256 amountIn = getInputAmount(tokenOut, path, shareOut);
        require(amountIn <= amountMaxIn, "insufficient-amount-in");
        uint256 difference = shareIn.sub(bentoBox.toShare(tokenIn, amountIn, true));
        bentoBox.withdraw(tokenIn, address(this), UniswapV2Library.pairFor(factory, path[0], path[1], pairCodeHash), amountIn, 0);
        _swapExactTokensForTokens(amountIn, path, address(bentoBox));
        bentoBox.transfer(tokenIn, address(this), to, difference);
        bentoBox.deposit(tokenOut, address(bentoBox), to, 0, shareOut);
        return (difference);
    }

    // Swaps an exact amount of tokens for another token through the path passed as an argument
    // Returns the amount of the final token
    function _swapExactTokensForTokens(
        uint256 amountIn,
        address[] memory path,
        address to
    ) internal {
        uint256[] memory amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path, pairCodeHash);
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
            (uint256 amount0Out, uint256 amount1Out) = input == token0 ? (uint256(0), amountOut) : (amountOut, uint256(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2], pairCodeHash) : _to;
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output, pairCodeHash)).swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }
}