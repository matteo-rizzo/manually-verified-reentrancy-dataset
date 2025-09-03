pragma solidity ^0.5.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) private balances;


    // this implementation does not allow calls from costructor bodies but it's wrong
    modifier isHuman() {
        require(tx.origin != msg.sender, "Not EOA");
        _;
    }

    function transfer(address from, address to) isHuman() public {
        uint256 amt = balances[from];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = to.call.value(amt)("");
        require(success, "Call failed");
        balances[from] = 0;    // side effect after call
    }

    // however, forgetting the modifier on an entry-point dealing with balances renders this contract vulnerable
    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }
}

