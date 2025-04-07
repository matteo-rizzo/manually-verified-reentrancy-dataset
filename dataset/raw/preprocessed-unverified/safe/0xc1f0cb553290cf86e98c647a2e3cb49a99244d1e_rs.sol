/**
 *Submitted for verification at Etherscan.io on 2021-02-04
*/

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


contract ICO is Owned {
    using SafeMath for uint256;
    
    address public tokenAddress;
    
    uint256 tokenRatePerEth = 1555;
    
    uint256 public ethersRaised; 
    
    constructor(address _tokenAddress) public {
        owner = 0x0C3B4D8E2eCF2aBBe45842FF1837C000Fd4Bdc08;
        tokenAddress = _tokenAddress;
    }

    receive() external payable  {
        
        uint256 tokens = getTokenAmount(msg.value);
        
        ethersRaised += msg.value;
        
        require(IToken(tokenAddress).transfer(msg.sender, tokens), "Insufficient balance of sale contract!");
        
        // send received funds to the owner
        owner.transfer(msg.value);
    }
    
    function getTokenAmount(uint256 amount) internal view returns(uint256){
        return (amount.mul(tokenRatePerEth));
    }
    
    // for emergency cases
    function getUnSoldTokens() external onlyOwner{
        uint256 tokens = IToken(tokenAddress).balanceOf(address(this));
        require(IToken(tokenAddress).transfer(owner, tokens), "No tokens in contract");
    }
}