/**
 *Submitted for verification at Etherscan.io on 2021-02-05
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------


contract PLS_Stake is Owned {
    using SafeMath for uint256;
    
    address public PLS;
    address public RW;
    
    uint256 private rewardPerPLS = 10000000000000000; // 0.01
    
    uint256 public  minStakingPeriod = 3 days;
    
    uint256 public  totalClaimedRewards;
    uint256 public  totalStaked;
    
    struct Account {
        uint256 stakedAmount;
        uint256 rewardsClaimed;
        uint256 pending;
        uint256 stakeDate;
    }
    
    mapping(address => Account) public stakers;
    
    event RewardClaimed(address claimer, uint256 reward);
    event UnStaked(address claimer, uint256 stakedTokens);
    event Staked(address staker, uint256 tokens);
    
    
    constructor(address _tokenAddress, address _rewardsWallet) public {
        PLS = _tokenAddress;
        RW = _rewardsWallet;
    }
    
    // ------------------------------------------------------------------------
    // Start the staking or add to existing stake
    // user must approve the staking contract to transfer tokens before staking
    // @param _amount number of tokens to stake
    // ------------------------------------------------------------------------
    function STAKE_PLS(uint256 _amount) external {

        totalStaked = totalStaked.add(_amount);
        
        // record it in contract's storage
        stakers[msg.sender].stakedAmount = stakers[msg.sender].stakedAmount.add(_amount); // add to the stake or fresh stake
        stakers[msg.sender].stakeDate = block.timestamp; // update the stake date
        
        // transfer the tokens from caller to staking contract
        IERC20(PLS).transferFrom(msg.sender, address(this), _amount);
        
        emit Staked(msg.sender, _amount);
    }
    
    // ------------------------------------------------------------------------
    // Claim reward
    // @required user must be a staker
    // @required must be claimable
    // ------------------------------------------------------------------------
    function ClaimReward() public {
        
        require(block.timestamp > stakers[msg.sender].stakeDate.add(minStakingPeriod), "claim date has not reached");
        
        uint256 pendingReward = pendingReward(msg.sender);
        uint256 claimableReward = claimableReward(msg.sender, pendingReward);
        
        // add claimed reward to global stats
        totalClaimedRewards = totalClaimedRewards.add(claimableReward);
        
        // add the reward to total claimed rewards
        stakers[msg.sender].rewardsClaimed = stakers[msg.sender].rewardsClaimed.add(claimableReward);
        
        // transfer the reward tokens
        IRW(RW).sendRewards(msg.sender, claimableReward);
         
        emit RewardClaimed(msg.sender, claimableReward);
    }
    
    // ------------------------------------------------------------------------
    // Unstake the tokens
    // @required user must be a staker
    // @required must be claimable
    // ------------------------------------------------------------------------
    function UnStake() public {
        uint256 stakedAmount = stakers[msg.sender].stakedAmount;
        require(stakedAmount > 0, "insufficient stake");

        totalStaked = totalStaked.sub(stakedAmount);
        stakers[msg.sender].pending = pendingReward(msg.sender);
        
        stakers[msg.sender].stakedAmount = 0;
        
        // transfer staked tokens
        IERC20(PLS).transfer(msg.sender, stakedAmount);
        
        emit UnStaked(msg.sender, stakedAmount);
    }
    
    // ------------------------------------------------------------------------
    // Query to get the pending reward
    // ------------------------------------------------------------------------
    function pendingReward(address user) public view returns (uint256 _pendingReward) {
        uint256 totalDays = (block.timestamp.sub(stakers[user].stakeDate)).div(1 days);
    
        uint256 reward = stakers[user].stakedAmount.mul(rewardPerPLS).mul(totalDays); 
        reward =  reward.sub(stakers[user].rewardsClaimed);
        return reward.add(stakers[user].pending);
    }
    
    // ------------------------------------------------------------------------
    // This will give how much of the pending reward is claimable by user
    // according to the current date
    // ------------------------------------------------------------------------
    function claimableReward(address user, uint256 _pendingReward) public view returns(uint256) {
        uint256 totalDays = (block.timestamp.sub(stakers[user].stakeDate)).div(1 days);
        if(totalDays < 5){
            return onePercent(_pendingReward).mul(40); //40% of the pending reward
        } else if(totalDays < 7){
            return onePercent(_pendingReward).mul(80); // 80% of the pending reward
        }
        return _pendingReward;
    }
    
    // ------------------------------------------------------------------------
    // Private function to calculate 1% percentage
    // ------------------------------------------------------------------------
    function onePercent(uint256 _tokens) private pure returns (uint256) {
        uint256 roundValue = _tokens.ceil(100);
        uint onePercentofTokens = roundValue.mul(100).div(100 * 10**uint(2));
        return onePercentofTokens;
    }
    
}