// Used by some early Defi contracts e.g., Bancor, Balancer v1
// now deprecated cause it limits the throughput or disables features that need a user to perform more than one transaction in the same block

pragma solidity ^0.8.20;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) private balances;


    mapping(address => uint256) private lastBlock;

    modifier noSameBlock() {
        require(lastBlock[msg.sender] < block.number, "Reentrancy blocked");
        lastBlock[msg.sender] = block.number;    // performing the update of the lastBlock in the prologue makes this safe
        _;
    }

    // an attacker can try to reenter from here, but lastBlock is updated and the attack is blocked
    function withdraw() noSameBlock public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;    // side effect BEFORE external call makes this safe anyway
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");  
        
    }

    function deposit() public payable noSameBlock {
        balances[msg.sender] += msg.value;       
    }
}