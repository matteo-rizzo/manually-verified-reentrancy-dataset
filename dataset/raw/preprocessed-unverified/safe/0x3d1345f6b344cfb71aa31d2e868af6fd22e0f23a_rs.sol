/**
 *Submitted for verification at Etherscan.io on 2020-10-22
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: MIT








contract YearnStackingDev_Marketing is Ownable {
    using SafeMath for uint;
    
    address public constant tokenAddress = 0x0f10b084b96a676E678753726DeD0b674c5daf67;
    
    
    // Team and Advisor = 2,000 YSFI     ;       Every Month Unlocking =   166.67 YSFI 
    //     Marketing    = 5,200 YSFI     ;       Every Month Unlocking =   433.33 YSFI 
    //     Total        = 7,200 YSFI     ;       Every Month Unlocking =   600.00 YFSI 
    
    
    uint public constant tokensLocked = 7200e18;      // 7200 YSFI 
    uint public constant unlockRate =   600;          // 600 YSFI unlocking every month
                                                       // 7200 ¡Â 600 = 12 
                                                       
    uint public constant lockDuration = 30 days;       // 600 YSFI unlock in every 30 days
    uint public lastClaimedTime;
    uint public deployTime;

    
    constructor() public {
        deployTime = now;
        lastClaimedTime = now;
    }
    
    function claim() public onlyOwner {
        uint pendingUnlocked = getPendingUnlocked();
        uint contractBalance = YSFI(tokenAddress).balanceOf(address(this));
        uint amountToSend = pendingUnlocked;
        if (contractBalance < pendingUnlocked) {
            amountToSend = contractBalance;
        }
        require(YSFI(tokenAddress).transfer(owner, amountToSend), "Could not transfer Tokens.");
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
        YSFI(_tokenAddr).transfer(_to, _amount);
    }

}