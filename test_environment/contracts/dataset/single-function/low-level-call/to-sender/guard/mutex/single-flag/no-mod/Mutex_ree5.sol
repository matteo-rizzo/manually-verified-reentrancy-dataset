pragma solidity ^0.8.0;
import '../../../../../../../../interfaces/ILowLevelCallToSender.sol';

// SPDX-License-Identifier: GPL-3.0
contract MutexesSingleNoModRee5 is ILowLevelCallToSender {
    mapping (address => uint256) private balances;

    bool private flag = false;

    function withdraw() public {
        // missing require(!flag)

        flag = true;

        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect after call

        flag = false;
    }

    function deposit() public payable {
        require(!flag);
        balances[msg.sender] += msg.value;       
    }

}