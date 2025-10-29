pragma solidity ^0.8.0;
import '../../../../../../../../interfaces/single-function/ILowLevelCallToSender.sol';

// SPDX-License-Identifier: GPL-3.0
contract MutexesSingleModRee4 is ILowLevelCallToSender {
    mapping (address => uint256) private balances;

    bool private flag = false;

    modifier nonReentrant() {   // broken mutex implemented via modifier
        // missing require(!flag);
        // missing flag = true
        _;
        flag = false;
    }

    function withdraw() public nonReentrant {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect after call
    }

    function deposit() public payable nonReentrant {
        balances[msg.sender] += msg.value;       
    }

}