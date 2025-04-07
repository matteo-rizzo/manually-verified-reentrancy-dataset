pragma solidity ^0.7.0;

// SPDX-License-Identifier: MIT


contract GrowthEscrowContract {
    
    address private owner; 
    uint256 public time; 
    uint public requestedAmount;
    
    uint public constant delay = 604800; 
    

    ERC20Interface private constant token = ERC20Interface(0x09e64c2B61a5f1690Ee6fbeD9baf5D6990F8dFd0);

    constructor () {
        owner = msg.sender;
        time = block.timestamp; 
        requestedAmount = 0;
    }
    

    modifier onlyOwner(){
        require(msg.sender == owner, "Unauthorized to call. ");
        _;
    }
    

    function depositToken(uint amount) public onlyOwner {
   
        require(amount > 0, "Amount must be greater than zero. ");
        require(token.transferFrom(msg.sender, address(this), amount) == true, "Inefficent balance or Unauthorized");
        
    }


    function withdrawToken() public onlyOwner {

        
        require(block.timestamp >= (time + delay) , "Cannot withdraw until 7 days afer requested. ");
        require(requestedAmount > 0, "There are currently no pending withraws to be processed. ");
        
        require(token.transfer(msg.sender, requestedAmount) == true, "Inefficient balance. ");
        requestedAmount = 0;
        
    }
    

    function requestWithdraw(uint amount) public onlyOwner {

        require(amount > 0, "Amount must be greater than zero. ");
        require(amount <= token.balanceOf(address(this)), "Amount requested is greater than balance on contract ");
        require(requestedAmount == 0, "There is already an amount requested pending.  ");
        time = block.timestamp;
        requestedAmount = amount;
        
    }
    

    function cancelWithdrawRequest() public onlyOwner {

        require(requestedAmount > 0, "There are currently no requested amounts to be cancelled. ");
        requestedAmount = 0; 
    }
    

    function getBalance() view public returns (uint) {
     
        return token.balanceOf(address(this));
    }
    

    function updateOwner(address newOwner) public onlyOwner {

        owner = newOwner; 
    }
    

    function getOwner() view public returns (address) {
        return owner; 
    }
    
}