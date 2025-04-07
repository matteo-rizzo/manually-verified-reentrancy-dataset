pragma solidity ^0.4.11;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control 
 * functions, this simplifies the implementation of "user permissions". 
 */


contract Token{
  function transfer(address to, uint value);
}

contract Indorser is Ownable {

    function multisend(address _tokenAddr, address[] _to, uint256[] _value)
    returns (uint256) {
        // loop through to addresses and send value
		for (uint8 i = 0; i < _to.length; i++) {
            Token(_tokenAddr).transfer(_to[i], _value[i]);
        }
        return(i);
    }
}