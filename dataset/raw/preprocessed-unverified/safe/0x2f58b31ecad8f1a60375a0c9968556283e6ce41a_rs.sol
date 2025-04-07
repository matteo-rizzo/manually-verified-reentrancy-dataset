pragma solidity ^0.4.21;



contract Gamble is Owned {
  uint constant magic = 5;
  
  function getMaxBet() public view returns (uint) {
    return getBalance()/magic;
  }
  
  function Play() public payable protect protect_mining {
    require(msg.value <= getMaxBet());
    if (now % magic != 0) {
      msg.sender.transfer(msg.value + msg.value/magic);
    }
    last_blocknumber = block.number;
  }

  modifier protect {
    require(tx.origin == msg.sender);
    _;
  }

  modifier protect_mining {
    //very simple protection against miners
    require (block.number != last_blocknumber);
    _;
  }

  function () public payable {
    Play();
  }
}