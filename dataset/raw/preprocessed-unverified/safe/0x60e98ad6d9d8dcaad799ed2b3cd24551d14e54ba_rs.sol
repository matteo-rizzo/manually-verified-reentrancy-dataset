/**
 *Submitted for verification at Etherscan.io on 2021-02-02
*/

// https://t.me/ChadDoge
// LFG!


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



contract cDogePreSale is Owned {
    using SafeMath for uint256;
    address public tokenAddress;
    bool public saleOpen;
    uint256 tokenRatePerEth = 600; 
    
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
        require(usersInvestments[msg.sender].add(msg.value) <= 1 ether 
                && usersInvestments[msg.sender].add(msg.value) >= 100 finney,
                "Installment must be in range of 1 to 0.1 ether");
        
        uint256 tokens = getTokenAmount(msg.value);
        
        require(IToken(tokenAddress).transfer(msg.sender, tokens), "Insufficient balance of sale contract!");
        
        usersInvestments[msg.sender] = usersInvestments[msg.sender].add(msg.value);
        
        // send received funds to the owner
        owner.transfer(msg.value);
    }
    
    function getTokenAmount(uint256 amount) internal view returns(uint256){
        return amount.mul(tokenRatePerEth).div(100);
    }
    
    function burnUnSoldTokens() external onlyOwner{
        require(!saleOpen, "Please close the sale first");
        IToken(tokenAddress).burnTokens(IToken(tokenAddress).balanceOf(address(this)));   
    }
}