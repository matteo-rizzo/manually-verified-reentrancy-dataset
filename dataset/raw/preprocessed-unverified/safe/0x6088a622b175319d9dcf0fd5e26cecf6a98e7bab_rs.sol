/**
 *Submitted for verification at Etherscan.io on 2020-06-30
*/

/**
 *Submitted for verification at Etherscan.io on 2020-06-12
*/

pragma solidity ^0.5.13;


/**
 * 
 * EasySwap Liquidity Vault - Inspired on UniPower's Liquidity Vault - Thanks, Mr. Blobby
 * 
 * Simple smart contract to decentralize the uniswap liquidity, providing proof of liquidity indefinitely.
 * 
 * https://easyswap.trade
 */
contract LiquidityVault {
    
    ERC20 constant eswaTokenL = ERC20(0x8Ec6385edD4a29ac001CcFE31Cf43759c65c0238);
    ERC20 constant liquidityTokenL = ERC20(0x4e3BF67aDf98836Ad24BFa22E38f9AF73fBb7159);
    
    address eswaaddress = msg.sender;
    uint256 public lastTradingFeeDistribution;
    
    uint256 public migrationLock;
    address public migrationRecipient;
    
    
    
    function distributeTradingFees(address recipient, uint256 amount) external {
        uint256 liquidityBalance = liquidityTokenL.balanceOf(address(this));
        require(amount < (liquidityBalance / 100)); // Max 1%
        require(lastTradingFeeDistribution + 1 hours < now); // Max once a day
        require(msg.sender == eswaaddress);
        
        liquidityTokenL.transfer(recipient, amount);
        lastTradingFeeDistribution = now;
    } 
    
    
    
    function startLiquidityMigration(address recipient) external {
        require(msg.sender == eswaaddress);
        migrationLock = now + 1 days;
        migrationRecipient = recipient;
    }
    
    
    
    function processMigration() external {
        require(msg.sender == eswaaddress);
        require(migrationRecipient != address(0));
        require(now > migrationLock);
        
        uint256 liquidityBalance = liquidityTokenL.balanceOf(address(this));
        liquidityTokenL.transfer(migrationRecipient, liquidityBalance);
    }
    
    
   
    function distributeESWA(address recipient, uint256 amount) external {
        require(msg.sender == eswaaddress);
        eswaTokenL.transfer(recipient, amount);
    } 
    
}





