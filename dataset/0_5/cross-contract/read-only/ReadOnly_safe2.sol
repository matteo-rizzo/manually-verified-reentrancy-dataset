// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

interface IPRNG {
    function rand() external returns (uint256);
}

contract ReadOnly_safe2 {
    ReadOnly_safe2_Oracle public o;
    mapping(address => uint256) private balances;
    bool private flag;

    constructor(address _o) public {
        o = ReadOnly_safe2_Oracle(_o);
    }

    modifier nonReentrant() {
        require(!flag, "Reentrant call");
        flag = true;
        _;
        flag = false;
    }

    function withdraw() external nonReentrant {
        uint256 bonus = o.getFix() / o.getRandomness();
        uint256 amt = balances[msg.sender] + bonus;

        balances[msg.sender] = 0;
        (bool success, ) = msg.sender.call.value(amt)("");
        require(success, "Failed");
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }
}

contract ReadOnly_safe2_Oracle {
    uint256 private fix = 100;
    uint256 private randomness = 10;
    bool private flag;

    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    modifier nonReentrantView() {
        require(!flag, "Locked");
        _;
    }

    function update(address prng, uint256 amt) external nonReentrant {
        fix += amt;
        uint256 rnd = IPRNG(prng).rand();
        randomness += amt + rnd;
    }

    function getFix() external view nonReentrantView returns (uint256) {
        return fix;
    }

    function getRandomness() external view nonReentrantView returns (uint256) {
        return randomness;
    }
}
