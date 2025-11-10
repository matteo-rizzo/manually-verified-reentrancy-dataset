// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPRNG {
    function getRandom() external returns (uint256);
}

contract ReadOnlyStaticCall_ree1 {
    ReadOnlyStaticCall_ree1_Oracle public o;
    mapping(address => uint) private balances;

    constructor(address _o) {
        o = ReadOnlyStaticCall_ree1_Oracle(_o);
    }

    function withdraw() external {
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
contract ReadOnlyStaticCall_ree1_Oracle {
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
