pragma solidity ^0.8.0;
import "../../../../../interfaces/ILowLevelCallToTarget.sol";

// SPDX-License-Identifier: GPL-3.0
contract ConstructorRee1 is ILowLevelCallToTarget {
    mapping (address => uint256) public balances;

    address payable private target;
    
    constructor(address t) {
        target = payable(t);
    }

    function pay() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = target.call{value:amt}("");      // calls to any address are potentially malicious
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect AFTER the call makes the contract vulnerable to reentrancy
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}