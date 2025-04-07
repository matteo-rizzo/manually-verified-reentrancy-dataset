/**
 *Submitted for verification at Etherscan.io on 2021-04-07
*/

pragma solidity 0.8.3;

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
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




contract BTAP_ETH_Pool is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint256 amount);
    
    // BTAP token contract address
    address public tokenAddress = 0x270371C58D9D775ED73971Dd414656107384f235;
    
    // BTAP/ETH LP token contract address
    address public LPtokenAddress = 0x709043b155f73589EEA2c4aEFd8FF3108F11134e;
    
    // Dev address to collect 10 % fee
    address public devAddress = 0xf655172B4dD0178B6A7C85D59c3b235C6A8cE68a;
    
    // reward rate 250 % per year
    uint256 public rewardRate = 122281;
    uint256 public devFee = 1000;
    uint256 public rewardInterval = 365 days;
    
    // unstaking possible after 5 days
    uint256 public cliffTime = 5 days;
    
    uint256 public farmEnableat;
    uint256 public totalClaimedRewards;
    uint256 public totalDevFee;
    uint256 private stakingAndDaoTokens = 100000e18; // Maximum token amount can be farmed.
    
    bool public farmEnabled = false;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint256) public depositedTokens;
    mapping (address => uint256) public stakingTime;
    mapping (address => uint256) public lastClaimedTime;
    mapping (address => uint256) public totalEarnedTokens;
    
    function updateAccount(address account) private {
        uint256 pendingDivs = getPendingDivs(account);
        uint256 fee = pendingDivs.mul(devFee).div(1e4);
        uint256 pendingDivsAfterFee = pendingDivs.sub(fee);
        
        if (pendingDivsAfterFee > 0) {
            require(Token(tokenAddress).transfer(account, pendingDivsAfterFee), "Could not transfer tokens.");
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivsAfterFee);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivsAfterFee);
            emit RewardsTransferred(account, pendingDivsAfterFee);
        }
        
        if (fee > 0) {
            require(Token(tokenAddress).transfer(devAddress, fee), "Could not transfer tokens.");
            totalDevFee = totalDevFee.add(fee);
            emit RewardsTransferred(devAddress, fee);
        }
        
        lastClaimedTime[account] = block.timestamp;
    }
    
    function getPendingDivs(address _holder) public view returns (uint256 _pendingDivs) {
        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;
        
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]);
        uint256 stakedAmount = depositedTokens[_holder];
        
        uint256 pendingDivs = stakedAmount.mul(rewardRate).mul(timeDiff).div(rewardInterval).div(1e4);
        
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint256) {
        return holders.length();
    }
    
    function deposit(uint256 amountToStake) public {
        require(amountToStake >= 24456053260000000 && amountToStake <= 122280266300000000000, "Invalid amount");
        require(farmEnabled, "Farming not enabled yet");
        require(Token(LPtokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        updateAccount(msg.sender);
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountToStake);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            stakingTime[msg.sender] = block.timestamp;
        }
    }
    
    function withdraw(uint256 amountToWithdraw) public {
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
        require(block.timestamp.sub(stakingTime[msg.sender]) > cliffTime, "You recently staked, please wait before withdrawing.");
        
        updateAccount(msg.sender);
        
        require(Token(LPtokenAddress).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");
        
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
    
    function setTokenAddress(address _tokenAddress) public onlyOwner {
        tokenAddress = _tokenAddress;
    }
    
    function setDevAddress(address _devAddress) public onlyOwner {
        devAddress = _devAddress;
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
    
    function setRewardRate(uint256 _rewardRate) public onlyOwner {
        rewardRate = _rewardRate;
    }
    
    function setDevdFee(uint256 _devFee) public onlyOwner {
        devFee = _devFee;
    }
    
    function enableFarming() external onlyOwner() {
        farmEnabled = true;
        farmEnableat = block.timestamp;
    }
    
    // function to allow admin to claim *any* ERC20 tokens sent to this contract
    function transferAnyERC20Tokens(address _tokenAddress, address _to, uint256 _amount) public onlyOwner {
        require(_tokenAddress != LPtokenAddress);
        
        Token(_tokenAddress).transfer(_to, _amount);
    }
}