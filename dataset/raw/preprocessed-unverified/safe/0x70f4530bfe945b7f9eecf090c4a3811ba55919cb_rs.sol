/**
 *Submitted for verification at Etherscan.io on 2020-12-03
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: MIT








contract CapitalDeFiLock is Ownable {
    using SafeMath for uint;
    
    address public constant tokenAddress = 0xEDA6eFE5556e134Ef52f2F858aa1e81c84CDA84b;
    
    uint public constant tokensLocked = 10000e18;         // 10,000 CAP
    uint public constant unlockRate =   10000;            
    uint public constant lockDuration = 30 days;           // Before 30 Days, Its impossible to unlock...
    uint public lastClaimedTime;
    uint public deployTime;

    
    constructor() public {
        deployTime = now;
        lastClaimedTime = now;
    }
    
    function claim() public onlyOwner {
        uint pendingUnlocked = getPendingUnlocked();
        uint contractBalance = CapitalDeFi(tokenAddress).balanceOf(address(this));
        uint amountToSend = pendingUnlocked;
        if (contractBalance < pendingUnlocked) {
            amountToSend = contractBalance;
        }
        require(CapitalDeFi(tokenAddress).transfer(owner, amountToSend), "Could not transfer Tokens.");
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

}