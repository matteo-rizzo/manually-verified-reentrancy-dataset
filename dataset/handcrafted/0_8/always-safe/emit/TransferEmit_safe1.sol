// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract TransferEmit_safe1 {
    mapping (address => uint256) public balances;

    event Transfered(uint256 amt);

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        payable(msg.sender).transfer(amt);
        emit Transfered(amt);           // this is not treated as an effect
        balances[msg.sender] = 0;   // the only effect is this one and occurs after the transfer(), which makes the contract safe
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}