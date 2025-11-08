// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.24;


contract This_safe2 {
    
    mapping(address => uint) private balances;

    constructor(uint _initialSupply)  public{
        balances[msg.sender] = _initialSupply;
    }

    function balanceOf(address account) public view returns (uint) {
        return balances[account];
    }

    function transfer(address to, uint amount) public returns (bool) {
        uint bal = this.balanceOf(msg.sender);      // emits a CALL but it always resolves the local method above, so this invocation is not an actual external call
        require(bal >= amount, "Not enough tokens");   
        balances[msg.sender] -= amount;             // even if the side effect is after the method invocation, it is safe
        balances[to] += amount;
        return true;
    }
}
