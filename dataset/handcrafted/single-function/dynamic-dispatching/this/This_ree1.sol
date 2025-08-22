pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0

contract C {
    mapping (address => uint256) public balances;

    function pay(uint256 amt) public returns (bool) {
        (bool b, ) = msg.sender.call{value: amt}("");
        balances[msg.sender] -= amt;    // side effect after call makes this vulnerable
        return b;
    }

    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        bool success = this.pay(amt);   // the compiler emits a CALL here, although it is never an external call as the pay() method above is always invoked
        require(success, "Call failed");
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}
