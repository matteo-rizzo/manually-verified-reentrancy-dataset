/**
 *Submitted for verification at Etherscan.io on 2021-02-18
*/

// SPDX-License-Identifier: bsl-1.1

pragma solidity ^0.8.1;
pragma experimental ABIEncoderV2;








contract SynthetixAMM  {
    using SafeERC20 for IERC20;
    
    address public governance;
    address public pendingGovernance;
    
    mapping(address => address) synths;
    
    IKeep3rV1Quote public constant exchange = IKeep3rV1Quote(0x31B06AaA465C7e7003b8D658A786d573D2216e1c);
    
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
    
    function quote(address synthIn, uint amountIn, address synthOut) public view returns (uint) {
        address _tokenOut = synths[synthOut];
        (IKeep3rV1Quote.QuoteParams memory q,) = exchange.assetToAsset(synths[synthIn], amountIn, _tokenOut, 2);
        return q.quoteOut * 10 ** 18 / 10 ** IERC20(_tokenOut).decimals();
    }
    
    function swap(address synthIn, uint amountIn, address synthOut, address recipient) external returns (uint) {
        uint quoteOut = quote(synthIn, amountIn, synthOut);
        IERC20(synthIn).safeTransferFrom(msg.sender, address(this), amountIn);
        IERC20(synthOut).safeTransfer(recipient, quoteOut);
        emit Swap(msg.sender, amountIn, 0, 0, quoteOut, recipient);
        return quoteOut;
    }
}