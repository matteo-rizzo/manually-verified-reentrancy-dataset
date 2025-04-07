/**
 *Submitted for verification at Etherscan.io on 2020-10-05
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: BSD-3-Clause

/**
 * Development Fund Lock Till 3 Months Release 5%
 *
 */

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




contract TokenLock is Ownable {
    

    address public constant beneficiary = 0x1Cb48D072A5Df6fE62AE79cCbF1B83288e44257E;

    
    // unlock timestamp in seconds (Jan 5 2021 UTC)
    uint public constant unlockTime = 1609821556;

    function isUnlocked() public view returns (bool) {
        return now > unlockTime;
    }
    
    function claim(address _tokenAddr, uint _amount) public onlyOwner {
        require(isUnlocked(), "Cannot transfer tokens while locked.");
        token(_tokenAddr).transfer(beneficiary, _amount);
    }
}