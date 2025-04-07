pragma solidity 0.6.12;

// SPDX-License-Identifier: BSD-3-Clause

/**
 * DAO Fund Locked Till DEC 15th 2020   
 *
 */

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




contract TokenLock is Ownable {
    

    address public constant beneficiary = 0xb5D899CB1a141ADeeD2C330E22a85Fb39a972d6F;

    
    // unlock timestamp in seconds (Dec 15 2020 UTC)
    uint public constant unlockTime = 1607990400;

    function isUnlocked() public view returns (bool) {
        return now > unlockTime;
    }
    
    function claim(address _tokenAddr, uint _amount) public onlyOwner {
        require(isUnlocked(), "Cannot transfer tokens while locked.");
        token(_tokenAddr).transfer(beneficiary, _amount);
    }
}