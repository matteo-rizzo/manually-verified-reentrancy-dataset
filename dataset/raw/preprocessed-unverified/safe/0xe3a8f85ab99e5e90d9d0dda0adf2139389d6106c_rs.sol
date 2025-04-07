/**
 *Submitted for verification at Etherscan.io on 2021-03-29
*/

pragma solidity ^0.5.17;

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
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */




contract StakingRewardsFactory {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool internal initialized;
    address public owner;
    address public rewardsToken;

    // Info of each pool.
    struct PoolInfo {
        address poolAddress;
        uint256 allocPoint;
    }
    uint256 public totalAllocPoint;
    // Info of each pool.
    PoolInfo[] public poolInfo;

    function initialize(address newOwner, address _rewardsToken) public {
        require(!initialized, "already initialized");
        require(newOwner != address(0), "new owner is the zero address");
        initialized = true;

        owner = newOwner;
        rewardsToken = _rewardsToken;
    }

    function add(uint256 _allocPoint, address _poolAddress) public onlyOwner {
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
        poolAddress: _poolAddress,
        allocPoint: _allocPoint
        }));
    }

    // Update the given pool's SUSHI allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint) public onlyOwner {
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function notifyRewardAmounts(uint256 reward, uint256 duration) public onlyOwner {
        uint balance = IERC20(rewardsToken).balanceOf(address(this));
        require(balance >= reward, 'reward balance is not enough');
        for (uint i = 0; i < poolInfo.length; i++) {
            PoolInfo storage pool = poolInfo[i];
            uint256 rewardAmount = balance.mul(pool.allocPoint).div(totalAllocPoint);
            IERC20(rewardsToken).safeTransfer(pool.poolAddress, rewardAmount);
            IRewardDistributionRecipient(pool.poolAddress).notifyRewardAmount(rewardAmount, duration);
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "!owner");
        _;
    }
}