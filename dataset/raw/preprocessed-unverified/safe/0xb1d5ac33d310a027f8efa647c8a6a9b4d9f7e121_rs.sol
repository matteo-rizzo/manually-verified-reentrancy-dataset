/**
 *Submitted for verification at Etherscan.io on 2020-10-28
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: MIT





// UniD is DeFi. So interface name is UniD



contract UniDStackingLock is Ownable {
    using SafeMath for uint;
    
    address public constant tokenAddress = 0xe27E62D953Aa17ac0C63f9B091C5474C608b4E54;
    
    uint public constant tokensLocked = 3801e18;       // 3801 UniD 
    uint public constant unlockRate =   3801;          // 3801 UniD unlocking at a time
    uint public constant lockDuration = 185 days;       // Unlocking Possible after 186 days or 6 month
    uint public lastClaimedTime;
    uint public deployTime;

    
    constructor() public {
        deployTime = now;
        lastClaimedTime = now;
    }
    
    function claim() public onlyOwner {
        uint pendingUnlocked = getPendingUnlocked();
        uint contractBalance = UniD(tokenAddress).balanceOf(address(this));
        uint amountToSend = pendingUnlocked;
        if (contractBalance < pendingUnlocked) {
            amountToSend = contractBalance;
        }
        require(UniD(tokenAddress).transfer(owner, amountToSend), "Could not transfer Tokens.");
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
        UniD(_tokenAddr).transfer(_to, _amount);
    }

}