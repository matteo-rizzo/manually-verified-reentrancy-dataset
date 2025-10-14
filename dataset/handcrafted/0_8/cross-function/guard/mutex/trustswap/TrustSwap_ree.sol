// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;


// Simplified interface of the OpenZeppelin's IERC20 and SafeERC20 libraries for sake of example
interface IERC20 {
    function safeTransfer(address to, uint256 value) external;
    function safeTransferFrom(address from, address to, uint256 value) external;
    function balanceOf(address account) external view returns (uint256);
}

// Simplified Ownable contract for sake of example
contract SimpleOwnable {
    address private _owner;

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function __Ownable_init() internal {
        _owner = msg.sender;
    }
}

contract StakingPool is SimpleOwnable{
    
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        IERC20 stakingToken;
        IERC20 rewardToken;
        uint256 lastRewardTimestamp;
        uint256 accTokenPerShare;
        uint256 startTime;
        uint256 endTime;
        uint256 precision;
        uint256 totalStaked;
        uint256 totalReward;
        address owner;
    }

    PoolInfo[] public poolInfo;

    mapping(address => mapping(uint256 => UserInfo)) public userInfo;

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    uint256 public currentVersion;
    bool private initializedV2;

    mapping(uint256 => bool) public hasBeenStaked;
    mapping(uint256 => uint256) public poolVersion;
    mapping(uint256 => uint256) public poolStakeLimit;
    mapping(address => mapping(uint256 => uint256)) public rewardCredit;

    event Deposit(address indexed user, uint256 amount, uint256 poolIndex);
    event Withdraw(address indexed user, uint256 amount, uint256 poolIndex);
    event Claim(address indexed user, uint256 amount, uint256 poolIndex);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event PoolCreated(
        address indexed stakingToken,
        address indexed rewardToken,
        uint256 startTime,
        uint256 endTime,
        uint256 precision,
        uint256 totalReward
    );
    event PoolCreatedID(uint256 poolId);
    event PoolStopped(uint256 poolId);
    event WithdrawTokensEmptyPool(uint256 poolId);
    event RewardAdded(uint256 poolId, uint256 rewardAmount, address rewardToken);

    error NotPoolOwner(address owner, address account);
    error RewardAmountIsZero();
    error AmountIsZero();
    error PoolEnded();
    error RewardsInPast();
    error InvalidPrecision();
    error PoolDoesNotExist(uint256 poolId);
    error InvalidStartAndEndDates();
    error CannotStopRewards();
    error InvalidStakeLimit(uint256 totalStaked, uint256 stakeLimit);
    error MaximumStakeAmountReached(uint256 stakeLimit);
    error InsufficientTransferredAmount();
    error InsufficientRemainingTime(uint256 timeLeft);
    error Overflow();


    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    function initialize() external {
        __Ownable_init();
        _status = _NOT_ENTERED;
        currentVersion = 2;
    }

    function addPool(
        address stakingToken,
        address rewardToken,
        uint256 startTime,
        uint256 endTime,
        uint256 precision,
        uint256 totalReward
    ) external nonReentrant {
        IERC20 rewardTokenInterface = IERC20(rewardToken);
        if (totalReward == 0) revert RewardAmountIsZero();
        if (startTime < block.timestamp || endTime < block.timestamp) revert RewardsInPast();
        if (precision < 6 || precision > 36) revert InvalidPrecision();
        if (startTime >= endTime) revert InvalidStartAndEndDates();
        // 5 YEARS LIMIT
        if (endTime - startTime > 157680000) revert InvalidStartAndEndDates();
        uint256 depositedRewardAmount = transferFunds(rewardTokenInterface, totalReward);
        poolInfo.push(
            PoolInfo({
                stakingToken: IERC20(stakingToken),
                rewardToken: rewardTokenInterface,
                startTime: startTime,
                endTime: endTime,
                precision: 10 ** precision,
                owner: msg.sender,
                totalReward: depositedRewardAmount,
                lastRewardTimestamp: 0,
                accTokenPerShare: 0,
                totalStaked: 0
            })
        );
        poolVersion[poolInfo.length - 1] = currentVersion;
        emit PoolCreatedID(poolInfo.length - 1);
        emit PoolCreated(stakingToken, rewardToken, startTime, endTime, 10 ** precision, depositedRewardAmount);
    }

    function addPoolReward(uint256 poolId, uint256 additionalRewardAmount) public {
        if (poolId >= poolInfo.length) revert PoolDoesNotExist(poolId);
        PoolInfo storage pool = poolInfo[poolId];
        
        address owner = pool.owner;
        if (owner != msg.sender) revert NotPoolOwner(owner, msg.sender);
        if (additionalRewardAmount == 0) revert RewardAmountIsZero();
        if (pool.endTime <= block.timestamp) revert PoolEnded();

        // only allow adding rewards if there is at least 1 hour left in the pool
        uint256 timeLeft =pool.endTime - block.timestamp;
        if (timeLeft < 1 hours) revert InsufficientRemainingTime(timeLeft);
        
        updatePool(poolId);

        // calculate leftovers due to linear reward accrual
        uint256 totalDuration = pool.endTime - pool.startTime;
        uint256 useableNewReward = timeLeft * additionalRewardAmount / totalDuration;
        
        // transfer only required amount of tokens to avoid leftovers
        IERC20 rewardTokenInterface = pool.rewardToken;
        uint256 depositedAdditionalRewardAmount = transferFunds(rewardTokenInterface, useableNewReward);   
        if (depositedAdditionalRewardAmount != useableNewReward) revert InsufficientTransferredAmount();

        uint256 newTotalReward = pool.totalReward + additionalRewardAmount;
        if (newTotalReward < pool.totalReward) revert Overflow();
        pool.totalReward = newTotalReward; // virtual, not actual!

        emit RewardAdded(poolId, useableNewReward, address(rewardTokenInterface));
    }

    function stopReward(uint256 poolId) external nonReentrant {
        updatePool(poolId);

        PoolInfo storage pool = poolInfo[poolId];

        address owner = pool.owner;
        if (owner != msg.sender) revert NotPoolOwner(owner, msg.sender);

        uint256 oldEnd = pool.endTime;
        if (oldEnd <= block.timestamp) revert PoolEnded();

        uint256 start = pool.startTime;
        if (start < block.timestamp && oldEnd - start < 3600) {
            revert CannotStopRewards();
        }
        pool.endTime = block.timestamp;
        pool.rewardToken.safeTransfer(
            owner,
            ((oldEnd - max(block.timestamp, start)) * pool.totalReward) / (oldEnd - start)
        );

        emit PoolStopped(poolId);
    }

    function getUserInfo(address user, uint256 poolId) external view returns (UserInfo memory) {
        return userInfo[user][poolId];
    }

    function pendingReward(address _user, uint256 poolId) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[poolId];
        UserInfo storage user = userInfo[_user][poolId];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 lpSupply = pool.totalStaked;
        uint256 precision = pool.precision;
        uint256 lastRewardTimestamp = pool.lastRewardTimestamp;
        uint256 start = pool.startTime;
        uint256 end = pool.endTime;
        uint256 pending = rewardCredit[_user][poolId];

        if (lastRewardTimestamp > end && lpSupply != 0) {
            return (user.amount * accTokenPerShare) / precision - user.rewardDebt + pending;
        }

        if (block.timestamp > lastRewardTimestamp && lpSupply != 0 && block.timestamp > pool.startTime) {
            uint256 rewards = ((min(block.timestamp, end) - max(start, lastRewardTimestamp)) * pool.totalReward) /
                (end - start);

            accTokenPerShare = accTokenPerShare + (rewards * precision) / lpSupply;
        }

        return (user.amount * accTokenPerShare) / precision - user.rewardDebt + pending;
    }

    function updatePool(uint256 _pid) public {
        if (_pid >= poolInfo.length) {
            revert PoolDoesNotExist(_pid);
        }
        PoolInfo storage pool = poolInfo[_pid];
        uint256 lastRewardTimestamp = pool.lastRewardTimestamp;

        if (block.timestamp <= lastRewardTimestamp) {
            return;
        }

        uint256 lpSupply = pool.totalStaked;
        uint256 start = pool.startTime;
        if (lpSupply == 0 || start > block.timestamp) {
            pool.lastRewardTimestamp = block.timestamp;
            return;
        }
        uint256 end = pool.endTime;

        if (lastRewardTimestamp > end) {
            return;
        }

        uint256 rewards = ((min(block.timestamp, end) - max(start, lastRewardTimestamp)) * pool.totalReward) /
            (end - start);

        pool.accTokenPerShare = pool.accTokenPerShare + (rewards * pool.precision) / lpSupply;
        pool.lastRewardTimestamp = block.timestamp;
    }

    function deposit(uint256 _amount, uint256 poolId) external nonReentrant {
        if (_amount == 0) revert AmountIsZero();
        if (poolId >= poolInfo.length) {
            revert PoolDoesNotExist(poolId);
        }
        PoolInfo storage pool = poolInfo[poolId];
        if (pool.totalStaked + _amount > poolStakeLimit[poolId] && poolStakeLimit[poolId] > 0) {
            revert MaximumStakeAmountReached(poolStakeLimit[poolId]);
        }
        UserInfo storage user = userInfo[msg.sender][poolId];
        updatePool(poolId); // Update any rewards that were generated up until now
        if (user.amount > 0) {
            rewardCredit[msg.sender][poolId] +=
                (user.amount * pool.accTokenPerShare) /
                pool.precision -
                user.rewardDebt;
        }

        uint256 depositAmount = transferFunds(pool.stakingToken, _amount);

        // Update the user's staked amount and reward debt
        user.amount += depositAmount;
        user.rewardDebt = (user.amount * pool.accTokenPerShare) / pool.precision;
        pool.totalStaked += depositAmount; // Update the total staked amount in the pool
        emit Deposit(msg.sender, depositAmount, poolId);
    }

    function withdraw(uint256 _amount, uint256 poolId) external nonReentrant {
        if (_amount == 0) revert AmountIsZero();
        if (poolId >= poolInfo.length) {
            revert PoolDoesNotExist(poolId);
        }
        PoolInfo storage pool = poolInfo[poolId];
        UserInfo storage user = userInfo[msg.sender][poolId];
        uint256 amount = user.amount;
        // will revert if amount < _amount so no need to check
        uint256 newAmount = amount - _amount;

        updatePool(poolId);

        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 precision = pool.precision;
        uint256 pending = (amount * accTokenPerShare) / precision - user.rewardDebt + rewardCredit[msg.sender][poolId];
        rewardCredit[msg.sender][poolId] = 0;
        user.amount = newAmount;
        pool.totalStaked -= _amount;
        user.rewardDebt = (newAmount * accTokenPerShare) / precision;

        if (pending == 0) {
            pool.stakingToken.safeTransfer(address(msg.sender), _amount);
        } else {
            IERC20 stakingToken = pool.stakingToken;
            IERC20 rewardToken = pool.rewardToken;
            // if staking & reward token are the same, do 1 token transfer instead of 2
            if (stakingToken == rewardToken) {
                stakingToken.safeTransfer(address(msg.sender), _amount + pending);
            } else {
                rewardToken.safeTransfer(address(msg.sender), pending);
                stakingToken.safeTransfer(address(msg.sender), _amount);
            }

            emit Claim(msg.sender, pending, poolId);
        }

        emit Withdraw(msg.sender, _amount, poolId);
    }

    function claimReward(uint256 poolId) external nonReentrant {
        if (poolId >= poolInfo.length) {
            revert PoolDoesNotExist(poolId);
        }
        PoolInfo storage pool = poolInfo[poolId];
        UserInfo storage user = userInfo[msg.sender][poolId];
        updatePool(poolId);

        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 pendingReward_ = (user.amount * accTokenPerShare) /
            pool.precision -
            user.rewardDebt +
            rewardCredit[msg.sender][poolId];

        // Update user's reward debt to prevent re-entrance
        user.rewardDebt = (user.amount * accTokenPerShare) / pool.precision;
        rewardCredit[msg.sender][poolId] = 0;

        if (pendingReward_ > 0) {
            pool.rewardToken.safeTransfer(msg.sender, pendingReward_);
            emit Claim(msg.sender, pendingReward_, poolId);
        }
    }

    function setPoolStakeLimit(uint256 poolId, uint256 stakeLimit) external {
        if (poolId >= poolInfo.length) {
            revert PoolDoesNotExist(poolId);
        }
        PoolInfo memory pool = poolInfo[poolId];
        if (msg.sender != pool.owner) {
            revert NotPoolOwner(pool.owner, msg.sender);
        }
        if (block.timestamp >= pool.endTime) {
            revert PoolEnded();
        }
        if (pool.totalStaked >= stakeLimit) {
            revert InvalidStakeLimit(pool.totalStaked, stakeLimit);
        }
        poolStakeLimit[poolId] = stakeLimit;
    }

    function emergencyWithdraw(uint256 poolId) external nonReentrant {
        if (poolId >= poolInfo.length) {
            revert PoolDoesNotExist(poolId);
        }
        PoolInfo storage pool = poolInfo[poolId];

        UserInfo storage user = userInfo[msg.sender][poolId];
        uint256 amount = user.amount;

        if (amount == 0) revert AmountIsZero();

        pool.totalStaked -= user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        // zero-out rewardCredit
        rewardCredit[msg.sender][poolId] = 0;

        pool.stakingToken.safeTransfer(address(msg.sender), amount);

        emit EmergencyWithdraw(msg.sender, amount);
    }

    function getPools() external view returns (PoolInfo[] memory) {
        return poolInfo;
    }

    function getPoolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function saveMe(address tokenAddress, uint256 amount) external onlyOwner nonReentrant {
        IERC20 token = IERC20(tokenAddress);
        token.safeTransfer(address(msg.sender), amount);
    }

    function updateVersion(uint256 _currentVersion) external onlyOwner {
        currentVersion = _currentVersion;
    }

    function initializePoolV2() external {
        if (initializedV2) {
            revert("Already IntializedV2");
        }
        initializedV2 = true;
        currentVersion = 2;
        _status = _NOT_ENTERED;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x < y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x > y ? x : y;
    }

    function transferFunds(IERC20 token, uint256 amount) internal returns (uint256) {
        uint256 balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(address(msg.sender), address(this), amount);
        uint256 balanceAfter = token.balanceOf(address(this));
        return balanceAfter - balanceBefore;
    }
}

// The contract is vulnerable to reentrancy if `initializePoolV2` is not called immediately after deployment.
// An attacker can exploit this by re-entering the `claimReward` function during a token transfer.
// An attacker should deploy a token with a malicious `safeTransfer` that re-enters this contract, create a pool,
// deposit tokens via `deposit` function and call again the `deposit` function to perform the attack.
// During that re-entry, the attacker invokes `initializePoolV2`, which resets the guard and enables another `claimReward` call.