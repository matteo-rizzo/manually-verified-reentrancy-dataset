/**
 *Submitted for verification at Etherscan.io on 2020-11-11
*/

/**
 *Submitted for verification at Etherscan.io on 2020-11-08
*/

pragma solidity 0.6.11;

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




contract Staking is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint amount);
    
    // trusted staking token contract address
    address public constant trustedStakeTokenAddress = 0xD14b5958E60b3762Ee7dF8c529A7dC73ff62b3A7;
    // trusted reward token contract address
    address public constant trustedRewardTokenAddress = 0x97f90Da7aaa8c9980df57bfD94e6E4246b74307B;
    
    // reward rate per year
    uint public rewardRatePercentX100 = 200e2;

    // lockup period
    uint public constant cliffTime = 7 days;

    uint public constant rewardInterval = 365 days;
    
    uint public totalClaimedRewards = 0;
    
    uint public stakingDuration = 365 days;
    
    // admin can transfer out reward tokens from this contract one month after staking has ended
    uint public adminCanClaimAfter = 395 days;
    
    uint public stakingDeployTime;
    uint public adminClaimableTime;
    uint public stakingEndTime;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public stakingTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    
    constructor () public {
        stakingDeployTime = now;
        stakingEndTime = stakingDeployTime.add(stakingDuration);
        adminClaimableTime = stakingDeployTime.add(adminCanClaimAfter);
    }
    
    // Admin can change APY% (or reward rate %)
    // Changing reward rate percent will also affect user's pending earnings
    // Be careful while using this function
    function setRewardRatePercentX100(uint _rewardRatePercentX100) public onlyOwner {
        rewardRatePercentX100 = _rewardRatePercentX100;
    }
    
    function updateAccount(address account) private {
        uint pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            require(Token(trustedRewardTokenAddress).transfer(account, pendingDivs), "Could not transfer tokens.");
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }
        lastClaimedTime[account] = now;
    }
    
    function getPendingDivs(address _holder) public view returns (uint) {
        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;
        
        uint timeDiff;
        uint _now = now;
        if (_now > stakingEndTime) {
            _now = stakingEndTime;
        }
        
        if (lastClaimedTime[_holder] >= _now) {
            timeDiff = 0;
        } else {
            timeDiff = _now.sub(lastClaimedTime[_holder]);
        }

        uint stakedAmount = depositedTokens[_holder];
        
        uint pendingDivs = stakedAmount
                            .mul(rewardRatePercentX100)
                            .mul(timeDiff)
                            .div(rewardInterval)
                            .div(1e4);
            
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint) {
        return holders.length();
    }
    
    
    function stake(uint amountToStake) public {
        require(amountToStake > 0, "Cannot stake 0 Tokens");
        require(Token(trustedStakeTokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        updateAccount(msg.sender);
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountToStake);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            stakingTime[msg.sender] = now;
        }
    }
    
    function unstake(uint amountToWithdraw) public {
        require(amountToWithdraw > 0, "Cannot unstake 0 Tokens");
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        require(now.sub(stakingTime[msg.sender]) > cliffTime, "You recently staked, please wait before withdrawing.");

        updateAccount(msg.sender);
 
        require(Token(trustedStakeTokenAddress).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    // emergency unstake without caring about pending earnings
    // pending earnings will be lost / set to 0 if used emergency unstake
    function emergencyUnstake(uint amountToWithdraw) public {
        require(amountToWithdraw > 0, "Cannot unstake 0 Tokens");
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        require(now.sub(stakingTime[msg.sender]) > cliffTime, "You recently staked, please wait before withdrawing.");

        // set pending earnings to 0 here
        lastClaimedTime[msg.sender] = now;
        
        require(Token(trustedStakeTokenAddress).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    function claim() public {
        updateAccount(msg.sender);
    }
    
    function getStakersList(uint startIndex, uint endIndex) 
        public 
        view 
        returns (address[] memory stakers, 
            uint[] memory stakingTimestamps, 
            uint[] memory lastClaimedTimeStamps,
            uint[] memory stakedTokens) {
        require (startIndex < endIndex);
        
        uint length = endIndex.sub(startIndex);
        address[] memory _stakers = new address[](length);
        uint[] memory _stakingTimestamps = new uint[](length);
        uint[] memory _lastClaimedTimeStamps = new uint[](length);
        uint[] memory _stakedTokens = new uint[](length);
        
        for (uint i = startIndex; i < endIndex; i = i.add(1)) {
            address staker = holders.at(i);
            uint listIndex = i.sub(startIndex);
            _stakers[listIndex] = staker;
            _stakingTimestamps[listIndex] = stakingTime[staker];
            _lastClaimedTimeStamps[listIndex] = lastClaimedTime[staker];
            _stakedTokens[listIndex] = depositedTokens[staker];
        }
        
        return (_stakers, _stakingTimestamps, _lastClaimedTimeStamps, _stakedTokens);
    }

    // function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    // Admin cannot transfer out staking tokens from this smart contract
    // Admin can transfer out reward tokens from this address once adminClaimableTime has reached
    function transferAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        require(_tokenAddr != trustedStakeTokenAddress, "Admin cannot transfer out Stake Tokens from this contract!");
        
        require((_tokenAddr != trustedRewardTokenAddress) || (now > adminClaimableTime), "Admin cannot Transfer out Reward Tokens yet!");
        
        Token(_tokenAddr).transfer(_to, _amount);
    }
}