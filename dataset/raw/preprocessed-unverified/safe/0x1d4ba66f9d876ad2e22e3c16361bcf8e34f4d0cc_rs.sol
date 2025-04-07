/**
 *Submitted for verification at Etherscan.io on 2021-07-08
*/

pragma solidity 0.6.11;
// SPDX-License-Identifier: BSD-3-Clause

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */






contract TokenLock is Ownable {
    using SafeMath for uint;
    
    // unix unlock
    uint public unlockTime;
    // max extension allowed - prevents owner from extending indefinitely by mistake
    uint public constant MAX_EXTENSION_ALLOWED = 30 days;
    
    constructor(uint initialUnlockTime) public {
        require(initialUnlockTime > now, "Cannot set an unlock time in past!");
        unlockTime = initialUnlockTime;
    }
    
    function isUnlocked() public view returns (bool) {
        return now > unlockTime;
    }
    
    function extendLock(uint extendedUnlockTimestamp) external onlyOwner {
        require(extendedUnlockTimestamp > now && extendedUnlockTimestamp > unlockTime , "Cannot set an unlock time in past!");
        require(extendedUnlockTimestamp.sub(now) <= MAX_EXTENSION_ALLOWED, "Cannot extend beyond MAX_EXTENSION_ALLOWED period!");
        unlockTime = extendedUnlockTimestamp;
    }
    
    function claim(address tokenAddress, address recipient, uint amount) external onlyOwner {
        require(isUnlocked(), "Not Unlocked Yet!");
        require(Token(tokenAddress).transfer(recipient, amount), "Transfer Failed!");
    }

    function claimLegacyToken(address tokenAddress, address recipient, uint amount) external onlyOwner {
        require(isUnlocked(), "Not Unlocked Yet!");
        LegacyToken(tokenAddress).transfer(recipient, amount);
    }
}