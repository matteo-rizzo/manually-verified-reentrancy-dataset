/**
 *Submitted for verification at Etherscan.io on 2021-06-19
*/

/**
 *Submitted for verification at Etherscan.io on 2021-06-19
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: MasterChef.sol

contract MasterChef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    // Info of each user.
    struct UserInfo {
        uint256 depositTime;
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
        uint256 reward;
    }
    // Info of each pool.
    struct PoolInfo {
        IERC20  lpToken; // Address of LP token contract.
        uint256 amount;  // How many LP tokens.
        uint256 allocPoint; // How many allocation points assigned to this pool. Token to distribute per block.
        uint256 lastRewardTime; // Last block number that Token distribution occurs.
        uint256 accTokenPerShare; // Accumulated Token per share, times 1e18. See below.
    }

    address public governance;
    address public pendingGovernance;
    address public guardian;
    uint256 public guardianTime;

    IERC20  public rewardToken;
    uint256 public totalReward;
    uint256 public totalGain;
    uint256 public epochId;
    uint256 public intervalTime;

    uint256 public reward;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public period;

    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;

    // Info of each pool.
    PoolInfo[] public poolInfos;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfos;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 reward);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid,  uint256 amount);

    constructor(address _rewardToken, uint256 _intervalTime) public {
        rewardToken = IERC20(_rewardToken);
        intervalTime = _intervalTime;
        governance = msg.sender;
        guardian = msg.sender;
        guardianTime = block.timestamp + 2592000; // 30 day
    }

    function setGuardian(address _guardian) public {
        require(msg.sender == guardian, "!guardian");
        guardian = _guardian;
    }

    function acceptGovernance() public {
        require(msg.sender == pendingGovernance, "!pendingGovernance");
        governance = msg.sender;
        pendingGovernance = address(0);
    }

    function setPendingGovernance(address _pendingGovernance) public {
        require(msg.sender == governance, "!governance");
        pendingGovernance = _pendingGovernance;
    }

    function setReward(uint256 _startTime, uint256 _period, uint256 _reward, bool _withUpdate) public {
        require(msg.sender == governance, "!governance");
        require(endTime < block.timestamp, "!endTime");
        require(block.timestamp <= _startTime, "!_startTime");
        require(_period > 0, "!_period");
        if (_withUpdate) {
            massUpdatePools();
        }

        // transfer _reward token
        uint256 _balance = rewardToken.balanceOf(address(this));
        require(_balance >= _reward, "!_reward");
        reward = _reward;

        totalReward = totalReward.add(reward);
        startTime = _startTime;
        endTime = _startTime.add(_period);
        period = _period;
        epochId++;
    }

    function setIntervalTime(uint256 _intervalTime) public {
        require(msg.sender == governance, "!governance");
        intervalTime = _intervalTime;
    }

    function setAllocPoint(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public {
        require(msg.sender == governance, "!governance");
        require(_pid < poolInfos.length, "!_pid");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfos[_pid].allocPoint).add(_allocPoint);
        require(totalAllocPoint > 0, "!totalAllocPoint");
        poolInfos[_pid].allocPoint = _allocPoint;
    }

    function addPool(address _lpToken, uint256 _allocPoint, bool _withUpdate) public {
        require(msg.sender == governance, "!governance");
        uint256 length = poolInfos.length;
        for (uint256 i = 0; i < length; i++) {
            require(_lpToken != address(poolInfos[i].lpToken), "!_lpToken");
        }
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 _lastRewardTime = block.timestamp > startTime ? block.timestamp : startTime;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfos.push(
            PoolInfo({
                lpToken: IERC20(_lpToken),
                amount: 0,
                allocPoint: _allocPoint,
                lastRewardTime: _lastRewardTime,
                accTokenPerShare: 0
            })
        );
    }

    function getReward(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= startTime || _from >= endTime) {
            return 0;
        }

        if (_from < startTime) {
            _from = startTime; // [startTime, endTime)
        }

        if (_to > endTime){
            _to = endTime;  // (startTime, endTime]
        }
        require(_from < _to, "!_from < _to");

        return _to.sub(_from).mul(reward).div(period);
    }

    // View function to see pending Token on frontend.
    function pendingToken(uint256 _pid, address _user) external view returns (uint256) {
        require(_pid < poolInfos.length, "!_pid");
        PoolInfo storage pool = poolInfos[_pid];
        UserInfo storage user = userInfos[_pid][_user];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 lpSupply = pool.amount;
        if (block.timestamp > startTime && pool.lastRewardTime < endTime && block.timestamp > pool.lastRewardTime && lpSupply != 0) {
            uint256 rewardTokenReward =  getReward(pool.lastRewardTime, block.timestamp).mul(pool.allocPoint).div(totalAllocPoint);
            accTokenPerShare = accTokenPerShare.add(rewardTokenReward.mul(1e18).div(lpSupply));
        }
        uint256 _reward = user.amount.mul(accTokenPerShare).div(1e18).sub(user.rewardDebt);
        return user.reward.add(_reward);
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfos.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        require(_pid < poolInfos.length, "!_pid");

        PoolInfo storage pool = poolInfos[_pid];
        if (block.timestamp <= pool.lastRewardTime) {
            return;
        }
        if (block.timestamp <= startTime) {
            pool.lastRewardTime = startTime;
            return;
        }

        if (pool.lastRewardTime >= endTime) {
            pool.lastRewardTime = block.timestamp;
            return;
        }

        uint256 lpSupply = pool.amount;
        if (lpSupply == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }

        uint256 rewardTokenReward = getReward(pool.lastRewardTime, block.timestamp).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accTokenPerShare = pool.accTokenPerShare.add(rewardTokenReward.mul(1e18).div(lpSupply));
        pool.lastRewardTime = block.timestamp;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        require(_pid < poolInfos.length, "!_pid");
        PoolInfo storage pool = poolInfos[_pid];
        UserInfo storage user = userInfos[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 _reward = user.amount.mul(pool.accTokenPerShare).div(1e18).sub(user.rewardDebt);
            user.reward = _reward.add(user.reward);
        }
        pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);
        user.depositTime = block.timestamp;
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e18);
        pool.amount = pool.amount.add(_amount);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        require(_pid < poolInfos.length, "!_pid");
        PoolInfo storage pool = poolInfos[_pid];
        UserInfo storage user = userInfos[_pid][msg.sender];
        require(user.amount >= _amount, "!_amount");
        require(block.timestamp >= user.depositTime + intervalTime, "!intervalTime");
        updatePool(_pid);
        uint256 _reward = user.amount.mul(pool.accTokenPerShare).div(1e18).sub(user.rewardDebt);
        user.reward = _reward.add(user.reward);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e18);
        pool.amount = pool.amount.sub(_amount);
        pool.lpToken.safeTransfer(msg.sender, _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function harvest(uint256 _pid) public{
        require(_pid < poolInfos.length, "!_pid");
        PoolInfo storage pool = poolInfos[_pid];
        UserInfo storage user = userInfos[_pid][msg.sender];
        updatePool(_pid);
        uint256 _reward = user.amount.mul(pool.accTokenPerShare).div(1e18).sub(user.rewardDebt);
        _reward = _reward.add(user.reward);
        user.reward = 0;
        safeTokenTransfer(msg.sender, _reward);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e18);
        emit Harvest(msg.sender, _pid, _reward);
    }

    function withdrawAndHarvest(uint256 _pid, uint256 _amount) public {
        require(_pid < poolInfos.length, "!_pid");
        PoolInfo storage pool = poolInfos[_pid];
        UserInfo storage user = userInfos[_pid][msg.sender];
        require(user.amount >= _amount, "!_amount");
        require(block.timestamp >= user.depositTime + intervalTime, "!intervalTime");
        updatePool(_pid);
        uint256 _reward = user.amount.mul(pool.accTokenPerShare).div(1e18).sub(user.rewardDebt);
        _reward = _reward.add(user.reward);
        user.reward = 0;
        safeTokenTransfer(msg.sender, _reward);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e18);
        pool.amount = pool.amount.sub(_amount);
        pool.lpToken.safeTransfer(msg.sender, _amount);
        emit Withdraw(msg.sender, _pid, _amount);
        emit Harvest(msg.sender, _pid, _reward);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        require(_pid < poolInfos.length, "!_pid");
        PoolInfo storage pool = poolInfos[_pid];
        UserInfo storage user = userInfos[_pid][msg.sender];
        require(block.timestamp >= user.depositTime + 1, "!intervalTime"); // prevent flash loan
        uint256 _amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.amount = pool.amount.sub(_amount);
        pool.lpToken.safeTransfer(msg.sender, _amount);
        emit EmergencyWithdraw(msg.sender, _pid, _amount);
    }

    // Safe rewardToken transfer function, just in case if rounding error causes pool to not have enough Token.
    function safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 _balance = rewardToken.balanceOf(address(this));
        if (_amount > _balance) {
            totalGain = totalGain.add(_balance);
            rewardToken.safeTransfer(_to, _balance);
        } else {
            totalGain = totalGain.add(_amount);
            rewardToken.safeTransfer(_to, _amount);
        }
    }

    function poolLength() external view returns (uint256) {
        return poolInfos.length;
    }

    function annualReward(uint256 _pid) public view returns (uint256){
        require(_pid < poolInfos.length, "!_pid");
        PoolInfo storage pool = poolInfos[_pid];
        // SECS_PER_YEAR  31_556_952  365.2425 days
        return reward.mul(31556952).mul(pool.allocPoint).div(totalAllocPoint).div(period);
    }

    function annualRewardPerShare(uint256 _pid) public view returns (uint256){
        require(_pid < poolInfos.length, "!_pid");
        PoolInfo storage pool = poolInfos[_pid];
        return annualReward(_pid).mul(1e18).div(pool.amount);
    }

    function sweepGuardian(address _token) public {
        require(msg.sender == guardian, "!guardian");
        require(block.timestamp > guardianTime, "!guardianTime");

        uint256 _balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(governance, _balance);
    }

    function sweep(address _token) public {
        require(msg.sender == governance, "!governance");
        require(_token != address(rewardToken), "!_token");
        uint256 length = poolInfos.length;
        for (uint256 i = 0; i < length; i++) {
            require(_token != address(poolInfos[i].lpToken), "!_token");
        }

        uint256 _balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(governance, _balance);
    }

    function sweepLpToken(uint256 _pid) public {
        require(msg.sender == governance, "!governance");
        require(_pid < poolInfos.length, "!_pid");
        PoolInfo storage pool = poolInfos[_pid];
        IERC20 _token = pool.lpToken;

        uint256 _balance = _token.balanceOf(address(this));
        uint256 _amount = _balance.sub(pool.amount);
        _token.safeTransfer(governance, _amount);
    }
}