// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPRNG {
    function rand(uint256) external returns (uint256);
}

contract ReadOnly_ree1 {
    ReadOnly_ree1_Oracle public o;
    mapping(address => uint) private balances;

    constructor(address _o) {
        o = ReadOnly_ree1_Oracle(_o);
    }

    function withdraw() external {
        uint256 bonus = (o.fix() * 0.01 ether) / o.randomness();
        uint256 amt = balances[msg.sender] + bonus;

        balances[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: amt}("");
        require(success, "Failed");
    }

    function deposit(address randomizer) external payable {
        balances[msg.sender] += msg.value;
        o.update(randomizer, msg.value);
    }
}

// THIS is the contract vulnerable to reentrancy
contract ReadOnly_ree1_Oracle {
    uint256 public fix;
    uint256 public randomness = 1;

    function update(address prng, uint256 amt) external {
        fix += amt;
        uint rnd = IPRNG(prng).rand(amt);
        randomness += amt + rnd;
    }
}

contract ReadOnly_ree1_DummyPRNG is IPRNG {
    function rand(uint amt) external view returns (uint256) {
        // This is a dummy PRNG for testing purposes
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        amt,
                        block.timestamp,
                        block.number,
                        msg.sender
                    )
                )
            ) % 1000000000000000;
    }
}
