pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract Whitelist is Ownable {
    mapping(address => uint256) public whitelist;

    event Whitelisted(address indexed who);
    
    uint256 public nextUserId = 1;

    function addAddress(address who) external onlyOwner {
        require(who != address(0));
        require(whitelist[who] == 0);
        whitelist[who] = nextUserId;
        nextUserId++;
        emit Whitelisted(who); // solhint-disable-line
    }

    function addAddresses(address[] addresses) external onlyOwner {
        require(addresses.length <= 100);
        address who;
        uint256 userId = nextUserId;
        for (uint256 i = 0; i < addresses.length; i++) {
            who = addresses[i];
            require(whitelist[who] == 0);
            whitelist[who] = userId;
            userId++;
            emit Whitelisted(who); // solhint-disable-line
        }
        nextUserId = userId;
    }
}