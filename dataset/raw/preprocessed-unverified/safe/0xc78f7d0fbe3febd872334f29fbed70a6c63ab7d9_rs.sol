pragma solidity 0.6.12;

// SPDX-License-Identifier: BSD-3-Clause

/**
 * Staking Fund Locked till 26th Oct 2020 
 * and then migrate to new staking smartcontract which will be without withdrawal permission   
 *
 */

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




contract TokenLock is Ownable {
    

    address public constant beneficiary = 0xdA745EA2e2A5461DF62539f07a9eABA6Cf36dc41;

    
    // unlock timestamp in seconds (Oct 26 2020 UTC)
    uint public constant unlockTime = 1603670400;

    function isUnlocked() public view returns (bool) {
        return now > unlockTime;
    }
    
    function claim(address _tokenAddr, uint _amount) public onlyOwner {
        require(isUnlocked(), "Cannot transfer tokens while locked.");
        token(_tokenAddr).transfer(beneficiary, _amount);
    }
}