/**
 *Submitted for verification at Etherscan.io on 2020-11-26
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: UNLICENSED

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 *
*/



// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------


contract SAV4_Sale {
    using SafeMath for uint256;
    address public constant tokenAddress = 0x9F47D90BAFF34769b7824400C4A72a97EEd9c047 ;
    uint256 tokenRatePerEth = 18720; // 1 eth = 18,720 SAV4
    address payable constant fundsReceiver = 0x04Ef9bfE400cC8D2B32bEb8B009E91fe0B09Fb10;
    
    uint256 public preSaleStart = 1606489200; // 27-nov-2020 15:00 gmt
    uint256 public preSaleEnd;
    
    modifier saleOpen{
        require(block.timestamp >= preSaleStart && block.timestamp <= preSaleEnd, "sale is close");
        _;
    }
    
    constructor() public {
        preSaleEnd = preSaleStart.add(24 hours);
    }
    
    function buyTokens() public payable saleOpen {
        uint256 tokens = getTokenAmount(msg.value);
        
        require(IToken(tokenAddress).transferFrom(fundsReceiver, msg.sender, tokens), "Insufficient balance of sale contract");
        
        // send received funds to the owner
        fundsReceiver.transfer(msg.value);
    }
    
    receive() external payable {
        buyTokens();
    }
    
    function getTokenAmount(uint256 amount) private view returns(uint256){
        return (amount.mul(tokenRatePerEth));
    }
}