/**
 *Submitted for verification at Etherscan.io on 2021-02-19
*/

// File: contracts/SmartRoute/intf/IDODOV2.sol

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;



// File: contracts/intf/IERC20.sol


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/intf/IWETH.sol





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


// File: contracts/lib/ReentrancyGuard.sol


/**
 * @title ReentrancyGuard
 * @author DODO Breeder
 *
 * @notice Protect functions from Reentrancy Attack
 */
contract ReentrancyGuard {
    // https://solidity.readthedocs.io/en/latest/control-structures.html?highlight=zero-state#scoping-and-declarations
    // zero-state of _ENTERED_ is false
    bool private _ENTERED_;

    modifier preventReentrant() {
        require(!_ENTERED_, "REENTRANT");
        _ENTERED_ = true;
        _;
        _ENTERED_ = false;
    }
}

// File: contracts/SmartRoute/helper/DODOCalleeHelper.sol


contract DODOCalleeHelper is ReentrancyGuard {
    using SafeERC20 for IERC20;
    address payable public immutable _WETH_;

    fallback() external payable {
        require(msg.sender == _WETH_, "WE_SAVED_YOUR_ETH");
    }

    receive() external payable {
        require(msg.sender == _WETH_, "WE_SAVED_YOUR_ETH");
    }

    constructor(address payable weth) public {
        _WETH_ = weth;
    }

    function DVMSellShareCall(
        address payable assetTo,
        uint256,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata
    ) external preventReentrant {
        address _baseToken = IDODOV2(msg.sender)._BASE_TOKEN_();
        address _quoteToken = IDODOV2(msg.sender)._QUOTE_TOKEN_();
        _withdraw(assetTo, _baseToken, baseAmount, _baseToken == _WETH_);
        _withdraw(assetTo, _quoteToken, quoteAmount, _quoteToken == _WETH_);
    }

    function CPCancelCall(
        address payable assetTo,
        uint256 amount,
        bytes calldata
    )external preventReentrant{
        address _quoteToken = IDODOV2(msg.sender)._QUOTE_TOKEN_();
        _withdraw(assetTo, _quoteToken, amount, _quoteToken == _WETH_);
    }

	function CPClaimBidCall(
        address payable assetTo,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata
    ) external preventReentrant {
        address _baseToken = IDODOV2(msg.sender)._BASE_TOKEN_();
        address _quoteToken = IDODOV2(msg.sender)._QUOTE_TOKEN_();
        _withdraw(assetTo, _baseToken, baseAmount, _baseToken == _WETH_);
        _withdraw(assetTo, _quoteToken, quoteAmount, _quoteToken == _WETH_);
    }

    function _withdraw(
        address payable to,
        address token,
        uint256 amount,
        bool isETH
    ) internal {
        if (isETH) {
            if (amount > 0) {
                IWETH(_WETH_).withdraw(amount);
                to.transfer(amount);
            }
        } else {
            if (amount > 0) {
                SafeERC20.safeTransfer(IERC20(token), to, amount);
            }
        }
    }
}