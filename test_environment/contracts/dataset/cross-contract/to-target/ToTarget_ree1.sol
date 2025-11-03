// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ToTargetRee1 {
    mapping(address => uint256) public balances;

    function pay(address payable target) public {
        require(target != msg.sender);
        uint256 amt = balances[msg.sender];
        (bool success, ) = target.call{value: amt}("");
        require(success, "Call failed");
        balances[msg.sender] = 0; // side effect after the call makes this contract vulnerable to attacks
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
}
