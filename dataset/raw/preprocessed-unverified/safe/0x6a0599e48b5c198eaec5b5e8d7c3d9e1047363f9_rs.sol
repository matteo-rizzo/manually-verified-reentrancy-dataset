/**
 *Submitted for verification at Etherscan.io on 2020-11-25
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
    address public constant trustedStakeTokenAddress = 0x9B1913fb1f3bE42632AAf49c6a00EC77b0e5767b;
    // trusted reward token contract address
    address public constant trustedRewardTokenAddress = trustedStakeTokenAddress;
    
    // reward rate
    uint public rewardRatePercentX100 = 200e2;
    uint public constant rewardInterval = 100 days;
    
    uint public totalClaimedRewards = 0;
    
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public stakingTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    
    
    mapping (address => address) public referrals;
    mapping (address => uint) public totalReferralFeeEarned;
    
    
    function updateAccount(address account) private {
        uint pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            uint _2Percent = pendingDivs.mul(2e2).div(100e2);
            Token(trustedRewardTokenAddress).burn(_2Percent);
            uint _3Percent = pendingDivs.mul(3e2).div(100e2);
            require(Token(trustedRewardTokenAddress).transfer(owner, _3Percent), "Could not transfer fee!");
            require(Token(trustedRewardTokenAddress).transfer(account, pendingDivs), "Could not transfer tokens.");
            
            uint _amountToDeduct = pendingDivs.div(2);
            if (depositedTokens[account] < _amountToDeduct) {
                _amountToDeduct = depositedTokens[account];
            }
            depositedTokens[account] = depositedTokens[account].sub(pendingDivs.div(2));
            
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
        
        timeDiff = now.sub(lastClaimedTime[_holder]);
        
        uint stakedAmount = depositedTokens[_holder];
        
        uint pendingDivs = stakedAmount
                            .mul(rewardRatePercentX100)
                            .mul(timeDiff)
                            .div(rewardInterval)
                            .div(1e4);
                            
        uint _200Percent = stakedAmount.mul(2);
        
        if (pendingDivs > _200Percent) {
            pendingDivs = _200Percent;
        }
            
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint) {
        return holders.length();
    }
    
    
    function stake(uint amountToStake, address referrer) public {
        require(amountToStake > 0, "Cannot stake 0 Tokens");
        require(Token(trustedStakeTokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        updateAccount(msg.sender);
        
        uint _2Percent = amountToStake.mul(2e2).div(100e2);
        // uint _3Percent = amountToStake.mul(3e2).div(100e2);
        uint amountAfterFee = amountToStake;
        
        Token(trustedStakeTokenAddress).burn(_2Percent);
        
        // require(Token(trustedStakeTokenAddress).transfer(owner, _3Percent), "Cannot transfer admin fee!");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountAfterFee);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            stakingTime[msg.sender] = now;
            
            referrals[msg.sender] = referrer;
        }
        
        disburseReferralFee(msg.sender, amountToStake);
    }
    
    function disburseReferralFee(address account, uint amount) private {
        address l1 = referrals[account];
        address l2 = referrals[l1];
        address l3 = referrals[l2];
        
        uint _1Percent = amount.mul(1e2).div(100e2);
        uint _2Percent = amount.mul(2e2).div(100e2);
        uint _3Percent = amount.mul(3e2).div(100e2);
        
        transferReferralFeeIfPossible(l1, _3Percent);
        transferReferralFeeIfPossible(l2, _2Percent);
        transferReferralFeeIfPossible(l3, _1Percent);
    }
    
    function transferReferralFeeIfPossible(address account, uint amount) private {
        if (account != address(0) && amount > 0) {
            totalReferralFeeEarned[account] = totalReferralFeeEarned[account].add(amount);
            require(Token(trustedRewardTokenAddress).transfer(account, amount), "Could not transfer referral fee!");
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
        
        require((_tokenAddr != trustedRewardTokenAddress), "Admin cannot Transfer out Reward Tokens!");
        
        Token(_tokenAddr).transfer(_to, _amount);
    }
}