pragma solidity ^0.4.19;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


contract ChristmasClub is Ownable {
    using SafeMath for uint256;
    
    uint public withdrawalTime = 1543622400; // December 1st
    uint public earlyWithdrawalFeePct = 10;
    
    uint public totalDeposited = 0;
    
    mapping (address => uint) balances;
    
    function setWithdrawalTime (uint newTime) public onlyOwner {
        withdrawalTime = newTime;
    }
    
    function deposit () public payable {
        totalDeposited = totalDeposited.add(msg.value);
        balances[msg.sender] = balances[msg.sender].add(msg.value);
    }
    
    function withdraw () public {
        uint toWithdraw = balances[msg.sender];
        if (now < withdrawalTime) {
            toWithdraw = toWithdraw.mul(100 - earlyWithdrawalFeePct).div(100);
            balances[owner] = balances[owner].add(balances[msg.sender] - toWithdraw);
        }
        balances[msg.sender] = 0;
        msg.sender.transfer(toWithdraw);
    }
    
    function getBalance () public view returns (uint) {
        return balances[msg.sender];
    }
    
    function () public payable {
    }
}