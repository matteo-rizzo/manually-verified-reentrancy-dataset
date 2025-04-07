/**
 *Submitted for verification at Etherscan.io on 2020-10-08
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: BSD-3-Clause
//BSD Zero Clause License: "SPDX-License-Identifier: <SPDX-License>"

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
 * 
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * 
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */





contract VAPEPOOL2 is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint amount);
    
    //token contract addresses
    address public VAPEAddress;
    address public LPTokenAddress;
    
    // reward rate % per year
    uint public rewardRate = 119880;
    uint public rewardInterval = 365 days;
    
    //farming fee in percentage
    uint public farmingFeeRate = 0;
    
    //unfarming fee in percentage
    uint public unfarmingFeeRate = 0;
    
    //unfarming possible Time
    uint public PossibleUnfarmTime = 48 hours;
    
    uint public totalClaimedRewards = 0;
    uint private ToBeFarmedTokens;
    
    
    bool public farmingStatus = false;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public farmingTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    
/*=============================ADMINISTRATIVE FUNCTIONS ==================================*/

    function setTokenAddresses(address _tokenAddr, address _liquidityAddr) public onlyOwner returns(bool){
     require(_tokenAddr != address(0) && _liquidityAddr != address(0), "Invalid addresses format are not supported");
     VAPEAddress = _tokenAddr;
     LPTokenAddress = _liquidityAddr;
        
    }
    
    function farmingFeeRateSet(uint _farmingFeeRate, uint _unfarmingFeeRate) public onlyOwner returns(bool){
     farmingFeeRate = _farmingFeeRate;
     unfarmingFeeRate = _unfarmingFeeRate;
    
     }
     
     function rewardRateSet(uint _rewardRate) public onlyOwner returns(bool){
     rewardRate = _rewardRate;
    
     }
     
     function StakingReturnsAmountSet(uint _poolreward) public onlyOwner returns(bool){
     ToBeFarmedTokens = _poolreward;
    
     }
     
     
    function possibleUnfarmTimeSet(uint _possibleUnfarmTime) public onlyOwner returns(bool){
        
     PossibleUnfarmTime = _possibleUnfarmTime;
    
     }
     
    function rewardIntervalSet(uint _rewardInterval) public onlyOwner returns(bool){
        
     rewardInterval = _rewardInterval;
    
     }
     
     
    function allowFarming(bool _status) public onlyOwner returns(bool){
        require(VAPEAddress != address(0) && LPTokenAddress != address(0), "Interracting token addresses are not yet configured");
        farmingStatus = _status;
    }
    
    function transferAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        if (_tokenAddr == VAPEAddress) {
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
            require(Token(VAPEAddress).transfer(account, unclaimedDivs), "Could not transfer tokens.");
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
    
    function farm(uint amountToFarm) public {
        require(farmingStatus == true, "Staking is not yet initialized");
        require(amountToFarm > 0, "Cannot deposit 0 Tokens");
        require(Token(LPTokenAddress).transferFrom(msg.sender, address(this), amountToFarm), "Insufficient Token Allowance");
        
        updateAccount(msg.sender);
        
        uint fee = amountToFarm.mul(farmingFeeRate).div(1e4);
        uint amountAfterFee = amountToFarm.sub(fee);
        require(Token(LPTokenAddress).transfer(admin, fee), "Could not transfer deposit fee.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountAfterFee);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            farmingTime[msg.sender] = now;
        }
    }
    
    function unfarm(uint amountToWithdraw) public {
        
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        require(now.sub(farmingTime[msg.sender]) > PossibleUnfarmTime, "You have not staked for a while yet, kindly wait a bit more");
        
        updateAccount(msg.sender);
        
        uint fee = amountToWithdraw.mul(unfarmingFeeRate).div(1e4);
        uint amountAfterFee = amountToWithdraw.sub(fee);
        
        require(Token(LPTokenAddress).transfer(admin, fee), "Could not transfer withdraw fee.");
        require(Token(LPTokenAddress).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    function claimRewards() public {
        updateAccount(msg.sender);
    }
    
    function getFundedTokens() public view returns (uint) {
        if (totalClaimedRewards >= ToBeFarmedTokens) {
            return 0;
        }
        uint remaining = ToBeFarmedTokens.sub(totalClaimedRewards);
        return remaining;
    }
    
   
}