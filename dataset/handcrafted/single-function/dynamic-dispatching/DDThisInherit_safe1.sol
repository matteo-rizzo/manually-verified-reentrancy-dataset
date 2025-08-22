pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0

// this contract 
contract C {
    mapping (address => uint256) internal balances;

    function pay(uint256 amt) public returns (bool) {
        balances[msg.sender] -= amt;    // side effect before call makes this safe
        (bool b, ) = msg.sender.call{value: amt}("");
        return b;
    }

    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        bool success = this.pay(amt);   // pay() is dynamically dispatched (obj.method() syntax always emits a CALL) but it always resolves the local method above
        require(success, "Call failed");
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}

