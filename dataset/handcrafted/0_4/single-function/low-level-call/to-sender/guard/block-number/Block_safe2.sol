// Used by some early Defi contracts e.g., Bancor, Balancer v1
// now deprecated cause it limits the throughput or disables features that need a user to perform more than one transaction in the same block

pragma solidity ^0.4.24;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) private balances;


    mapping(address => uint256) private lastBlock;

    modifier noSameBlock() {
        require(lastBlock[msg.sender] < block.number, "Reentrancy blocked");
        lastBlock[msg.sender] = block.number;
        _;
    }

    // an attacker can reenter from here, but only using a different contract, thus it is not possible to change balances[msg.sender] of the initial call
    function withdraw() noSameBlock() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;    // side effect BEFORE external call make this even more safe
        (bool success, ) = msg.sender.call.value(amt)("");
        require(success, "Call failed");  
        
    }

    function deposit() public  noSameBlock() {
        balances[msg.sender] += msg.value;       
    }
}