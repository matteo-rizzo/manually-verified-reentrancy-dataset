/**
 *Submitted for verification at Etherscan.io on 2021-07-21
*/

// File: contracts/intf/IERC20.sol

// This is a file copied from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol
// SPDX-License-Identifier: MIT

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

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


// File: contracts/DODOBuyBackBatchSwap.sol


contract DODOBuyBackBatchSwap {
    using SafeERC20 for IERC20;

    event FailedSwap(address fromToken);
    
    function batchSwap(
        address[] memory fromTokens,
        uint256[] memory fromAmounts,
        bytes[] memory dodoApiDatas,
        address toToken,
        address dodoApprove,
        address dodoProxy
    ) external {
        require(fromTokens.length > 0, "PARAM_INVALID");
        require(fromTokens.length == fromAmounts.length, "PARAM_INVALID");
        require(fromTokens.length == dodoApiDatas.length, "PARAM_INVALID");

        for (uint256 i = 0; i < fromTokens.length; i++) {
            IERC20(fromTokens[i]).transferFrom(msg.sender, address(this), fromAmounts[i]);
            _generalApproveMax(fromTokens[i], dodoApprove, fromAmounts[i]);

            (bool success, ) = dodoProxy.call{value: 0}(dodoApiDatas[i]);

            if(!success) {
                emit FailedSwap(fromTokens[i]);
            }else {
                uint256 returnAmount = IERC20(toToken).balanceOf(address(this));
                IERC20(toToken).safeTransfer(msg.sender, returnAmount);
            }
        }
    }


    function _generalApproveMax(
        address token,
        address to,
        uint256 amount
    ) internal {
        uint256 allowance = IERC20(token).allowance(address(this), to);
        if (allowance < amount) {
            if (allowance > 0) {
                IERC20(token).safeApprove(to, 0);
            }
            IERC20(token).safeApprove(to, uint256(-1));
        }
    }
}