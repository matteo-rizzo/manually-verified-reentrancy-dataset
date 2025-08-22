pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0

interface I {
    function pay() external view returns (bool, uint256);
}

contract C {
    mapping (address => uint256) public balances;

    function withdraw(address addr, uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        (bool success, ) = I(addr).pay();   // pay() implementation is unknown but it's marked as VIEW, thus it cannot reenter because a view method cannot invoke call()
        require(success, "Call failed");
        balances[msg.sender] -= amt;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}