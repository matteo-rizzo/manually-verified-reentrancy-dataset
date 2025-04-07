/**
 *Submitted for verification at Etherscan.io on 2021-09-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */


contract StakingFactory {
    
    ManagerRole public manager;
    
    constructor(ManagerRole _manager) {
        manager = _manager;
    }
    
    modifier onlyManager {
        require(manager.isManager(msg.sender), "Manager:: Unauthorized Access");
        _;
    }
    
    struct Stake {
        address _stakingToken;     
        uint256 _stakingPool;
        uint256 _stakingPoolRewards;
        uint256 _stakingOpenTime;
        uint256 _stakingDuration;
    }
    mapping (address => Stake) public Stakes;
    Staking[] public allStakes;
    address[] noOfStakes;
    
    event NewStakingCreated(address _address);
    
    function createStaking(address _stakingToken, uint256 _stakingPool, uint256 _stakingPoolRewards, uint256 _stakingOpenTime, uint256 _stakingDuration, ManagerRole _manager) external onlyManager {
        Staking _staking = new Staking(_stakingToken, _stakingPool, _stakingPoolRewards, _stakingOpenTime, _stakingDuration, _manager);
        Stakes[address(_staking)]._stakingToken = _stakingToken;
        Stakes[address(_staking)]._stakingPool = _stakingPool;
        Stakes[address(_staking)]._stakingPoolRewards = _stakingPoolRewards;
        Stakes[address(_staking)]._stakingOpenTime = _stakingOpenTime;
        Stakes[address(_staking)]._stakingDuration = _stakingDuration;
        allStakes.push(_staking);
        noOfStakes.push(address(_staking));
        emit NewStakingCreated(address(_staking));
    }

    function totalStakes() external view returns(uint256) {
        return noOfStakes.length;
    }

    function getAllStakes() external view returns(address[] memory) {
        return noOfStakes;
    }
}

