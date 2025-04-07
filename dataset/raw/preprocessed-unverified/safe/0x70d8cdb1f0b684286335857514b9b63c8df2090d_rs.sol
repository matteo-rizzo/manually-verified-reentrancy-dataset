/**
 *Submitted for verification at Etherscan.io on 2021-02-19
*/

// SPDX-License-Identifier: bsl-1.1

pragma solidity ^0.8.1;
pragma experimental ABIEncoderV2;








contract SynthetixAMM  {
    using SafeERC20 for IERC20;
    
    address public governance;
    address public pendingGovernance;
    
    mapping(address => address) synths;
    
    IKeep3rV1Quote public constant exchange = IKeep3rV1Quote(0x5eb63b45691775606ed71386c3E7083520623FD0);
    
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
    
    function addSynth(address synth, address token) external {
        require(msg.sender == governance);
        synths[synth] = token;
    }
    
    function quote(address synthIn, uint amountIn, address synthOut) public view returns (uint amountOut) {
        address _tokenOut = synths[synthOut];
        address _tokenIn = synths[synthIn];
        (IKeep3rV1Quote.QuoteParams memory q,) = exchange.assetToAsset(_tokenIn, amountIn * 10 ** IERC20(_tokenIn).decimals() / 10 ** 18, _tokenOut, 2);
        amountOut = q.quoteOut * 10 ** 18 / 10 ** IERC20(_tokenOut).decimals();
        require(amountOut <= IERC20(synthOut).balanceOf(address(this)), "SynthetixAMM: Insufficient liquidity for trade");
        return amountOut;
    }
    
    function swap(address synthIn, uint amountIn, address synthOut, uint minOut, address recipient) external returns (uint) {
        uint quoteOut = quote(synthIn, amountIn, synthOut);
        require(quoteOut >= minOut, "SynthetixAMM: Quote less than mininum output");
        IERC20(synthIn).safeTransferFrom(msg.sender, address(this), amountIn);
        IERC20(synthOut).safeTransfer(recipient, quoteOut);
        emit Swap(msg.sender, amountIn, 0, 0, quoteOut, recipient);
        return quoteOut;
    }
}