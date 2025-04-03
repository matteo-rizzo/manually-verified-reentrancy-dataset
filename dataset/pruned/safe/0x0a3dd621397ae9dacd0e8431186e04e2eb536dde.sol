/**
 *Submitted for verification at Etherscan.io on 2020-12-17
*/

pragma solidity ^0.6.0;

// SPDX-License-Identifier: MIT



// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------



contract STEKpresale is Owned {
    using SafeMath for uint256;
    address public tokenAddress;
    bool public saleOpen;
    uint256 tokenRatePerEth = 65000;     // 65000 ¡Â 100 = 650 Tokens   // 1 ETH = 650 STEK
    
    mapping(address => uint256) public usersInvestments;
    
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
        require(usersInvestments[msg.sender].add(msg.value) <= 5 ether, "Max investment allowed is 5 ether");
        
        uint256 tokens = getTokenAmount(msg.value);
        
        require(IToken(tokenAddress).transfer(msg.sender, tokens), "Insufficient balance of sale contract!");
        
        usersInvestments[msg.sender] = usersInvestments[msg.sender].add(msg.value);
        
        // send received funds to the owner
        owner.transfer(msg.value);
    }
    
    function getTokenAmount(uint256 amount) internal view returns(uint256){
        return (amount.mul(tokenRatePerEth)).div(10**2);
    }
    
    function burnUnSoldTokens() external onlyOwner{
        require(!saleOpen, "please close the sale first");
        IToken(tokenAddress).burnTokens(IToken(tokenAddress).balanceOf(address(this)));   
    }
}