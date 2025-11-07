// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.22;

contract CrossDoubleInit_safe1 {

    bool private flag;
    mapping (address => uint256) public balances;
    uint256 public currentVersion;
    bool private initializedV2;

    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    constructor () public {
        flag = false;
        currentVersion = 2;
    }

// using the nonReentrant modifier on initializePoolV2() protects the whole contract from reentrancy attacks
    function initializePoolV2() external nonReentrant {
        if (initializedV2) {
            revert("Already IntializedV2");
        }
        initializedV2 = true;
        currentVersion = 2;
        flag = false;
    }

    function withdraw() nonReentrant public {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        bool success = msg.sender.call.value(amt)("");
        require(success, "Call failed");
        balances[msg.sender] = 0;
    }

    function deposit() nonReentrant public payable {
        balances[msg.sender] += msg.value;       
    }

}
