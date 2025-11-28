// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

interface IPRNG {
    function rand() external returns (uint256);
}

contract ReadOnly_ree1 {
    ReadOnly_ree1_Oracle public o;
    mapping (address => uint) private balances;

    constructor(address _o)  public{
        o = ReadOnly_ree1_Oracle(_o);
    }

    function withdraw() external {
        uint256 bonus = o.fix() / o.randomness();
        uint256 amt = balances[msg.sender] + bonus;

        bool success = (msg.sender).call.value(amt)("");
        require (success, "Failed");
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }
}

// THIS is the contract vulnerable to reentrancy
contract ReadOnly_ree1_Oracle {
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

//     constructor(address _v, address _o)  public{
//         v = Victim(_v);
//         o = Oracle_ree(_o);
//     }

//     function rand() external returns (uint256) {
//         v.withdraw();
//         return 1;
//     }

//     function() external payable {
//         o.update(address(this), 10);
//     }
// }