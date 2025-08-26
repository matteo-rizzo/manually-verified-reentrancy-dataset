pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) private balances;


    // this implementation is safe as it does not allow calls from costructor bodies
    modifier isHuman() {
        require(tx.origin != msg.sender, "Not EOA");
        _;
    }

    function transfer(address from, address to) isHuman() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[from] = 0;    // side effect before call
        (bool success, ) = to.call{value:amt}("");
        require(success, "Call failed");
    }

    function deposit() public payable isHuman() {
        balances[msg.sender] += msg.value;       
    }
}

