/**
 *Submitted for verification at Etherscan.io on 2020-12-23
*/

pragma solidity ^0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
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
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


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



contract GoBrrrToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    mapping(address => uint256) private _balanceOf;
    mapping (address => mapping (address => uint256)) private _allowance;
    
    modifier validRecipient(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    string private constant _name = "Go BRRR";
    string private constant _symbol = "BRRR";
    uint256 private constant _decimals = 18;

    uint256 private _totalSupply = 111 * (uint256(10) ** _decimals);
    
    uint256 public transBurnrate = 3;//0.03%

    constructor() public {
        _owner = msg.sender;
        
        // Initially assign all tokens to the contract's creator.
        _balanceOf[msg.sender] = _totalSupply;
        emit Transfer(address(0x0), msg.sender, _totalSupply);       
    }
    
    function name() public pure returns (string memory) {
        return _name;
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    
    function decimals() public pure returns (uint256) {
        return _decimals;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256)
    {
        return _balanceOf[account];
    }
    
    function transfer(address to, uint256 value) public validRecipient(to) virtual override returns (bool)
    {
        require(_balanceOf[msg.sender] >= value);
        
        uint256 remainrate = 10000; 
        remainrate = remainrate.sub(transBurnrate); //99.97%->99.97/10000
        uint256 leftvalue = value.mul(remainrate);
        leftvalue = leftvalue.sub(leftvalue.mod(10000));
        leftvalue = leftvalue.div(10000);

        _balanceOf[msg.sender] -= value;  // deduct from sender's balance
        _balanceOf[to] += leftvalue;          // add to recipient's balance
        
        uint256 decayvalue = value.sub(leftvalue); //3%->3/100->value-leftvalue
        _totalSupply = _totalSupply.sub(decayvalue);
        
        emit Transfer(msg.sender, address(0x0), decayvalue);
        emit Transfer(msg.sender, to, leftvalue);
        
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public validRecipient(to) virtual override returns (bool)
    {
        require(value <= _balanceOf[from]);
        require(value <= _allowance[from][msg.sender]);
        
        uint256 remainrate = 10000; 
        remainrate = remainrate.sub(transBurnrate); //99.97%->99.97/10000
        uint256 leftvalue = value.mul(remainrate);
        leftvalue = leftvalue.sub(leftvalue.mod(10000));
        leftvalue = leftvalue.div(10000);

        _balanceOf[from] -= value;
        _balanceOf[to] += leftvalue;
        _allowance[from][msg.sender] -= value;
        
        uint256 decayvalue = value.sub(leftvalue); //0.03%->3/10000->value-leftvalue
        _totalSupply = _totalSupply.sub(decayvalue);
        
        emit Transfer(from, address(0x0), decayvalue);
        emit Transfer(from, to, leftvalue);
        return true;
    }

    function approve(address spender, uint256 value) public virtual override returns (bool)
    {
        _allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual override returns (uint256)
    {
        return _allowance[owner][spender];
    }      
    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool)
    {
        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool)
    {
        uint256 oldValue = _allowance[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowance[msg.sender][spender] = 0;
        } else {
            _allowance[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }        
    
    function changetransBurnrate(uint256 _transBurnrate) external onlyOwner returns (bool) {
        transBurnrate = _transBurnrate;
        return true;
    }

    function mint(address account, uint256 amount) public onlyOwner {
        require(account != address(0));
        
        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balanceOf[account] = _balanceOf[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}


// MasterChef is the master of Brrr. He can make Brrr and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once BRRR is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterChef is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of BRRRs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accBrrrPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accBrrrPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. BRRRs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that BRRRs distribution occurs.
        uint256 accBrrrPerShare; // Accumulated BRRRs per share, times 1e12. See below.
    }

    // The BRRR TOKEN!
    GoBrrrToken public brrr;
    // Dev address.
    address public devaddr;
    // Block number when bonus BRRR period ends.
    uint256 public bonusEndBlock;
    // BRRR tokens created per block.
    uint256 public brrrPerBlock;
    // Bonus muliplier for early brrr makers.
    uint256 public constant BONUS_MULTIPLIER = 10;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when BRRR mining starts.
    uint256 public startBlock;
    
    uint256 public teamrewardrate = 3;//3%->3/100
    
    uint256 public withdrawlFee = 100;//100->10%
   
    
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EthRewardAdded(address indexed user, uint256 ethReward);
    event addpool(uint256 _allocPoint, IERC20 _lpToken);
    event setpool(uint256 _pid, uint256 _allocPoint);

    constructor(
        GoBrrrToken _brrr,
        address _devaddr,
        uint256 _brrrPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) public {
        brrr = _brrr;
        devaddr = _devaddr;
        brrrPerBlock = _brrrPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }
    
    
    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accBrrrPerShare: 0
        }));
        emit addpool(_allocPoint, _lpToken);
    }

    // Update the given pool's BRRR allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        emit setpool(_pid, _allocPoint);
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                _to.sub(bonusEndBlock)
            );
        }
    }

    // View function to see pending BRRRs on frontend.
    function pendingBrrr(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accBrrrPerShare = pool.accBrrrPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 brrrReward = multiplier.mul(brrrPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accBrrrPerShare = accBrrrPerShare.add(brrrReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accBrrrPerShare).div(1e12).sub(user.rewardDebt);
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
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 brrrReward = multiplier.mul(brrrPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        uint256 teambrrrReward = brrrReward.sub(brrrReward.mod(100));
        teambrrrReward = teambrrrReward.div(100).mul(teamrewardrate);
        brrr.mint(devaddr, teambrrrReward);
        brrr.mint(address(this), brrrReward);
        pool.accBrrrPerShare = pool.accBrrrPerShare.add(brrrReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for BRRR allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accBrrrPerShare).div(1e12).sub(user.rewardDebt);
            safeBrrrTransfer(msg.sender, pending);
        }
        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accBrrrPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accBrrrPerShare).div(1e12).sub(user.rewardDebt);
        safeBrrrTransfer(msg.sender, pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accBrrrPerShare).div(1e12);
        
        //test
        uint256 withdrawFeeAmount = _amount.mul(withdrawlFee).div(1000);
        uint256 remainingUserAmount = _amount.sub(withdrawFeeAmount);
        
        // 50% of the LP tokens kept by the unstaking fee will be locked forever in the BRRR contract, the other 50% will be sent to team.
        uint256 lpTokensToLock = withdrawFeeAmount.div(2);
        uint256 lpTokensToTeam = lpTokensToLock;
        
        pool.lpToken.safeTransfer(address(msg.sender), remainingUserAmount);
        pool.lpToken.safeTransfer(devaddr, lpTokensToTeam);
        pool.lpToken.safeTransfer(address(this), lpTokensToLock);
        
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Safe brrr transfer function, just in case if rounding error causes pool to not have enough BRRRs.
    function safeBrrrTransfer(address _to, uint256 _amount) internal {
        uint256 brrrBal = brrr.balanceOf(address(this));
        if (_amount > brrrBal) {
            brrr.transfer(_to, brrrBal);
        } else {
            brrr.transfer(_to, _amount);
        }
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }
    
    
    //change the TPB(tokensPerBlock)
    function changetokensPerBlock(uint256 _newtokensPerBlock) public onlyOwner {
        brrrPerBlock = _newtokensPerBlock;
    }
    //change the transBurnrate
    function changetransBurnrate(uint256 _newtransBurnrate) public onlyOwner {
        brrr.changetransBurnrate(_newtransBurnrate);
    }
    //change the transBurnrate
    function changeteamrewardrate(uint256 _newteamrewardrate) public onlyOwner {
        teamrewardrate = _newteamrewardrate;
    }
}



