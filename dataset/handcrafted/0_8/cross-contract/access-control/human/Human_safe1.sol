// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Human_safe1 {
    mapping (address => uint256) private bids;
    uint highestBid;
    address highestBidder;
    mapping (address => mapping (address => uint256)) private allowances;

    modifier isHuman() {
        require(tx.origin == msg.sender, "Not EOA");    // this implementation of the modifier does not allow reentrancy from constructors, hence the contract is safe
        _;
    }

    function bid() public payable isHuman() {
        require(msg.value > 0, "no zero value");
        require(msg.value > highestBid, "no lowballing");
        highestBid = msg.value;
        highestBidder = msg.sender;
        bids[msg.sender] += msg.value;
    }

    function transfer(address to) isHuman() public {
        transferFrom(msg.sender, to);
    }

    function setAllowance(address a, uint256 amt) public {
        allowances[msg.sender][a] = amt;
    }

    function transferFrom(address from, address to) isHuman() public {
        uint256 amt = bids[from];
        require(amt > 0, "Insufficient funds");
        require(allowances[msg.sender][from] >= amt);
        (bool success, ) = to.call{value:amt}("");
        require(success, "Call failed");
        bids[from] = 0;    // side effect after call
        allowances[msg.sender][from] = 0;
    }
}