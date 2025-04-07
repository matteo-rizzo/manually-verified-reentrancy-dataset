/**
 *Submitted for verification at Etherscan.io on 2020-09-26
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: MIT

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */





contract Jpluslock is Ownable {
    using SafeMath for uint;
    
    address public constant tokenAddress = 0xE2779DF83D0C75Df4d2e6173Af671Adb5Aa56eF6;
    
    uint public constant tokensLocked = 10000e18;    // 10,000 Tokens Locked
    uint public constant unlockRate = 67000;         // 200 Token unlock in every month to 4 years
    uint public constant lockDuration = 30 days;     // CAN WITHDRAW AFTER EVERY 30 DAYS 
    uint public lastClaimedTime;
    uint public deployTime;

    
    constructor() public {
        deployTime = now;
        lastClaimedTime = now;
    }
    
    function claim() public onlyOwner {
        uint pendingUnlocked = getPendingUnlocked();
        uint contractBalance = Jplus(tokenAddress).balanceOf(address(this));
        uint amountToSend = pendingUnlocked;
        if (contractBalance < pendingUnlocked) {
            amountToSend = contractBalance;
        }
        require(Jplus(tokenAddress).transfer(owner, amountToSend), "Could not transfer Tokens.");
        lastClaimedTime = now;
    }
    
    function getPendingUnlocked() public view returns (uint) {
        uint timeDiff = now.sub(lastClaimedTime);
        uint pendingUnlocked = tokensLocked
                                    .mul(unlockRate)
                                    .mul(timeDiff)
                                    .div(lockDuration)
                                    .div(1e4);
        return pendingUnlocked;
    }
    
    // function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    function transferAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        require(_tokenAddr != tokenAddress, "Cannot transfer out reward tokens");
        Jplus(_tokenAddr).transfer(_to, _amount);
    }

}