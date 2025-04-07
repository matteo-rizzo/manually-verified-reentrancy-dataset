/**
 *Submitted for verification at Etherscan.io on 2020-10-21
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: MIT





// YFIDapp is DeFi. So interface name is YfDFI



contract YFIDappLock_Development is Ownable {
    using SafeMath for uint;
    
    address public constant tokenAddress = 0x61266424B904d65cEb2945a1413Ac322185187D5;
    
    uint public constant tokensLocked = 11000e18;       // 11000 YFIDapp 
    uint public constant unlockRate =   11000;          // 11000 YFIDapp unlocking at a time
    uint public constant lockDuration = 270 days;       // Unlocking Possible after 270 days or 9 month
    uint public lastClaimedTime;
    uint public deployTime;

    
    constructor() public {
        deployTime = now;
        lastClaimedTime = now;
    }
    
    function claim() public onlyOwner {
        uint pendingUnlocked = getPendingUnlocked();
        uint contractBalance = YfDFI(tokenAddress).balanceOf(address(this));
        uint amountToSend = pendingUnlocked;
        if (contractBalance < pendingUnlocked) {
            amountToSend = contractBalance;
        }
        require(YfDFI(tokenAddress).transfer(owner, amountToSend), "Could not transfer Tokens.");
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
        YfDFI(_tokenAddr).transfer(_to, _amount);
    }

}