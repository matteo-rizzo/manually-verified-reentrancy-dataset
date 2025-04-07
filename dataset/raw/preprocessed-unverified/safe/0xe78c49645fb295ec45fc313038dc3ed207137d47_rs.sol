/**
 *Submitted for verification at Etherscan.io on 2020-07-13
*/

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;



/**
 * @title ReentrancyGuard
 * @author DODO Breeder
 *
 * @notice Protect functions from Reentrancy Attack
 */
contract ReentrancyGuard {
    Types.EnterStatus private _ENTER_STATUS_;

    constructor() internal {
        _ENTER_STATUS_ = Types.EnterStatus.NOT_ENTERED;
    }

    modifier preventReentrant() {
        require(_ENTER_STATUS_ != Types.EnterStatus.ENTERED, "REENTRANT");
        _ENTER_STATUS_ = Types.EnterStatus.ENTERED;
        _;
        _ENTER_STATUS_ = Types.EnterStatus.NOT_ENTERED;
    }
}

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


// File: contracts/intf/IDODO.sol

/*

    Copyright 2020 DODO ZOO.

*/



// File: contracts/intf/IDODOZoo.sol

/*

    Copyright 2020 DODO ZOO.

*/



// File: contracts/intf/IWETH.sol

/*

    Copyright 2020 DODO ZOO.

*/



// File: contracts/DODOEthProxy.sol

/*

    Copyright 2020 DODO ZOO.

*/

/**
 * @title DODO Eth Proxy
 * @author DODO Breeder
 *
 * @notice Handle ETH-WETH converting for users. Use it only when WETH is base token
 */
contract DODOEthProxy is ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public _DODO_ZOO_;
    address payable public _WETH_;

    // ============ Events ============

    event ProxySellEth(
        address indexed seller,
        address indexed quoteToken,
        uint256 payEth,
        uint256 receiveQuote
    );

    event ProxyBuyEth(
        address indexed buyer,
        address indexed quoteToken,
        uint256 receiveEth,
        uint256 payQuote
    );

    event ProxyDepositEth(address indexed lp, address indexed DODO, uint256 ethAmount);

    event ProxyWithdrawEth(address indexed lp, address indexed DODO, uint256 ethAmount);

    // ============ Functions ============

    constructor(address dodoZoo, address payable weth) public {
        _DODO_ZOO_ = dodoZoo;
        _WETH_ = weth;
    }

    fallback() external payable {
        require(msg.sender == _WETH_, "WE_SAVED_YOUR_ETH_:)");
    }

    receive() external payable {
        require(msg.sender == _WETH_, "WE_SAVED_YOUR_ETH_:)");
    }

    function sellEthTo(
        address quoteTokenAddress,
        uint256 ethAmount,
        uint256 minReceiveTokenAmount
    ) external payable preventReentrant returns (uint256 receiveTokenAmount) {
        require(msg.value == ethAmount, "ETH_AMOUNT_NOT_MATCH");
        address DODO = IDODOZoo(_DODO_ZOO_).getDODO(_WETH_, quoteTokenAddress);
        require(DODO != address(0), "DODO_NOT_EXIST");
        IWETH(_WETH_).deposit{value: ethAmount}();
        IWETH(_WETH_).approve(DODO, ethAmount);
        receiveTokenAmount = IDODO(DODO).sellBaseToken(ethAmount, minReceiveTokenAmount);
        _transferOut(quoteTokenAddress, msg.sender, receiveTokenAmount);
        emit ProxySellEth(msg.sender, quoteTokenAddress, ethAmount, receiveTokenAmount);
        return receiveTokenAmount;
    }

    function buyEthWith(
        address quoteTokenAddress,
        uint256 ethAmount,
        uint256 maxPayTokenAmount
    ) external preventReentrant returns (uint256 payTokenAmount) {
        address DODO = IDODOZoo(_DODO_ZOO_).getDODO(_WETH_, quoteTokenAddress);
        require(DODO != address(0), "DODO_NOT_EXIST");
        payTokenAmount = IDODO(DODO).queryBuyBaseToken(ethAmount);
        _transferIn(quoteTokenAddress, msg.sender, payTokenAmount);
        IERC20(quoteTokenAddress).approve(DODO, payTokenAmount);
        IDODO(DODO).buyBaseToken(ethAmount, maxPayTokenAmount);
        IWETH(_WETH_).withdraw(ethAmount);
        msg.sender.transfer(ethAmount);
        emit ProxyBuyEth(msg.sender, quoteTokenAddress, ethAmount, payTokenAmount);
        return payTokenAmount;
    }

    function depositEth(uint256 ethAmount, address quoteTokenAddress)
        external
        payable
        preventReentrant
    {
        require(msg.value == ethAmount, "ETH_AMOUNT_NOT_MATCH");
        address DODO = IDODOZoo(_DODO_ZOO_).getDODO(_WETH_, quoteTokenAddress);
        require(DODO != address(0), "DODO_NOT_EXIST");
        IWETH(_WETH_).deposit{value: ethAmount}();
        IWETH(_WETH_).approve(DODO, ethAmount);
        IDODO(DODO).depositBaseTo(msg.sender, ethAmount);
        emit ProxyDepositEth(msg.sender, DODO, ethAmount);
    }

    function withdrawEth(uint256 ethAmount, address quoteTokenAddress)
        external
        preventReentrant
        returns (uint256 withdrawAmount)
    {
        address DODO = IDODOZoo(_DODO_ZOO_).getDODO(_WETH_, quoteTokenAddress);
        require(DODO != address(0), "DODO_NOT_EXIST");
        address ethLpToken = IDODO(DODO)._BASE_CAPITAL_TOKEN_();

        // transfer all pool shares to proxy
        uint256 lpBalance = IERC20(ethLpToken).balanceOf(msg.sender);
        IERC20(ethLpToken).transferFrom(msg.sender, address(this), lpBalance);
        IDODO(DODO).withdrawBase(ethAmount);

        // transfer remain shares back to msg.sender
        lpBalance = IERC20(ethLpToken).balanceOf(address(this));
        IERC20(ethLpToken).transfer(msg.sender, lpBalance);

        // because of withdraw penalty, withdrawAmount may not equal to ethAmount
        // query weth amount first and than transfer ETH to msg.sender
        uint256 wethAmount = IERC20(_WETH_).balanceOf(address(this));
        IWETH(_WETH_).withdraw(wethAmount);
        msg.sender.transfer(wethAmount);
        emit ProxyWithdrawEth(msg.sender, DODO, wethAmount);
        return wethAmount;
    }

    function withdrawAllEth(address quoteTokenAddress)
        external
        preventReentrant
        returns (uint256 withdrawAmount)
    {
        address DODO = IDODOZoo(_DODO_ZOO_).getDODO(_WETH_, quoteTokenAddress);
        require(DODO != address(0), "DODO_NOT_EXIST");
        address ethLpToken = IDODO(DODO)._BASE_CAPITAL_TOKEN_();

        // transfer all pool shares to proxy
        uint256 lpBalance = IERC20(ethLpToken).balanceOf(msg.sender);
        IERC20(ethLpToken).transferFrom(msg.sender, address(this), lpBalance);
        IDODO(DODO).withdrawAllBase();

        // because of withdraw penalty, withdrawAmount may not equal to ethAmount
        // query weth amount first and than transfer ETH to msg.sender
        uint256 wethAmount = IERC20(_WETH_).balanceOf(address(this));
        IWETH(_WETH_).withdraw(wethAmount);
        msg.sender.transfer(wethAmount);
        emit ProxyWithdrawEth(msg.sender, DODO, wethAmount);
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