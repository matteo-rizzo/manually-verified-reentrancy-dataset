// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPRNG {
    function rand() external returns (uint256);
}

contract ReadOnly_ree2 {
    ReadOnly_ree2_Oracle public o;
    mapping (address => uint) private balances;
    bool private flag;

    constructor(address _o) {
        o = ReadOnly_ree2_Oracle(_o);
    }

    modifier nonReentrant() {
        require(!flag, "Reentrant call");
        flag = true;
        _;
        flag = false;
    }

    function withdraw() nonReentrant external {
        uint256 bonus = o.fix() / o.randomness();
        uint256 amt = balances[msg.sender] + bonus;

        (bool success, ) = payable(msg.sender).call{value: amt}("");
        require (success, "Failed");
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }
}

// THIS is the contract vulnerable to reentrancy
contract ReadOnly_ree2_Oracle {
    uint256 public fix;
    uint256 public randomness;

    function update(address prng, uint256 amt) external {
        fix += amt;
        uint rnd = IPRNG(prng).rand();
        randomness += amt + rnd;
    }
}

// contract Attacker is IPRNG {
//     Victim public v;
//     Oracle_ree public o;

//     constructor(address payable _v, address _o) {
//         v = Victim(_v);
//         o = Oracle_ree(_o);
//     }

//     function rand() external returns (uint256) {
//         v.withdraw();
//         return 1;
//     }

//     receive() external payable {
//         o.update(address(this), 10);
//     }
// }