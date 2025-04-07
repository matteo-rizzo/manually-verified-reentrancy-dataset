/**
 *Submitted for verification at Etherscan.io on 2021-02-06
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


contract IFY_Stake is Owned {
    using SafeMath for uint256;
    
    IERC20 public IFY;
    
    uint256 public  totalClaimedRewards;
    uint256 public  totalStaked;
    
    struct Account{
        uint256 stakedAmount;
        uint256 rewardsClaimed;
        uint256 pending;
        uint256 stakingOpt;
        uint256 stakingEndDate;
        uint256 rewardPercentage;
    }
    
    mapping(address => Account) public stakers;
    
    struct StakingOpts{
        uint256 stakingPeriod;
        uint256 stakingPercentage;
    }
    
    StakingOpts[4] public stakingOptions;
    
    event RewardClaimed(address claimer, uint256 reward);
    event UnStaked(address claimer, uint256 stakedTokens);
    event Staked(address staker, uint256 tokens, uint256 stakingOption);
    
    constructor() public {
        /*
        1 week: 5% ROI
        1 month: 25% ROI
        3 months: 100% ROI
        6 months: 245% ROI
        */
        stakingOptions[0].stakingPeriod = 1 weeks;
        stakingOptions[0].stakingPercentage = 5;
        
        stakingOptions[1].stakingPeriod = 30 days; // 1 month
        stakingOptions[1].stakingPercentage = 25;
        
        stakingOptions[2].stakingPeriod = 90 days;
        stakingOptions[2].stakingPercentage = 100;
        
        stakingOptions[3].stakingPeriod = 180 days;
        stakingOptions[3].stakingPercentage = 245;
        
        owner = 0xa97F07bc8155f729bfF5B5312cf42b6bA7c4fCB9;
    }
    
    // ------------------------------------------------------------------------
    // Set Token Address
    // only Owner can use it
    // @param _tokenAddress the address of token
    // -----------------------------------------------------------------------
    function setTokenAddress(address _tokenAddress) external onlyOwner{
        IFY = IERC20(_tokenAddress);
    }
    
    // ------------------------------------------------------------------------
    // Start the staking or add to existing stake
    // user must approve the staking contract to transfer tokens before staking
    // @param _amount number of tokens to stake
    // ------------------------------------------------------------------------
    function STAKE(uint256 _amount, uint256 optionNumber) external {
        require(optionNumber >= 1 && optionNumber <= 4, "Invalid option choice");
        require(stakers[msg.sender].stakedAmount == 0, "Your stake is already running");
        
        // no tax will be applied upon staking IFY
        totalStaked = totalStaked.add(_amount);
        
        // record it in contract's storage
        stakers[msg.sender].stakedAmount = stakers[msg.sender].stakedAmount.add(_amount); // add to the stake or fresh stake
        stakers[msg.sender].stakingOpt = optionNumber;
        stakers[msg.sender].stakingEndDate = block.timestamp.add(stakingOptions[optionNumber.sub(1)].stakingPeriod);
        stakers[msg.sender].rewardPercentage = stakingOptions[optionNumber.sub(1)].stakingPercentage;
        
        emit Staked(msg.sender, _amount, optionNumber);
        
        // transfer the tokens from caller to staking contract
        require(IFY.transferFrom(msg.sender, address(this), _amount));
    }
    
    function Exit() external{
        if(pendingReward(msg.sender) > 0)
            ClaimReward();
        if(stakers[msg.sender].stakedAmount > 0)
            UnStake();
    }
    
    // ------------------------------------------------------------------------
    // Claim reward
    // @required user must be a staker
    // @required must be claimable
    // ------------------------------------------------------------------------
    function ClaimReward() public {
        require(pendingReward(msg.sender) > 0, "nothing pending to claim");
        require(block.timestamp > stakers[msg.sender].stakingEndDate, "claim date has not reached");
        
        uint256 reward = pendingReward(msg.sender);
        
        // add claimed reward to global stats
        totalClaimedRewards = totalClaimedRewards.add(reward);
        
        // add the reward to total claimed rewards
        stakers[msg.sender].rewardsClaimed = stakers[msg.sender].rewardsClaimed.add(reward);
        
        emit RewardClaimed(msg.sender, reward);
        
        // transfer the reward tokens
        require(IFY.transfer(msg.sender, reward), "reward transfer failed");
    }
    
    // ------------------------------------------------------------------------
    // Unstake the tokens
    // @required user must be a staker
    // @required must be claimable
    // ------------------------------------------------------------------------
    function UnStake() public {
        uint256 stakedAmount = stakers[msg.sender].stakedAmount;
        require(stakedAmount > 0, "insufficient stake");
        require(block.timestamp > stakers[msg.sender].stakingEndDate, "staking period has not ended");
        
        totalStaked = totalStaked.sub(stakedAmount);
        
        if(pendingReward(msg.sender) > 0)
            stakers[msg.sender].pending = pendingReward(msg.sender);
        
        stakers[msg.sender].stakedAmount = 0;
        
        emit UnStaked(msg.sender, stakedAmount);
        
        // transfer staked tokens
        require(IFY.transfer(msg.sender, stakedAmount));
    }
    
    // ------------------------------------------------------------------------
    // Query to get the pending reward
    // ------------------------------------------------------------------------
    function pendingReward(address user) public view returns(uint256 _pendingReward){
        uint256 reward = (onePercent(stakers[user].stakedAmount)).mul(stakers[user].rewardPercentage);
        reward =  reward.sub(stakers[user].rewardsClaimed);
        return reward.add(stakers[msg.sender].pending);
    }
    
    // ------------------------------------------------------------------------
    // Private function to calculate 1% percentage
    // ------------------------------------------------------------------------
    function onePercent(uint256 _tokens) private pure returns (uint256){
        uint256 roundValue = _tokens.ceil(100);
        uint onePercentofTokens = roundValue.mul(100).div(100 * 10**uint(2));
        return onePercentofTokens;
    }
    
}