/**
 *Submitted for verification at Etherscan.io on 2020-11-05
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity 0.6.12;










abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}






contract LPStaking is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;         // How many LP tokens the user has provided.
        uint256 rewardDebt;     // Reward debt. See explanation below.
        uint256 lockRewards;    // lock rewards when not migrated
        uint256 stakeBlocks;    // number of blocks containing staking;
        uint256 lastBlock;      // the last block.number when update shares;
        uint256 accStakeShares; // accumulate stakes: ¡Æ(amount * stakeBlocks);
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. Token to distribute per block.
        uint256 lastRewardBlock;  // Last block number that Token distribution occurs.
        uint256 accTokenPerShare; // Accumulated Token per share, times 1e12. See below.
    }

    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    IMigrator public migrator;
    // The block number when Token mining starts.
    uint256 immutable public startBlock;
    // The block number when Token mining ends.
    uint256 immutable public endBlock;
    // Reward token created per block.
    uint256 public tokenPerBlock = 755 * 10 ** 16;

    mapping(address => bool) public poolIn;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;

    bool public migrated;
    IAward award;

    event Add(uint256 allocPoint, address lpToken, bool withUpdate);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event SetMigrator(address indexed newMigrator);
    event Migrate(uint256 pid, address indexed lpToken, address indexed newToken);
    event Initialization(address award, uint256 tokenPerBlock, uint256 startBlock, uint256 endBlock);
    event Set(uint256 pid, uint256 allocPoint, bool withUpdate);
    event UpdatePool(uint256 pid, uint256 accTokenPerShare, uint256 lastRewardBlock);

    constructor(
        IAward _award,
        uint256 _tokenPerBlock,
        uint256 _startBlock,
        uint256 _endBlock
    ) public {
        require(_startBlock < _endBlock, "LPStaking: invalid block range");
        award = _award;
        tokenPerBlock = _tokenPerBlock;
        startBlock = _startBlock;
        endBlock = _endBlock;
        emit Initialization(address(_award), _tokenPerBlock, _startBlock, _endBlock);
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, address _lpToken, bool _withUpdate) public onlyOwner {
        require(!poolIn[_lpToken], "LPStaking: duplicate lpToken");
        if (_withUpdate) {
            batchUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken : IERC20(_lpToken),
            allocPoint : _allocPoint,
            lastRewardBlock : lastRewardBlock,
            accTokenPerShare : 0
            }));
        poolIn[_lpToken] = true;
        emit Add(_allocPoint, _lpToken, _withUpdate);
    }

    // Update the given pool's Token allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        require(_pid < poolInfo.length, "LPStaking: pool index overflow");
        if (_withUpdate) {
            batchUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        emit Set(_pid, _allocPoint, _withUpdate);
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigrator _migrator) public onlyOwner {
        migrator = _migrator;
        emit SetMigrator(address(_migrator));
    }

    // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    function migrate(uint256 _pid) public {
        require(_pid < poolInfo.length, "LPStaking: pool index overflow");
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
        emit Migrate(_pid, address(lpToken), address(newLpToken));
    }

    function setMigrated() onlyOwner public {
        migrated = true;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) private view returns (uint256) {
        if (_to <= endBlock) {
            return _to.sub(_from);
        } else if (_from >= endBlock) {
            return 0;
        } else {
            return endBlock.sub(_from);
        }
    }

    // View function to see pending Token on frontend.
    function pendingShares(uint256 _pid, address _user) external view returns (uint256) {
        require(_pid < poolInfo.length, "LPStaking: pool index overflow");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 rewards = multiplier.mul(tokenPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accTokenPerShare = accTokenPerShare.add(rewards.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accTokenPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function batchUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        require(_pid < poolInfo.length, "LPStaking: pool index overflow");
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number > pool.lastRewardBlock) {
            uint256 lpSupply = pool.lpToken.balanceOf(address(this));
            if (lpSupply == 0) {
                pool.lastRewardBlock = block.number;
            } else {
                uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
                uint256 rewards = multiplier.mul(tokenPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
                pool.accTokenPerShare = pool.accTokenPerShare.add(rewards.mul(1e12).div(lpSupply));
                pool.lastRewardBlock = block.number;
            }
        }
        emit UpdatePool(_pid, pool.accTokenPerShare, pool.lastRewardBlock);
    }

    function shareAwards(uint256 _pid) private {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending = 0;
        if (user.amount > 0) {
            pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);

            uint256 num = block.number - user.lastBlock;
            user.stakeBlocks = user.stakeBlocks.add(num);
            user.accStakeShares = user.accStakeShares.add(user.amount.mul(num));
        }
        if (migrated) {
            uint256 locked = user.lockRewards.add(pending);
            user.lockRewards = 0;
            uint256 audit = user.stakeBlocks.mul(user.amount);
            if (user.accStakeShares > audit) {
                uint256 _locked = locked.mul(audit).div(user.accStakeShares);
                award.destroy(locked.sub(_locked));
                locked = _locked;
            }
            if (locked > 0) {
                award.addAward(msg.sender, locked);
            }
        } else {
            user.lockRewards = user.lockRewards.add(pending);
        }
        user.lastBlock = block.number;
    }

    // Deposit LP tokens to Staking for shares allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        require(_pid < poolInfo.length, "LPStaking: pool index overflow");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        shareAwards(_pid);
        pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from LPStaking.
    function withdraw(uint256 _pid, uint256 _amount) public {
        require(_pid < poolInfo.length, "LPStaking: pool index overflow");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        shareAwards(_pid);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        pool.lpToken.safeTransfer(msg.sender, _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        require(_pid < poolInfo.length, "LPStaking: pool index overflow");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(msg.sender, user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }
}