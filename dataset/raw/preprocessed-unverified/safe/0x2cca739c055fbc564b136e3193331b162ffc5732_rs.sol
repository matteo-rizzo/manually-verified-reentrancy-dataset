/**
 *Submitted for verification at Etherscan.io on 2021-03-01
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: MIT

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




contract Pool_4 is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint256 amount);
    
    // YPro token contract address
    address public tokenAddress = 0xAc9C0F1bFD12cf5c4daDbeAb943473c4C45263A0;
    
    // LP token contract address
    address public LPtokenAddress = 0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11;
    
    // reward rate 100 % per year
    uint256 public rewardRate = 502700 ;
    uint256 public rewardInterval = 365 days;
    
    // staking fee 0%
    uint256 public stakingFeeRate = 0;
    
    // unstaking fee 0%
    uint256 public unstakingFeeRate = 0;
    
    // unstaking possible after 0 days
    uint256 public cliffTime = 0 days;
    
    uint256 public farmEnableat;
    uint256 public totalClaimedRewards = 0;
    uint256 private stakingAndDaoTokens = 100000e18;
    
    bool public farmEnabled = false;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint256) public depositedTokens;
    mapping (address => uint256) public stakingTime;
    mapping (address => uint256) public lastClaimedTime;
    mapping (address => uint256) public totalEarnedTokens;
    
    function updateAccount(address account) private {
        uint256 pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            require(Token(tokenAddress).transfer(account, pendingDivs), "Could not transfer tokens.");
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }
        lastClaimedTime[account] = now;
    }
    
    function getPendingDivs(address _holder) public view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;
        
        uint256 timeDiff = now.sub(lastClaimedTime[_holder]);
        uint256 stakedAmount = depositedTokens[_holder];

        if (now > farmEnableat + 7 days) {
            
            uint256 pendingDivs = stakedAmount.mul(2010797).mul(timeDiff).div(rewardInterval).div(1e4);
            
            return pendingDivs;
        } else if (now <= farmEnableat + 7 days) {
            
            uint256 pendingDivs = stakedAmount.mul(rewardRate).mul(timeDiff).div(rewardInterval).div(1e4);
            
            return pendingDivs;
        }
        
    }
    
    function getNumberOfHolders() public view returns (uint256) {
        return holders.length();
    }
    
    
    function deposit(uint256 amountToStake) public {
        require(amountToStake > 0, "Cannot deposit 0 Tokens");
        require(farmEnabled, "Farming is not enabled");
        require(Token(LPtokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        updateAccount(msg.sender);
        
        uint256 fee = amountToStake.mul(stakingFeeRate).div(1e4);
        uint256 amountAfterFee = amountToStake.sub(fee);
        require(Token(LPtokenAddress).transfer(owner, fee), "Could not transfer deposit fee.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountAfterFee);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            stakingTime[msg.sender] = now;
        }
    }
    
    function withdraw(uint256 amountToWithdraw) public {
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        require(now.sub(stakingTime[msg.sender]) > cliffTime, "You recently staked, please wait before withdrawing.");
        
        updateAccount(msg.sender);
        
        uint256 fee = amountToWithdraw.mul(unstakingFeeRate).div(1e4);
        uint256 amountAfterFee = amountToWithdraw.sub(fee);
        
        require(Token(LPtokenAddress).transfer(owner, fee), "Could not transfer deposit fee.");
        require(Token(LPtokenAddress).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    function claimDivs() public {
        updateAccount(msg.sender);
    }
    
    function getStakingAndDaoAmount() public view returns (uint256) {
        if (totalClaimedRewards >= stakingAndDaoTokens) {
            return 0;
        }
        uint256 remaining = stakingAndDaoTokens.sub(totalClaimedRewards);
        return remaining;
    }
    
    function setTokenAddress(address _tokenAddressess) public onlyOwner {
        tokenAddress = _tokenAddressess;
    }
    
    function setLPTokenAddress(address _LPtokenAddressess) public onlyOwner {
        LPtokenAddress = _LPtokenAddressess;
    }
    
    function setCliffTime(uint256 _time) public onlyOwner {
        cliffTime = _time;
    }
    
    function setRewardInterval(uint256 _rewardInterval) public onlyOwner {
        rewardInterval = _rewardInterval;
    }
    
    function setStakingAndDaoTokens(uint256 _stakingAndDaoTokens) public onlyOwner {
        stakingAndDaoTokens = _stakingAndDaoTokens;
    }
    
    function setStakingFeeRate(uint256 _Fee) public onlyOwner {
        stakingFeeRate = _Fee;
    }
    
    function setUnstakingFeeRate(uint256 _Fee) public onlyOwner {
        unstakingFeeRate = _Fee;
    }
    
    function setRewardRate(uint256 _rewardRate) public onlyOwner {
        rewardRate = _rewardRate;
    }
    
    function enableFarming() external onlyOwner() {
        farmEnabled = true;
        farmEnableat = now;
    }
    
    // function to allow admin to claim *any* ERC20 tokens sent to this contract
    function transferAnyERC20Tokens(address _tokenAddress, address _to, uint256 _amount) public onlyOwner {
        require(_tokenAddress != LPtokenAddress);
        
        Token(_tokenAddress).transfer(_to, _amount);
    }
}