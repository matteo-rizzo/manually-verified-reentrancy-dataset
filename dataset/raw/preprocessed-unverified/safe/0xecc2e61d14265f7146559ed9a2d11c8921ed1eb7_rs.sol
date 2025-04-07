/**
 *Submitted for verification at Etherscan.io on 2020-07-22
*/

// File: contracts/lib/Ownable.sol

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;


/**
 * @title Ownable
 * @author DODO Breeder
 *
 * @notice Ownership related functions
 */


// File: contracts/intf/IDODO.sol

/*

    Copyright 2020 DODO ZOO.

*/




// File: contracts/intf/IERC20.sol

// This is a file copied from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/lib/SafeMath.sol

/*

    Copyright 2020 DODO ZOO.

*/


/**
 * @title SafeMath
 * @author DODO Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */


// File: contracts/lib/SafeERC20.sol

/*

    Copyright 2020 DODO ZOO.
    This is a simplified version of OpenZepplin's SafeERC20 library

*/





/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/helper/UniswapArbitrageur.sol

/*

    Copyright 2020 DODO ZOO.

*/












contract UniswapArbitrageur is Ownable, IUniswapV2Callee {
    using SafeERC20 for IERC20;

    /*
    data encode:
    1. address dodoAddress
    2. bool isBuy on dodo
    3. uint256 amount

    */

    function uniswapV2Call(
        address,
        uint256 amount0,
        uint256,
        bytes calldata data
    ) external override {
        address token0 = IUniswapV2Pair(msg.sender).token0(); // fetch the address of token0
        address token1 = IUniswapV2Pair(msg.sender).token1(); // fetch the address of token1

        (address dodo, bool isBuy, uint256 amount) = abi.decode(data, (address, bool, uint256));

        address base;
        address quote;

        if (isBuy) {
            if (amount0 != 0) {
                quote = token0;
                base = token1;
            } else {
                quote = token1;
                base = token0;
            }
        } else {
            if (amount0 != 0) {
                base = token0;
                quote = token1;
            } else {
                base = token1;
                quote = token0;
            }
        }

        if (isBuy) {
            // if buy on dodo, buy amount and send all base token back to msg.sender
            IDODO(dodo).buyBaseToken(amount, uint256(-1));
            IERC20(base).safeTransfer(msg.sender, IERC20(base).balanceOf(address(this)));
        } else {
            // if sell on dodo, sell all and send amount quote token back to msg.sender
            IDODO(dodo).sellBaseToken(IERC20(base).balanceOf(address(this)), 0);
            IERC20(quote).safeTransfer(msg.sender, amount);
        }
        IERC20(quote).safeTransfer(_OWNER_, IERC20(quote).balanceOf(address(this)));
    }

    function retrieve(address token, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    function approve(address token, address spender) external onlyOwner {
        IERC20(token).approve(spender, uint256(-1));
    }
}