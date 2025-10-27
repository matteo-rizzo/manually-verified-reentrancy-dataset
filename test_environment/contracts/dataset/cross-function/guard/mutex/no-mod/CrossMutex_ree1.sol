// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import '../../../../../interfaces/cross-function/ICrossCall.sol';

contract CrossMutexRee1 is ICrossCall {
    bool private flag = false;
    mapping (address => uint256) public balances;


    // this function is not protected by the mutex
    // so an attacker can reenter after the external call below and move the amount in balances[msg.sender] to another address (parameter 'to') owned by the attacker
    // a subsequent invocation of withdraw() performed by 'to' will receive money that the attacker never deposited
    function transfer(address to, uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[to] += amt;
        balances[msg.sender] -= amt;
    }

    function withdraw() public {
        require(!flag, "Locked");
        flag = true;
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        balances[msg.sender] = 0;
        flag = false;
    }

    function deposit() public payable {
        require(!flag, "Locked");
        balances[msg.sender] += msg.value;       
    }

}