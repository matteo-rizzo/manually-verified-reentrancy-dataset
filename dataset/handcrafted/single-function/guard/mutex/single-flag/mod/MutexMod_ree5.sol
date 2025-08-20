pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) private balances;

    bool private flag = false;

    modifier nonReentrant() {   // broken mutex implemented via modifier
        // missing require(!flag);
        flag = true;
        _;
        flag = false;
    }

    function withdraw(uint256 amt) public nonReentrant {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        balances[msg.sender] -= amt;    // side effect after call
    }

    function deposit() public payable nonReentrant {
        balances[msg.sender] += msg.value;       
    }

}