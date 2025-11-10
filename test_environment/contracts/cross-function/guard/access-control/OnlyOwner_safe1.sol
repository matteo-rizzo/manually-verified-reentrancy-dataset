// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OnlyOwner_safe1 {
    bool private flag;
    struct PendingPayment {
        address payable recipient;
        uint256 amount;
    }

    address public owner;

    uint constant fee_partition = 10;

    PendingPayment[] private pendingPayments;

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

    // all functions are protected by a reentrancyguard, making the contract safe

    function payAll() public nonReentrant onlyOwner {
        for (uint256 i = 0; i < pendingPayments.length; ++i) {
            address payable recipient = pendingPayments[i].recipient;
            uint256 amount = pendingPayments[i].amount;
            require(address(this).balance >= amount, "Insufficient balance");
            (bool success, ) = recipient.call{value: amount + i}("");
            require(success, "Transfer failed");
        }
        delete pendingPayments; // side-effect AFTER external calls is protected by the reentrancy guard
    }

    function requestPay(address payable recipient) public payable nonReentrant {
        require(msg.value > 0, "No credit");
        pendingPayments.push(
            PendingPayment({
                recipient: recipient,
                amount: msg.value - msg.value / fee_partition
            })
        );
    }
}
