/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

// ----------------------------------------------------------------------------
// OXS Staking
// Symbol      : OXS
// Name        : OXSign
// Staking supply: 6,0000 (6 Thousand)
// Decimals    : 10
// ----------------------------------------------------------------------------



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 *
*/
 



// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------


contract OXS_Staking is Owned{
    
    using SafeMath for uint256;

    uint256 public totalRewards;
    uint256 public stakingRate = 25; // .25%
    uint256 public totalStakes;
    
    address public OXS = 0xD48a38BAD734A7c491E98367321f7abE79BB19A2;
    
    struct DepositedToken{
        uint256 activeDeposit;
        uint256 totalDeposits;
        uint256 startTime;
        uint256 pendingGains;
        uint256 lastClaimedDate;
        uint256 totalGained;
    }
    
    mapping(address => DepositedToken) users;
    
    event StakeStarted(uint256 indexed _amount);
    event RewardsCollected(uint256 indexed _rewards);
    event AddedToExistingStake(uint256 indexed tokens);
    event StakingStopped(uint256 indexed _refunded);
    

    function Stake(uint256 _amount) external{
        
        // add to stake
        _newDeposit(_amount);
        
        // transfer tokens from user to the contract balance
        require(IERC20(OXS).transferFrom(msg.sender, address(this), _amount));
        
        emit StakeStarted(_amount);
    }
    

    function AddToStake(uint256 _amount) external{
        
        _addToExisting(_amount);
        
        // move the tokens from the caller to the contract address
        require(IERC20(OXS).transferFrom(msg.sender,address(this), _amount));
        
        emit AddedToExistingStake(_amount);
    }
    
 
    function ClaimReward() external {
        require(PendingReward(msg.sender) > 0, "No pending rewards");
    
        uint256 _pendingReward = PendingReward(msg.sender);
        
        // Global stats update
        totalRewards = totalRewards.add(_pendingReward);
        
        // update the record
        users[msg.sender].totalGained = users[msg.sender].totalGained.add(_pendingReward);
        users[msg.sender].lastClaimedDate = now;
        users[msg.sender].pendingGains = 0;
        
        // mint more tokens inside token contract equivalent to _pendingReward
        require(IERC20(OXS).transfer(msg.sender, _pendingReward));
        
        emit RewardsCollected(_pendingReward);
    }
    

    function StopStaking() external {
        require(users[msg.sender].activeDeposit >= 0, "No active stake");
        uint256 _activeDeposit = users[msg.sender].activeDeposit;
        
        // update staking stats
            // check if we have any pending rewards, add it to previousGains var
            users[msg.sender].pendingGains = PendingReward(msg.sender);
            // update amount 
            users[msg.sender].activeDeposit = 0;
            // reset last claimed figure as well
            users[msg.sender].lastClaimedDate = now;
        
        // withdraw the tokens and move from contract to the caller
        require(IERC20(OXS).transfer(msg.sender, _activeDeposit));
        
        emit StakingStopped(_activeDeposit);
    }

    function PendingReward(address _caller) public view returns(uint256 _pendingRewardWeis){
        uint256 _totalStakingTime = now.sub(users[_caller].lastClaimedDate);
        
        uint256 _reward_token_second = ((stakingRate).mul(10 ** 21)).div(365 days); // added extra 10^21
        
        uint256 reward = ((users[_caller].activeDeposit).mul(_totalStakingTime.mul(_reward_token_second))).div(10 ** 23); // remove extra 10^21 // 10^2 are for 100 (%)
        
        return reward.add(users[_caller].pendingGains);
    }
    

    function ActiveStakeDeposit(address _user) external view returns(uint256 _activeDeposit){
        return users[_user].activeDeposit;
    }

    function YourTotalStakingTillToday(address _user) external view returns(uint256 _totalStaking){
        return users[_user].totalDeposits;
    }
    

    function LastStakedOn(address _user) external view returns(uint256 _unixLastStakedTime){
        return users[_user].startTime;
    }
    

    function TotalStakingRewards(address _user) external view returns(uint256 _totalEarned){
        return users[_user].totalGained;
    }
 
    function _newDeposit(uint256 _amount) internal{
        require(users[msg.sender].activeDeposit ==  0, "Already running, use funtion add to stake");

        users[msg.sender].pendingGains = PendingReward(msg.sender);
            
        users[msg.sender].activeDeposit = _amount;
        users[msg.sender].totalDeposits = users[msg.sender].totalDeposits.add(_amount);
        users[msg.sender].startTime = now;
        users[msg.sender].lastClaimedDate = now;
        

        totalStakes = totalStakes.add(_amount);
    }

       
    function _addToExisting(uint256 _amount) internal{
        
        require(users[msg.sender].activeDeposit > 0, "no running farming/stake");

            users[msg.sender].pendingGains = PendingReward(msg.sender);

            users[msg.sender].activeDeposit = users[msg.sender].activeDeposit.add(_amount);

            users[msg.sender].totalDeposits = users[msg.sender].totalDeposits.add(_amount);

            users[msg.sender].startTime = now;

            users[msg.sender].lastClaimedDate = now;
            

        totalStakes = totalStakes.add(_amount);
    }
}