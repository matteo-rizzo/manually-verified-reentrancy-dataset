/**
 *Submitted for verification at Etherscan.io on 2020-07-11
*/

pragma solidity ^0.5.17;

 /*
 * 
 * Ruletka's Liquidity Vault
 * 
 * Simple smart contract to decentralize the uniswap liquidity, providing proof of liquidity indefinitely.
 * Original smart contract: MrBlobby (UniPower), modified by George.
 * https://ruletka.fun
 * 
 */
 
contract Vault {
    
    ERC20 constant liquidityToken = ERC20(0x056bD5A0edeE2bd5ba0B1A1671cf53aA22e03916);
    
    address owner = msg.sender;
    
    uint256 public migrationLock;
    address public migrationRecipient;

    event liquidityMigrationStarted(address recipient, uint256 unlockTime);
    

    /**
     * This function allows liquidity to be moved, after a 14 days lockup -preventing abuse.
     */
    function startLiquidityMigration(address recipient) external {
        require(msg.sender == owner);
        migrationLock = now + 14 days;
        migrationRecipient = recipient;
        emit liquidityMigrationStarted(recipient, migrationLock);
    }
    
    
    /**
     * Moves liquidity to new location, assuming the 14 days lockup has passed -preventing abuse.
     */
    function processMigration() external {
        require(msg.sender == owner);
        require(migrationRecipient != address(0));
        require(now > migrationLock);
        
        uint256 liquidityBalance = liquidityToken.balanceOf(address(this));
        liquidityToken.transfer(migrationRecipient, liquidityBalance);
    }
    
    
}




