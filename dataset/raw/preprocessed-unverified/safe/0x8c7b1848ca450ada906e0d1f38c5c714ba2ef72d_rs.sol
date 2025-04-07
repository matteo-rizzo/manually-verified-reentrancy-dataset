// File: smartcontract/chefInOne.sol

/*

website: CrabFarm.io

░█████╗░██████╗░░█████╗░██████╗░███████╗░█████╗░██████╗░███╗░░░███╗
██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗████╗░████║
██║░░╚═╝██████╔╝███████║██████╦╝█████╗░░███████║██████╔╝██╔████╔██║
██║░░██╗██╔══██╗██╔══██║██╔══██╗██╔══╝░░██╔══██║██╔══██╗██║╚██╔╝██║
╚█████╔╝██║░░██║██║░░██║██████╦╝██║░░░░░██║░░██║██║░░██║██║░╚═╝░██║
░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═╝░░░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░░░░╚═╝

forked from SUSHI

*/

pragma solidity ^0.6.6;

abstract contract Context {
    function _msgSender() internal virtual view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal virtual view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}











contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract CrabChef is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of CRABs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accCrabPerShare) - user.rewardDebt
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. CRABs to distribute per block.
        uint256 lastRewardBlock; // Last block number that CRABs distribution occurs.
        uint256 accCrabPerShare; // Accumulated CRABs per share, times 1e12. See below.
    }

    // The CRAB TOKEN!
    IERC20 public crab;
    // Dev address.
    address public devaddr;
    // Block number when bonus CRAB period ends.
    uint256 public bonusEndBlock;
    // CRAB tokens created per block.
    uint256 public crabPerBlock;
    // Bonus muliplier for early crab makers.
    // no bonus
    IMigratorChef public migrator;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    mapping(address => bool) public lpTokenExistsInPool;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when CRAB mining starts.
    uint256 public startBlock;

    uint256 public blockInADay = 5760; // Assume 15s per block
    uint256 public blockInAMonth = 172800;
    uint256 public halvePeriod = blockInAMonth;
    uint256 public minimumCrabPerBlock = 125 ether; // Start at 1000, halve 3 times, 500 -> 250 -> 125.
    uint256 public lastHalveBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event Halve(uint256 newCrabPerBlock, uint256 nextHalveBlockNumber);

    constructor(
        IERC20 _crab,
        address _devaddr,
        uint256 _startBlock
    ) public {
        crab = _crab;
        devaddr = _devaddr;
        crabPerBlock = 1000 ether;
        startBlock = _startBlock;
        lastHalveBlock = _startBlock;
    }

    function doHalvingCheck(bool _withUpdate) public {
        if (crabPerBlock <= minimumCrabPerBlock) {
            return;
        }
        bool doHalve = block.number > lastHalveBlock + halvePeriod;
        if (!doHalve) {
            return;
        }
        uint256 newCrabPerBlock = crabPerBlock.div(2);
        if (newCrabPerBlock >= minimumCrabPerBlock) {
            crabPerBlock = newCrabPerBlock;
            lastHalveBlock = block.number;
            emit Halve(newCrabPerBlock, block.number + halvePeriod);

            if (_withUpdate) {
                massUpdatePools();
            }
        }
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
        require(
            !lpTokenExistsInPool[address(_lpToken)],
            "CrabChef: LP Token Address already exists in pool"
        );
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accCrabPerShare: 0
            })
        );
        lpTokenExistsInPool[address(_lpToken)] = true;
    }

    function updateLpTokenExists(address _lpTokenAddr, bool _isExists)
        external
        onlyOwner
    {
        lpTokenExistsInPool[_lpTokenAddr] = _isExists;
    }

    // Update the given pool's CRAB allocation point. Can only be called by the owner.
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

    function setMigrator(IMigratorChef _migrator) public onlyOwner {
        migrator = _migrator;
    }

    function migrate(uint256 _pid) public onlyOwner {
        require(
            address(migrator) != address(0),
            "CrabChef: Address of migrator is null"
        );
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(
            !lpTokenExistsInPool[address(newLpToken)],
            "CrabChef: New LP Token Address already exists in pool"
        );
        require(
            bal == newLpToken.balanceOf(address(this)),
            "CrabChef: New LP Token balance incorrect"
        );
        pool.lpToken = newLpToken;
        lpTokenExistsInPool[address(newLpToken)] = true;
    }

    // View function to see pending CRABs on frontend.
    function pendingCrab(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accCrabPerShare = pool.accCrabPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blockPassed = block.number.sub(pool.lastRewardBlock);
            uint256 crabReward = blockPassed
                .mul(crabPerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint);
            accCrabPerShare = accCrabPerShare.add(
                crabReward.mul(1e12).div(lpSupply)
            );
        }
        return
            user.amount.mul(accCrabPerShare).div(1e12).sub(user.rewardDebt);
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
        doHalvingCheck(false);
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 blockPassed = block.number.sub(pool.lastRewardBlock);
        uint256 crabReward = blockPassed
            .mul(crabPerBlock)
            .mul(pool.allocPoint)
            .div(totalAllocPoint);
        crab.mint(devaddr, crabReward.div(16)); // 6.25%
        crab.mint(address(this), crabReward);
        pool.accCrabPerShare = pool.accCrabPerShare.add(
            crabReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for CRAB allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(pool.accCrabPerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            safeCrabTransfer(msg.sender, pending);
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accCrabPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(
            user.amount >= _amount,
            "CrabChef: Insufficient Amount to withdraw"
        );
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accCrabPerShare).div(1e12).sub(
            user.rewardDebt
        );
        safeCrabTransfer(msg.sender, pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accCrabPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
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

    // Safe crab transfer function, just in case if rounding error causes pool to not have enough CRABs.
    function safeCrabTransfer(address _to, uint256 _amount) internal {
        uint256 crabBal = crab.balanceOf(address(this));
        if (_amount > crabBal) {
            crab.transfer(_to, crabBal);
        } else {
            crab.transfer(_to, _amount);
        }
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(
            msg.sender == devaddr,
            "CrabChef: Sender is not the developer"
        );
        devaddr = _devaddr;
    }
}