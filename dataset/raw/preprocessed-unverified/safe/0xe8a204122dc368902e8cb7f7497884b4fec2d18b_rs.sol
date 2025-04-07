/**
 *Submitted for verification at Etherscan.io on 2021-09-28
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;





contract MultiStaking {
    address public stakingRewardsAddress = 0x2a16bBD6f197BF245EbB23EC4664c8A354Ff5f1F;
    
    function stakeTransferWithBalance(IERC20 token, uint256[] memory amounts, address[] memory userAddresses, uint256[] memory lockingPeriods) external {
        IStakingRewards stakingRewardsContract = IStakingRewards(stakingRewardsAddress);
        uint256 totalBalance = 0;
        
        for (uint256 i = 0; i < userAddresses.length; i++) {
            totalBalance = totalBalance + amounts[i];
        }
        
        require(token.transferFrom(msg.sender, address(this), totalBalance));
        require(token.approve(stakingRewardsAddress, totalBalance));
        
        for (uint256 i = 0; i < userAddresses.length; i++) {
            stakingRewardsContract.stakeTransferWithBalance(amounts[i], userAddresses[i], lockingPeriods[i]);
        }
    }
    
}