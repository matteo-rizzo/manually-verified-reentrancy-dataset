/**

 *Submitted for verification at Etherscan.io on 2018-11-03

*/



pragma solidity 0.4.21;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract Forwarder is Ownable {

  address destinationAddress;

  event LogForwarded(address indexed sender, uint amount);

  event LogFlushed(address indexed sender, uint amount);



  function Forwarder() public {

    destinationAddress = msg.sender;

  }



  function() payable public {

    emit LogForwarded(msg.sender, msg.value);

    destinationAddress.transfer(msg.value);

  }



  function flush(address owner) public {

    emit LogFlushed(destinationAddress, address(this).balance);

    destinationAddress.transfer(address(this).balance);

  }



}