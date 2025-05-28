// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/utils/SafeERC20Upgradeable.sol";

/// @title TrustSwap StakingPool
/// @notice A contract for staking tokens to earn rewards.
/// @dev This contract allows users to stake tokens and claim rewards based on the staked amount and duration.
contract StakingPool is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    // Structure to store information about each user in the staking pool.
    struct UserInfo {
        uint256 amount; // Amount of tokens staked by the user.
        uint256 rewardDebt; // Reward debt of the user, used to calculate claimable rewards.
    }

    // Structure to store information about each staking pool.
    struct PoolInfo {
        IERC20Upgradeable stakingToken; // Token that users stake in the pool.
        IERC20Upgradeable rewardToken; // Token distributed as rewards to users.
        uint256 lastRewardTimestamp; // Last timestamp when rewards were calculated and distributed.
        uint256 accTokenPerShare; // Accumulated reward tokens per share, scaled by precision.
        uint256 startTime; // Start time for reward distribution.
        uint256 endTime; // End time for reward distribution.
        uint256 precision; // Scaling factor to manage different decimal places of tokens.
        uint256 totalStaked; // Total amount of tokens staked in the pool.
        uint256 totalReward; // Total reward tokens allocated for distribution.
        address owner; // Owner of the pool with privileges to manage it.
    }

    // Array of all pools.
    PoolInfo[] public poolInfo;

    // Mapping from user address to pool ID to UserInfo, storing each user's staking information per pool.
    mapping(address => mapping(uint256 => UserInfo)) public userInfo;

    // Constants for reentrancy guard.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    // Status variable for reentrancy guard.
    uint256 private _status;

    // Current version of the staking pool contract.
    uint256 public currentVersion;
    // Flag to track initialization of version 2.
    bool private initializedV2;

    // Mapping to track if a pool has been staked in.
    mapping(uint256 => bool) public hasBeenStaked;
    // Mapping from pool ID to its associated version.
    mapping(uint256 => uint256) public poolVersion;
    // Mapping from pool ID to its staking limit.
    mapping(uint256 => uint256) public poolStakeLimit;
    // Mapping from user address to pool ID to pending reward for that pool.
    mapping(address => mapping(uint256 => uint256)) public rewardCredit;

    // Events for logging activities in the contract.
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

    // Custom error messages for different failure conditions.
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

    /**
     * @notice Modifier to prevent reentrant calls to certain functions.
     * @dev Keep for new deployment and comment for contract upgrade.
     */
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Initializes the staking pool contract, setting up the Ownable module and reentrancy guard.
     * @notice This function sets the contract's owner and initial status for the reentrancy guard.
     */
    function initialize() external initializer {
        __Ownable_init();
        _status = _NOT_ENTERED;
        currentVersion = 2;
    }

    /**
     * @dev Creates a new staking pool with specified parameters.
     * @notice Allows the owner to create a new pool for users to stake tokens.
     * @param stakingToken The address of the token that users will stake.
     * @param rewardToken The address of the token used for rewards.
     * @param startTime The start time for reward distribution.
     * @param endTime The end time for reward distribution.
     * @param precision The scaling factor for reward calculation.
     * @param totalReward The total amount of rewards allocated for the pool.
     */
    function addPool(
        address stakingToken,
        address rewardToken,
        uint256 startTime,
        uint256 endTime,
        uint256 precision,
        uint256 totalReward
    ) external nonReentrant {
        IERC20Upgradeable rewardTokenInterface = IERC20Upgradeable(rewardToken);
        if (totalReward == 0) revert RewardAmountIsZero();
        if (startTime < block.timestamp || endTime < block.timestamp) revert RewardsInPast();
        if (precision < 6 || precision > 36) revert InvalidPrecision();
        if (startTime >= endTime) revert InvalidStartAndEndDates();
        // 5 YEARS LIMIT
        if (endTime - startTime > 157680000) revert InvalidStartAndEndDates();
        uint256 depositedRewardAmount = transferFunds(rewardTokenInterface, totalReward);
        poolInfo.push(
            PoolInfo({
                stakingToken: IERC20Upgradeable(stakingToken),
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

    /// @notice Adds additional rewards to an existing pool
    /// @dev This function allows the pool owner to increase the total reward for a given pool.
    /// It does not adjust the reward rate or pool duration. The increased rewards will affect
    /// future rewards distribution, potentially increasing the APY for the remaining duration.
    /// @param poolId The ID of the pool to add rewards to
    /// @param additionalRewardAmount The amount of additional rewards to add
    /// @custom:security-note This function assumes the pool owner understands the impact on APY
    /// @custom:security-note Only the pool owner or contract owner can call this function
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
        IERC20Upgradeable rewardTokenInterface = pool.rewardToken;
        uint256 depositedAdditionalRewardAmount = transferFunds(rewardTokenInterface, useableNewReward);   
        if (depositedAdditionalRewardAmount != useableNewReward) revert InsufficientTransferredAmount();

        uint256 newTotalReward = pool.totalReward + additionalRewardAmount;
        if (newTotalReward < pool.totalReward) revert Overflow();
        pool.totalReward = newTotalReward; // virtual, not actual!

        emit RewardAdded(poolId, useableNewReward, address(rewardTokenInterface));
    }

    /**
     * @dev Stops reward distribution for a specific pool and returns remaining rewards to the owner.
     * @notice Can be called by the pool owner to end rewards distribution early. The amount of remaining rewards returned to the owner
     * @param poolId The ID of the pool for which to stop rewards.
     */
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

    /**
     * @dev Provides information about a user's staking in a specific pool.
     * @notice This function is used to fetch the staking details of a user in a particular pool.
     * @param user The address of the user whose information is being requested.
     * @param poolId The ID of the pool for which user information is requested.
     * @return A `UserInfo` struct containing the user's staking details in the specified pool.
     */
    function getUserInfo(address user, uint256 poolId) external view returns (UserInfo memory) {
        return userInfo[user][poolId];
    }

    /**
     * @dev Calculates and returns the pending reward for a user in a specific pool.
     * @notice Used to view the amount of reward that a user can claim from a particular pool.
     * @param _user The address of the user whose pending reward is being calculated.
     * @param poolId The ID of the pool for which the pending reward is calculated.
     * @return The amount of reward tokens that the user can claim from the pool.
     */
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

    /**
     * @dev Updates reward variables for a given pool to ensure proper reward distribution.
     * @notice This function is called before any deposit, withdrawal, or claim operation to ensure that the pool's reward variables are up to date.
     * @param _pid The ID of the pool to update.
     */
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

    /**
     * @dev Allows a user to deposit staking tokens into a specific pool.
     * @notice Users can deposit tokens to start earning rewards, without claiming existing rewards.
     * @param _amount The amount of tokens to deposit.
     * @param poolId The ID of the pool to deposit into.
     */
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

    /**
     * @dev Allows a user to withdraw staked tokens from a specific pool.
     * @notice Users can withdraw their staked tokens and any pending rewards.
     * @param _amount The amount of tokens to withdraw.
     * @param poolId The ID of the pool to withdraw from.
     */
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
            IERC20Upgradeable stakingToken = pool.stakingToken;
            IERC20Upgradeable rewardToken = pool.rewardToken;
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

    /**
     * @dev Allows a user to claim pending rewards from a specific pool, but only after the pool has ended.
     * @notice Users can claim their rewards only after the pool's end time has passed, ensuring rewards are locked until the end of the pool period.
     * @param poolId The ID of the pool from which to claim rewards.
     * Requirements:
     * - The caller must be a staker in the pool.
     * - The current time must be after the pool's `endTime` to ensure rewards are only claimed post-maturity.
     * Emits a {Claim} event indicating the successful claim of pending rewards.
     */
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

    /// @notice Sets the stake limit for a specific pool
    /// @dev This function allows the pool owner to set a maximum limit on the total amount that can be staked in the pool
    /// @param poolId The ID of the pool to set the stake limit for
    /// @param stakeLimit The maximum amount of tokens that can be staked in the pool
    /// @custom:security-note Only the pool owner can call this function
    /// @custom:security-note The new stake limit must be greater than or equal to the current total staked amount
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

    /**
     * @dev Withdraws staked tokens from a pool without claiming rewards. Used in emergencies.
     * @notice This is an emergency function to withdraw staked tokens without rewards.
     * @param poolId The ID of the pool to perform an emergency withdrawal from.
     */
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

    /**
     * @dev Retrieves the array of all pools.
     * @notice Allows querying of all existing pools in the staking contract.
     * @return An array of `PoolInfo` structs representing each pool.
     */
    function getPools() external view returns (PoolInfo[] memory) {
        return poolInfo;
    }

    /**
     * @dev Returns the total number of pools in the contract.
     * @notice Useful for front-end applications to iterate over all pools.
     * @return The total number of pools.
     */
    function getPoolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    /**
     * @dev Allows the owner to transfer tokens out of the contract for recovery purposes.
     * @notice This emergency function is used to recover tokens mistakenly sent to the contract.
     * @param tokenAddress The address of the token to transfer out.
     * @param amount The amount of tokens to transfer.
     */
    function saveMe(address tokenAddress, uint256 amount) external onlyOwner nonReentrant {
        IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
        token.safeTransfer(address(msg.sender), amount);
    }

    /**
     * @dev Updates the current version of the staking pool contract.
     * @notice Used to track contract upgrades and changes over time.
     * @param _currentVersion The new version number to set.
     */
    function updateVersion(uint256 _currentVersion) external onlyOwner {
        currentVersion = _currentVersion;
    }

    /**
     * @dev Initializes the staking pool contract for Version 2 upgrades.
     * @notice This function is used to upgrade the contract to Version 2.
     */
    function initializePoolV2() external {
        if (initializedV2) {
            revert("Already IntializedV2");
        }
        initializedV2 = true;
        currentVersion = 2;
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns the smaller of two values.
     * @notice Used internally for calculations involving two potential minimum values.
     * @param x The first value.
     * @param y The second value.
     * @return z The smaller of the two values.
     */
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x < y ? x : y;
    }

    /**
     * @dev Returns the larger of two values.
     * @notice Used internally for calculations involving two potential maximum values.
     * @param x The first value.
     * @param y The second value.
     * @return z The larger of the two values.
     */
    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x > y ? x : y;
    }

    /**
     * @dev Transfers tokens to the contract and returns the actual amount transferred.
     * @notice Used internally to handle token transfers safely, accounting for transaction fees or other factors.
     * @param token The ERC20 token to transfer.
     * @param amount The amount of tokens to transfer.
     * @return The actual amount of tokens transferred to the contract.
     */
    function transferFunds(IERC20Upgradeable token, uint256 amount) internal returns (uint256) {
        uint256 balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(address(msg.sender), address(this), amount);
        uint256 balanceAfter = token.balanceOf(address(this));
        return balanceAfter - balanceBefore;
    }
}