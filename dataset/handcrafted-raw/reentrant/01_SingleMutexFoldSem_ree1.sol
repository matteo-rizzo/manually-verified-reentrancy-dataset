pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    bool flag = false;
    mapping (address => uint256) public balances;

    function toggle() internal {
        flag = !flag;
    }

    function withdraw() public {
        require(!flag, "Locked");
        toggle();


        (bool success, ) = msg.sender.call{value:balances[msg.sender]}("");
        require(success, "Call failed");
        balances[msg.sender] = 0;


        toggle();
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}