contract Staking {
    
    using SafeMath for uint256;
    ManagerRole public manager;

    struct StakeHolder {
        bool isClaimed;                 // Current Staking status
        uint256 amount;                 // Current active stake
        uint256 stakedBlock;            // Last staked block (if any)
        uint256 releaseBlock;           // Last claimed block (if any)
        uint256 claimedOn;              // Last time claimed
        uint256 rewards;                // Rewards
    }
    mapping (address => StakeHolder) public StakeHolders;
    
    // List of stake holders
    address[] private allStakeHolders;
    
    // Stake & Reward Token
    address public stakeToken;

    // To check if the staking is paused
    bool public isStakingPaused;

    // To check if the pool is Active
    bool public isPoolActive;
    
    // No.of Staking Pool Tokens 
    uint256 public stakingPool;

    // No.of Staking Pool Rewards
    uint256 public stakingPoolRewards;

    // Staking Duration in Days
    uint256 public stakingDuration;

    // Staking Opening Time for users to stake
    uint256 public stakingOpenTime;

    // Staking reward start block
    uint256 public stakingStartBlock;

    // Staking rewards ending block
    uint256 public stakingEndBlock;

    // No.of Staking Blocks
    uint256 public noOfStakingBlocks;

    // No.of users staked
    uint256 public noOfStakes;
    
    // 6440 is the avg no.of Ethereum Blocks per day, Applicable only for Ethereum network 
    uint256 public avgETHBlocksPerDay = 6440;

    // To calculate the no.of Currently staked tokens
    uint256 public currentPool;

    // To check if the users are fully calimed
    bool public isPoolFullyClaimed;

    // no.of Days in a Year
    uint256 private daysInAYear = 365;

    /* EVENTS */
    event Staked(address _address, uint256 _stakedTokens);
    event Claimed(address _address, uint256 _stakedTokens, uint256 _claimedTokens);
    event Paused(bool _status, uint256 _timestamp, uint256 _blockNumber);
    event Withdraw(address _stakeToken, address _hotwallet, uint256 _noOfTokens, uint256 _timestamp, uint256 _blockNumber);
    event SafeWithdraw(address _stakeToken, address _hotwallet, uint256 _noOfTokens, uint256 _timestamp, uint256 _blockNumber);
    event EmergencyWithdraw(address _stakeToken, address _hotwallet, uint256 _noOfTokens, uint256 _timestamp, uint256 _blockNumber);

    /**
     * @param _stakingToken address of the Token which user stakes
     * @param _stakingPool is the total no.of tokens to meet the requirement to start the staking
     * @param _stakingPoolRewards is the total no.of rewards for the _rewardCapital
     * @param _stakingOpenTime is the pool opening time (like count down) epoch
     * @param _stakingDuration is the statking duration of staking ex: 30 days, 60 days, 90 days... in days
     * @param _manager is to manage the managers of the contracts
     */
    constructor(address _stakingToken, uint256 _stakingPool, uint256 _stakingPoolRewards, uint256 _stakingOpenTime, uint256 _stakingDuration, ManagerRole _manager) {
        stakeToken= _stakingToken;
        stakingPool = _stakingPool;
        stakingPoolRewards = _stakingPoolRewards;
        stakingOpenTime = _stakingOpenTime;
        stakingDuration = _stakingDuration;
        stakingStartBlock = _currentBlockNumber();
        manager = _manager;
        isStakingPaused = false;
        isPoolActive = false;
        noOfStakes = 0;
    }

    function hotWallet() internal view returns(address) {
        return manager.getHotWallet();
    }

    function getAPY() external view returns(uint256) {
        uint256 apy = stakingPoolRewards.mul(daysInAYear).mul(100).div(stakingPool.mul(stakingDuration));
        return apy;
    }
    
    /* MODIFIERS */
    modifier onlyManager {
        require(manager.isManager(msg.sender), "Manager:: Unauthorized Access");
        _;
    }

    /**
     * @notice This is the endpoint for staking
     * @param _noOfTokens is the no.of Tokens user want to stake into the pool in WEI
     */
    function stake(uint256 _noOfTokens) external {
        require(isStakingPaused == false, "Stake:: Staking is paused");
        require(_noOfTokens > 0, "Stake:: Can not stake Zero Tokens");
        require(_currentBlockTimestamp() > stakingOpenTime, "Stake:: Staking have not started for this pool");
        require(stakingPool > currentPool, "Stake:: Staking Pool is Full");
        require(_noOfTokens <= stakingPool.sub(currentPool), "Stake: Can not stake more than pool size");
        _stake(_noOfTokens);
    }

    /**
     * @notice This is the internal staking function which can be called by stake
     * @param _noOfTokens is the no.of Tokens user want to stake into the pool in WEI
     */
    function _stake(uint256 _noOfTokens) internal {
        IERC20(stakeToken).transferFrom(msg.sender, address(this), _noOfTokens);
        StakeHolders[msg.sender].amount = StakeHolders[msg.sender].amount.add(_noOfTokens);
        StakeHolders[msg.sender].isClaimed = false;
        StakeHolders[msg.sender].stakedBlock = block.number;
        StakeHolders[msg.sender].rewards = _calculateRewards(_noOfTokens);
        currentPool = currentPool.add(_noOfTokens);
        if(stakingPool == currentPool) {
            isPoolActive = true;
            stakingEndBlock = _currentBlockNumber().add(stakingDuration.mul(avgETHBlocksPerDay));
        }
        noOfStakes = noOfStakes.add(1);
        allStakeHolders.push(msg.sender);
        emit Staked(msg.sender, _noOfTokens);
    }

    /**
     * @notice This is the internal reward calculation function which can be called by _stake
     * @param _noOfTokens is the no.of Tokens user want to stake into the pool in WEI
     */
    function _calculateRewards(uint256 _noOfTokens) internal view returns (uint256) {
        uint256 userShareInPool = (_noOfTokens.mul(1e6)).div(stakingPool);
        return StakeHolders[msg.sender].rewards.add((userShareInPool.mul(stakingPoolRewards)).div(1e6));
    }

    /**
     * @notice This is the external function to calculate reward
     * @param _noOfTokens is the no.of Tokens user want to stake into the pool in WEI
     */
    function calculateRewardsView(address _wallet, uint256 _noOfTokens) external view returns (uint256) {
        uint256 userShareInPool = (_noOfTokens.mul(1e6)).div(stakingPool);
        return StakeHolders[_wallet].rewards.add((userShareInPool.mul(stakingPoolRewards)).div(1e6));
    }

    /**
     * @notice This is the endpoint for Claiming the Stake + Rewards
     */
    function claim() external {
        require(isStakingPaused == false, "Claim:: Pool is Paused");
        require(isPoolActive == true, "Claim:: Pool is not active");
        require(StakeHolders[msg.sender].isClaimed == false, "Claim:: Already Claimed");
        require(StakeHolders[msg.sender].amount > 0, "Claim:: Seems like haven't staked to claim");
        require(_currentBlockNumber() > stakingEndBlock, "Claim:: You can not claim before staked duration");
        require(IERC20(stakeToken).balanceOf(address(this)) >= (StakeHolders[msg.sender].amount).add(StakeHolders[msg.sender].rewards), "Claim:: Insufficient Balance");
        _claim();
    }

    /**
     * @notice This is the internal function which will be called by claim
     */
    function _claim() internal {
        uint256 claimedTokens = StakeHolders[msg.sender].amount;
        uint256 claimedRewards = StakeHolders[msg.sender].rewards;
        IERC20(stakeToken).transfer(msg.sender, claimedTokens);
        IERC20(stakeToken).transfer(msg.sender, claimedRewards);
        StakeHolders[msg.sender].isClaimed = true;
        StakeHolders[msg.sender].amount = claimedTokens;
        StakeHolders[msg.sender].rewards = claimedRewards;
        StakeHolders[msg.sender].releaseBlock = _currentBlockNumber();
        StakeHolders[msg.sender].claimedOn = _currentBlockTimestamp();
        updateFullyClaimed();
        emit Claimed(msg.sender, claimedTokens, claimedRewards);
    }

    /**
     * @notice Admin Function
     */
    function pauseStaking() external onlyManager {
        isStakingPaused = true;
        emit Paused(isStakingPaused, block.timestamp, block.number);
    }

    /**
     * @notice Admin Function
     */
    function unPauseStaking() external onlyManager {
        isStakingPaused = false;
        emit Paused(isStakingPaused, block.timestamp, block.number);
    }

    /**
     * @notice This is the internal function which fetch the Current Time Stamp from Network
     */
    function _currentBlockTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }

    /**
     * @notice This is the internal function which fetch the Current Block number from Network
     */
    function _currentBlockNumber() internal view returns (uint256) {
        return block.number;
    }

    /**
     * @notice This is the external function which allow user to check the staking status
     */
    function claimStatus(address _address) external view returns (bool) {
        return StakeHolders[_address].isClaimed;
    }

    /**
     * @notice This is the external function to fetch the wallet and token information
     */
    function stakeTokenInfo(address _wallet) external view returns(string memory, string memory, uint256) {
        return (IERC20(stakeToken).name(), IERC20(stakeToken).symbol(), IERC20(stakeToken).balanceOf(_wallet));
    }
    
    /**
     * @notice Admin Function
     */
    function withdraw(uint256 _noOfTokens) external onlyManager {
        require(_currentBlockNumber() < stakingEndBlock, "Withdraw:: Invalid withdraw");
        require(IERC20(stakeToken).balanceOf(address(this)) >= _noOfTokens, "Withdraw:: Invalid Balance");
        IERC20(stakeToken).transfer(hotWallet(), _noOfTokens);
        emit Withdraw(stakeToken, hotWallet(), _noOfTokens, block.timestamp, block.number);
    }
    
    /**
     * @notice Admin Function
     */
    function safeWithdraw() external onlyManager {
        require(_currentBlockNumber() > stakingEndBlock, "SafeWithdraw:: Invalid withdraw");
        
        // Unclaimed Tokens
        uint256 notClaimedStake;
        uint256 notClaimedRewards;
        
        // Claimed Tokens
        uint256 claimedStake;
        uint256 claimedRewards;
        
        for(uint256 i=0; i<allStakeHolders.length; i++) {
            if(StakeHolders[allStakeHolders[i]].isClaimed == false) {
                notClaimedStake = notClaimedStake.add(StakeHolders[allStakeHolders[i]].amount);
                notClaimedRewards = notClaimedRewards.add(StakeHolders[allStakeHolders[i]].rewards); 
            } else if (StakeHolders[allStakeHolders[i]].isClaimed == true) {
                claimedStake = claimedStake.add(StakeHolders[allStakeHolders[i]].amount);
                claimedRewards = claimedRewards.add(StakeHolders[allStakeHolders[i]].rewards); 
            }
        }
        
        // Calculate Balance
        uint256 totalUnClaimed = notClaimedStake.add(notClaimedRewards);
        uint256 balanceInContract = IERC20(stakeToken).balanceOf(address(this));
        
        if(balanceInContract > totalUnClaimed) {
            IERC20(stakeToken).transfer(hotWallet(), balanceInContract.sub(totalUnClaimed));
            emit SafeWithdraw(stakeToken, hotWallet(), balanceInContract.sub(totalUnClaimed), block.timestamp, block.number);
        }
    }

    /**
     * @notice Total Unclaimed Tokens
     */
    function totalUnClaimedTokens() public view returns(uint256) {        
        uint256 notClaimedStake;
        uint256 notClaimedRewards;
        for(uint256 i=0; i<allStakeHolders.length; i++) {
            if(StakeHolders[allStakeHolders[i]].isClaimed == false) {
                notClaimedStake = notClaimedStake.add(StakeHolders[allStakeHolders[i]].amount);
                notClaimedRewards = notClaimedRewards.add(StakeHolders[allStakeHolders[i]].rewards); 
            }
        }
        uint256 totalUnClaimed = notClaimedStake.add(notClaimedRewards);
        return totalUnClaimed;
    }

    /**
     * @notice Update Fully Claimed Status
     */
    function updateFullyClaimed() internal {
        if(totalUnClaimedTokens() == 0) {
            isPoolFullyClaimed = true;
        }
    }

    /**
     * @notice Get the current balance of the tokens in the contract
     */
    function balanceOfContact() external view returns(uint256) {
        return IERC20(stakeToken).balanceOf(address(this));
    }

    /**
     * @notice Get the current balance of the tokens
     */
    function balanceToMaintain() external view returns(uint256) {
        uint256 currentBalance = IERC20(stakeToken).balanceOf(address(this));
        uint256 totalUnClaimed = totalUnClaimedTokens();
        if(totalUnClaimed > currentBalance) {
            return totalUnClaimed.sub(currentBalance);
        } else {
            return 0;
        }
    }

    /** 
     * @notice EMERGENCY WITHDRAWL is used to empty the balance in contract in case of Emergency Situation
     */
    function emergencyWithdrawl() external onlyManager {
        isStakingPaused = true;
        uint256 balanceInContract = IERC20(stakeToken).balanceOf(address(this));
        IERC20(stakeToken).transfer(hotWallet(), balanceInContract);
        emit EmergencyWithdraw(stakeToken, hotWallet(), balanceInContract, block.timestamp, block.number);
    }
}

