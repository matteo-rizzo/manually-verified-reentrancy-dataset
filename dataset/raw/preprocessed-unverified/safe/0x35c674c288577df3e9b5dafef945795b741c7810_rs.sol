/**
 *Submitted for verification at Etherscan.io on 2021-06-22
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.12;



contract Memefund {

    using SafeMaths for uint256;

    address public rebaseOracle;       // Used for authentication
    address public owner;              // Used for authentication
    address public newOwner;

    uint8 public decimals;
    uint256 public totalSupply;
    string public name;
    string public symbol;

    uint256 private constant MAX_UINT256 = ~uint256(0);   // (2^256) - 1
    uint256 private constant MAXSUPPLY = ~uint128(0);  // (2^128) - 1

    uint256 private totalAtoms;
    uint256 private atomsPerMolecule;

    mapping (address => uint256) private atomBalances;
    mapping (address => mapping (address => uint256)) private allowedMolecules;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event LogRebase(uint256 _totalSupply);
    event LogNewRebaseOracle(address _rebaseOracle);
    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public
    {
        decimals = 9;                               // decimals  
        totalSupply = 100000000*10**9;                // initialSupply
        name = "Memefund";                         // Set the name for display purposes
        symbol = "MFUND";                            // Set the symbol for display purposes

        owner = msg.sender;
        totalAtoms = MAX_UINT256 - (MAX_UINT256 % totalSupply);     // totalAtoms is a multiple of totalSupply so that atomsPerMolecule is an integer.
        atomBalances[msg.sender] = totalAtoms;
        atomsPerMolecule = totalAtoms.div(totalSupply);

        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /**
     * @param newRebaseOracle The address of the new oracle for rebasement (used for authentication).
     */
    function setRebaseOracle(address newRebaseOracle) external {
        require(msg.sender == owner, "Can only be executed by owner.");
        rebaseOracle = newRebaseOracle;

        emit LogNewRebaseOracle(rebaseOracle);
    }

    /**
     * @dev Propose a new owner.
     * @param _newOwner The address of the new owner.
     */
    function transferOwnership(address _newOwner) public
    {
        require(msg.sender == owner, "Can only be executed by owner.");
        require(_newOwner != address(0), "0x00 address not allowed.");
        newOwner = _newOwner;
    }

    /**
     * @dev Accept new owner.
     */
    function acceptOwnership() public
    {
        require(msg.sender == newOwner, "Sender not authorized.");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    /**
     * @dev Notifies Benchmark contract about a new rebase cycle.
     * @param supplyDelta The number of new molecule tokens to add into or remove from circulation.
     * @param increaseSupply Whether to increase or decrease the total supply.
     * @return The total number of molecules after the supply adjustment.
     */
    function rebase(uint256 supplyDelta, bool increaseSupply) external returns (uint256) {
        require(msg.sender == rebaseOracle, "Can only be executed by rebaseOracle.");
        
        if (supplyDelta == 0) {
            emit LogRebase(totalSupply);
            return totalSupply;
        }

        if (increaseSupply == true) {
            totalSupply = totalSupply.add(supplyDelta);
        } else {
            totalSupply = totalSupply.sub(supplyDelta);
        }

        if (totalSupply > MAXSUPPLY) {
            totalSupply = MAXSUPPLY;
        }

        atomsPerMolecule = totalAtoms.div(totalSupply);

        emit LogRebase(totalSupply);
        return totalSupply;
    }

    /**
     * @param who The address to query.
     * @return The balance of the specified address.
     */
    function balanceOf(address who) public view returns (uint256) {
        return atomBalances[who].div(atomsPerMolecule);
    }

    /**
     * @dev Transfer tokens to a specified address.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     * @return True on success, false otherwise.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0),"Invalid address.");
        require(to != address(this),"Molecules contract can't receive MARK.");

        uint256 atomValue = value.mul(atomsPerMolecule);

        atomBalances[msg.sender] = atomBalances[msg.sender].sub(atomValue);
        atomBalances[to] = atomBalances[to].add(atomValue);

        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner has allowed to a spender.
     * @param owner_ The address which owns the funds.
     * @param spender The address which will spend the funds.
     * @return The number of tokens still available for the spender.
     */
    function allowance(address owner_, address spender) public view returns (uint256) {
        return allowedMolecules[owner_][spender];
    }

    /**
     * @dev Transfer tokens from one address to another.
     * @param from The address you want to send tokens from.
     * @param to The address you want to transfer to.
     * @param value The amount of tokens to be transferred.
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0),"Invalid address.");
        require(to != address(this),"Molecules contract can't receive MARK.");

        allowedMolecules[from][msg.sender] = allowedMolecules[from][msg.sender].sub(value);

        uint256 atomValue = value.mul(atomsPerMolecule);
        atomBalances[from] = atomBalances[from].sub(atomValue);
        atomBalances[to] = atomBalances[to].add(atomValue);
        
        emit Transfer(from, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of
     * msg.sender. This method is included for ERC20 compatibility.
     * IncreaseAllowance and decreaseAllowance should be used instead.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        allowedMolecules[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner has allowed to a spender.
     * This method should be used instead of approve() to avoid the double approval vulnerability.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        allowedMolecules[msg.sender][spender] = allowedMolecules[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, allowedMolecules[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner has allowed to a spender.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 oldValue = allowedMolecules[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            allowedMolecules[msg.sender][spender] = 0;
        } else {
            allowedMolecules[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, allowedMolecules[msg.sender][spender]);
        return true;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}






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

contract Memestake is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20; 
    
       
    struct UserInfo{
        uint256 amount; // How many tokens got staked by user.
        uint256 rewardDebt; // Reward debt. See Explanation below.

        // We do some fancy math here. Basically, any point in time, the amount of 
        // claimable MFUND by a user is:
        //
        //   pending reward = (user.amount * pool.accMFundPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accMfundPerShare` (and `lastRewardedBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    struct PoolInfo {
        IERC20 tokenContract; // Address of Token contract.
        uint256 allocPoint; // Allocation points from the pool
        uint256 lastRewardBlock; // Last block number where MFUND got distributed.
        uint256 accMfundPerShare; // Accumulated MFUND per share.
    }

    Memefund public mFundToken;
    uint256 public mFundPerBlock;

    PoolInfo[] public poolInfo;

    mapping (uint256 => mapping(address => UserInfo)) public userInfo;

    mapping (address => bool) isTokenContractAdded;

    uint256 public totalAllocPoint;

    uint256 public totalMfund;

    uint256 public startBlock;

    uint256 public endBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);



    constructor(Memefund _mFundToken,
                uint256 _totalMfund,
                uint256 _startBlock,
                uint256 _endBlock) public{
                require(address(_mFundToken) != address(0), "constructor: _mFundToken must not be zero address!");
                require(_totalMfund > 0, "constructor: _totalMfund must be greater than 0");

                mFundToken = _mFundToken;
                totalMfund = _totalMfund;
                startBlock = _startBlock;
                endBlock = _endBlock;
                
                uint256 numberOfBlocksForFarming = endBlock.sub(startBlock);
                mFundPerBlock = totalMfund.div(numberOfBlocksForFarming);
    }
    
    /// @notice Returns the number of pools that have been added by the owner
    /// @return Number of pools
    function numberOfPools() external view returns(uint256){
        return poolInfo.length;
    }
    

    /// @notice Create a new LPT pool by whitelisting a new ERC20 token.
    /// @dev Can only be called by the contract owner
    /// @param _allocPoint Governs what percentage of the total LPT rewards this pool and other pools will get
    /// @param _tokenContract Address of the staking token being whitelisted
    /// @param _withUpdate Set to true for updating all pools before adding this one
    function add(uint256 _allocPoint, IERC20 _tokenContract, bool _withUpdate) public onlyOwner {
        require(block.number < endBlock, "add: must be before end");
        address tokenContractAddress = address(_tokenContract);
        require(tokenContractAddress != address(0), "add: _tokenConctract must not be zero address");
        require(isTokenContractAdded[tokenContractAddress] == false, "add: already whitelisted");

        if (_withUpdate) {
            massUpdatePools();
        }

        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            tokenContract : _tokenContract,
            allocPoint : _allocPoint,
            lastRewardBlock : lastRewardBlock,
            accMfundPerShare : 0
        }));

        isTokenContractAdded[tokenContractAddress] = true;
    }

    /// @notice Update a pool's allocation point to increase or decrease its share of contract-level rewards
    /// @notice Can also update the max amount that can be staked per user
    /// @dev Can only be called by the owner
    /// @param _pid ID of the pool being updated
    /// @param _allocPoint New allocation point
    /// @param _withUpdate Set to true if you want to update all pools before making this change - it will checkpoint those rewards
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        require(block.number < endBlock, "set: must be before end");
        require(_pid < poolInfo.length, "set: invalid _pid");

        if (_withUpdate) {
            massUpdatePools();
        }

        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);

        poolInfo[_pid].allocPoint = _allocPoint;
    }

    /// @notice View function to see pending and unclaimed Mfunds for a given user
    /// @param _pid ID of the pool where a user has a stake
    /// @param _user Account being queried
    /// @return Amount of MFUND tokens due to a user
    function pendingRewards(uint256 _pid, address _user) external view returns (uint256) {
        require(_pid < poolInfo.length, "pendingMfund: invalid _pid");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 accMfundPerShare = pool.accMfundPerShare;
        uint256 lpSupply = pool.tokenContract.balanceOf(address(this));

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 maxBlock = block.number <= endBlock ? block.number : endBlock;
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, maxBlock);
            uint256 mFundReward = multiplier.mul(mFundPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accMfundPerShare = accMfundPerShare.add(mFundReward.mul(1e18).div(lpSupply));
        }

        return user.amount.mul(accMfundPerShare).div(1e18).sub(user.rewardDebt);
    }
    
    
    function claimRewards(uint256 _pid) public{
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accMfundPerShare).div(1e24).sub(user.rewardDebt);
        require(pending > 0, "harvest: no reward owed");
        user.rewardDebt = user.amount.mul(pool.accMfundPerShare).div(1e24);
        safeMfundTransfer(msg.sender, pending);
        emit Claim(msg.sender, _pid, pending);
    }
        /// @notice Cycles through the pools to update all of the rewards accrued
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }
    
    
    

    /// @notice Updates a specific pool to track all of the rewards accrued up to the TX block
    /// @param _pid ID of the pool
    function updatePool(uint256 _pid) public {
        require(_pid < poolInfo.length, "updatePool: invalid _pid");

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        uint256 tokenContractSupply = pool.tokenContract.balanceOf(address(this));
        if (tokenContractSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 maxEndBlock = block.number <= endBlock ? block.number : endBlock;
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, maxEndBlock);

        // No point in doing any more logic as the rewards have ended
        if (multiplier == 0) {
            return;
        }

        uint256 mFundReward = multiplier.mul(mFundPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

        pool.accMfundPerShare = pool.accMfundPerShare.add(mFundReward.mul(1e18).div(tokenContractSupply));
        pool.lastRewardBlock = maxEndBlock;
    }

    /// @notice Where any user can stake their ERC20 tokens into a pool in order to farm $LPT
    /// @param _pid ID of the pool
    /// @param _amount Amount of ERC20 being staked
    function deposit(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accMfundPerShare).div(1e18).sub(user.rewardDebt);
            if (pending > 0) {
                safeMfundTransfer(msg.sender, pending);
            }
        }

        if (_amount > 0) {
            pool.tokenContract.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }

        user.rewardDebt = user.amount.mul(pool.accMfundPerShare).div(1e18);
        emit Deposit(msg.sender, _pid, _amount);
    }

    /// @notice Allows a user to withdraw any ERC20 tokens staked in a pool
    /// @dev Partial withdrawals permitted
    /// @param _pid Pool ID
    /// @param _amount Being withdrawn
    function withdraw(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(user.amount >= _amount, "withdraw: _amount not good");

        updatePool(_pid);

        uint256 pending = user.amount.mul(pool.accMfundPerShare).div(1e18).sub(user.rewardDebt);
        if (pending > 0) {
            safeMfundTransfer(msg.sender, pending);
        }

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.tokenContract.safeTransfer(address(msg.sender), _amount);
        }

        user.rewardDebt = user.amount.mul(pool.accMfundPerShare).div(1e18);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    /// @notice Emergency only. Should the rewards issuance mechanism fail, people can still withdraw their stake
    /// @param _pid Pool ID
    function emergencyWithdraw(uint256 _pid) external {
        require(_pid < poolInfo.length, "updatePool: invalid _pid");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        pool.tokenContract.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    ////////////
    // Private /
    ////////////

    /// @dev Safe MFUND transfer function, just in case if rounding error causes pool to not have enough LPTs.
    /// @param _to Whom to send MFUND into
    /// @param _amount of MFUND to send
    function safeMfundTransfer(address _to, uint256 _amount) internal {
        uint256 mFundBal = mFundToken.balanceOf(address(this));
        if (_amount > mFundBal) {
            mFundToken.transfer(_to, mFundBal);
        } else {
            mFundToken.transfer(_to, _amount);
        }
    }

    /// @notice Return reward multiplier over the given _from to _to block.
    /// @param _from Block number
    /// @param _to Block number
    /// @return Number of blocks that have passed
    function getMultiplier(uint256 _from, uint256 _to) private view returns (uint256) {
        return _to.sub(_from);
    }
}