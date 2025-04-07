/**
 *Submitted for verification at Etherscan.io on 2021-08-31
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/Context

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/SafeMath

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */


// Part: OpenZeppelin/[email protected]/Ownable

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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


// File: MillionFarm.sol

// Enter the Serengeti
contract MillionFarm is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        IERC20 stake;              
        uint256 allocPoint;         
        uint256 lastTimeStamp;      
        uint256 accSimbaPerShare;   
        uint256 totalStaked;        
        uint16 depositFeeBP;
    }

    
    IERC20 immutable public simba;

    address public simbaTreasury;

    uint256 public simbaPerSecond;
    uint256 public totalAllocPoint = 0;
    uint256 public startTime;
    uint256 public emissionCheckpoint;
    uint256 public halvingTime= 15768000; //seconds
    uint256 public halvingCount=0;

    PoolInfo[] public poolInfo;

    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        IERC20 _simba,
        address _simbaTreasury,
        uint256 _simbaPerSecond,
        uint256 _startTime) public {
        simba = _simba;
        simbaTreasury = _simbaTreasury;
        simbaPerSecond = _simbaPerSecond;
        startTime = _startTime;
        emissionCheckpoint=_startTime.add(halvingTime);
    }

    function add(uint256 _allocPoint, IERC20 _stake, uint16 _depositFeeBP, bool _withUpdate) external onlyOwner {
        require(_depositFeeBP <= 500, "add: invalid deposit fee basis points");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastTimeStamp = block.timestamp > startTime ? block.timestamp : startTime;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            stake: _stake,
            allocPoint: _allocPoint,
            lastTimeStamp: lastTimeStamp,
            accSimbaPerShare: 0,
            totalStaked: 0,
            depositFeeBP: _depositFeeBP
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, uint16 _depositFeeBP, bool _withUpdate) external onlyOwner {
        require(_depositFeeBP <= 500, "set: invalid deposit fee basis points");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
    }

    function deposit(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accSimbaPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeSimbaTransfer(msg.sender, pending);
            }
        }
        if(_amount > 0) {
            pool.stake.safeTransferFrom(address(msg.sender), address(this), _amount);
            if(pool.depositFeeBP > 0){
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                pool.stake.safeTransfer(simbaTreasury, depositFee);
                user.amount = user.amount.add(_amount).sub(depositFee);
                pool.totalStaked= pool.totalStaked.add(_amount).sub(depositFee);
            }else{
                user.amount = user.amount.add(_amount);
                pool.totalStaked= pool.totalStaked.add(_amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accSimbaPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: no good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accSimbaPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeSimbaTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.stake.safeTransfer(address(msg.sender), _amount);
            pool.totalStaked=pool.totalStaked.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accSimbaPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // withdraws staked amount without bothering with rewards
    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.stake.safeTransfer(address(msg.sender), amount);
        pool.totalStaked=pool.totalStaked.sub(amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function updateRewardPerSecond() external onlyOwner {
        require(block.timestamp > emissionCheckpoint,"you cannot halve emissions yet");
        require(halvingCount<6);
        massUpdatePools();
        simbaPerSecond =  simbaPerSecond.div(2);
        emissionCheckpoint=emissionCheckpoint.add(halvingTime);
        halvingCount=halvingCount.add(1);
    }

    function simbaRewards(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSimbaPerShare = pool.accSimbaPerShare;
        uint256 stakeSupply = pool.totalStaked;
        if (block.timestamp > pool.lastTimeStamp && stakeSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastTimeStamp, block.timestamp);
            uint256 simbaReward = multiplier.mul(simbaPerSecond).mul(pool.allocPoint).div(totalAllocPoint);
            accSimbaPerShare = accSimbaPerShare.add(simbaReward.mul(1e12).div(stakeSupply));
        }
        return user.amount.mul(accSimbaPerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastTimeStamp) {
            return;
        }
        uint256 stakeSupply = pool.totalStaked;
        if (stakeSupply == 0 || pool.allocPoint == 0) {
            pool.lastTimeStamp = block.timestamp;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastTimeStamp, block.timestamp);
        uint256 simbaReward = multiplier.mul(simbaPerSecond).mul(pool.allocPoint).div(totalAllocPoint);

        pool.accSimbaPerShare = pool.accSimbaPerShare.add(simbaReward.mul(1e12).div(stakeSupply));
        pool.lastTimeStamp = block.timestamp;
    }

    function safeSimbaTransfer(address _to, uint256 _amount) internal {
        uint256 simbaBal = simba.balanceOf(address(this));
        if (_amount > simbaBal) {
            simba.transfer(_to, simbaBal);
        } else {
            simba.transfer(_to, _amount);
        }
    }

    function getMultiplier(uint256 _from, uint256 _to) internal pure returns (uint256) {
        return _to.sub(_from);
    }

}