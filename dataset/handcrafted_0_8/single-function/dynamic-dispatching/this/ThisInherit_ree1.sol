pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0

// this super-contract, if taken into account as standalone, can be considered safe
contract C {
    mapping (address => uint256) internal balances;

    function pay(uint256 amt) public virtual returns (bool) {
        balances[msg.sender] -= amt;    // side effect before call makes this safe
        (bool b, ) = msg.sender.call{value: amt}("");
        return b;
    }

    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        bool success = this.pay(amt);   // this is dynamically dispatched (obj.method() syntax always emits a CALL) but it always resolves the local method above
        require(success, "Call failed");
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}

// this sub-contract, which depends on the inheritance, is vulnerable
contract D is C {  
    // this override introduces a vulnerability
    function pay(uint256 amt) public override returns (bool) {
        (bool b, ) = msg.sender.call{value: amt}("");
        balances[msg.sender] -= amt;    // side effect AFTER call makes this vulnerable to reentrancy
        return b;
    }
}


