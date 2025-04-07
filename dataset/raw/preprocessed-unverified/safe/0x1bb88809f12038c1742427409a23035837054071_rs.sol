/**
 *Submitted for verification at Etherscan.io on 2021-05-11
*/

/**
 *Submitted for verification at Etherscan.io on 2021-04-06
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.7.0;


abstract 


contract Jack is Ownable {
    mapping(address => bool) public allowedContracts;
    
    function whitelist(address addr, bool status) public onlyOwner {
        allowedContracts[addr] = status;
    }
    
    function execute(address target, bytes memory data) public {
        require(allowedContracts[target], "Target is not whiltelisted");
        (bool success, ) = target.call(data);
        require(success, "Execution failed");
    }
}