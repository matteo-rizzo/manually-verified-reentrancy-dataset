/**
 *Submitted for verification at Etherscan.io on 2021-09-23
*/

// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.7.5;
pragma abicoder v2;

// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolImmutables.sol
/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values


// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolState.sol
/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction


// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolDerivedState.sol
/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.


// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolActions.sol
/// @title Permissionless pool actions
/// @notice Contains pool methods that can be called by anyone


// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolOwnerActions.sol
/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner


// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolEvents.sol
/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool


// File: @uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol
/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}

// File: @uniswap/v3-core/contracts/libraries/FullMath.sol
/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits


// File: @uniswap/v3-core/contracts/libraries/FixedPoint96.sol
/// @title FixedPoint96
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)
/// @dev Used in SqrtPriceMath.sol


// File: @uniswap/v3-core/contracts/libraries/TickMath.sol
/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128


// File: @uniswap/v3-periphery/contracts/libraries/PoolAddress.sol
/// @title Provides functions for deriving a pool address from the factory, tokens, and the fee


// File: @uniswap/v3-periphery/contracts/libraries/BytesLib.sol
/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <[email protected]>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */


// File: @uniswap/v3-periphery/contracts/libraries/Path.sol
/// @title Functions for manipulating path data for multihop swaps


// File: contracts/libraries/PathPrice.sol


// File: @uniswap/v3-core/contracts/libraries/FixedPoint128.sol
/// @title FixedPoint128
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)


// File: @uniswap/v3-periphery/contracts/libraries/PositionKey.sol


// File: @uniswap/v3-core/contracts/libraries/LowGasSafeMath.sol
/// @title Optimized overflow and underflow safe math operations
/// @notice Contains methods for doing math operations that revert on overflow or underflow for minimal gas cost


// File: @uniswap/v3-periphery/contracts/libraries/LiquidityAmounts.sol
/// @title Liquidity amount functions
/// @notice Provides functions for computing liquidity amounts from token amounts and prices


// File: @uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol
/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface


// File: @uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol
/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}

// File: @uniswap/v3-core/contracts/libraries/SafeCast.sol
/// @title Safe casting methods
/// @notice Contains methods for safely casting between types


// File: @uniswap/v3-core/contracts/libraries/UnsafeMath.sol
/// @title Math functions that do not check inputs or outputs
/// @notice Contains methods that perform common math functions but do not do any overflow or underflow checks


// File: @uniswap/v3-core/contracts/libraries/SqrtPriceMath.sol
/// @title Functions based on Q64.96 sqrt price and liquidity
/// @notice Contains the math that uses square root of price as a Q64.96 and liquidity to compute deltas


// File: contracts/libraries/Position.sol
