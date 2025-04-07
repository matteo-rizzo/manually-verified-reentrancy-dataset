/**
 *Submitted for verification at Etherscan.io on 2020-12-16
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






contract TokenVestingLock is Ownable {
    using SafeMath for uint;
    
    // ========== CONTRACT VARIABLES ===============
    
    // enter token contract address here
    address public constant tokenAddress = 0x961C8c0B1aaD0c0b10a51FeF6a867E3091BCef17;
    
    // enter token locked amount here
    uint public constant tokensLocked = 1822392e18;
    
    // enter unlock duration here
    uint public constant lockDuration = 730 days;
    
    // DON'T Change This - unlock 100% Tokens over lockDuration
    uint public constant unlockRate = 100e2;
    
    // ======== END CONTRACT VARIABLES ===============
    
    uint public lastClaimedTime;
    uint public deployTime;

    constructor() public {
        deployTime = now;
        lastClaimedTime = now;
    }
    
    function claim() external onlyOwner {
        uint pendingUnlocked = getPendingUnlocked();
        uint contractBalance = Token(tokenAddress).balanceOf(address(this));
        uint amountToSend = pendingUnlocked;
        if (contractBalance < pendingUnlocked) {
            amountToSend = contractBalance;
        }
        require(Token(tokenAddress).transfer(owner, amountToSend), "Could not transfer Tokens.");
        lastClaimedTime = now;
    }
    
    function getPendingUnlocked() public view returns (uint) {
        uint timeDiff = now.sub(lastClaimedTime);
        uint pendingUnlocked = tokensLocked
                                    .mul(unlockRate)
                                    .mul(timeDiff)
                                    .div(lockDuration)
                                    .div(100e2);
        return pendingUnlocked;
    }
    
    // function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    function transferAnyERC20Tokens(address tokenContractAddress, address tokenRecipient, uint amount) external onlyOwner {
        require(tokenContractAddress != tokenAddress || now > deployTime.add(lockDuration), "Cannot transfer out locked tokens yet!");
        require(Token(tokenContractAddress).transfer(tokenRecipient, amount), "Transfer failed!");
    }
    
    // function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    function transferAnyLegacyERC20Tokens(address tokenContractAddress, address tokenRecipient, uint amount) external onlyOwner {
        require(tokenContractAddress != tokenAddress || now > deployTime.add(lockDuration), "Cannot transfer out locked tokens yet!");
        LegacyToken(tokenContractAddress).transfer(tokenRecipient, amount);
    }
}