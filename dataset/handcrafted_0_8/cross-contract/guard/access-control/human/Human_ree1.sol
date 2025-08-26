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

    function transfer(address from, address to, uint256 amt) isHuman() public {
        require(balances[from] >= amt, "Insufficient funds");
        (bool success, ) = to.call{value:amt}("");
        require(success, "Call failed");
        balances[from] -= amt;    // side effect after call
    }

    function deposit() public payable isHuman() {
        balances[msg.sender] += msg.value;       
    }
}

// an attacker performs from off-chain:
// deposit(100)
// then, transfer(self, attacker, 100) 
// where self is the EOA of the attacker
// and attacker is an instance of the Attacker contract
// contract Attacker {    
//     receive() payable external {
//         // now this contract has received 100
//         // and a new contract is instantiated, passing addresses for reentering
//         Aux att = new Aux(address(this), msg.sender);
//     }
// }

// contract Aux {
//     constructor(address attacker, address sender) {
//         // within this constructor a reentrancy is performed and another 100 are transfered to the Attacker contract
//         // the isHuman guard succeedes because we are INSIDE a constructor
//         C(sender).transfer(sender, attacker, 100);
//     }
// }
