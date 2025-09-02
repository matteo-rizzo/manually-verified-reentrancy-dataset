pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
interface I {
    function pay(uint256 amt) external;
}

contract C {
    mapping (address => uint256) public balances;

    event Paid(uint256 amt);

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;   // the only effect is this one and occurs before the external call
        I(msg.sender).pay(amt);
        emit Paid(amt);    // this is not treated as an effect, thus the contract is safe
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}