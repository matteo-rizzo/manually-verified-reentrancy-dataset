/**
 *Submitted for verification at Etherscan.io on 2020-11-16
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.6;


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
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


// 
/**
 * @dev Collection of functions related to the address type
 */


// 
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// 
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

enum RebaseResult { Double, Park, Draw }





contract TautrinoFarming is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    ITautrinoRewardPool public rewardPool;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Total reward distributed.
    }

    struct PoolInfo {
        IERC20 lpToken;                                     // Address of LP token contract.
        address rewardToken;                                // Address of reward token - TAU or TRINO.
        mapping (address => uint256) userLastRewardEpoch;   // last reward epoch of user in this pool.
        uint256 rewardPerShare;                             // Reward per share, times 1e12. See below.
        uint256 totalRewardPaid;                            // Total reward paid in this pool.
        uint256 deposits;                                   // Current deposited amount.
        uint256 rewardEndEpoch;                             // Pool farming reward end timestamp. 0: no end
    }

    PoolInfo[] _poolInfo;
    mapping (address => bool) public tokenAdded;
    mapping (uint256 => mapping (address => UserInfo)) _userInfo;

    event onDeposit(address indexed user, uint256 indexed pid, uint256 amount);
    event onWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event onClaimReward(address indexed user, uint256 indexed pid, uint256 reward, uint256 baseReward);

    /**
     * @dev Constructor.
     * @param _rewardPool reward pool address.
     */

    constructor(ITautrinoRewardPool _rewardPool) public Ownable() {
        rewardPool = _rewardPool;
    }

    /**
     * @return return pool length.
     */

    function poolLength() external view returns (uint256) {
        return _poolInfo.length;
    }

    /**
     * @dev add new pool. must be called by owner
     * @param _lpToken lpToken for farming.
     * @param _rewardToken reward token by farming.
     * @param _rewardPerShare reward per lp share.
     */

    function add(address _lpToken, address _rewardToken, uint256 _rewardPerShare) external onlyOwner {
        require(tokenAdded[_lpToken] == false, "already exist!");
        _poolInfo.push(PoolInfo({
            lpToken: IERC20(_lpToken),
            rewardToken: _rewardToken,
            rewardPerShare: _rewardPerShare,
            totalRewardPaid: 0,
            deposits: 0,
            rewardEndEpoch: 0
        }));
        tokenAdded[_lpToken] = true;
    }

    /**
     * @dev update rewardPerShare of pool. must be called by owner
     * @param _pid id of pool.
     * @param _rewardPerShare new reward per lp share. 0 - no update
     * @param _rewardEndEpoch reward end epoch. 0 - no update
     */

    function set(uint256 _pid, uint256 _rewardPerShare, uint256 _rewardEndEpoch) external onlyOwner {
        if (_rewardPerShare > 0) {
            _poolInfo[_pid].rewardPerShare = _rewardPerShare;
        }
        if (_rewardEndEpoch > 0) {
            _poolInfo[_pid].rewardEndEpoch = _rewardEndEpoch;
        }
    }

    /**
     * @dev pending reward of user in the pool.
     * @param _pid id of pool.
     * @param _user user address.
     * @return pending reward amount.
     */

    function pendingReward(uint256 _pid, address _user) public view returns (uint256) {
        uint256 factor2 = ITautrinoToken(_poolInfo[_pid].rewardToken).factor2();
        return pendingBaseReward(_pid, _user).mul(2 ** factor2);
    }

    /**
     * @dev pending base reward of user in the pool.
     * @param _pid id of pool.
     * @param _user user address.
     * @return pending reward amount.
     */

    function pendingBaseReward(uint256 _pid, address _user) internal view returns (uint256) {
        PoolInfo storage pool = _poolInfo[_pid];
        UserInfo storage user = _userInfo[_pid][_user];
        uint256 lastRewardEpoch = pool.userLastRewardEpoch[_user];
        uint rewardEndEpoch = block.timestamp;
        if (pool.rewardEndEpoch > 0 && pool.rewardEndEpoch < block.timestamp) {
            rewardEndEpoch = pool.rewardEndEpoch;
        }
        if (rewardEndEpoch > lastRewardEpoch) {
            return user.amount.mul(pool.rewardPerShare).div(1e12).mul(rewardEndEpoch - lastRewardEpoch);
        }
        return 0;
    }

    /**
     * @dev deposit lp token.
     * @param _pid id of pool.
     * @param _amount lp amount.
     */

    function deposit(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = _poolInfo[_pid];
        require(pool.rewardEndEpoch == 0 || pool.rewardEndEpoch > block.timestamp, "paused!");

        UserInfo storage user = _userInfo[_pid][msg.sender];

        _claimReward(_pid, msg.sender);

        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            pool.deposits = pool.deposits.add(_amount);
        }

        emit onDeposit(msg.sender, _pid, _amount);
    }

    /**
     * @dev withdraw lp token.
     * @param _pid id of pool.
     * @param _amount lp amount.
     */

    function withdraw(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = _poolInfo[_pid];
        UserInfo storage user = _userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "insufficient!");

        _claimReward(_pid, msg.sender);

        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.deposits = pool.deposits.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        emit onWithdraw(msg.sender, _pid, _amount);
    }

    /**
     * @dev claim pending reward.
     * @param _pid id of pool.
     */

    function claimReward(uint256 _pid) external {
        _claimReward(_pid, msg.sender);
    }

    /**
     * @dev claim pending reward to user - internal method.
     * @param _pid id of pool.
     * @param _user user address.
     */

    function _claimReward(uint256 _pid, address _user) internal {
        PoolInfo storage pool = _poolInfo[_pid];
        UserInfo storage user = _userInfo[_pid][_user];

        uint256 baseReward = pendingBaseReward(_pid, _user);

        if (baseReward > 0) {
            uint256 factor2 = ITautrinoToken(pool.rewardToken).factor2();
            uint256 reward = baseReward.mul(2 ** factor2);
            rewardPool.withdrawReward(_user, pool.rewardToken, reward);
            user.rewardDebt = user.rewardDebt.add(baseReward);

            pool.totalRewardPaid = pool.totalRewardPaid.add(baseReward);
            emit onClaimReward(_user, _pid, reward, baseReward);
        }
        pool.userLastRewardEpoch[_user] = block.timestamp;
    }

    /**
     * @dev last reward timestamp of user.
     * @param _pid id of pool.
     * @param _user user address.
     */

    function userLastRewardEpoch(uint256 _pid, address _user) external view returns (uint256) {
        return _poolInfo[_pid].userLastRewardEpoch[_user];
    }

    /**
     * @dev User info.
     * @param _pid id of pool.
     * @param _user user address.
     */

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256, uint256) {
        UserInfo memory user = _userInfo[_pid][_user];
        uint256 factor2 = ITautrinoToken(_poolInfo[_pid].rewardToken).factor2();
        uint256 rewardDistributed = user.rewardDebt.mul(2 ** factor2);
        uint256 reward = pendingReward(_pid, _user);
        return (user.amount, rewardDistributed, reward);
    }

    /**
     * @dev Pool info.
     * @param _pid id of pool.
     */

    function poolInfo(uint256 _pid) external view returns (address, address, uint256, uint256, uint256, uint256) {
        PoolInfo memory pool = _poolInfo[_pid];
        address rewardToken = pool.rewardToken;
        uint256 factor2 = ITautrinoToken(rewardToken).factor2();
        uint256 rewardDistributed = pool.totalRewardPaid.mul(2 ** factor2);
        return (address(pool.lpToken), rewardToken, pool.rewardPerShare, rewardDistributed, pool.deposits, pool.rewardEndEpoch);
    }

    /**
     * @dev set reward pool. must be called by owner
     * @param _rewardPool new reward pool address.
     */

    function setRewardPool(ITautrinoRewardPool _rewardPool) public onlyOwner {
        rewardPool = _rewardPool;
    }
}