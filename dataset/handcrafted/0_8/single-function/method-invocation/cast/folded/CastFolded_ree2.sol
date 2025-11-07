// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;


interface I {
    function transfer(uint256 amt) external returns (bool);
}

contract C {
    mapping (address => uint256) public balances;

    function pay(address addr, uint256 amt) internal {
        bool success = I(addr).transfer(amt);   // the implementation is unknown and could be malicious
        require(success, "Call failed");
    }

    function withdraw(address addr) public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        pay(addr, amt);
        update();
    }

    function update() internal {
        balances[msg.sender] = 0;    // side effect is folded and AFTER the folded call, making this vulnerable
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}