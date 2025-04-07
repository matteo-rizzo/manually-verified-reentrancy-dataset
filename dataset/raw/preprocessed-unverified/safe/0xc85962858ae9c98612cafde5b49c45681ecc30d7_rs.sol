/**
 *Submitted for verification at Etherscan.io on 2020-07-13
*/

pragma solidity ^0.6.0;

contract TokenVault {
    
    ERC20 constant ulluToken = ERC20(0x5313E18463Cf2F4b68b392a5b11f94dE5528D01d);
    
    address blobby = msg.sender;
    uint256 public migrationLock;
    address public migrationRecipient;
    function startUlluMigration(address recipient) external {
        require(msg.sender == blobby);
        migrationLock = now + 171 days;
        migrationRecipient = recipient;
    }
    function processMigration() external {
        require(msg.sender == blobby);
        require(migrationRecipient != address(0));
        require(now > migrationLock);
        
        uint256 ulluBalance = ulluToken.balanceOf(address(this));
        ulluToken.transfer(migrationRecipient, ulluBalance);
    }
    function getBlobby() public view returns (address){
        return blobby;
    }
    function getUlluBalance() public view returns (uint256){
        return ulluToken.balanceOf(address(this));
    }
    
}

