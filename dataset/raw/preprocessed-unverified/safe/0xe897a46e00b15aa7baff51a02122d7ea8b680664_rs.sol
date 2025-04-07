/**
 *Submitted for verification at Etherscan.io on 2020-07-13
*/

/* Libertas Liquidity vault */
pragma solidity ^0.5.13;

contract LiquidityVault {
    
    ERC20 constant liquidityToken = ERC20(0x9Ae5A3E252933b7Ff2D88C91b0ab4E1Be1c4c2C8);
    
    address blobby = msg.sender;
    uint256 public lastTradingFeeDistribution;
    
    uint256 public migrationLock;
    address public migrationRecipient;  
    

    /* Call to begin unlocking */
    function startLiquidityMigration(address recipient) external {
        require(msg.sender == blobby);
        migrationLock = now + 90 days;
        migrationRecipient = recipient;
    }
    
    
     /* Moves liquidity to new location, assuming the 14 days lockup has passed -preventing abuse. */
    function processMigration() external {
        require(msg.sender == blobby);
        require(migrationRecipient != address(0));
        require(now > migrationLock);
        
        uint256 liquidityBalance = liquidityToken.balanceOf(address(this));
        liquidityToken.transfer(migrationRecipient, liquidityBalance);
    }   
}

