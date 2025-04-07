/**
 *Submitted for verification at Etherscan.io on 2020-11-26
*/

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

//SPDX-License-Identifier: UNLICENSED

contract Splitter {
    address owner = msg.sender;
    
    modifier isOwner() {
        require(msg.sender == owner, "Forbidden.");
        _;
    }
    
    function getEther(uint amount) isOwner external {
       msg.sender.transfer(amount);
    }
    
    function splitEther(address payable[] memory EOAs) external payable {
        uint Count = EOAs.length;
        uint Split = SafeMath.div(msg.value, Count);
        uint Check = SafeMath.mul(Split, Count);
        uint Miettes;
        if (Check < msg.value) {
            Miettes = SafeMath.sub(msg.value, Check);
        }
        for (uint i=0; i<Count; i++) {
            address payable CurrentAddress = EOAs[i];
            if (Miettes > 0 && i == 0) {
                CurrentAddress.transfer(SafeMath.add(Split, Miettes));
            } else {
                CurrentAddress.transfer(Split);
            }
        }
    }
}

