/**

 *Submitted for verification at Etherscan.io on 2018-08-25

*/



pragma solidity ^0.4.18;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







contract DistributeETH is Ownable {

  



  function distribute(address[] _addrs, uint[] _bals) onlyOwner public{

    for(uint i = 0; i < _addrs.length; ++i){

      if(!_addrs[i].send(_bals[i])) throw;

    }

  }

  

  function multiSendEth(address[] addresses) public onlyOwner{

    for(uint i = 0; i < addresses.length; i++) {

      addresses[i].transfer(msg.value / addresses.length);

    }

    msg.sender.transfer(this.balance);

  }

}