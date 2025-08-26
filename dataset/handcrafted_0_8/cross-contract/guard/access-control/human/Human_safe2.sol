pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) private balances;


    // this implementation is safe as it does not allow calls from costructor bodies
    modifier isHuman() {
        require(tx.origin != msg.sender, "Not EOA");
        _;
    }

    function transfer(address from, address to, uint256 amt) isHuman() public {
        require(balances[from] >= amt, "Insufficient funds");
        balances[from] -= amt;    // side effect before call
        (bool success, ) = to.call{value:amt}("");
        require(success, "Call failed");
    }

    function deposit() public payable isHuman() {
        balances[msg.sender] += msg.value;       
    }
}

