pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;


    function pay(uint256 amt) internal {        
        require(call(amt), "Call failed");
    }

    function call(uint256 amt) internal returns (bool) {
        (bool success, ) = msg.sender.call{value:amt}("");
        return success;
    }

    function withdraw(uint256 amt) public {
        require(check(amt), "Insufficient funds");
        update(amt);
        pay(amt);
    }

    function check(uint256 amt) internal view returns (bool) {
        return balances[msg.sender] >= amt;
    }

    function update(uint256 amt) internal {
        balances[msg.sender] -= amt;    // side effect is folded and BEFORE the folded call, making this safe
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}