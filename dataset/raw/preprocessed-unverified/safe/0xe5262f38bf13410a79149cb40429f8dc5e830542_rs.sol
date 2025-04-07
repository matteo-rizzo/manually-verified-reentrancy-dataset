/**
 *Submitted for verification at Etherscan.io on 2021-08-03
*/

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.6.11;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
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


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */




contract ConstantReturnStaking_BuyBack is Ownable {
    using Address for address;
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    
    event RewardsTransferred(address indexed holder, uint amount);
    event DepositTokenAdded(address indexed tokenAddress);
    event DepositTokenRemoved(address indexed tokenAddress);
    event Stake(address indexed holder, uint amount);
    event Unstake(address indexed holder, uint amount);
    
    event EmergencyDeclared(address indexed owner);
    
    // ============================= CONTRACT VARIABLES ==============================
    
    // stake token contract address
    address public constant TRUSTED_TOKEN_ADDRESS = 0x961C8c0B1aaD0c0b10a51FeF6a867E3091BCef17;
    
    // earnings reward rate
    uint public constant REWARD_RATE_X_100 = 34e2;
    uint public constant REWARD_INTERVAL = 120 days;
    
    // unstaking possible after lockup time
    uint public LOCKUP_TIME = 60 days;
    
    uint public constant ADMIN_CAN_CLAIM_AFTER = 130 days;
    
    // admin can transfer ALL tokens from this contract after this time
    uint public constant EMERGENCY_WAIT_TIME = 3 days;
    
    // Uniswap v2 Router
    IUniswapV2Router public constant uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 
    
    // ========================= END CONTRACT VARIABLES ==============================
    
    uint public totalClaimedRewards = 0;
    uint public totalDepositedTokens;
    bool public isEmergency = false;
    
    uint public immutable contractStartTime;
    
    // Contracts are not allowed to deposit, claim or withdraw
    modifier noContractsAllowed() {
        require(tx.origin == msg.sender, "No Contracts Allowed!");
        _;
    }
    
    modifier notDuringEmergency() {
        require(!isEmergency, "Cannot execute during emergency!");
        _;
    }
    
    function declareEmergency() external onlyOwner notDuringEmergency {
        isEmergency = true;
        adminClaimableTime = now.add(EMERGENCY_WAIT_TIME);
        LOCKUP_TIME = 0;
        
        uint contractBalance = IERC20(TRUSTED_TOKEN_ADDRESS).balanceOf(address(this));
        uint adminBalance = 0;
        
        if (contractBalance >= totalDepositedTokens) {
            adminBalance = contractBalance.sub(totalDepositedTokens);
        }
        if (adminBalance > 0) {
            IERC20(TRUSTED_TOKEN_ADDRESS).safeTransfer(owner, adminBalance);
        }
        
        emit EmergencyDeclared(owner);
    }
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public stakingTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    
    mapping (address => uint) public rewardsPendingClaim;
    
    uint public adminClaimableTime;
    
    constructor() public {
        contractStartTime = now;
        adminClaimableTime = now.add(ADMIN_CAN_CLAIM_AFTER);
    }
    
    mapping (address => bool) public trustedDepositTokens;
    function addTrustedDepositToken(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0), "Cannot add 0 address!");
        require(_tokenAddress != TRUSTED_TOKEN_ADDRESS, "Cannot add reward token as deposit token!");
        trustedDepositTokens[_tokenAddress] = true;
        emit DepositTokenAdded(_tokenAddress);
    }
    function removeTrustedDepositToken(address _tokenAddress) external onlyOwner {
        trustedDepositTokens[_tokenAddress] = false;
        emit DepositTokenRemoved(_tokenAddress);
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
    
    function getTotalPendingDivs(address _holder) external view returns (uint) {
        uint pending = getPendingDivs(_holder);
        uint awaitingClaim = rewardsPendingClaim[_holder];
        return pending.add(awaitingClaim);
    }
    
    function getNumberOfHolders() external view returns (uint) {
        return holders.length();
    }
    
    function stake(uint amountToDeposit, address depositToken, uint _amountOutMin, uint _deadline) external noContractsAllowed notDuringEmergency {
        require(amountToDeposit > 0, "Cannot deposit 0 Tokens!");
        require(depositToken != address(0), "Deposit Token Cannot be 0!");
        require(depositToken != TRUSTED_TOKEN_ADDRESS, "Deposit token cannot be same as reward token!");
        require(trustedDepositTokens[depositToken], "Deposit token not trusted yet!");
        IERC20(depositToken).safeTransferFrom(msg.sender, address(this), amountToDeposit);
        IERC20(depositToken).safeApprove(address(uniswapV2Router), 0);
        IERC20(depositToken).safeApprove(address(uniswapV2Router), amountToDeposit);
        
        uint oldPlatformTokenBalance = IERC20(TRUSTED_TOKEN_ADDRESS).balanceOf(address(this));
        
        address[] memory path;
        
        if (depositToken == uniswapV2Router.WETH()) {
            path = new address[](2);
            path[0] = depositToken;
            path[1] = TRUSTED_TOKEN_ADDRESS;
        } else {
            path = new address[](3);
            path[0] = depositToken;
            path[1] = uniswapV2Router.WETH();
            path[2] = TRUSTED_TOKEN_ADDRESS;
        }
        
        uniswapV2Router.swapExactTokensForTokens(amountToDeposit, _amountOutMin, path, address(this), _deadline);
        
        uint newPlatformTokenBalance = IERC20(TRUSTED_TOKEN_ADDRESS).balanceOf(address(this));
        uint platformTokensReceived = newPlatformTokenBalance.sub(oldPlatformTokenBalance);
        uint amountToStake = platformTokensReceived;
        
        require(amountToStake > 0, "Cannot stake 0 Tokens");
        
        updateAccount(msg.sender);
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountToStake);
        totalDepositedTokens = totalDepositedTokens.add(amountToStake);
        
        holders.add(msg.sender);
        
        stakingTime[msg.sender] = now;
        emit Stake(msg.sender, amountToStake);
    }
    
    function unstake(uint amountToWithdraw) external noContractsAllowed {
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        require(now.sub(stakingTime[msg.sender]) > LOCKUP_TIME, "You recently staked, please wait before withdrawing.");
        
        updateAccount(msg.sender);
        
        require(IERC20(TRUSTED_TOKEN_ADDRESS).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        if (totalDepositedTokens >= amountToWithdraw) {
            totalDepositedTokens = totalDepositedTokens.sub(amountToWithdraw);
        }
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
        emit Unstake(msg.sender, amountToWithdraw);
    }
    
    // emergency unstake without caring about pending earnings
    // pending earnings will be lost / set to 0 if used emergency unstake
    function emergencyUnstake(uint amountToWithdraw) external noContractsAllowed {
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        require(now.sub(stakingTime[msg.sender]) > LOCKUP_TIME, "You recently staked, please wait before withdrawing.");
        
        // set pending earnings to 0 here
        lastClaimedTime[msg.sender] = now;
        
        require(IERC20(TRUSTED_TOKEN_ADDRESS).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        if (totalDepositedTokens >= amountToWithdraw) {
            totalDepositedTokens = totalDepositedTokens.sub(amountToWithdraw);
        }
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
        emit Unstake(msg.sender, amountToWithdraw);
    }
    
    function claim() external noContractsAllowed notDuringEmergency {
        updateAccount(msg.sender);
        uint amount = rewardsPendingClaim[msg.sender];
        if (amount > 0) {
            rewardsPendingClaim[msg.sender] = 0;
            require(IERC20(TRUSTED_TOKEN_ADDRESS).transfer(msg.sender, amount), "Could not transfer earned tokens.");  
            emit RewardsTransferred(msg.sender, amount);
        }
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
    
    // admin can claim any tokens left in the contract after it expires
    function claimAnyToken(address token, uint amount) external onlyOwner {
        require(now > adminClaimableTime, "Contract not expired yet!");
        if (token == address(0)) {
            msg.sender.transfer(amount);
            return;
        }
        IERC20(token).safeTransfer(msg.sender, amount);
    }
}