pragma solidity 0.6.12;

// SPDX-License-Identifier: BSD-3-Clause

/**
 * Vaults Reward Fund Locked till 20th Oct 2020 
 * Farming vault token will transfer on Vaults smart contrcat after unlock which will be without withdrawal permission
 *
 */

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




contract TokenLock is Ownable {
    

    address public constant beneficiary = 0x3E7e36f4Dd5394E48ce3D5dB86D71F062B18aE1B;

    
    // unlock timestamp in seconds (Oct 20 2020 UTC)
    uint public constant unlockTime = 1603152000;

    function isUnlocked() public view returns (bool) {
        return now > unlockTime;
    }
    
    function claim(address _tokenAddr, uint _amount) public onlyOwner {
        require(isUnlocked(), "Cannot transfer tokens while locked.");
        token(_tokenAddr).transfer(beneficiary, _amount);
    }
}