pragma solidity ^0.5.0;

// SPDX-License-Identifier: GPL-3.0

contract C {
    mapping (address => uint256) public balances;

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        bool success = this.pay(amt);   // emits a CALL but it always resolves the local method above, so this invocation is not an actual external call
        balances[msg.sender] = 0;       // the position of the side effect is irrelevant, as the contract is safe anyway
        require(success, "Call failed");
    }

    function pay(uint256 amt) public returns (bool) {
        require(msg.sender == address(this));   // only this can call pay()
        return (msg.sender).send(amt);   // send() has too few gas to allow reentrancy
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}
