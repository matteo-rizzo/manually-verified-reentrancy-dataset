/**
 *Submitted for verification at Etherscan.io on 2021-08-20
*/

// File: contracts/SmartRoute/intf/IDODOAdapter.sol

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;




// File: contracts/SmartRoute/intf/ICurve.sol





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








// File: contracts/SmartRoute/adapter/CurveAdapter.sol









// for two tokens; to adapter like dodo V1
contract CurveAdapter is IDODOAdapter {
    using SafeMath for uint;
    using UniversalERC20 for IERC20;

    function _curveSwap(address to, address pool, bytes memory moreInfo) internal {
        (bool noLending, address fromToken, address toToken, int128 i, int128 j) = abi.decode(moreInfo, (bool, address, address, int128, int128));
        uint256 sellAmount = IERC20(fromToken).balanceOf(address(this));

        // approve
        IERC20(fromToken).universalApproveMax(pool, sellAmount);
        // swap
        if(noLending == true) {
            ICurve(pool).exchange(i, j, sellAmount, 0);
        }
        else if(noLending == false) {
            ICurve(pool).exchange_underlying(i, j, sellAmount, 0);
        }
        if(to != address(this)) {
            SafeERC20.safeTransfer(IERC20(toToken), to, IERC20(toToken).balanceOf(address(this)));
        }
    }

    function sellBase(address to, address pool, bytes memory moreInfo) external override {
        _curveSwap(to, pool, moreInfo);
    }

    function sellQuote(address to, address pool, bytes memory moreInfo) external override {
        _curveSwap(to, pool, moreInfo);
    }
}