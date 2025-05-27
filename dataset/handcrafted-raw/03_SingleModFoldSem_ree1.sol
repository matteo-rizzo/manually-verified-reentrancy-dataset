pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    bool flag = false;
    mapping (address => uint256) public balances;


    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    function withdrawAll() nonReentrant public {
        (bool success, ) = msg.sender.call{value:balances[msg.sender]}("");
        require(success, "Call failed");
        update();
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

    function update() internal {
        balances[msg.sender] = 0;
    }

}