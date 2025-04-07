pragma solidity ^0.4.16;        
   
  contract CentraSale { 

    using SafeMath for uint; 

    address public contract_address = 0x96a65609a7b84e8842732deb08f56c3e21ac6f8a; 

    address public owner;    
    uint public constant min_value = 10**18*1/10;     

    uint256 public constant token_price = 1481481481481481;  
    uint256 public tokens_total;  
   
    // Functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }      
 
    // Constructor
    function CentraSale() {
        owner = msg.sender;                         
    }
      
    //default function for crowdfunding
    function() payable {    

      if(!(msg.value >= min_value)) throw;                                 

      tokens_total = msg.value*10**18/token_price;
      if(!(tokens_total > 0)) throw;           

      if(!contract_transfer(tokens_total)) throw;
      owner.send(this.balance);
    }

    //Contract execute
    function contract_transfer(uint _amount) private returns (bool) {      

      if(!contract_address.call(bytes4(sha3("transfer(address,uint256)")),msg.sender,_amount)) {    
        return false;
      }
      return true;
    }     

    //Withdraw money from contract balance to owner
    function withdraw() onlyOwner returns (bool result) {
        owner.send(this.balance);
        return true;
    }    
      
 }

 /**
   * Math operations with safety checks
   */
  