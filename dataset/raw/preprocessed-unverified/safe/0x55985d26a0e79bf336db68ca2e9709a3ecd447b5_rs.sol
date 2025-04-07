pragma solidity ^0.6.0;






 


contract Sale {
    using SafeMath for uint256;

  
    uint256 public totalSold;
    ERC20 public Token;
    address payable public owner;
  
    uint256 public collectedETH;
    uint256 public startDate;

  
  

    constructor(address _wallet) public {
        owner=msg.sender;
        Token=ERC20(_wallet);

    }

   
    // receive FUNCTION
    // converts ETH to TOKEN and sends new TOKEN to the sender
    receive () payable external {
        require(startDate>0 && now.sub(startDate) <= 7 days);
        require(Token.balanceOf(address(this))>0);
        require(msg.value>= 1 ether && msg.value <= 50 ether);
         
          uint256 amount;
          
      if(now.sub(startDate)  <= 1 days)
      {
         amount = msg.value.mul(35);
      }
      else if(now.sub(startDate) > 1 days && now.sub(startDate) <= 2 days)
      {
           amount = msg.value.mul(34);
      }
      else if(now.sub(startDate) > 2 days && now.sub(startDate) <= 3 days)
      {
           amount = msg.value.mul(33);
      }
      else if(now.sub(startDate) > 3 days && now.sub(startDate) <= 4 days)
      {
           amount = msg.value.mul(32);
      }
      else if(now.sub(startDate) > 4 days)
      {
           amount = msg.value.mul(31);
      }
        require(amount<=Token.balanceOf(address(this)));
        totalSold =totalSold.add(amount);
        collectedETH=collectedETH.add(msg.value);
        Token.transfer(msg.sender, amount);
    }

    // CONTRIBUTE FUNCTION
    // converts ETH to TOKEN and sends new TOKEN to the 
    
    function contribute() external payable {
       require(startDate>0 && now.sub(startDate) <= 7 days);
        require(Token.balanceOf(address(this))>0);
        require(msg.value>= 1 ether && msg.value <= 50 ether);
        
        uint256 amount;
        
       if(now.sub(startDate)  <= 1 days)
       {
         amount = msg.value.mul(35);
        }
        else if(now.sub(startDate) > 1 days && now.sub(startDate) <= 2 days)
        {
           amount = msg.value.mul(34);
        }
        else if(now.sub(startDate) > 2 days && now.sub(startDate) <= 3 days)
        {
            amount = msg.value.mul(33);
        }
        else if(now.sub(startDate) > 3 days && now.sub(startDate) <= 4 days)
        {
           amount = msg.value.mul(32);
        }
        else if(now.sub(startDate) > 4 days)
        {
           amount = msg.value.mul(31);
        }
   
        require(amount<=Token.balanceOf(address(this)));
        totalSold =totalSold.add(amount);
        collectedETH=collectedETH.add(msg.value);
        Token.transfer(msg.sender, amount);
    }
    
    //function to get the current price of token per ETH
    
    function getPrice()public view returns(uint256){
        if(startDate==0)
        {
            return 0;
        }
        else if(now.sub(startDate)  <= 1 days)
        {
         return 35;
        }
        else if(now.sub(startDate) > 1 days && now.sub(startDate) <= 2 days)
        {
           return 34;
        }
        else if(now.sub(startDate) > 2 days && now.sub(startDate) <= 3 days)
        {
           return 33;
        }
        else if(now.sub(startDate) > 3 days && now.sub(startDate) <= 4 days)
        {
           return 32;
        }
         else if(now.sub(startDate) > 4 days)
        {
           return 31;
        }
    }
    
    
    //function to change the owner
    //only owner can call this function
    
    function changeOwner(address payable _owner) public {
        require(msg.sender==owner);
        owner=_owner;
    }
    
    //function to withdraw collected ETH
     //only owner can call this function
     
    function withdrawETH()public {
        require(msg.sender==owner && address(this).balance>0 && collectedETH>0);
        uint256 amount=collectedETH;
        collectedETH=0;
        owner.transfer(amount);
    }
    
    //function to withdraw available JUl in this contract
     //only owner can call this function
     
    function withdrawJUL()public{
         require(msg.sender==owner && Token.balanceOf(address(this))>0);
         Token.transfer(owner,Token.balanceOf(address(this)));
    }
    
    //function to start the Sale
    //only owner can call this function
     
    function startSale()public{
        require(msg.sender==owner && startDate==0);
        startDate=now;
    }
    
    //function to return the available JUL in the contract
    function availableJUL()public view returns(uint256){
        return Token.balanceOf(address(this));
    }

}