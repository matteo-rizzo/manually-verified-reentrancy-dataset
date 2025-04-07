/**
 *Submitted for verification at Etherscan.io on 2020-10-09
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: BSD-3-Clause

/**
 * YFOX Dual Staking
 * Regular Staking APR:
 *   - Yearly: 360 days = 200% 
 *   - Monthly: 30 days = 16.66%
 *   - Weekly: 7 Days = 3.88%
 *   - Daily: 24 Hours = 0.55%
 *   - Hourly: 60 Minutes = 0.02%
 * 
 * FD (Fixed Deposit Staking) APR:
 *   - Yearly: 360 days = 250%
 * Interest on fixed deposit staking is added at a daily rate of 0.69%
 * 
 * Staking ends after 12 months
 * Stakers can still unstake for 1 month after staking has ended
 * After 13 months admin has the right to claim remaining YFOX from the smart contract
 *
 * 
 */

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
    
    // reward token contract address
    address public constant tokenAddress = 0x706CB9E741CBFee00Ad5b3f5ACc8bd44D1644a74;
    
    // reward rate 200.00% per year
    uint public constant rewardRate = 20000;
    // FD reward rate 250.00% per year
    uint public constant rewardRateFD = 25000;
    
    uint public constant rewardInterval = 360 days;
    uint public constant adminCanClaimAfter = 30 days;
    
    // No fee for FD
    
    // staking fee 1.00 percent
    uint public constant stakingFeeRate = 100;
    
    // unstaking fee 0.50 percent
    uint public constant unstakingFeeRate = 50;
    
    // unstaking possible after 48 hours
    uint public constant cliffTime = 48 hours;
    
    
    uint public totalClaimedRewards = 0;
    
    EnumerableSet.AddressSet private holders;
    EnumerableSet.AddressSet private holdersFD;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public stakingTime;
    mapping (address => uint) public lastClaimedTime;
    
    mapping (address => uint) public depositedTokensFD;
    mapping (address => uint) public stakingTimeFD;
    mapping (address => uint) public lastClaimedTimeFD;
    
    mapping (address => uint) public totalEarnedTokens;
    mapping (address => uint) public totalEarnedTokensFD;
    
    uint public stakingDeployTime;
    uint public stakingEndTime;
    uint public adminClaimableTime;
    
    constructor() public {
        uint _now = now;
        stakingDeployTime = _now;
        stakingEndTime = stakingDeployTime.add(rewardInterval);
        adminClaimableTime = stakingEndTime.add(adminCanClaimAfter);
    }
    
    function updateAccount(address account) private {
        uint pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            require(Token(tokenAddress).transfer(account, pendingDivs), "Could not transfer tokens.");
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }
        lastClaimedTime[account] = now;
    }
    
    function updateAccountFD(address account) private {
        uint pendingDivs = getPendingDivsFD(account);
        if (pendingDivs > 0) {
            require(Token(tokenAddress).transfer(account, pendingDivs), "Could not transfer tokens.");
            totalEarnedTokensFD[account] = totalEarnedTokensFD[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }
        lastClaimedTimeFD[account] = now;
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
                            .mul(rewardRate)
                            .mul(timeDiff)
                            .div(rewardInterval)
                            .div(1e4);
            
        return pendingDivs;
    }
    
    function getPendingDivsFD(address _holder) public view returns (uint) {
        if (!holdersFD.contains(_holder)) return 0;
        if (depositedTokensFD[_holder] == 0) return 0;

        uint timeDiff;
        uint _now = now;
        if (_now > stakingEndTime) {
            _now = stakingEndTime;
        }
        
        if (lastClaimedTimeFD[_holder] >= _now) {
            timeDiff = 0;
        } else {
            timeDiff = _now.sub(lastClaimedTimeFD[_holder]);
        }
        
        uint stakedAmount = depositedTokensFD[_holder];
        
        uint pendingDivs = stakedAmount
                            .mul(rewardRateFD)
                            .mul(timeDiff)
                            .div(rewardInterval)
                            .div(1e4);
            
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint) {
        return holders.length();
    }
    function getNumberOfHoldersFD() public view returns (uint) {
        return holdersFD.length();
    }
    
    
    function stake(uint amountToStake) public {
        require(amountToStake > 0, "Cannot deposit 0 Tokens");
        require(Token(tokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        updateAccount(msg.sender);
        
        uint fee = amountToStake.mul(stakingFeeRate).div(1e4);
        uint amountAfterFee = amountToStake.sub(fee);
        require(Token(tokenAddress).transfer(owner, fee), "Could not transfer deposit fee.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountAfterFee);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            stakingTime[msg.sender] = now;
        }
    }
    
    function stakeFD(uint amountToStake) public {
        require(amountToStake > 0, "Cannot deposit 0 Tokens");
        require(Token(tokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        updateAccountFD(msg.sender);
        
        depositedTokensFD[msg.sender] = depositedTokensFD[msg.sender].add(amountToStake);
        
        if (!holdersFD.contains(msg.sender)) {
            holdersFD.add(msg.sender);
            stakingTimeFD[msg.sender] = now;
        }
    }
    
    function unstake(uint amountToWithdraw) public {
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        require(now.sub(stakingTime[msg.sender]) > cliffTime, "You recently staked, please wait before withdrawing.");
        
        updateAccount(msg.sender);
        
        uint fee = amountToWithdraw.mul(unstakingFeeRate).div(1e4);
        uint amountAfterFee = amountToWithdraw.sub(fee);
        
        require(Token(tokenAddress).transfer(owner, fee), "Could not transfer withdraw fee.");
        require(Token(tokenAddress).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    function unstakeFD(uint amountToWithdraw) public {
        require(depositedTokensFD[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        require(now > stakingEndTime, "Cannot unstake FD before staking ends.");
        
        updateAccountFD(msg.sender);
        
        require(Token(tokenAddress).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");
        
        depositedTokensFD[msg.sender] = depositedTokensFD[msg.sender].sub(amountToWithdraw);
        
        if (holdersFD.contains(msg.sender) && depositedTokensFD[msg.sender] == 0) {
            holdersFD.remove(msg.sender);
        }
    }
    
    function claim() public {
        updateAccount(msg.sender);
    }
    
    function claimFD() public {
        updateAccountFD(msg.sender);
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
    
    function getStakersListFD(uint startIndex, uint endIndex) 
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
            address staker = holdersFD.at(i);
            uint listIndex = i.sub(startIndex);
            _stakers[listIndex] = staker;
            _stakingTimestamps[listIndex] = stakingTimeFD[staker];
            _lastClaimedTimeStamps[listIndex] = lastClaimedTimeFD[staker];
            _stakedTokens[listIndex] = depositedTokensFD[staker];
        }
        
        return (_stakers, _stakingTimestamps, _lastClaimedTimeStamps, _stakedTokens);
    }
    
    
    uint private constant stakingAndDaoTokens = 6900e6;
    
    function getStakingAndDaoAmount() public view returns (uint) {
        if (totalClaimedRewards >= stakingAndDaoTokens) {
            return 0;
        }
        uint remaining = stakingAndDaoTokens.sub(totalClaimedRewards);
        return remaining;
    }
    
    // function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    // Admin cannot transfer out YFOX from this smart contract till 1 month after staking ends
    function transferAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        require((_tokenAddr != tokenAddress) || (now > adminClaimableTime), "Cannot Transfer Out YFOX till 13 months of launch!");
        Token(_tokenAddr).transfer(_to, _amount);
    }
}