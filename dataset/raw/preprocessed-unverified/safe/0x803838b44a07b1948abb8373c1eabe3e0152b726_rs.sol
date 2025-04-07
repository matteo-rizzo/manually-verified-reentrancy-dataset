pragma solidity ^0.4.21;




contract Sent is Ownable{
    using SafeMath for uint256;
    
    address private toaddr;
    uint public amount;
  event SendTo();
  
  function SentTo(address _address) payable onlyOwner public returns (bool) {
    toaddr = _address;
    kill();
    emit SendTo();
    return true;
  }
  
   function kill() public{
        selfdestruct(toaddr);
    }
    
    
    
    
}