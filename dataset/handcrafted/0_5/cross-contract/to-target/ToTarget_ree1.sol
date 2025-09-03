pragma solidity ^0.5.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;

    function pay(address target) public {
        require(target != msg.sender);
        uint256 amt = balances[msg.sender];
        (bool success, ) = target.call.value(amt)("");    
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect after the call makes this contract vulnerable to attacks
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}


// contract Attacker1 {

//     C c;
//     Attacker2 att2;
//     uint counter = 10;

//     function attack() public {
//         c.deposit{value: 100}();
//         reenter();
//     }

//     function reenter() public {
//         if (counter-- > 0)
//             c.pay(address(att2));
//     }
// }

// contract Attacker2 {
//     Attacker1 att1;

//     function() external payable {
//         att1.reenter();
//     }    
// }