pragma solidity ^0.4.13;        
   
  contract CentraAsiaWhiteList { 
 
      using SafeMath for uint;  
 
      address public owner;
      uint public operation;
      mapping(uint => address) public operation_address;
      mapping(uint => uint) public operation_amount; 
      
   
      // Functions with this modifier can only be executed by the owner
      modifier onlyOwner() {
          if (msg.sender != owner) {
              throw;
          }
          _;
      }
   
      // Constructor
      function CentraAsiaWhiteList() {
          owner = msg.sender; 
          operation = 0;         
      }
      
      //default function for crowdfunding
      function() payable {    
 
        if(msg.value < 0) throw;
        if(this.balance > 47000000000000000000000) throw; // 0.1 eth
        if(now > 1505865600)throw; // timestamp 2017.09.20 00:00:00
        
        operation_address[operation] = msg.sender;
        operation_amount[operation] = msg.value;        
        operation = operation.add(1);
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
  