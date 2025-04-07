/**
 *Submitted for verification at Etherscan.io on 2021-04-06
*/

// SPDX-License-Identifier: NLPL

pragma solidity ^0.6.12;


// 
/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {
    /**
    * @dev Indicates that the contract has been initialized.
    */
    bool private initialized;

    /**
    * @dev Indicates that the contract is in the process of being initialized.
    */
    bool private initializing;

    /**
    * @dev Modifier to use in the initializer function of a contract.
    */
    modifier initializer() {
      require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

      bool isTopLevelCall = !initializing;
      if (isTopLevelCall) {
        initializing = true;
        initialized = true;
      }

      _;

      if (isTopLevelCall) {
        initializing = false;
      }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
      // extcodesize checks the size of the code stored in an address, and
      // address returns the current address. Since the code is still not
      // deployed when running a constructor, any checks on its code size will
      // yield zero, making it an effective way to detect if a contract is
      // under construction or not.
      address self = address(this);
      uint256 cs;
      assembly { cs := extcodesize(self) }
      return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is Initializable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
      address indexed previousOwner,
      address indexed newOwner
    );

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    function init(address sender) public initializer {
      _owner = sender;
    }

    /**
    * @return the address of the owner.
    */
    function owner() public view returns(address) {
      return _owner;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
      require(isOwner());
      _;
    }

    /**
    * @return true if `msg.sender` is the owner of the contract.
    */
    function isOwner() public view returns(bool) {
      return msg.sender == _owner;
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
      emit OwnershipRenounced(_owner);
      _owner = address(0);
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0));
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }

    uint256[50] private ______gap;
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for SIERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @title A simple holder of tokens.
 * This is a simple contract to hold tokens. It's useful in the case where a separate contract
 * needs to hold multiple distinct pools of the same token.
 */
contract TokenPool is Ownable {
    IERC20 public token;

    constructor(IERC20 _token) public {
        Ownable.init(msg.sender);
        token = _token;
    }

    function balance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function transfer(address to, uint256 value) external onlyOwner returns (bool) {
        return token.transfer(to, value);
    }
}

