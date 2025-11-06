// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPRNG {
    function getRandom() external returns (uint256);
}

contract Victim {
    Oracle_ree public o;
    mapping (address => uint) private balances;

    constructor(address _o) {
        o = Oracle_ree(_o);
    }

    function withdraw() external {
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
contract Oracle_ree {
    uint256 public fix;
    uint256 public randomness;

    function update(address prng, uint256 amt) external {
        fix += amt;
        uint rnd = IPRNG(prng).getRandom();
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

//     function getRandom() external returns (uint256) {
//         v.withdraw();
//         return 1;
//     }

//     receive() external payable {
//         o.update(address(this), 10);
//     }
// }