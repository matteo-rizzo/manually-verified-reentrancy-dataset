pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0

interface I {
    function transfer(uint256 amt) external returns (bool);
}

contract C {
    mapping (address => uint256) public balances;

    function pay(address addr, uint256 amt) internal {
        bool success = I(addr).transfer(amt);   // the implementation is unknown and could be malicious
        require(success, "Call failed");
    }

    function withdraw(address addr, uint256 amt) public {
        require(check(amt), "Insufficient funds");
        pay(addr, amt);
        update(amt);
    }

    function update(uint256 amt) internal {
        balances[msg.sender] -= amt;    // side effect is folded and AFTER the folded call, making this vulnerable
    }

    function check(uint256 amt) internal view returns (bool) {
        return balances[msg.sender] >= amt;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}
