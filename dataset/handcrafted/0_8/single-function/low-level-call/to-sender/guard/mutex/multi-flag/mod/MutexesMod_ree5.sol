// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../../../../../../interfaces/single-function/ILowLevelCallToSender.sol";

contract MutexesMod_ree5 is ILowLevelCallToSender {
    mapping(address => uint256) private balances;
    mapping(address => bool) private flags; // mutex flags on a per-address basis

    modifier nonReentrant() {
        //broken mutex implemented via modifier
        // missing require(!flags[msg.sender]);
        flags[msg.sender] = true;
        _;
        flags[msg.sender] = false;
    }

    function withdraw() public nonReentrant {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call{value: amt}("");
        require(success, "Call failed");
        balances[msg.sender] = 0; // side effect can be AFTER external call thanks to the mutex
    }

    function deposit() public payable nonReentrant {
        balances[msg.sender] += msg.value;
    }
}
