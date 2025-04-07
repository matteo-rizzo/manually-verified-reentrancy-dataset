pragma solidity ^0.4.24;

/**
 * Powered by Daonomic (https://daonomic.io)
 */

contract Whitelist {
  function isInWhitelist(address addr) public view returns (bool);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract WhitelistImpl is Ownable, Whitelist {
  mapping(address => bool) whitelist;
  event WhitelistChange(address indexed addr, bool allow);

  function isInWhitelist(address addr) constant public returns (bool) {
    return whitelist[addr];
  }

  function addToWhitelist(address[] _addresses) public onlyOwner {
    for (uint i = 0; i < _addresses.length; i++) {
      setWhitelistInternal(_addresses[i], true);
    }
  }

  function removeFromWhitelist(address[] _addresses) public onlyOwner {
    for (uint i = 0; i < _addresses.length; i++) {
      setWhitelistInternal(_addresses[i], false);
    }
  }

  function setWhitelist(address addr, bool allow) public onlyOwner {
    setWhitelistInternal(addr, allow);
  }

  function setWhitelistInternal(address addr, bool allow) internal {
    whitelist[addr] = allow;
    emit WhitelistChange(addr, allow);
  }
}