// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../../../interfaces/single-function/ILowLevelCallToSender.sol";

contract CallFolded_ree1 is ILowLevelCallToSender {
    mapping(address => uint256) public balances;

    function pay(uint256 amt) internal {
        (bool success, ) = msg.sender.call{value: amt}("");
        require(success, "Call failed");
    }

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        pay(amt);
        balances[msg.sender] = 0; // side effect AFTER the folded call makes this vulnerable
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
}
