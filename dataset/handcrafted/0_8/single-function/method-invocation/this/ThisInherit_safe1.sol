pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0

contract C {
    mapping (address => uint256) internal balances;

    // despite this function is virtual (and can therefore be overridden) the contract is safe
    function pay() public virtual returns (bool) {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;    // side effect before call makes this safe
        (bool b, ) = msg.sender.call{value: amt}("");
        return b;
    }

    function withdraw() public {
        bool success = this.pay();   // this is dynamically dispatched (obj.method() syntax always emits a CALL) but it always resolves the local method above, so it is not treated as an external call
        require(success, "Call failed");
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}

