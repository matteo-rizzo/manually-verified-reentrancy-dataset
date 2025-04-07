pragma solidity ^0.4.23;



contract EthAirdrop is Ownable {
  uint256 public amountToSend;

  function() payable public {}
  
  function destroyMe() onlyOwner public {
    selfdestruct(owner);
  }

  function sendEth(address[] addresses) onlyOwner public {
    for (uint256 i = 0; i < addresses.length; i++) {
      addresses[i].transfer(amountToSend);
      emit TransferEth(addresses[i], amountToSend);
    }
  }

  function changeAmount(uint256 _amount) onlyOwner public {
    amountToSend = _amount;
  }

  function getEth() onlyOwner public {
    owner.transfer(address(this).balance);
  }
  
  event TransferEth(address _address, uint256 _amount);
}