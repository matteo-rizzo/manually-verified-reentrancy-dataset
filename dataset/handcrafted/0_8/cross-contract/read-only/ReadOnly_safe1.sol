// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPRNG {
    function getRandom() external returns (uint256);
}

contract ReadOnly_safe1 {
    ReadOnly_safe1_Oracle public o;
    mapping(address => uint) private balances;
    bool private flag;

    constructor(address _o) {
        o = ReadOnly_safe1_Oracle(_o);
    }

    function withdraw() external {
        uint256 bonus = o.getFix() / o.getRandomness();
        uint256 amt = balances[msg.sender] + bonus;

        (bool success, ) = payable(msg.sender).call{value: amt}("");
        require(success, "Failed");
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }
}

// THIS is the contract vulnerable to reentrancy
contract ReadOnly_safe1_Oracle {
    uint256 private fix;
    uint256 private randomness;
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
        uint rnd = IPRNG(prng).getRandom();
        fix += amt;
        randomness += amt + rnd;
    }

    function getFix() external view nonReentrantView returns (uint256) {
        return fix;
    }

    function getRandomness() external view nonReentrantView returns (uint256) {
        return randomness;
    }
}
