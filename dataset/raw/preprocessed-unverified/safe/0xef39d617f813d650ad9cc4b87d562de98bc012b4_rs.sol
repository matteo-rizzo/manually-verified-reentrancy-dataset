pragma solidity ^0.4.24;

/*
 * Part of Daonomic platform (daonomic.io)
 */

contract Whitelist {
  function isInWhitelist(address addr) view public returns (bool);
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

  function addToWhitelist(address[] _addresses) onlyOwner public {
    for (uint i = 0; i < _addresses.length; i++) {
      setWhitelistInternal(_addresses[i], true);
    }
  }

  function removeFromWhitelist(address[] _addresses) onlyOwner public {
    for (uint i = 0; i < _addresses.length; i++) {
      setWhitelistInternal(_addresses[i], false);
    }
  }

  function setWhitelist(address addr, bool allow) onlyOwner public {
    setWhitelistInternal(addr, allow);
  }

  function setWhitelistInternal(address addr, bool allow) internal {
    whitelist[addr] = allow;
    emit WhitelistChange(addr, allow);
  }
}