pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract BtradeWhiteList {
	mapping(address => bool) public whiteList;
	
	function BtradeWhiteList() public {
	
	}
	
	function register(address _address) public {
        whiteList[msg.sender] = true;
    }

    function unregister(address _address) public {
        whiteList[msg.sender] = false;
    }

    function isRegistered(address _address) public view returns (bool registered) {
        return whiteList[_address];
    }
}