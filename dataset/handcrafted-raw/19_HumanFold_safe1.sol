pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;

    modifier isHuman() {
        require(tx.origin == msg.sender, "Not EOA");
        _;
    }

    function pay(address to, uint256 amt) internal {
        (bool success, ) = to.call{value:amt}("");
        require(success, "Call failed");
    }

    function transfer(address to, uint256 amt) isHuman() public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        pay(to, amt);
        balances[msg.sender] -= amt;
    }

    function deposit() isHuman() public payable {
        balances[msg.sender] += msg.value;       
    }

}