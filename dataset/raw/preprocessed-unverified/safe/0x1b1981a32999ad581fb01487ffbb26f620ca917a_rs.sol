pragma solidity ^0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


contract Forgiveness {
    using SafeMath for uint256;
    
    uint constant forgivenessFee = 0.01 ether;
    uint public ownerBalance;
    address public owner;
    
    mapping (bytes32 => bool) forgiven;
    
    function Forgiveness () public {
        owner = msg.sender;
    }
    
    function askForgiveness (string transaction) public payable {
        require(msg.value >= forgivenessFee);
        require(!isForgiven(transaction));
        ownerBalance += msg.value;
        forgiven[keccak256(transaction)] = true;
    }
    
    function isForgiven (string transaction) public view returns (bool) {
        return forgiven[keccak256(transaction)];
    }
    
    function withdrawFees () public {
        require(msg.sender == owner);
        uint toWithdraw = ownerBalance;
        ownerBalance = 0;
        msg.sender.transfer(toWithdraw);
    }
    
    function getBalance () public view returns (uint) {
        require(msg.sender == owner);
        return ownerBalance;
    }

    function () public payable {
    }
}