/**
 *Submitted for verification at Etherscan.io on 2021-07-10
*/

// SPDX-License-Identifier: MIT
// Copyright (c) 2021 Varia LLC
/// Wet Code by Erich Dylus & Sarah Brennan
/// Dry Code by LexDAO LLC
pragma solidity ^0.8.6;

/// @notice This contract manages function access control, adapted from @boringcrypto (https://github.com/boringcrypto/BoringSolidity).


/// @notice This contract allows potential delegates of DAO voting power to ethSign a ricardian template for delegation disclosures.
contract VoteDelegateDisclosure is Ownable {
    uint8 public version; // counter for ricardian template versions
    string public template; // string stored for ricardian template signature - amendable by `owner`
    
    mapping(address => bool) public registrations; // maps signatories to registration status (true/false)
    
    event Amend(string template);
    event Sign(string details);
    event Revoke(string details);
    
    constructor(string memory _template) {
        template = _template; // initialize ricardian template
    }
    
    function amend(string calldata _template) external onlyOwner {
        version++; // increment ricardian template version
        template = _template; // update ricardian template string stored in this contract
        emit Amend(_template); // emit amendment details in event for apps
    }

    function sign(string calldata details) external {
        registrations[msg.sender] = true; // register caller signatory
        emit Sign(details); // emit signature details in event for apps
    }
    
    function revoke(string calldata details) external {
        registrations[msg.sender] = false; // nullify caller registration
        emit Revoke(details); // emit revocation details in event for apps
    }
}