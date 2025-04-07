/**
 *Submitted for verification at Etherscan.io on 2020-12-16
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





contract FarmPrdzEth60 is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint amount);
    event RewardsDisbursed(uint amount);
    
    // deposit token contract address
    address public trustedDepositTokenAddress;
    address public trustedRewardTokenAddress; 
    uint public adminCanClaimAfter = 395 days;
    uint public withdrawFeePercentX100 = 0;
    uint public disburseAmount = 45e18;
    uint public disburseDuration = 30 days;
    uint public cliffTime = 60 days;
    
    
    uint public disbursePercentX100 = 10000;
    
    uint public contractDeployTime;
    uint public adminClaimableTime;
    uint public lastDisburseTime;
    
    constructor(address _trustedDepositTokenAddress, address _trustedRewardTokenAddress) public {
        trustedDepositTokenAddress = _trustedDepositTokenAddress;
        trustedRewardTokenAddress = _trustedRewardTokenAddress;
        contractDeployTime = now;
        adminClaimableTime = contractDeployTime.add(adminCanClaimAfter);
        lastDisburseTime = contractDeployTime;
    }

    
    uint public totalClaimedRewards = 0;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public depositTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    mapping (address => uint) public lastDivPoints;
    
    uint public totalTokensDisbursed = 0;
    uint public contractBalance = 0;
    
    uint public totalDivPoints = 0;
    uint public totalTokens = 0;

    uint internal pointMultiplier = 1e18;
    
    function addContractBalance(uint amount) public onlyOwner {
        require(Token(trustedRewardTokenAddress).transferFrom(msg.sender, address(this), amount), "Cannot add balance!");
        contractBalance = contractBalance.add(amount);
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
        lastDivPoints[account] = totalDivPoints;
    }
    
    function getPendingDivs(address _holder) public view returns (uint) {
        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;
        
        uint newDivPoints = totalDivPoints.sub(lastDivPoints[_holder]);

        uint depositedAmount = depositedTokens[_holder];
        
        uint pendingDivs = depositedAmount.mul(newDivPoints).div(pointMultiplier);
            
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint) {
        return holders.length();
    }
    
     function canWithdraw(address account) public view returns (uint) {
       if(now.sub(depositTime[account]) > cliffTime){
            return 1 ; 
       }
       else{
            return 0 ; 

       }
    }
    
    function deposit(uint amountToDeposit) public {
        require(amountToDeposit > 0, "Cannot deposit 0 Tokens");
        
        updateAccount(msg.sender);
        
        require(Token(trustedDepositTokenAddress).transferFrom(msg.sender, address(this), amountToDeposit), "Insufficient Token Allowance");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountToDeposit);
        totalTokens = totalTokens.add(amountToDeposit);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            depositTime[msg.sender] = now;
        }
        
    }
    
    function withdraw(uint amountToWithdraw) public {
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        require(now.sub(depositTime[msg.sender]) > cliffTime, "Please wait before withdrawing!");

        updateAccount(msg.sender);
        
        uint fee = amountToWithdraw.mul(withdrawFeePercentX100).div(1e4);
        uint amountAfterFee = amountToWithdraw.sub(fee);
        
        require(Token(trustedDepositTokenAddress).transfer(owner, fee), "Could not transfer fee!");

        require(Token(trustedDepositTokenAddress).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        totalTokens = totalTokens.sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
     
    
    function claim() public {
        updateAccount(msg.sender);
    }
    
    function distributeDivs(uint amount) private {
        if (totalTokens == 0) return;
        totalDivPoints = totalDivPoints.add(amount.mul(pointMultiplier).div(totalTokens));
        emit RewardsDisbursed(amount);
    }
    
    function disburseTokens() public onlyOwner {
        uint amount = getPendingDisbursement();
        
        // uint contractBalance = Token(trustedRewardTokenAddress).balanceOf(address(this));
        
        if (contractBalance < amount) {
            amount = contractBalance;
        }
        if (amount == 0) return;
        distributeDivs(amount);
        contractBalance = contractBalance.sub(amount);
        lastDisburseTime = now;
        
    }
    
    function getPendingDisbursement() public view returns (uint) {
        uint timeDiff = now.sub(lastDisburseTime);
        uint pendingDisburse = disburseAmount
                                    .mul(disbursePercentX100)
                                    .mul(timeDiff)
                                    .div(disburseDuration)
                                    .div(10000);
        return pendingDisburse;
    }
    
    function getDepositorsList(uint startIndex, uint endIndex) 
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
            _stakingTimestamps[listIndex] = depositTime[staker];
            _lastClaimedTimeStamps[listIndex] = lastClaimedTime[staker];
            _stakedTokens[listIndex] = depositedTokens[staker];
        }
        
        return (_stakers, _stakingTimestamps, _lastClaimedTimeStamps, _stakedTokens);
    }
    
 
}