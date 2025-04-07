pragma solidity ^0.4.15;



contract IPFSEvents {
  event HashAdded(address PubKey, string IPFSHash, uint ttl);
  event HashRemoved(address PubKey, string IPFSHash);
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



contract Parameters is IPFSEvents,Ownable {
  mapping (string => string) parameters;

  event ParameterSet(string name, string value);
  uint defaultTTL;

  function Parameters(uint _defaultTTL) public {
    defaultTTL = _defaultTTL;
  }

  function setTTL(uint _ttl) onlyOwner public {
    defaultTTL = _ttl;
  }

  function setParameter(string _name, string _value) onlyOwner public {
    ParameterSet(_name,_value);
    parameters[_name] = _value;
  }

  function setIPFSParameter(string _name, string _ipfsValue) onlyOwner public {
    setParameter(_name,_ipfsValue);
    HashAdded(this,_ipfsValue,defaultTTL);
  }

  function getParameter(string _name) public constant returns (string){
    return parameters[_name];
  }

}