contract ManagerRole {
    address public superAdmin;
    address _hotWallet;

    event ManagerAdded(address _manager, bool _status);
    event ManagerUpdated(address _manager, bool _status);
    event HotWalletUpdated(address _oldHotWallet, address _newHotWallet);
    
    constructor(address _wallet) {
        require(_wallet != address(0), "Hotwallet can't be the zero address");
        superAdmin = msg.sender;
        _hotWallet = _wallet;
    }
    
    modifier onlySuperAdmin {
        require(superAdmin == msg.sender, "Unauthorized Access");
        _;
    }

    struct Manager {
        address _manager;
        bool _isActive;
    }
    
    mapping (address => Manager) public managers;
    
    function addManager(address _address, bool _status) external onlySuperAdmin {
        require(_address != address(0), "Manager can't be the zero address");
        managers[_address]._manager = _address;
        managers[_address]._isActive = _status;
        emit ManagerAdded(_address, _status);
    }
    
    function getManager(address _address) view external returns (address, bool) {
        return(managers[_address]._manager, managers[_address]._isActive);
    }

    function isManager(address _address) external view returns(bool _status) {
        return(managers[_address]._isActive);
    }
    
    function updateManager(address _address, bool _status) external onlySuperAdmin {
        require(_address != address(0), "Manager can't be the zero address");
        require(managers[_address]._isActive != _status);
        managers[_address]._isActive = _status;
        emit ManagerUpdated(_address, _status);
    }
    
    function governance() external view returns(address){
        return superAdmin;
    }
    
    function getHotWallet() external view returns(address) {
        return _hotWallet;
    }
    
    function setNewHotWallet(address _newHotWallet) external onlySuperAdmin {
        require(_newHotWallet != address(0), "Hotwallet can't be the zero address");
        address _oldHotWallet = _hotWallet;
        _hotWallet = _newHotWallet;
        emit HotWalletUpdated(_oldHotWallet, _newHotWallet);
    }
    
}

