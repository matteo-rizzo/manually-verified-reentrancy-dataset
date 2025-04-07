/**
 *Submitted for verification at Etherscan.io on 2021-07-07
*/

// File: contracts/SmartRoute/intf/IDODOAdapter.sol

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;



// File: contracts/SmartRoute/intf/IUniswapV3SwapCallback.sol



/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface


// File: contracts/SmartRoute/intf/IUniV3.sol





// File: contracts/intf/IERC20.sol



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/lib/SafeMath.sol




/**
 * @title SafeMath
 * @author DODO Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */


// File: contracts/lib/SafeERC20.sol






/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/SmartRoute/lib/UniversalERC20.sol








// File: contracts/lib/TickMath.sol



/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128


// File: contracts/intf/IWETH.sol





// File: contracts/SmartRoute/adapter/UniV3Adapter.sol











//import {TickMath} from '@uniswap/v3-core/contracts/libraries/TickMath.sol';

// to adapter like dodo V1
contract UniV3Adapter is IDODOAdapter, IUniswapV3SwapCallback {
    using SafeMath for uint;

    // ============ Storage ============

    address constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public immutable _WETH_;

    constructor (
        address payable weth
    ) public {
        _WETH_ = weth;
    }

    function _uniV3Swap(address to, address pool, uint160 sqrtX96, bytes memory data) internal {
        (address fromToken, address toToken, uint24 fee) = abi.decode(data, (address, address, uint24));
        
        uint256 sellAmount = IERC20(fromToken).balanceOf(address(this));
        bool zeroForOne = fromToken < toToken;

        // transfer
        //IERC20(fromToken).transfer(pool, sellAmount);
        // swap
        IUniV3(pool).swap(
            to, 
            zeroForOne, 
            int256(sellAmount), 
            sqrtX96 == 0
                ? (zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1)
                : sqrtX96,
            data
        );
    }

    function sellBase(address to, address pool, bytes memory moreInfo) external override {
        (uint160 sqrtX96, bytes memory data) = abi.decode(moreInfo, (uint160, bytes));
        _uniV3Swap(to, pool, sqrtX96, data);
    }

    function sellQuote(address to, address pool, bytes memory moreInfo) external override {
        (uint160 sqrtX96, bytes memory data) = abi.decode(moreInfo, (uint160, bytes));
        _uniV3Swap(to, pool, sqrtX96, data);
    }


    // for uniV3 callback

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata _data
    ) external override {
        require(amount0Delta > 0 || amount1Delta > 0); // swaps entirely within 0-liquidity regions are not supported
        (address tokenIn, address tokenOut, uint24 fee) = abi.decode(_data, (address, address, uint24));

        (bool isExactInput, uint256 amountToPay) =
            amount0Delta > 0
                ? (tokenIn < tokenOut, uint256(amount0Delta))
                : (tokenOut < tokenIn, uint256(amount1Delta));
        if (isExactInput) {
            pay(tokenIn, address(this), msg.sender, amountToPay);
        } else {           
            tokenIn = tokenOut; // swap in/out because exact output swaps are reversed
            pay(tokenIn, address(this), msg.sender, amountToPay);
        }
    }

    /// @param token The token to pay
    /// @param payer The entity that must pay
    /// @param recipient The entity that will receive payment
    /// @param value The amount to pay
    function pay(
        address token,
        address payer,
        address recipient,
        uint256 value
    ) internal {
        if (token == _WETH_ && address(this).balance >= value) {
            // pay with WETH9
            IWETH(_WETH_).deposit{value: value}(); // wrap only what is needed to pay
            IWETH(_WETH_).transfer(recipient, value);
        } else if (payer == address(this)) {
            // pay with tokens already in the contract (for the exact input multihop case)
            SafeERC20.safeTransfer(IERC20(token), recipient, value);
        } else {
            // pull payment
            SafeERC20.safeTransferFrom(IERC20(token), payer, recipient, value);
        }
    }

}