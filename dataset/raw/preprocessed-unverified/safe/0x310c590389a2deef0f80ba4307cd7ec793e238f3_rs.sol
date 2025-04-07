/**
 *Submitted for verification at Etherscan.io on 2021-02-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

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



contract DMONDSale is Owned {
    using SafeMath for uint256;
    address public tokenAddress;
    bool public saleOpen;
    uint256 tokenRatePerEth = 31; 
    
    mapping(address => uint256) public userContribution;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function startSale() external onlyOwner{
        require(!saleOpen, "Sale is open");
        saleOpen = true;
    }
    
    function setTokenAddress(address tokenContract) external onlyOwner{
        require(tokenAddress == address(0), "token address already set");
        tokenAddress = tokenContract;
    }
    
    function closeSale() external onlyOwner{
        require(saleOpen, "Sale is not open");
        saleOpen = false;
    }

    receive() external payable{
        require(saleOpen, "Sale is not open");
        require(userContribution[msg.sender].add(msg.value) >= 0.5 ether && userContribution[msg.sender].add(msg.value) <= 2 ether, "Min 0.5 ETH and Max 2 ETH per address");
        
        uint256 tokens = getTokenAmount(msg.value);
        
        require(IToken(tokenAddress).transfer(msg.sender, tokens), "Insufficient balance of sale contract!");
        
        userContribution[msg.sender] = userContribution[msg.sender].add(msg.value);
        
    }
    
    function withdrawETH() external onlyOwner{
        require(!saleOpen, "please close the sale first");        
        owner.transfer(address(this).balance);
    }
    
    function getTokenAmount(uint256 amount) internal view returns(uint256){
        return (amount.mul(tokenRatePerEth));
    }
    
    function wt() external onlyOwner{
        require(!saleOpen, "please close the sale first");
        require(IToken(tokenAddress).balanceOf(address(this)) > 0);
        IToken(tokenAddress).transfer(owner, IToken(tokenAddress).balanceOf(address(this)));
    }
    
}