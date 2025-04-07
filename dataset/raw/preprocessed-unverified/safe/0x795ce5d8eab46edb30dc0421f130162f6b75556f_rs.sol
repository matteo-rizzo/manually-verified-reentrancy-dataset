// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

/**
 * @title Ownership Contract
 */


/**
 * @title Interface of DefiBids
 */
 


contract StakingPoolFunds is Ownable {
    
    using SafeMath for uint256;

    address public divPoolAddress;
    address public constant bidsTokenAddress = 0x912B38134F395D1BFAb4C6F9db632C31667ACF98;
    
    modifier onlyDivPool() {
        require(divPoolAddress == msg.sender, "Ownable: caller is not the authorized.");
        _;
    }
    
    /*
        Fallback function. It just accepts incoming ETH
    */
    function () payable external {}
    
    function requestDividendRewards() external onlyDivPool returns(uint256 ethRewards, uint256 bidsRewards){
        
        bidsRewards = BIDSInterface(bidsTokenAddress).balanceOf(address(this));
        
        // Calculate remaining amount to be tranferred at staking portal
        uint256 BURN_RATE = BIDSInterface(bidsTokenAddress).BURN_RATE();
        bool isStakingActive = BIDSInterface(bidsTokenAddress).isStackingActive();
        
        uint256 remainingAmount = bidsRewards;
        if(BURN_RATE > 0){
            uint256 burnAmount = bidsRewards.mul(BURN_RATE).div(1000);
            remainingAmount = remainingAmount.sub(burnAmount);

        }
        
        if(isStakingActive){
            uint256 amountToStakePool = bidsRewards.mul(10).div(1000);
            remainingAmount = remainingAmount.sub(amountToStakePool);
        }
        
        if(bidsRewards > 0){
            BIDSInterface(bidsTokenAddress).transfer(msg.sender, bidsRewards);
        }
        
        ethRewards = address(this).balance;
        if(ethRewards > 0){
            msg.sender.transfer(ethRewards);
        }
        
        return (ethRewards, remainingAmount);
        
    }
    
    function availableDividendRewards() external view returns(uint256 ethRewards, uint256 bidsRewards){
        
        bidsRewards = BIDSInterface(bidsTokenAddress).balanceOf(address(this));
        ethRewards = address(this).balance;
        
         // Calculate remaining amount to be tranferred at staking portal
        uint256 BURN_RATE = BIDSInterface(bidsTokenAddress).BURN_RATE();
        bool isStakingActive = BIDSInterface(bidsTokenAddress).isStackingActive();
        
        uint256 remainingAmount = bidsRewards;
        if(BURN_RATE > 0){
            uint256 burnAmount = bidsRewards.mul(BURN_RATE).div(1000);
            remainingAmount = remainingAmount.sub(burnAmount);
        }
        
        if(isStakingActive){
            uint256 amountToStakePool = bidsRewards.mul(10).div(1000);
            remainingAmount = remainingAmount.sub(amountToStakePool);
        }
        
        return (ethRewards, remainingAmount);
        
    }
    
    function setDivPoolAddress(address _a) public onlyOwner returns(bool){
        divPoolAddress = _a;
        return true;
    }
    
}