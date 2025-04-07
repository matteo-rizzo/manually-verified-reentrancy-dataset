/**
 *Submitted for verification at Etherscan.io on 2020-08-04
*/

pragma solidity ^0.6.0;


/**
 * 
 * UniPower's Liquidity Vault
 * 
 * Simple smart contract to decentralize the uniswap liquidity, providing proof of liquidity indefinitely.
 * For more info visit: https://unipower.network 
 * 
 */
contract LiquidityVault {
    
    ERC20 constant garlic = ERC20(0xB256297F2Dec36719a922024f6f08DebDB3e298f);
    ERC20 constant liquidityToken = ERC20(0x39549f5D4F21Fc450B64Bd27586F528a5Bf0f398);
    
    address cash = msg.sender;
    uint256 public lastTradingFeeDistribution;
    uint256 public migrationLock;
    address public migrationRecipient;
    
 
    function distributeWeekly(address recipient) external {
        uint256 liquidityBalance = liquidityToken.balanceOf(address(this));
        require(lastTradingFeeDistribution + 7 days < now); // Max once a day
        require(msg.sender == cash);
        liquidityToken.transfer(recipient, (liquidityBalance / 100));
        lastTradingFeeDistribution = now;
    } 
    
    
    function startLiquidityMigration(address recipient) external {
        require(msg.sender == cash);
        migrationLock = now + 100 days;
        migrationRecipient = recipient;
    }
    
    
    function processMigration() external {
        require(msg.sender == cash);
        require(migrationRecipient != address(0));
        require(now > migrationLock);
        
        uint256 liquidityBalance = liquidityToken.balanceOf(address(this));
        liquidityToken.transfer(migrationRecipient, liquidityBalance);
    }
    
    
    
    function getcash() public view returns (address){
        return cash;
    }
    function getLiquidityBalance() public view returns (uint256){
        return liquidityToken.balanceOf(address(this));
    }
    
}

