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





contract Pool2 is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint amount);
    
    // yfilend token contract address
    address public tokenAddress;
    address public liquiditytoken1;
    
    // reward rate % per year
    uint public rewardRate = 5000;
    uint public rewardInterval = 365 days;
    
    // staking fee percent
    uint public stakingFeeRate = 0;
    
    // unstaking fee percent
    uint public unstakingFeeRate = 0;
    
    // unstaking possible Time
    uint public PossibleUnstakeTime = 48 hours;
    
    uint public totalClaimedRewards = 0;
    uint private FundedTokens;
    
    
    bool public stakingStatus = false;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public stakingTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    
/*=============================ADMINISTRATIVE FUNCTIONS ==================================*/

    function setTokenAddresses(address _tokenAddr, address _liquidityAddr) public onlyOwner returns(bool){
     require(_tokenAddr != address(0) && _liquidityAddr != address(0), "Invalid addresses format are not supported");
     tokenAddress = _tokenAddr;
     liquiditytoken1 = _liquidityAddr;
    
    }
    
    function stakingFeeRateSet(uint _stakingFeeRate, uint _unstakingFeeRate) public onlyOwner returns(bool){
     stakingFeeRate = _stakingFeeRate;
     unstakingFeeRate = _unstakingFeeRate;
    
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
        require(tokenAddress != address(0) && liquiditytoken1 != address(0), "Interracting token addresses are not yet configured");
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
        }
        lastClaimedTime[account] = now;
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
    
    function place(uint amountToStake) public {
        require(stakingStatus == true, "Staking is not yet initialized");
        require(amountToStake > 0, "Cannot deposit 0 Tokens");
        require(Token(liquiditytoken1).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        updateAccount(msg.sender);
        
        uint fee = amountToStake.mul(stakingFeeRate).div(1e4);
        uint amountAfterFee = amountToStake.sub(fee);
        require(Token(liquiditytoken1).transfer(admin, fee), "Could not transfer deposit fee.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountAfterFee);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            stakingTime[msg.sender] = now;
        }
    }
    
    function lift(uint amountToWithdraw) public {
        
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        require(now.sub(stakingTime[msg.sender]) > PossibleUnstakeTime, "You have not staked for a while yet, kindly wait a bit more");
        
        updateAccount(msg.sender);
        
        uint fee = amountToWithdraw.mul(unstakingFeeRate).div(1e4);
        uint amountAfterFee = amountToWithdraw.sub(fee);
        
        require(Token(liquiditytoken1).transfer(admin, fee), "Could not transfer withdraw fee.");
        require(Token(liquiditytoken1).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    function claimYields() public {
        updateAccount(msg.sender);
    }
    
    function getFundedTokens() public view returns (uint) {
        if (totalClaimedRewards >= FundedTokens) {
            return 0;
        }
        uint remaining = FundedTokens.sub(totalClaimedRewards);
        return remaining;
    }
    
   
}