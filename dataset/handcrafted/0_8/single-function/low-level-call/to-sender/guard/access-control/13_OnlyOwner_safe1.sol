// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ControlledPayout {

    struct PendingPayment {
        address payable recipient;
        uint256 amount;
    }

    address public owner;
    PendingPayment[] private pendingPayments;
    bool private flag;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    // the nonReentrant mod is necessary to prevent attackers reenter into the requestPay() and increase 
    // the array length while iterating within the payAll()
    function requestPay(address payable recipient) nonReentrant public payable {
        require(msg.value > 0, "No credit");
        pendingPayments.push(PendingPayment({recipient: recipient, amount: msg.value}));
    }

    function payAll() nonReentrant public {
        for (uint256 i = 0; i < pendingPayments.length; ++i)
            pay(pendingPayments[i].recipient, pendingPayments[i].amount);
        delete pendingPayments;
    }

    function pay(address payable recipient, uint256 amount) onlyOwner public {
        require(address(this).balance >= amount, "Insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");
    }
}