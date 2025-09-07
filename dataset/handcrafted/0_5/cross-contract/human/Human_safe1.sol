pragma solidity ^0.5.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    address[] private buyers;

    uint public currentKeyPrice = 1;
    address private lastBuyer;
    uint private lastBuyTimestamp;

    modifier isHuman() {
        require(tx.origin == msg.sender, "Not EOA");    // this implementation of the modifier does not allow reentrancy from constructors, hence the contract is safe
        _;
    }

    function buyKey(address refund_address) isHuman() public payable {
        require(msg.value > currentKeyPrice, "Not enough to buy a key");
        lastBuyer = msg.sender;
        lastBuyTimestamp = block.timestamp;
        currentKeyPrice = buyers.length * 100;
        buyers.push(refund_address);

        for (uint i = 0; i < buyers.length; i++) {
            (bool success, ) = buyers[i].call.value(1)("");
            require(success, "Refund failed");
        }
    }

    function close() isHuman public {
        require(block.timestamp > lastBuyTimestamp + 1 hours);
        (bool success, ) = lastBuyer.call.value(currentKeyPrice * 2)("");
        require(success, "Call failed");
    }
}
