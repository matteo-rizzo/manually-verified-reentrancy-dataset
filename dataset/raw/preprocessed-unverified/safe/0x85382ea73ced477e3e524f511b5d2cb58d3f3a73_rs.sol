/**
 *Submitted for verification at Etherscan.io on 2021-06-15
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






contract RemitVaultFarmEth is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint amount);
    event RewardsDisbursed(uint amount);
    
    address public trustedDepositTokenAddress;
    address public trustedRewardTokenAddress; 

    uint public adminCanClaimAfter = 395 days;
    uint public withdrawFeePercentX100 = 50;

    uint public disburseAmount = 68287036999999990;
    
    uint public disburseDuration = 15;
    
    uint public cliffTime = 20 days;
    
    uint public constant rewardFeeRate = 500;

    uint public disbursePercentX100 = 10000;
    
    uint public contractDeployTime;
    uint public adminClaimableTime;
    uint public lastDisburseTime;
    
    constructor(address _trustedDepositTokenAddress) public {
        contractDeployTime = now;
        adminClaimableTime = contractDeployTime.add(adminCanClaimAfter);
        lastDisburseTime = contractDeployTime;
        trustedDepositTokenAddress = _trustedDepositTokenAddress;
        trustedRewardTokenAddress = 0xa2fcC180fa0cbc0983F9b6948D22df733273925b;
        
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
    
   
    
    function updateAccount(address account) private {
        distributeDivs();
        uint pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            uint feeReward = pendingDivs.mul(rewardFeeRate).div(1e4);
            pendingDivs = pendingDivs.sub(feeReward);
            require(Token(trustedRewardTokenAddress).transfer(account, pendingDivs), "Could not transfer tokens.");
            require(Token(trustedRewardTokenAddress).transfer(owner, feeReward), "Could not transfer tokens.");
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
    
    
    function deposit(uint amountToDeposit) public {
        require(amountToDeposit > 0, "Cannot deposit 0 Tokens");
        
        updateAccount(msg.sender);
        
        require(Token(trustedDepositTokenAddress).transferFrom(msg.sender, address(this), amountToDeposit), "Insufficient Token Allowance");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountToDeposit);
        totalTokens = totalTokens.add(amountToDeposit);
        
        depositTime[msg.sender] = now;
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
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
    
    // withdraw without caring about Rewards
    function emergencyWithdraw(uint amountToWithdraw) public {
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        require(now.sub(depositTime[msg.sender]) > cliffTime, "Please wait before withdrawing!");

        lastClaimedTime[msg.sender] = now;
        lastDivPoints[msg.sender] = totalDivPoints;
        
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
    
    function distributeDivs() private {
        if (totalTokens == 0) return;
        uint amount = getPendingDisbursement();
        uint256 mintedToken = Token(trustedRewardTokenAddress).mintStakeFarmSupply(address(this),amount);
        totalDivPoints = totalDivPoints.add(mintedToken.mul(pointMultiplier).div(totalTokens));
        lastDisburseTime = now;
        emit RewardsDisbursed(amount);
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
    

    // function to allow owner to claim *other* ERC20 tokens sent to this contract
    function transferAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        // require(_tokenAddr != trustedRewardTokenAddress && _tokenAddr != trustedDepositTokenAddress, "Cannot send out reward tokens or staking tokens!");
        
        require(_tokenAddr != trustedDepositTokenAddress, "Admin cannot transfer out deposit tokens from this vault!");
        require((_tokenAddr != trustedRewardTokenAddress) || (now > adminClaimableTime), "Admin cannot Transfer out Reward Tokens yet!");
        
        Token(_tokenAddr).transfer(_to, _amount);
    }

    function setDepositTokenAddress(address _trustedDepositTokenAddress) public onlyOwner {
        trustedDepositTokenAddress = _trustedDepositTokenAddress;
    }
    
    function setWithdrawFeePercent(uint256 _fee) public onlyOwner {
        withdrawFeePercentX100 = _fee;
    }

    function setRewardTokenAddress(address _trustedRewardTokenAddress) public onlyOwner {
        trustedRewardTokenAddress = _trustedRewardTokenAddress;
    }
}