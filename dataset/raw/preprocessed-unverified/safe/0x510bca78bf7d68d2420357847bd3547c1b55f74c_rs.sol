/**
 *Submitted for verification at Etherscan.io on 2021-04-03
*/

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.6.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @dev Collection of functions related to the address type
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






contract ConstantReturnStaking is Ownable {
    using Address for address;
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address indexed holder, uint amount);
    event Reinvest(address indexed holder, uint amount);
    
    // ============================= CONTRACT VARIABLES ==============================
    
    // stake token contract address
    address public constant TRUSTED_TOKEN_ADDRESS = 0xE14e06671702F0Db50055388c29aDc66821D933B;
    
    // earnings reward rate
    uint public constant REWARD_RATE_X_100 = 5500;
    uint public constant REWARD_INTERVAL = 365 days;
    
    // staking fee
    uint public constant STAKING_FEE_RATE_X_100 = 50;
    
    // unstaking fee 
    uint public constant UNSTAKING_FEE_RATE_X_100 = 50;
    
    // unstaking possible after lockup period
    uint public constant LOCKUP_TIME = 90 days;
    
    uint public constant ADMIN_CAN_CLAIM_AFTER = 395 days;
    
    // ========================= END CONTRACT VARIABLES ==============================
    
    uint public totalClaimedRewards = 0;
    uint public totalTokens = 0;
    
    uint public immutable contractStartTime;
    
    // Contracts are not allowed to deposit, claim or withdraw
    modifier noContractsAllowed() {
        require(!(address(msg.sender).isContract()) && tx.origin == msg.sender, "No Contracts Allowed!");
        _;
    }
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public depositTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    
    mapping (address => uint) public rewardsPendingClaim;
    
    constructor() public {
        contractStartTime = now;
    }
    
    function updateAccount(address account) private {
        uint pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            
            uint amount = pendingDivs;
            
            rewardsPendingClaim[account] = rewardsPendingClaim[account].add(amount);
            totalEarnedTokens[account] = totalEarnedTokens[account].add(amount);
            
            totalClaimedRewards = totalClaimedRewards.add(amount);
            
        }
        lastClaimedTime[account] = now;
    }
    
    
    function getPendingDivs(address _holder) public view returns (uint) {
        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;
        
        uint timeDiff;
        uint stakingEndTime = contractStartTime.add(REWARD_INTERVAL);
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
                            .mul(REWARD_RATE_X_100)
                            .mul(timeDiff)
                            .div(REWARD_INTERVAL)
                            .div(1e4);
            
        return pendingDivs;
    }
    
    function getEstimatedPendingDivs(address _holder) external view returns (uint) {
        uint pending = getPendingDivs(_holder);
        uint awaitingClaim = rewardsPendingClaim[_holder];
        return pending.add(awaitingClaim);
    }
    
    function getNumberOfHolders() external view returns (uint) {
        return holders.length();
    }
    
    
    function deposit(uint amountToStake) external noContractsAllowed {
        require(amountToStake > 0, "Cannot deposit 0 Tokens");
        require(Token(TRUSTED_TOKEN_ADDRESS).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        updateAccount(msg.sender);
        
        uint fee = amountToStake.mul(STAKING_FEE_RATE_X_100).div(1e4);
        uint amountAfterFee = amountToStake.sub(fee);
      
        require(Token(TRUSTED_TOKEN_ADDRESS).transfer(owner, fee), "Could not transfer deposit fee.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountAfterFee);
        totalTokens = totalTokens.add(amountAfterFee);
        
        holders.add(msg.sender);
        
        depositTime[msg.sender] = now;
    }
    
    function withdraw(uint amountToWithdraw) external noContractsAllowed {
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        require(now.sub(depositTime[msg.sender]) > LOCKUP_TIME, "You recently staked, please wait before withdrawing.");
        
        updateAccount(msg.sender);
        
        uint fee = amountToWithdraw.mul(UNSTAKING_FEE_RATE_X_100).div(1e4);
        uint amountAfterFee = amountToWithdraw.sub(fee);
        
        require(Token(TRUSTED_TOKEN_ADDRESS).transfer(owner, fee), "Could not transfer withdraw fee.");
        require(Token(TRUSTED_TOKEN_ADDRESS).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        totalTokens = totalTokens.sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    // emergency unstake without caring about pending earnings
    // pending earnings will be lost / set to 0 if used emergency unstake
    function emergencyWithdraw(uint amountToWithdraw) external noContractsAllowed {
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        require(now.sub(depositTime[msg.sender]) > LOCKUP_TIME, "You recently staked, please wait before withdrawing.");
        
        // set pending earnings to 0 here
        lastClaimedTime[msg.sender] = now;
        
        uint fee = amountToWithdraw.mul(UNSTAKING_FEE_RATE_X_100).div(1e4);
        uint amountAfterFee = amountToWithdraw.sub(fee);
        
        require(Token(TRUSTED_TOKEN_ADDRESS).transfer(owner, fee), "Could not transfer withdraw fee.");
        require(Token(TRUSTED_TOKEN_ADDRESS).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        totalTokens = totalTokens.sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    function claim() external noContractsAllowed {
        updateAccount(msg.sender);
        uint amount = rewardsPendingClaim[msg.sender];
        if (amount > 0) {
            rewardsPendingClaim[msg.sender] = 0;
            require(Token(TRUSTED_TOKEN_ADDRESS).transfer(msg.sender, amount), "Could not transfer earned tokens.");  
            emit RewardsTransferred(msg.sender, amount);
        }
    }
    
    function reInvest() external noContractsAllowed {
        updateAccount(msg.sender);
        uint amount = rewardsPendingClaim[msg.sender];
        if (amount > 0) {
            rewardsPendingClaim[msg.sender] = 0;
            
            // re-invest here
            depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amount);
            
            depositTime[msg.sender] = now;
            emit Reinvest(msg.sender, amount);
        }
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
    
    
    // function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    // Admin cannot transfer out reward tokens from this smart contract
    function transferAnyERC20Token(address tokenAddress, address recipient, uint amount) external onlyOwner {
        require (tokenAddress != TRUSTED_TOKEN_ADDRESS || now > contractStartTime.add(ADMIN_CAN_CLAIM_AFTER), "Cannot Transfer Out main tokens!");
        require (Token(tokenAddress).transfer(recipient, amount), "Transfer failed!");
    }
    
    // function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    // Admin cannot transfer out reward tokens from this smart contract
    function transferAnyLegacyERC20Token(address tokenAddress, address recipient, uint amount) external onlyOwner {
        require (tokenAddress != TRUSTED_TOKEN_ADDRESS || now > contractStartTime.add(ADMIN_CAN_CLAIM_AFTER), "Cannot Transfer Out main tokens!");
        LegacyToken(tokenAddress).transfer(recipient, amount);
    }
}