contract OwnerChef is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
 
    //
    MasterChef public masterchef;
    //
    uint256 public constant maxburnrate = 600;//6%->600/10000
    //
    uint256 public constant maxtokenperblock = 1000000000000000000;// 1 token
    
    uint256 public constant maxteamrewardrate = 5;//5%->5/100
    
    event setpoolevent(uint256 _pid, uint256 _allocPoint);
    event addpoolevent(uint256 _allocPoint, IERC20 _lpToken);
    event changeTRRevent(uint256 _newTRR);
    event changeTBRevent(uint256 _newTBR);
    event changeTPBevent(uint256 _newTPB);

    constructor(
        MasterChef _masterchef
    ) public {
        masterchef = _masterchef;
    }

   
    
    //
    function changeTPB(uint256 _newTPB) public onlyOwner {
        require(_newTPB <= maxtokenperblock, "too high value");
        masterchef.changetokensPerBlock(_newTPB);
        emit changeTPBevent(_newTPB);
    }
    //
    function changeTBR(uint256 _newTBR) public onlyOwner {
        require(_newTBR <= maxburnrate, "too high value");
        masterchef.changetransBurnrate(_newTBR);
        emit changeTBRevent(_newTBR);
    }
    //
    function changeTRR(uint256 _newTRR) public onlyOwner {
        require(_newTRR <= maxteamrewardrate, "too high value");
        masterchef.changeteamrewardrate(_newTRR);
        emit changeTRRevent(_newTRR);
    }
    
    // 
    function addpool(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {
        masterchef.add(_allocPoint, _lpToken, _withUpdate);
        emit addpoolevent(_allocPoint, _lpToken);
    }

    // 
    function setpool(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        masterchef.set(_pid, _allocPoint, _withUpdate);
        emit setpoolevent(_pid, _allocPoint);
    }
    
    
}