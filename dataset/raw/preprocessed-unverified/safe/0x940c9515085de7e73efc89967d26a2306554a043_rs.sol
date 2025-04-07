pragma solidity ^0.4.21;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Bounty is Ownable {
    function Bounty() public {
        owner = msg.sender;
    }
    
    function sendToMe() public onlyOwner {
        msg.sender.transfer(this.balance);
    }
    
    function sendTokensToMe(address token, uint amount) public onlyOwner {
        ERC20Basic(token).transfer(msg.sender, amount);
    }
    
    function () payable {
    }
}