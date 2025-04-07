/**
 *Submitted for verification at Etherscan.io on 2020-12-17
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: UNLICENSED

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 *
*/



// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------


contract PreSale is Owned {
    using SafeMath for uint256;
    address public tokenAddress = 0x7a0F27B4ECDF145d22719aeC06bD2c18A0cDfAA5;
    uint256 tokenRatePerEth = 100;
    address payable fundsReceiver;
    
    constructor() public {
        owner = 0xed82261bCE9F9F730a91897B92e9E27F8FD1a181;
        fundsReceiver = 0xed82261bCE9F9F730a91897B92e9E27F8FD1a181;
    }

    receive() external payable {
        
        uint256 tokens = getTokenAmount(msg.value);
        
        require(IToken(tokenAddress).transfer(msg.sender, tokens), "Insufficient balance of sale contract!");
        
        // send received funds to the owner
        fundsReceiver.transfer(msg.value);
    }
    
    function getTokenAmount(uint256 amount) internal view returns(uint256){
        return (amount.mul(tokenRatePerEth));
    }
    
    function getUnSoldTokens() external onlyOwner{
        uint256 tokens = IToken(tokenAddress).balanceOf(address(this));
        require(IToken(tokenAddress).transfer(owner, tokens), "No tokens in contract");
    }
}