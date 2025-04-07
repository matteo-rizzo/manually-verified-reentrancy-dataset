/**
 *Submitted for verification at Etherscan.io on 2021-02-17
*/

pragma solidity 0.6.12;







contract TKOStaking is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint amount);
    
    // TKO token contract address
    address public constant tokenAddress = 0xcA1024B60b00bbd8b5c278F3BBD65B40AAB4e837;
    // Fee collect address
    address public constant feeAddress = 0x59BA4C88129D6178657fC039D6f70a8873628826;
    // Fee collect address
    address public constant TKOFoundationWallet = 0x08f3ec531A6817960D5a641bd215459D4EcdDC06;
    
    uint public totalClaimedRewards = 0;
    // reward rate 150% per day
    uint public  rewardRate = 15000;
    uint public constant rewardInterval = 1 days;
    // Staking total time
    uint public stakingTotalTime;
    // transaction fee 0.02 percent
    uint public stakingFeeRate = 2;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public stakingTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    
    constructor(address owner) public {
    stakingTotalTime = now + 180 days;
    transferOwnership(owner);
    }
    
    function stakingPoolStop() public onlyOwner{
        require(now >= stakingTotalTime,"Pool is not over yet!");
            uint256 balance = Token(tokenAddress).balanceOf(address(this));
            require(Token(tokenAddress).transfer(TKOFoundationWallet, balance), "Could not transfer tokens.");
    }
    
    function updateRewardRate(uint _newRewardRate) public onlyOwner{
        rewardRate = _newRewardRate; 
    }
      function updateFeeRate(uint _newFeeRate) public onlyOwner{
        stakingFeeRate = _newFeeRate; 
    }
  
   function updateStakingTime(uint _timeInDays) public onlyOwner{
        stakingTotalTime = now + _timeInDays.mul(86400); 
    }
    
    function updateAccount(address account) private {
        uint pendingRewards = getPendingReward(account);
        if (pendingRewards > 0) {
            require(Token(tokenAddress).transfer(account, pendingRewards), "Could not transfer tokens.");
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingRewards);
            totalClaimedRewards = totalClaimedRewards.add(pendingRewards);
            emit RewardsTransferred(account, pendingRewards);
        }
        lastClaimedTime[account] = now;
    }
    
    function getPendingReward(address _holder) public view returns (uint) {
        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;

        uint timeDiff = now.sub(lastClaimedTime[_holder]);
        uint stakedAmount = depositedTokens[_holder];
        
        uint pendingDivs = stakedAmount
                            .mul(rewardRate)
                            .mul(timeDiff)
                            .div(rewardInterval)
                            .div(1e4);
            
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint) {
        return holders.length();
    }
    
    function stake(uint amountToStake) public {
        require(now < stakingTotalTime,"Staking pool time is ended");
        require(amountToStake > 0, "Cannot deposit 0 Tokens");
        require(Token(tokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        updateAccount(msg.sender);
        
        uint fee = amountToStake.mul(stakingFeeRate).div(1e4);
        uint amountAfterFee = amountToStake.sub(fee);
        require(Token(tokenAddress).transfer(feeAddress, fee), "Could not transfer deposit fee.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountAfterFee);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            stakingTime[msg.sender] = now;
        }
    }
    
    function unstake(uint amountToWithdraw) public {
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        uint fee = amountToWithdraw.mul(stakingFeeRate).div(1e4);
        uint amountAfterFee = amountToWithdraw.sub(fee);
        require(Token(tokenAddress).transfer(feeAddress, fee), "Could not transfer deposit fee.");
        
        updateAccount(msg.sender);
        
        require(Token(tokenAddress).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    function claimReward() public {
        updateAccount(msg.sender);
    }
    
}