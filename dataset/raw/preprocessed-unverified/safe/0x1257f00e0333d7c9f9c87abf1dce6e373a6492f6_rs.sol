pragma solidity ^0.4.15;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract ReturnVestingRegistry is Ownable {

  mapping (address => address) public returnAddress;

  function record(address from, address to) {
    require(from != 0);
    require(returnAddress[from] == 0);
    require(Ownable(msg.sender).owner() == owner);

    returnAddress[from] = to;
  }
}