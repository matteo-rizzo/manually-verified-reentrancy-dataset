/**
 *Submitted for verification at Etherscan.io on 2020-12-14
*/

/**
 *Submitted for verification at Etherscan.io on 12-14-2020
*/
/*

    Copyright 2020 Charge Factory.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;



// lib/ReentrancyGuard.sol
/**
 * @title ReentrancyGuard
 * @author Charge Breeder
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

// lib/SafeERC20.sol
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// lib/SafeMath.sol
/**
 * @title SafeMath
 * @author Charge Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */


// intf/ICharge.sol


// intf/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// intf/IWETH.sol

// ChargeEthProxy.sol
/**
 * @title Charge Eth Proxy
 * @author Charge Breeder
 *
 * @notice Handle ETH-WETH converting for users.
 */
contract ChargeEthProxy is ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public _Charge_Factory_;
    address payable public _WETH_;

    // ============ Events ============

    event ProxySellEthToToken(
        address indexed seller,
        address indexed quoteToken,
        uint256 payEth,
        uint256 receiveToken
    );

    event ProxyBuyEthWithToken(
        address indexed buyer,
        address indexed quoteToken,
        uint256 receiveEth,
        uint256 payToken
    );

    event ProxySellTokenToEth(
        address indexed seller,
        address indexed baseToken,
        uint256 payToken,
        uint256 receiveEth
    );

    event ProxyBuyTokenWithEth(
        address indexed buyer,
        address indexed baseToken,
        uint256 receiveToken,
        uint256 payEth
    );

    event ProxyDepositEthAsBase(address indexed lp, address indexed Charge, uint256 ethAmount);

    event ProxyWithdrawEthAsBase(address indexed lp, address indexed Charge, uint256 ethAmount);

    event ProxyDepositEthAsQuote(address indexed lp, address indexed Charge, uint256 ethAmount);

    event ProxyWithdrawEthAsQuote(address indexed lp, address indexed Charge, uint256 ethAmount);

    // ============ Functions ============

    constructor(address ChargeFactory, address payable weth) public {
        _Charge_Factory_ = ChargeFactory;
        _WETH_ = weth;
    }

    fallback() external payable {
        require(msg.sender == _WETH_, "WE_SAVED_YOUR_ETH_:)");
    }

    receive() external payable {
        require(msg.sender == _WETH_, "WE_SAVED_YOUR_ETH_:)");
    }

    function sellEthToToken(
        address quoteTokenAddress,
        uint256 ethAmount,
        uint256 minReceiveTokenAmount
    ) external payable preventReentrant returns (uint256 receiveTokenAmount) {
        require(msg.value == ethAmount, "ETH_AMOUNT_NOT_MATCH");
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(_WETH_, quoteTokenAddress);
        require(Charge != address(0), "Charge_NOT_EXIST");
        IWETH(_WETH_).deposit{value: ethAmount}();
        IWETH(_WETH_).approve(Charge, ethAmount);
        receiveTokenAmount = ICharge(Charge).sellBaseToken(ethAmount, minReceiveTokenAmount, "");
        _transferOut(quoteTokenAddress, msg.sender, receiveTokenAmount);
        emit ProxySellEthToToken(msg.sender, quoteTokenAddress, ethAmount, receiveTokenAmount);
        return receiveTokenAmount;
    }

    function buyEthWithToken(
        address quoteTokenAddress,
        uint256 ethAmount,
        uint256 maxPayTokenAmount
    ) external preventReentrant returns (uint256 payTokenAmount) {
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(_WETH_, quoteTokenAddress);
        require(Charge != address(0), "Charge_NOT_EXIST");
        payTokenAmount = ICharge(Charge).queryBuyBaseToken(ethAmount);
        _transferIn(quoteTokenAddress, msg.sender, payTokenAmount);
        IERC20(quoteTokenAddress).safeApprove(Charge, payTokenAmount);
        ICharge(Charge).buyBaseToken(ethAmount, maxPayTokenAmount, "");
        IWETH(_WETH_).withdraw(ethAmount);
        msg.sender.transfer(ethAmount);
        emit ProxyBuyEthWithToken(msg.sender, quoteTokenAddress, ethAmount, payTokenAmount);
        return payTokenAmount;
    }

    function sellTokenToEth(
        address baseTokenAddress,
        uint256 tokenAmount,
        uint256 minReceiveEthAmount
    ) external preventReentrant returns (uint256 receiveEthAmount) {
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(baseTokenAddress, _WETH_);
        require(Charge != address(0), "Charge_NOT_EXIST");
        IERC20(baseTokenAddress).safeApprove(Charge, tokenAmount);
        _transferIn(baseTokenAddress, msg.sender, tokenAmount);
        receiveEthAmount = ICharge(Charge).sellBaseToken(tokenAmount, minReceiveEthAmount, "");
        IWETH(_WETH_).withdraw(receiveEthAmount);
        msg.sender.transfer(receiveEthAmount);
        emit ProxySellTokenToEth(msg.sender, baseTokenAddress, tokenAmount, receiveEthAmount);
        return receiveEthAmount;
    }

    function buyTokenWithEth(
        address baseTokenAddress,
        uint256 tokenAmount,
        uint256 maxPayEthAmount
    ) external payable preventReentrant returns (uint256 payEthAmount) {
        require(msg.value == maxPayEthAmount, "ETH_AMOUNT_NOT_MATCH");
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(baseTokenAddress, _WETH_);
        require(Charge != address(0), "Charge_NOT_EXIST");
        payEthAmount = ICharge(Charge).queryBuyBaseToken(tokenAmount);
        IWETH(_WETH_).deposit{value: payEthAmount}();
        IWETH(_WETH_).approve(Charge, payEthAmount);
        ICharge(Charge).buyBaseToken(tokenAmount, maxPayEthAmount, "");
        _transferOut(baseTokenAddress, msg.sender, tokenAmount);
        uint256 refund = maxPayEthAmount.sub(payEthAmount);
        if (refund > 0) {
            msg.sender.transfer(refund);
        }
        emit ProxyBuyTokenWithEth(msg.sender, baseTokenAddress, tokenAmount, payEthAmount);
        return payEthAmount;
    }

    function depositEthAsBase(uint256 ethAmount, address quoteTokenAddress)
        external
        payable
        preventReentrant
    {
        require(msg.value == ethAmount, "ETH_AMOUNT_NOT_MATCH");
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(_WETH_, quoteTokenAddress);
        require(Charge != address(0), "Charge_NOT_EXIST");
        IWETH(_WETH_).deposit{value: ethAmount}();
        IWETH(_WETH_).approve(Charge, ethAmount);
        ICharge(Charge).depositBaseTo(msg.sender, ethAmount);
        emit ProxyDepositEthAsBase(msg.sender, Charge, ethAmount);
    }

    function withdrawEthAsBase(uint256 ethAmount, address quoteTokenAddress)
        external
        preventReentrant
        returns (uint256 withdrawAmount)
    {
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(_WETH_, quoteTokenAddress);
        require(Charge != address(0), "Charge_NOT_EXIST");
        address ethLpToken = ICharge(Charge)._BASE_CAPITAL_TOKEN_();

        // transfer all pool shares to proxy
        uint256 lpBalance = IERC20(ethLpToken).balanceOf(msg.sender);
        IERC20(ethLpToken).transferFrom(msg.sender, address(this), lpBalance);
        ICharge(Charge).withdrawBase(ethAmount);

        // transfer remain shares back to msg.sender
        lpBalance = IERC20(ethLpToken).balanceOf(address(this));
        IERC20(ethLpToken).transfer(msg.sender, lpBalance);

        // because of withdraw penalty, withdrawAmount may not equal to ethAmount
        // query weth amount first and than transfer ETH to msg.sender
        uint256 wethAmount = IERC20(_WETH_).balanceOf(address(this));
        IWETH(_WETH_).withdraw(wethAmount);
        msg.sender.transfer(wethAmount);
        emit ProxyWithdrawEthAsBase(msg.sender, Charge, wethAmount);
        return wethAmount;
    }

    function withdrawAllEthAsBase(address quoteTokenAddress)
        external
        preventReentrant
        returns (uint256 withdrawAmount)
    {
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(_WETH_, quoteTokenAddress);
        require(Charge != address(0), "Charge_NOT_EXIST");
        address ethLpToken = ICharge(Charge)._BASE_CAPITAL_TOKEN_();

        // transfer all pool shares to proxy
        uint256 lpBalance = IERC20(ethLpToken).balanceOf(msg.sender);
        IERC20(ethLpToken).transferFrom(msg.sender, address(this), lpBalance);
        ICharge(Charge).withdrawAllBase();

        // because of withdraw penalty, withdrawAmount may not equal to ethAmount
        // query weth amount first and than transfer ETH to msg.sender
        uint256 wethAmount = IERC20(_WETH_).balanceOf(address(this));
        IWETH(_WETH_).withdraw(wethAmount);
        msg.sender.transfer(wethAmount);
        emit ProxyWithdrawEthAsBase(msg.sender, Charge, wethAmount);
        return wethAmount;
    }

    function depositEthAsQuote(uint256 ethAmount, address baseTokenAddress)
        external
        payable
        preventReentrant
    {
        require(msg.value == ethAmount, "ETH_AMOUNT_NOT_MATCH");
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(baseTokenAddress, _WETH_);
        require(Charge != address(0), "Charge_NOT_EXIST");
        IWETH(_WETH_).deposit{value: ethAmount}();
        IWETH(_WETH_).approve(Charge, ethAmount);
        ICharge(Charge).depositQuoteTo(msg.sender, ethAmount);
        emit ProxyDepositEthAsQuote(msg.sender, Charge, ethAmount);
    }

    function withdrawEthAsQuote(uint256 ethAmount, address baseTokenAddress)
        external
        preventReentrant
        returns (uint256 withdrawAmount)
    {
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(baseTokenAddress, _WETH_);
        require(Charge != address(0), "Charge_NOT_EXIST");
        address ethLpToken = ICharge(Charge)._QUOTE_CAPITAL_TOKEN_();

        // transfer all pool shares to proxy
        uint256 lpBalance = IERC20(ethLpToken).balanceOf(msg.sender);
        IERC20(ethLpToken).transferFrom(msg.sender, address(this), lpBalance);
        ICharge(Charge).withdrawQuote(ethAmount);

        // transfer remain shares back to msg.sender
        lpBalance = IERC20(ethLpToken).balanceOf(address(this));
        IERC20(ethLpToken).transfer(msg.sender, lpBalance);

        // because of withdraw penalty, withdrawAmount may not equal to ethAmount
        // query weth amount first and than transfer ETH to msg.sender
        uint256 wethAmount = IERC20(_WETH_).balanceOf(address(this));
        IWETH(_WETH_).withdraw(wethAmount);
        msg.sender.transfer(wethAmount);
        emit ProxyWithdrawEthAsQuote(msg.sender, Charge, wethAmount);
        return wethAmount;
    }

    function withdrawAllEthAsQuote(address baseTokenAddress)
        external
        preventReentrant
        returns (uint256 withdrawAmount)
    {
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(baseTokenAddress, _WETH_);
        require(Charge != address(0), "Charge_NOT_EXIST");
        address ethLpToken = ICharge(Charge)._QUOTE_CAPITAL_TOKEN_();

        // transfer all pool shares to proxy
        uint256 lpBalance = IERC20(ethLpToken).balanceOf(msg.sender);
        IERC20(ethLpToken).transferFrom(msg.sender, address(this), lpBalance);
        ICharge(Charge).withdrawAllQuote();

        // because of withdraw penalty, withdrawAmount may not equal to ethAmount
        // query weth amount first and than transfer ETH to msg.sender
        uint256 wethAmount = IERC20(_WETH_).balanceOf(address(this));
        IWETH(_WETH_).withdraw(wethAmount);
        msg.sender.transfer(wethAmount);
        emit ProxyWithdrawEthAsQuote(msg.sender, Charge, wethAmount);
        return wethAmount;
    }

    // ============ Helper Functions ============

    function _transferIn(
        address tokenAddress,
        address from,
        uint256 amount
    ) internal {
        IERC20(tokenAddress).safeTransferFrom(from, address(this), amount);
    }

    function _transferOut(
        address tokenAddress,
        address to,
        uint256 amount
    ) internal {
        IERC20(tokenAddress).safeTransfer(to, amount);
    }
}