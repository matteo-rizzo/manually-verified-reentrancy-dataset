/**
 *Submitted for verification at Etherscan.io on 2020-07-23
*/

/**

 * GearProtocol's Dev fund Vault
 
 * Smart contract to lockup dev fund for a period of 6 months. 

 * Official Website: 
https://GearProtocol.com
 
 */




pragma solidity ^0.6.0;


contract GearDevVault {
    
    ERC20 constant GearToken = ERC20(0xBD753A8D3bE45F4772145D75E28014a333B705Fb);
    
    address owner = msg.sender;
    
    
    uint256 public LockPeriod;
    address public UnlockRecipient;
    
    

// Function allows GEAR token to be unlocked, after 6 months lockup period 


    function startUnlock(address recipient) external {
        require(msg.sender == owner);
        LockPeriod = now + 180 days;
        UnlockRecipient = recipient;
    }
    
    
// Transfer token to dev, assuming the 6 months lockup has passed -preventing abuse.


    function Unlock() external {
        require(msg.sender == owner);
        require(UnlockRecipient != address(0));
        require(now > LockPeriod);
        
        uint256 GearBalance = GearToken.balanceOf(address(this));
        GearToken.transfer(UnlockRecipient, GearBalance);
    }  
    
}



