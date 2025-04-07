/**
 *Submitted for verification at Etherscan.io on 2019-10-21
*/

pragma solidity ^0.5.4;



contract LandRegistryProxy is Ownable {
  address public landRegistry;

  event Set(address indexed landRegistry);

  function set(address _landRegistry) public onlyOwner {
    landRegistry = _landRegistry;
    emit Set(landRegistry);
  }
}