// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

interface IPRNG {
    function rand() external returns (uint256);
}

contract ReadOnly_ree2 {
    ReadOnly_ree2_Oracle public o;
    mapping(address => uint256) private balances;
    bool private flag;

    constructor(address _o) public {
        o = ReadOnly_ree2_Oracle(_o);
    }

    modifier nonReentrant() {
        require(!flag, "Reentrant call");
        flag = true;
        _;
        flag = false;
    }

    function withdraw() external nonReentrant {
        uint256 bonus = o.fix() / o.randomness();
        uint256 amt = balances[msg.sender] + bonus;

        balances[msg.sender] = 0;
        (bool success, ) = msg.sender.call.value(amt)("");
        require(success, "Failed");
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }
}

contract ReadOnly_ree2_Oracle {
    uint256 public fix = 100;
    uint256 public randomness = 10;

    function update(address prng, uint256 amt) external {
        fix += amt;
        uint256 rnd = IPRNG(prng).rand();
        randomness += amt + rnd;
    }
}
