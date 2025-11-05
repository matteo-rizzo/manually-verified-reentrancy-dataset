// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


// TODO This contract must be fixed cause this is not vulnerabile as it is now
// contract ControlledPayout {

//     struct PendingPayment {
//         address payable recipient;
//         uint256 amount;
//     }

//     address public owner;
//     PendingPayment[] private pendingPayments;

//     constructor() {
//         owner = msg.sender;
//     }

//     modifier onlyOwner() {
//         require(msg.sender == owner, "Not authorized");
//         _;
//     }

//     function payAll() public onlyOwner() {  
//         for (uint256 i = 0; i < pendingPayments.length; ++i){
//             address payable recipient = pendingPayments[i].recipient;
//             uint256 amount = pendingPayments[i].amount;
//             require(address(this).balance >= amount, "Insufficient balance");
//             (bool success, ) = recipient.call{value: amount}("");
//             require(success, "Transfer failed");
//         }
//         delete pendingPayments; // side-effect after external calls on a state variable that can be modified by an attacker reentering in requestPay()
//     }

//     // while the owner is iterating within the payAll(), attackers may reenter into the requestPay() and increase the array length
//     function requestPay(address payable recipient) public payable {
//         require(msg.value > 0, "No credit");
//         pendingPayments.push(PendingPayment({recipient: recipient, amount: msg.value}));
//     }

// }

