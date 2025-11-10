// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPRNG {
    function getRandom() external returns (uint256);
}

contract ReadOnlyStaticCall_safe1 {
    ReadOnlyStaticCall_safe1_Oracle public o;
    mapping(address => uint) private balances;
    bool private flag;

    constructor(address _o) {
        o = ReadOnlyStaticCall_safe1_Oracle(_o);
    }

    modifier nonReentrant() {
        require(!flag, "Reentrant call");
        flag = true;
        _;
        flag = false;
    }

    function withdraw() external nonReentrant {
        (bool success, bytes memory data) = address(o).staticcall("fix"); // static calls are equivalent to view-method invocations
        require(success, "Staticcall failed");
        uint256 fix = abi.decode(data, (uint256));

        (success, data) = address(o).staticcall("randomness");
        require(success, "Staticcall failed");
        uint256 randomness = abi.decode(data, (uint256));

        uint256 bonus = fix / randomness;
        uint256 amt = balances[msg.sender] + bonus;

        (success, ) = payable(msg.sender).call{value: amt}("");
        require(success, "Failed");
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }
}

// THIS is the contract vulnerable to reentrancy
contract ReadOnlyStaticCall_safe1_Oracle {
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
