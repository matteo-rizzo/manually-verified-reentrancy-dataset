/**
 *Submitted for verification at Etherscan.io on 2021-06-12
*/

/**
 *Submitted for verification at Etherscan.io on 2021-06-12
*/

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.6.11;

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
 * @dev Collection of functions related to the address type
 */



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */







contract DAO1FarmingUniswap is Ownable {
    using SafeMath for uint;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint amount);
    event RewardsDisbursed(uint amount);
    
    // deposit token contract address and reward token contract address
    // these contracts are "trusted" and checked to not contain re-entrancy pattern 
    // to safely avoid checks-effects-interactions where needed to simplify logic
    address public trustedDepositTokenAddress = 0xF94556124786E08171d278a75cf1b46eE9592227;
    address public trustedRewardTokenAddress = 0xCE3f6f6672616c39D8B6858F8DAC9902eCa42C84; 
    uint public constant LOCKUP_TIME = 3 days;
    
    uint public constant STAKING_FEE_RATE_X_100 = 50;
    uint public constant UNSTAKING_FEE_RATE_X_100 = 50;

    // Amount of tokens
    uint public disburseAmount = 5400e18;
    // To be disbursed continuously over this duration
    uint public disburseDuration = 180 days;
    
    // If there are any undistributed or unclaimed tokens left in contract after this time
    // Admin can claim them
    uint public adminCanClaimAfter = 200 days;
    
    
    // do not change this => disburse 100% rewards over `disburseDuration`
    uint public disbursePercentX100 = 100e2;
    
    uint public contractDeployTime;
    uint public adminClaimableTime;
    uint public lastDisburseTime;
    
    // Contracts are not allowed to deposit, claim or withdraw
    modifier noContractsAllowed() {
        require(!(address(msg.sender).isContract()) && tx.origin == msg.sender, "No Contracts Allowed!");
        _;
    }
    
    constructor() public {
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
        disburseTokens();
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
    
    function getEstimatedPendingDivs(address _holder) public view returns (uint) {
        uint pendingDivs = getPendingDivs(_holder);
        uint pendingDisbursement = getPendingDisbursement();
        if (contractBalance < pendingDisbursement) {
            pendingDisbursement = contractBalance;
        }
        uint depositedAmount = depositedTokens[_holder];
        if (depositedAmount == 0) return 0;
        if (totalTokens == 0) return 0;
        
        uint myShare = depositedAmount.mul(pendingDisbursement).div(totalTokens);
                                
        return pendingDivs.add(myShare);
    }
    
    function getNumberOfHolders() public view returns (uint) {
        return holders.length();
    }
    
    
    function deposit(uint amountToDeposit) external noContractsAllowed {
        require(now.add(LOCKUP_TIME) <= contractDeployTime.add(disburseDuration), "Deposits are closed now!");
        require(amountToDeposit > 0, "Cannot deposit 0 Tokens");
        
        updateAccount(msg.sender);
        
        require(Token(trustedDepositTokenAddress).transferFrom(msg.sender, address(this), amountToDeposit), "Insufficient Token Allowance");
        
        uint fee = amountToDeposit.mul(STAKING_FEE_RATE_X_100).div(100e2);
        uint amountAfterFee = amountToDeposit.sub(fee);
        
        require(Token(trustedDepositTokenAddress).transfer(owner, fee), "Fee transfer failed!");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountAfterFee);
        totalTokens = totalTokens.add(amountAfterFee);

        holders.add(msg.sender);
        depositTime[msg.sender] = now;
    }
    
    function withdraw(uint amountToWithdraw) external noContractsAllowed {
        require(amountToWithdraw > 0, "Cannot withdraw 0 Tokens!");
        require(now.sub(depositTime[msg.sender]) > LOCKUP_TIME, "You recently staked, please wait before withdrawing.");
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        updateAccount(msg.sender);
        
        uint fee = amountToWithdraw.mul(UNSTAKING_FEE_RATE_X_100).div(100e2);
        uint amountAfterFee = amountToWithdraw.sub(fee);
        
        require(Token(trustedDepositTokenAddress).transfer(owner, fee), "Fee transfer failed!");
        
        require(Token(trustedDepositTokenAddress).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        totalTokens = totalTokens.sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    // withdraw without caring about Rewards
    function emergencyWithdraw(uint amountToWithdraw) external noContractsAllowed {
        require(amountToWithdraw > 0, "Cannot withdraw 0 Tokens!");
        require(now.sub(depositTime[msg.sender]) > LOCKUP_TIME, "You recently staked, please wait before withdrawing.");
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        // manual update account here without withdrawing pending rewards
        disburseTokens();
        lastClaimedTime[msg.sender] = now;
        lastDivPoints[msg.sender] = totalDivPoints;
        
        uint fee = amountToWithdraw.mul(UNSTAKING_FEE_RATE_X_100).div(100e2);
        uint amountAfterFee = amountToWithdraw.sub(fee);
        
        require(Token(trustedDepositTokenAddress).transfer(owner, fee), "Fee transfer failed!");
        
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
    
    function disburseTokens() private {
        uint amount = getPendingDisbursement();

        if (contractBalance < amount) {
            amount = contractBalance;
        }
        if (amount == 0 || totalTokens == 0) return;
        
        totalDivPoints = totalDivPoints.add(amount.mul(pointMultiplier).div(totalTokens));
        totalTokensDisbursed = totalTokensDisbursed.add(amount);
        emit RewardsDisbursed(amount);
        
        contractBalance = contractBalance.sub(amount);
        lastDisburseTime = now;
        
    }
    
    function getPendingDisbursement() public view returns (uint) {
        uint timeDiff;
        uint _now = now;
        uint _stakingEndTime = contractDeployTime.add(disburseDuration);
        if (_now > _stakingEndTime) {
            _now = _stakingEndTime;
        }
        if (lastDisburseTime >= _now) {
            timeDiff = 0;
        } else {
            timeDiff = _now.sub(lastDisburseTime);   
        }
        
        uint pendingDisburse = disburseAmount
                                    .mul(disbursePercentX100)
                                    .mul(timeDiff)
                                    .div(disburseDuration)
                                    .div(10000);
        return pendingDisburse;
    }
    
    function getHoldersList(uint startIndex, uint endIndex) 
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
    

    // function to allow owner to claim *other* modern ERC20 tokens sent to this contract
    function transferAnyERC20Token(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        
        require(_tokenAddr != trustedDepositTokenAddress, "Admin cannot transfer out deposit tokens from this vault!");
        require((_tokenAddr != trustedRewardTokenAddress) || (now > adminClaimableTime), "Admin cannot Transfer out Reward Tokens Yet!");
        require(Token(_tokenAddr).transfer(_to, _amount), "Could not transfer out tokens!");
    }
    
    // function to allow owner to claim *other* modern ERC20 tokens sent to this contract
    function transferAnyOldERC20Token(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        
        require(_tokenAddr != trustedDepositTokenAddress, "Admin cannot transfer out deposit tokens from this vault!");
        require((_tokenAddr != trustedRewardTokenAddress) || (now > adminClaimableTime), "Admin cannot Transfer out Reward Tokens Yet!");
        
        OldIERC20(_tokenAddr).transfer(_to, _amount);
    }
}