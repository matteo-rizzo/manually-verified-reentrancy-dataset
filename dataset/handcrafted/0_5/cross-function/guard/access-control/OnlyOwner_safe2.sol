// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract ControlledPayout {


    uint256 max_queued;
    struct PendingPayment {
        address payable recipient;
        uint256 amount;
    }

    address public owner;
    PendingPayment[] private pendingPayments;

    constructor()  public {
        owner = msg.sender;
        max_queued = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // while the owner is iterating within the payAll(), attackers may reenter into the requestPay()
    // and increase the array length
    function requestPay(address payable recipient) public payable {
        require(max_queued < 100); // accepts at most 100 payment requests at a time
        require(msg.value > 0, "No credit");
        pendingPayments.push(PendingPayment({recipient: recipient, amount: msg.value}));
        max_queued += 1;
    }

    function payAll() public onlyOwner() {
        require(max_queued == 100);
        for (uint256 i = 0; i < pendingPayments.length; ++i) 
            pay(pendingPayments[i].recipient, pendingPayments[i].amount);
        delete pendingPayments; 
        max_queued = 0;
    }

    function pay(address payable recipient, uint256 amount) public onlyOwner() {
        require(address(this).balance >= amount, "Insufficient balance");

        (bool success, ) = recipient.call.value(amount)(""); // if an attacker reenters requestPay before all payments have been processed, require(max_queued < 100) fails because it has not been set to 0 yet
        require(success, "Transfer failed");
    }
}

