/**
 *Submitted for verification at Etherscan.io on 2021-03-23
*/

// SPDX-License-Identifier: AGPL-3.0-or-later\
pragma solidity 0.7.5;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract OlympusLPStaking {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    modifier onlyOwner() {
        require(msg.sender == owner, "Owner only");
        _;
    }

    struct User {
        uint256 _LPDeposited;
        uint256 _rewardDebt;
    }

    event StakeCompleted(address _staker, uint256 _amount, uint256 _totalStaked, uint256 _time);
    event PoolUpdated(uint256 _blocksRewarded, uint256 _amountRewarded, uint256 _time);
    event RewardsClaimed(address _staker, uint256 _rewardsClaimed, uint256 _time);    
    event WithdrawCompleted(address _staker, uint256 _amount, uint256 _time);
    event TransferredOwnership(address _previous, address _next, uint256 _time);

    IERC20 public LPToken;
    IERC20 public OHMToken;

    address public rewardPool;
    address public owner;

    uint256 public rewardPerBlock;
    uint256 public accOHMPerShare;
    uint256 public lastRewardBlock;
    uint256 public totalStaked;

    mapping(address => User) public userDetails;

    // Constructor will set the address of OHM/ETH LP token
    constructor(address _LPToken, address _OHMToken, address _rewardPool, uint256 _rewardPerBlock, uint _blocksToWait) {
        LPToken = IERC20(_LPToken);
        OHMToken = IERC20(_OHMToken);
        rewardPool = _rewardPool;
        lastRewardBlock = block.number.add( _blocksToWait );
        rewardPerBlock = _rewardPerBlock;
        accOHMPerShare;
        owner = msg.sender;
    }

    function transferOwnership(address _owner) external onlyOwner() returns ( bool ) {
        address previousOwner = owner;
        owner = _owner;
        emit TransferredOwnership(previousOwner, owner, block.timestamp);

        return true;
    }

    // Sets OHM reward for each block
    function setRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner() returns ( bool ) {
        rewardPerBlock = _rewardPerBlock;

        return true;
    }

    // Function that will get balance of a certain stake
    function getUserBalance(address _staker) external view returns(uint256 _amountStaked) {
        return userDetails[_staker]._LPDeposited;
    }

    // Function that returns User's pending rewards
    function pendingRewards(address _staker) external view returns(uint256) {
        User storage user = userDetails[_staker];

        uint256 _accOHMPerShare = accOHMPerShare;

        if (block.number > lastRewardBlock && totalStaked != 0) {
            uint256 blocksToReward = block.number.sub(lastRewardBlock);
            uint256 ohmReward = blocksToReward.mul(rewardPerBlock);
            _accOHMPerShare = _accOHMPerShare.add(ohmReward.mul(1e18).div(totalStaked));
        }

        return user._LPDeposited.mul(_accOHMPerShare).div(1e18).sub(user._rewardDebt);
    }

    // Function that updates OHM/DAI LP pool
    function updatePool() public returns ( bool ) {
        if (block.number <= lastRewardBlock) {
            return true;
        }

        if (totalStaked == 0) {
            lastRewardBlock = block.number;
            return true;
        }

        uint256 blocksToReward = block.number.sub(lastRewardBlock);
        lastRewardBlock = block.number;

        uint256 ohmReward = blocksToReward.mul(rewardPerBlock);
        accOHMPerShare = accOHMPerShare.add(ohmReward.mul(1e18).div(totalStaked));

        OHMToken.safeTransferFrom(rewardPool, address(this), ohmReward);

        emit PoolUpdated(blocksToReward, ohmReward, block.timestamp);

        return true;
    }

    // Function that lets user stake OHM/DAI LP
    function stakeLP(uint256 _amount) external returns ( bool ) {
        require(_amount > 0, "Can not stake 0 LP tokens");

        updatePool();

        User storage user = userDetails[msg.sender];

        if(user._LPDeposited > 0) {
            uint256 _pendingRewards = user._LPDeposited.mul(accOHMPerShare).div(1e18).sub(user._rewardDebt);

            if(_pendingRewards > 0) {
                OHMToken.safeTransfer(msg.sender, _pendingRewards);
                emit RewardsClaimed(msg.sender, _pendingRewards, block.timestamp);
            }
        }

        LPToken.safeTransferFrom(msg.sender, address(this), _amount);
        user._LPDeposited = user._LPDeposited.add(_amount);
        totalStaked = totalStaked.add(_amount);

        user._rewardDebt = user._LPDeposited.mul(accOHMPerShare).div(1e18);

        emit StakeCompleted(msg.sender, _amount, user._LPDeposited, block.timestamp);

        return true;

    }

    // Function that will allow user to claim rewards
    function claimRewards() external returns ( bool ) {
        updatePool();

        User storage user = userDetails[msg.sender];

        uint256 _pendingRewards = user._LPDeposited.mul(accOHMPerShare).div(1e18).sub(user._rewardDebt);
        user._rewardDebt = user._LPDeposited.mul(accOHMPerShare).div(1e18);
        
        require(_pendingRewards > 0, "No rewards to claim!");

        OHMToken.safeTransfer(msg.sender, _pendingRewards);

        emit RewardsClaimed(msg.sender, _pendingRewards, block.timestamp);

        return true;
    }

    // Function that lets user unstake OHM/DAI LP in system
    function unstakeLP() external returns ( bool ) {        

        updatePool();

        User storage user = userDetails[msg.sender];
        require(user._LPDeposited > 0, "User has no stake");

        uint256 _pendingRewards = user._LPDeposited.mul(accOHMPerShare).div(1e18).sub(user._rewardDebt);

        uint256 beingWithdrawn = user._LPDeposited;

        user._LPDeposited = 0;
        user._rewardDebt = 0;

        totalStaked = totalStaked.sub(beingWithdrawn);

        LPToken.safeTransfer(msg.sender, beingWithdrawn);
        OHMToken.safeTransfer(msg.sender, _pendingRewards);

        emit WithdrawCompleted(msg.sender, beingWithdrawn, block.timestamp);
        emit RewardsClaimed(msg.sender, _pendingRewards, block.timestamp);

        return true;
    }

}