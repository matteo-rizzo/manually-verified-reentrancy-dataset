// Used by some early Defi contracts e.g., Bancor, Balancer v1
// now deprecated cause it limits the throughput or disables features that need a user to perform more than one transaction in the same block

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;
contract C {
    mapping (address => uint256) private balances;


    mapping(address => uint256) private lastBlock;

    modifier noSameBlock() {
        require(lastBlock[msg.sender] < block.number, "Reentrancy blocked");
        _;
        lastBlock[msg.sender] = block.number;   // performing the update of the lastBlock in the epilogue makes this vulnerable to reentrancy
    }

    // an attacker can reenter from here
    function withdraw() noSameBlock public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect after the external call together with lastBlock update 
    }

    function deposit() public payable noSameBlock {
        balances[msg.sender] += msg.value;
    }
}