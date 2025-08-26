pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;

    address private target;
    
    constructor(address t) {
        target = t;
    }

    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        (bool success, ) = target.call{value:amt}("");      // calls to any address are potentially malicious
        require(success, "Call failed");
        balances[msg.sender] -= amt;    // side effect AFTER the call makes the contract vulnerable to reentrancy
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}

// sample target contract at address given at construction time
// this contract seems trustful but it is actually vulnerable
// contract Target {
//     address private owner;

//     // this is public and could be called by anyone, including malicious entities reassigning the onwer address
//     function changeOwner() public {
//         owner = msg.sender;
//     }

//     receive() external payable {
//         (bool success, ) = owner.call("");  // a malicious owner may reenter in C.withdraw()
//         require(success, "Call failed");
//     }
// }