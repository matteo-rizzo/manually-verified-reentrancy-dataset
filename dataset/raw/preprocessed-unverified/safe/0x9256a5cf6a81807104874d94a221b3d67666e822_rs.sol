/**
 *Submitted for verification at Etherscan.io on 2020-10-29
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: BSD-3-Clause

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */





contract PoolA is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint amount);
    event Upline(address indexed addr, address indexed upline);
    event RewardAllocation(address indexed ref, address indexed _addr, uint bonus);
    
    
    address public tokenAddress;
    
    // reward rate % per year
    uint public rewardRate = 60000;
    uint public rewardInterval = 365 days;
    
    // staking fee percent
    uint public stakingFeeRate = 0;
    
    // unstaking fee percent
    uint public unstakingFeeRate = 0;
    
    // unstaking possible Time
    uint public PossibleUnstakeTime = 24 hours;
    
    uint public totalClaimedRewards = 0;
    uint private FundedTokens;
    
    
    bool public stakingStatus = false;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public stakingTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    mapping (address => address) public referer;
    mapping (address => uint) public referrals;
    mapping (address => uint) public rewardBonuses;
    uint ref_bonus = 1;
    
    
/*=============================ADMINISTRATIVE FUNCTIONS ==================================*/

    function setTokenAddresses(address _tokenAddr) public onlyOwner returns(bool){
     require(_tokenAddr != address(0), "Invalid addresses format are not supported");
     tokenAddress = _tokenAddr;
    
    }
    
    function stakingFeeRateSet(uint _stakingFeeRate, uint _unstakingFeeRate) public onlyOwner returns(bool){
     stakingFeeRate = _stakingFeeRate;
     unstakingFeeRate = _unstakingFeeRate;
    
    }
    
     function refSet(uint _value) public onlyOwner returns(bool){
     ref_bonus = _value;
    
    }
     
     function rewardRateSet(uint _rewardRate) public onlyOwner returns(bool){
     rewardRate = _rewardRate;
    
     }
     
     function StakingReturnsAmountSet(uint _poolreward) public onlyOwner returns(bool){
     FundedTokens = _poolreward;
    
     }
     
     
    function possibleUnstakeTimeSet(uint _possibleUnstakeTime) public onlyOwner returns(bool){
        
     PossibleUnstakeTime = _possibleUnstakeTime;
    
     }
     
    function rewardIntervalSet(uint _rewardInterval) public onlyOwner returns(bool){
        
     rewardInterval = _rewardInterval;
    
     }
     
     
    function allowStaking(bool _status) public onlyOwner returns(bool){
        require(tokenAddress != address(0), "Interracting token address are not yet configured");
        stakingStatus = _status;
    }
    
    function transferAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        if (_tokenAddr == tokenAddress) {
            if (_amount > getFundedTokens()) {
                revert();
            }
            totalClaimedRewards = totalClaimedRewards.add(_amount);
        }
        Token(_tokenAddr).transfer(_to, _amount);
    }
    
    
    function updateAccount(address account) private {
        
        uint unclaimedDivs = getUnclaimedDivs(account);
        if (unclaimedDivs > 0) {
            require(Token(tokenAddress).transfer(account, unclaimedDivs), "Could not transfer tokens.");
            totalEarnedTokens[account] = totalEarnedTokens[account].add(unclaimedDivs);
            totalClaimedRewards = totalClaimedRewards.add(unclaimedDivs);
            emit RewardsTransferred(account, unclaimedDivs);
            
            _refPayout(account, unclaimedDivs);
        }
        
        lastClaimedTime[account] = now;
        
    }
    
    function updateRef(address account) private {
        uint unclaimedRef = rewardBonuses[account];
        
        if (unclaimedRef > 0) {
            require(Token(tokenAddress).transfer(account, unclaimedRef), "Could not transfer tokens.");
            rewardBonuses[account] = rewardBonuses[account].sub(unclaimedRef);
        }
        
    }
    
    function getUnclaimedDivs(address _holder) public view returns (uint) {
        
        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;

        uint timeDiff = now.sub(lastClaimedTime[_holder]);
        
        uint stakedAmount = depositedTokens[_holder];
        
        uint unclaimedDivs = stakedAmount
                            .mul(rewardRate)
                            .mul(timeDiff)
                            .div(rewardInterval)
                            .div(1e4);
            
        return unclaimedDivs;
    }
    
    function getNumberOfHolders() public view returns (uint) {
        return holders.length();
    }
    
    
    function deposit(uint amountToStake, address _upline) public{
        
        _setUpline(msg.sender, _upline);
        _deposit(amountToStake);
        
    }
    
   
    
    function _deposit(uint amountToStake) internal {
        
        require(stakingStatus == true, "Staking is not yet initialized");
        require(amountToStake > 0, "Cannot deposit 0 Tokens");
        require(referer[msg.sender] != address(0) || msg.sender == admin, "No upline, you need an upline"); 
        require(Token(tokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        updateAccount(msg.sender);
        
        uint fee = amountToStake.mul(stakingFeeRate).div(1e4);
        uint amountAfterFee = amountToStake.sub(fee);
        require(Token(tokenAddress).transfer(admin, fee), "Could not transfer deposit fee.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountAfterFee);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            stakingTime[msg.sender] = now;
        }
    }
    
    function withdraw(uint amountToWithdraw) public {
        
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        require(now.sub(stakingTime[msg.sender]) > PossibleUnstakeTime, "You have not staked for a while yet, kindly wait a bit more");
        
        updateAccount(msg.sender);
        
        uint fee = amountToWithdraw.mul(unstakingFeeRate).div(1e4);
        uint amountAfterFee = amountToWithdraw.sub(fee);
        
        require(Token(tokenAddress).transfer(admin, fee), "Could not transfer withdraw fee.");
        require(Token(tokenAddress).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    function claim() public {
        updateAccount(msg.sender);
        claimRef();
    }
    
    
    
    function claimRef() public {
        updateRef(msg.sender);
    }
 
    
    
    function getFundedTokens() public view returns (uint) {
        if (totalClaimedRewards >= FundedTokens) {
            return 0;
        }
        uint remaining = FundedTokens.sub(totalClaimedRewards);
        return remaining;
    }
    
    
    
    function _setUpline(address _addr, address _upline) public {
        
        if(referer[_addr] == address(0) && _upline != _addr && (stakingTime[_upline] > 0 || _upline == admin)) {
       
            referer[_addr] = _upline; 
            referrals[_upline]++; 

            emit Upline(_addr, _upline);

        }
        
    }
 
 
    function _refPayout(address _addr, uint256 _amount) private {
        
        address ref = referer[_addr];
        if(ref != address(0)){
            
            uint256 bonus = _amount * ref_bonus / 100;
            rewardBonuses[ref] += bonus;
            emit RewardAllocation(ref, _addr, bonus);
            
        }
        
    }
    
    
   
}