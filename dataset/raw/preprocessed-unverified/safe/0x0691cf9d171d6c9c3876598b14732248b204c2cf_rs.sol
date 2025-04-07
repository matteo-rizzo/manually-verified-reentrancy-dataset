/**
 *Submitted for verification at Etherscan.io on 2021-02-17
*/

// SPDX-License-Identifier: bsl-1.1

pragma solidity ^0.8.1;
pragma experimental ABIEncoderV2;








contract SynthetixExchange  {
    using SafeERC20 for IERC20;
    
    address public governance;
    address public pendingGovernance;
    
    mapping(address => address) synths;
    
    IKeep3rV1Quote public constant exchange = IKeep3rV1Quote(0xAa1D14BE4b3Fa42CbBF3C3f61c6F2c57fAF559DF);
    
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    
    constructor() {
        governance = msg.sender;
    }
    
    function setGovernance(address _gov) external {
        require(msg.sender == governance);
        pendingGovernance = _gov;
    } 
    
    function acceptGovernance() external {
        require(msg.sender == pendingGovernance);
        governance = pendingGovernance;
    }
    
    function withdraw(address token, uint amount) external {
        require(msg.sender == governance);
        IERC20(token).safeTransfer(governance, amount);
    }
    
    function withdrawAll(address token) external {
        require(msg.sender == governance);
        IERC20(token).safeTransfer(governance, IERC20(token).balanceOf(address(this)));
    }
    
    function addSynth(address token, address synth) external {
        require(msg.sender == governance);
        synths[token] = synth;
    }
    
    function quote(address tokenIn, uint amountIn, address tokenOut) external view returns (uint) {
        (IKeep3rV1Quote.QuoteParams memory q,) = exchange.assetToAsset(tokenIn, amountIn, tokenOut, 2);
        return q.quoteOut * 10 ** 18 / 10 ** IERC20(tokenOut).decimals();
    }
    
    function swap(address tokenIn, uint amountIn, address tokenOut, address recipient) external returns (uint) {
        (IKeep3rV1Quote.QuoteParams memory q,) = exchange.assetToAsset(tokenIn, amountIn, tokenOut, 2);
        IERC20(synths[tokenIn]).safeTransferFrom(msg.sender, address(this), amountIn * 10 ** 18 / 10 ** IERC20(tokenIn).decimals());
        IERC20(synths[tokenOut]).safeTransfer(recipient, q.quoteOut * 10 ** 18 / 10 ** IERC20(tokenOut).decimals());
        emit Swap(msg.sender, amountIn, 0, 0, q.quoteOut, recipient);
        return q.quoteOut;
    }
}