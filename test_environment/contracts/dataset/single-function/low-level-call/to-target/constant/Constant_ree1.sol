// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "../../../../../interfaces/single-function/ILowLevelCallToTarget.sol";

contract ConstantRee is ILowLevelCallToTarget {
    mapping (address => uint256) public balances;

    address private target = 0xD591678684E7c2f033b5eFF822553161bdaAd781; 

    function pay() public {
        
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = target.call{value:amt}("");      // calls to a constant target address are potentially malicious
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect AFTER the call makes the contract vulnerable to reentrancy
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}