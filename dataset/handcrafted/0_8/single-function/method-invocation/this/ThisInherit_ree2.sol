pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0

// this super-contract, if taken into account as standalone, can be considered vulnerable
contract C_ree {
    mapping (address => uint256) internal balances;

    function pay() public virtual returns (bool) {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool b, ) = msg.sender.call{value: amt}("");
        balances[msg.sender] = 0;    // side effect after call makes this vulnerable
        return b;
    }

    function withdraw() public {
        bool success = this.pay();   // this is dynamically dispatched (obj.method() syntax always emits a CALL) but it always resolves the local method above
        require(success, "Call failed");
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}

// this sub-contract, which depends on the inheritance, is safe
contract D_safe is C_ree {  
    // this override introduces a vulnerability
    function pay() public override returns (bool) {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;    // side effect before call makes this safe
        (bool b, ) = msg.sender.call{value: amt}("");
        return b;
    }

}


