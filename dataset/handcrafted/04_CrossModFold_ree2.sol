pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    bool flag = false;
    mapping (address => uint256) public balances;


    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    function update(address a, int256 amt) internal {
        if (amt < 0)
            balances[a] -= uint256(amt);
        else 
            balances[a] += uint256(amt);
    }

    function transfer(address to, uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        update(to, int256(amt));
        update(msg.sender, -int256(amt));
    }

    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        update(msg.sender, -int256(amt));
    }

    function deposit() nonReentrant public payable {
        balances[msg.sender] += msg.value;       
    }

}