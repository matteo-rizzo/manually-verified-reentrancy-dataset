/**

 *Submitted for verification at Etherscan.io on 2019-04-05

*/



pragma solidity ^0.4.24;



contract MultiSend {



  struct Receiver {

    address addr;

    uint amount;

  }



  event MultiTransfer (

    address from,

    uint total,

    Receiver[] receivers

  );



  address owner;



  constructor () public {

    owner = msg.sender;

  }



  modifier onlyOwner() {

    require(owner == msg.sender, "msg sender is not owner!");

    _;

  }



  function close() public onlyOwner {

    selfdestruct(owner);

  }



  function _safeTransfer(address _to, uint _amount) internal {

      require(_to != 0);

      _to.transfer(_amount);

  }



  function multiTransfer(address[] _addresses, uint[] _amounts)

    payable public returns(bool)

  {

      require(_addresses.length == _amounts.length);

      Receiver[] memory receivers = new Receiver[](_addresses.length);

      uint toReturn = msg.value;

      for (uint i = 0; i < _addresses.length; i++) {

          _safeTransfer(_addresses[i], _amounts[i]);

          toReturn = SafeMath.sub(toReturn, _amounts[i]);

          receivers[i].addr = _addresses[i];

          receivers[i].amount = _amounts[i]; 

      }

      emit MultiTransfer(msg.sender, msg.value, receivers);

      return true;

  }

}



