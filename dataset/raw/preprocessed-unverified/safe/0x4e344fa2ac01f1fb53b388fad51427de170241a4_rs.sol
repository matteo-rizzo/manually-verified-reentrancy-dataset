/**
 *Submitted for verification at Etherscan.io on 2020-11-23
*/

pragma solidity ^0.6.0;

// SPDX-License-Identifier: UNLICENSED



// Owned contract




// ERC20 Token Interface




contract LIDOSale is Owned {
    using SafeMath for uint256;
    address public tokenAddress;
    bool public saleOpen;
    uint256 tokenRatePerEth = 5000;
    
    mapping(address => uint256) public usersInvestments;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function startLIDOSale() external onlyOwner{
        require(!saleOpen, "LIDO sale is already open");
        saleOpen = true;
    }
    
    function setTokenAddress(address tokenContract) external onlyOwner{
        require(tokenAddress == address(0), "Address is already set");
        tokenAddress = tokenContract;
    }
    
    function closeLIDOSale() external onlyOwner{
        require(saleOpen, "LIDO sale is closed");
        saleOpen = false;
    }

    receive() external payable{
        require(saleOpen, "LIDO sale is not open");
        require(usersInvestments[msg.sender].add(msg.value) <= 5 ether, "Maximum investment allowed: 5 ETH");
        uint256 tokens = getTokenAmount(msg.value);
        require(IToken(tokenAddress).transfer(msg.sender, tokens), "Insufficient balance of the sale Contract");
        usersInvestments[msg.sender] = usersInvestments[msg.sender].add(msg.value);
        
        owner.transfer(msg.value);
    }
    
    function getTokenAmount(uint256 amount) internal view returns(uint256){
        return (amount.mul(tokenRatePerEth)).div(10**0);
    }
    
    function burnUnsoldLIDOTokens() external onlyOwner{
        require(!saleOpen, "Please close the sale first");
        IToken(tokenAddress).burnTokens(IToken(tokenAddress).balanceOf(address(this)));   
    }
}