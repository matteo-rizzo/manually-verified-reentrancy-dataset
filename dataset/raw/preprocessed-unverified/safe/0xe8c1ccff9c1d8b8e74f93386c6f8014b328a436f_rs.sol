/**
 *Submitted for verification at Etherscan.io on 2021-05-18
*/

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity 0.6.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */






contract GDEFI_MarketingAndPartnership_Vesting is Ownable {
    using SafeMath for uint;
    
    // ========== CONTRACT VARIABLES ===============
    
    // enter token contract address here
    address public constant tokenAddress = 0xb5e88B229B18e748e3aa16A1C2bFefdFc8a5560d;
    
    // enter token locked amount here
    uint public constant tokensLocked = 100000e18;
    
    // enter unlock duration here
    uint public constant lockDuration = 305 days;
    
    // ======== END CONTRACT VARIABLES ===============

    // DON'T Change This - unlock 100% Tokens over lockDuration
    uint public constant unlockRate = 100e2;
    
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