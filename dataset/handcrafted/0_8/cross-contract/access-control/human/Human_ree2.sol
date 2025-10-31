pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
// TODO This contract must be fixed cause this is not vulnerabile as it is now

// contract C {
//     mapping (address => uint256) private bids;
//     uint highestBid;
//     address highestBidder;

//     modifier isHuman() {
//         address _addr = msg.sender;
//         uint256 _codeLength;
//         assembly {_codeLength := extcodesize(_addr)}
//         require(_codeLength == 0, "sorry humans only");
//         _;
//     }

//     function bid() public payable isHuman() {
//         require(msg.value > 0, "no zero value");
//         require(msg.value > highestBid, "no lowballing");
//         highestBid = msg.value;
//         highestBidder = msg.sender;
//         bids[msg.sender] += msg.value;       
//     }

//     function transfer(address to) isHuman() public {
//         uint256 amt = bids[msg.sender];
//         require(amt > 0, "Insufficient funds");
//         (bool success, ) = to.call{value:amt}("");
//         require(success, "Call failed");
//         bids[msg.sender] = 0;    // side effect after call
//     }

// }