// UBXTStaking is the master of Token. He can make Token and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once Token is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract UBXTStaking is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP TOKENs the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 rewardUBXTDebt;
        //
        // We do some fancy math here. Basically, any point in time, the amount of TOKENs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accTokenPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP TOKENs to a pool. Here's what happens:
        //   1. The pool's `accTokenPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }
    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. TOKENs to distribute per block.
        uint256 lastRewardBlock; // Last block number that TOKENs distribution occurs.
        uint256 lastUBXTTotalReward; // Perf Pool Rewards
        uint256 accTokenPerShare; // Accumulated TOKENs per share, times 1e12. See below.
        uint256 ubxtAccRewardPerShare;
    }
    // The TOKEN TOKEN!
    address public token;
    // TOKEN TOKENs created per block.
    uint256 public tokenPerBlock;
    // Token holder
    TokenPool private _lockedPool;
    // Bonus muliplier for early token makers.
    uint256 public constant BONUS_MULTIPLIER = 1;
    // notice total UBXT rewards for distribution
    uint256 totalUBXTReward;
    // notice last UBXT rewards balance
    uint256 lastUBXTRewardBalance;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP TOKENs.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // Total UBXT staked
    uint256 public totalStakedUBXT;
    // The block number when TOKEN mining starts.
    uint256 public startBlock;
    // notice minimum time interval to call epoch
    uint256 public minEpochTimeIntervalSec;
    // notice to call epoch at fixed time in a day 
    uint256 public epochWindowOffsetSec;
    // notice seconds for epoch active
    uint256 public epochWindowLengthSec;
    // notice last epoch call time
    uint256 public lastEpochTimestampSec;
    // notice minted reward tokens for week
    uint256 public mintedRewardToken;
    // notice epoch count
    uint256 public epoch;
    // perf pool address
    address public perfPool;
    // withdraw fee
    uint256 private withdrawFee;
    // treasury address
    address public treasuryAddress;
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor() public
    { }
    
    function initialize(address _token, uint256 _tokenPerBlock, address _owner) public initializer {
        Ownable.init(_owner);
        token = _token;
        tokenPerBlock = _tokenPerBlock;
        startBlock = block.number;
        _lockedPool = new TokenPool(IERC20(_token));
        treasuryAddress = _owner;
        withdrawFee = 300;

        minEpochTimeIntervalSec = 43200;  // 43200
        epochWindowOffsetSec = 0;
        epochWindowLengthSec = 30 minutes;  // 30 minutes
        lastEpochTimestampSec = 0;
    }
    
    /**
     * @return Total number of locked distribution tokens.
     */
    function totalLocked() public view returns (uint256) {
        return _lockedPool.balance();
    }
    
    // Lock Tokens for Reserved
    function lockUbxtTokens(uint256 _amount) public onlyOwner {
        require(_lockedPool.token().transferFrom(msg.sender, address(_lockedPool), _amount),
            'UBXTStaking: transfer into locked pool failed');
    }

    /**
     * @return If the latest block timestamp is within the Epoch time window it, returns true.
     *         Otherwise, returns false.
     */
    function inEpochWindow() public view returns (bool) {
        return (
            now.mod(minEpochTimeIntervalSec) >= epochWindowOffsetSec &&
            now.mod(minEpochTimeIntervalSec) < (epochWindowOffsetSec.add(epochWindowLengthSec))
        );
    }

    /**
     * @notice Sets the parameters which control the timing and frequency of
     *         Epoch operations.
     *         a) the minimum time period that must elapse between Epoch cycles.
     *         b) the Epoch window offset parameter.
     *         c) the Epoch window length parameter.
     * @param minEpochTimeIntervalSec_ More than this much time must pass between Epoch
     *        operations, in seconds.
     * @param EpochWindowOffsetSec_ The number of seconds from the beginning of
              the Epoch interval, where the Epoch window begins.
     * @param EpochWindowLengthSec_ The length of the Epoch window in seconds.
     */
    function setEpochTimingParameters(
        uint256 minEpochTimeIntervalSec_,
        uint256 EpochWindowOffsetSec_,
        uint256 EpochWindowLengthSec_)
        external
        onlyOwner
    {
        require(minEpochTimeIntervalSec_ > 0);
        require(EpochWindowOffsetSec_ < minEpochTimeIntervalSec_);

        minEpochTimeIntervalSec = minEpochTimeIntervalSec_;
        epochWindowOffsetSec = EpochWindowOffsetSec_;
        epochWindowLengthSec = EpochWindowLengthSec_;
    }

    /**
     * @notice Call epoch to distribure perf pool ubxt to users 
     * this method will call in every 12 hours at fixed time
     */
    function distributePerfPoolRewards() public onlyOwner {
        require(inEpochWindow(), "Can not call epoch that time");

        // This comparison also ensures there is no reentrancy.
        require(lastEpochTimestampSec.add(minEpochTimeIntervalSec) < now, "Epoch will call after some time");

        // Snap the Epoch time to the start of this window.
        uint256 ubxtBal = IERC20(token).balanceOf(perfPool);
        IERC20(token).transferFrom(perfPool, address(this), ubxtBal);

        epoch = epoch.add(1);
    }

    // updated Perf pool address
    function updatePerfPoolAddress(address _perfPoolAddress) public onlyOwner {
        perfPool = _perfPoolAddress;
    }

    // updated treasury address
    function updateTreasuryAddress(address _treasuryAddress) public onlyOwner {
        treasuryAddress = _treasuryAddress;
    }
    
    // update withdraw fee
    function updateWithdrawFee(uint256 _withdrawFee) public onlyOwner {
        withdrawFee = _withdrawFee;
    }

    // update token per block value
    function updateTokenPerBlock(uint256 _tokenPerBlock) public onlyOwner {
        massUpdatePools();
        tokenPerBlock = _tokenPerBlock;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                lastUBXTTotalReward: 0,
                accTokenPerShare: 0,
                ubxtAccRewardPerShare: 0
            })
        );
    }

    // Update the given pool's TOKEN allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        pure
        returns (uint256)
    {
        return _to.sub(_from);
    }

    // View function to see pending TOKENs on frontend.
    function pendingToken(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 lpSupply;
        if(_pid == 0)
            lpSupply = totalStakedUBXT;
        else
            lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardBlock, block.number);
            uint256 tokenReward =
                multiplier.mul(tokenPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accTokenPerShare = accTokenPerShare.add(
                tokenReward.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accTokenPerShare).div(1e12).sub(user.rewardDebt);
    }
    
    /**
     * @return Return total earned UBXT token for staked time period
     * @param _user User address
     */
    function pendingUBXTReward(address _user) external view returns (uint256) 
    {
        uint256 _poolId = 0;
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][_user];
        uint256 accRewardPerShare = pool.ubxtAccRewardPerShare;
        uint256 supply = totalStakedUBXT;
        
        uint256 balance = IERC20(token).balanceOf(address(this)).sub(totalStakedUBXT);
        uint256 _totalReward = totalUBXTReward;
        if (balance > lastUBXTRewardBalance) {
            _totalReward = _totalReward.add(balance.sub(lastUBXTRewardBalance));
        }
        if (_totalReward > pool.lastUBXTTotalReward && supply != 0) {
            uint256 reward = _totalReward.sub(pool.lastUBXTTotalReward).mul(100).div(100);
            accRewardPerShare = accRewardPerShare.add(reward.mul(1e12).div(supply));
        }
    
        return user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardUBXTDebt);
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        
        uint256 ubxtRewardBalance = IERC20(token).balanceOf(address(this)).sub(totalStakedUBXT);
        uint256 _totalUBXTReward = totalUBXTReward.add(ubxtRewardBalance.sub(lastUBXTRewardBalance));
        lastUBXTRewardBalance = ubxtRewardBalance;
        totalUBXTReward = _totalUBXTReward;
        
        uint256 lpSupply;
        if(_pid == 0)
            lpSupply = totalStakedUBXT;
        else
            lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            pool.lastUBXTTotalReward = _totalUBXTReward;
            return;
        }
        
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 tokenReward =
            multiplier.mul(tokenPerBlock).mul(pool.allocPoint).div(
                totalAllocPoint
            );
        pool.accTokenPerShare = pool.accTokenPerShare.add(
            tokenReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
        
        if(_pid == 0 && lpSupply != 0) {
            uint256 ubxtReward = _totalUBXTReward.sub(pool.lastUBXTTotalReward).mul(100).div(100);
            pool.ubxtAccRewardPerShare = pool.ubxtAccRewardPerShare.add(ubxtReward.mul(1e12).div(lpSupply));
            pool.lastUBXTTotalReward = _totalUBXTReward;
        } else {
            pool.ubxtAccRewardPerShare = 0;
            pool.lastUBXTTotalReward = 0;
            user.rewardUBXTDebt = 0;
        }
    }

    // Deposit LP TOKENs to UBXTStaking for TOKEN allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending =
                user.amount.mul(pool.accTokenPerShare).div(1e12).sub(
                    user.rewardDebt
                );
            if (_pid == 0) {
                uint256 ubxtPending = 
                user.amount.mul(pool.ubxtAccRewardPerShare).div(1e12).sub(
                    user.rewardUBXTDebt);
                safePerfPoolTokenTransfer(msg.sender, ubxtPending);                
            }
            safeTokenTransfer(msg.sender, pending);
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        if (_pid == 0)
            totalStakedUBXT = totalStakedUBXT.add(_amount);
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        user.rewardUBXTDebt = user.amount.mul(pool.ubxtAccRewardPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP TOKENs from UBXTStaking.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending =
            user.amount.mul(pool.accTokenPerShare).div(1e12).sub(
                user.rewardDebt
            );
        safeTokenTransfer(msg.sender, pending);
        
        if (_pid == 0) {
            uint256 ubxtPending = 
                user.amount.mul(pool.ubxtAccRewardPerShare).div(1e12).sub(
                    user.rewardUBXTDebt);
            safePerfPoolTokenTransfer(msg.sender, ubxtPending);                
        }
        user.amount = user.amount.sub(_amount);
        if (_pid == 0)
            totalStakedUBXT = totalStakedUBXT.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        user.rewardUBXTDebt = user.amount.mul(pool.ubxtAccRewardPerShare).div(1e12);
        uint256 withdrawFee = _amount.mul(withdrawFee).div(100000);
        _amount = _amount.sub(withdrawFee);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        pool.lpToken.safeTransfer(address(treasuryAddress), withdrawFee);
        emit Withdraw(msg.sender, _pid, _amount.add(withdrawFee));
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 _amount = user.amount;
        uint256 withdrawFee = _amount.mul(withdrawFee).div(100000);
        _amount = _amount.sub(withdrawFee);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        pool.lpToken.safeTransfer(address(treasuryAddress), withdrawFee);
        if (_pid == 0)
            totalStakedUBXT = totalStakedUBXT.sub(user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.rewardUBXTDebt = 0;
    }

    // Safe token transfer function, just in case if rounding error causes pool to not have enough TOKENs.
    function safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = totalLocked();
        if (_amount > tokenBal) {
            _lockedPool.transfer(_to, tokenBal);
        } else {
            _lockedPool.transfer(_to, _amount);
        }
    }
    
    // Safe token transfer function, just in case if rounding error causes pool to not have enough TOKENs.
    function safePerfPoolTokenTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = IERC20(token).balanceOf(address(this));
        if (_amount > tokenBal) {
            IERC20(token).transfer(_to, tokenBal);
        } else {
            IERC20(token).transfer(_to, _amount);
        }
        lastUBXTRewardBalance = IERC20(token).balanceOf(address(this)).sub(totalStakedUBXT);
    }

    // Emergency Withdraw.
    function emergencyWithdrawToken(address _to, uint256 _amount) public onlyOwner {
        uint256 tokenBal = IERC20(token).balanceOf(address(this));
        if (_amount > tokenBal) {
            IERC20(token).transfer(_to, tokenBal);
        } else {
            IERC20(token).transfer(_to, _amount);
        }
    }
}