/**
 *Submitted for verification at Etherscan.io on 2020-10-27
*/

pragma solidity 0.6.12;

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

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _whitelistedAddresses;

    uint256 private _totalSupply;
    uint256 private _burnedSupply;
    uint256 private _burnRate;
    string private _name;
    string private _symbol;
    uint256 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint256 decimals, uint256 burnrate, uint256 initSupply) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _burnRate = burnrate;
        _totalSupply = 0;
        _mint(msg.sender, initSupply*(10**_decimals));
        _burnedSupply = 0;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint256) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the amount of burned tokens.
     */
    function burnedSupply() public view returns (uint256) {
        return _burnedSupply;
    }

    /**
     * @dev Returns the burnrate.
     */
    function burnRate() public view returns (uint256) {
        return _burnRate;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function burn(uint256 amount) public virtual returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (_whitelistedAddresses[sender] == true || _whitelistedAddresses[recipient] == true) {
            _beforeTokenTransfer(sender, recipient, amount);
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        } else {
            uint256 amount_burn = amount.mul(_burnRate).div(100);
            uint256 amount_send = amount.sub(amount_burn);
            require(amount == amount_send + amount_burn, "Burn value invalid");
            _burn(sender, amount_burn);
            amount = amount_send;
            _beforeTokenTransfer(sender, recipient, amount);
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     * 
     * HINT: This function is 'internal' and therefore can only be called from another
     * function inside this contract!
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        _burnedSupply = _burnedSupply.add(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {burnRate} to a value other than the initial one.
     */
    function _setupBurnrate(uint8 burnrate_) internal virtual {
        _burnRate = burnrate_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an minter) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the minter account will be the one that deploys the contract. This
 * can later be changed with {transferMintership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyMinter`, which can be applied to your functions to restrict their use to
 * the minter.
 */
contract Mintable is Context {

    /**
     * @dev So here we seperate the rights of the classic ownership into 'owner' and 'minter'
     * this way the developer/owner stays the 'owner' and can make changes like adding a pool
     * at any time but cannot mint anymore as soon as the 'minter' gets changes (to the chef contract)
     */
    address private _minter;

    event MintershipTransferred(address indexed previousMinter, address indexed newMinter);

    /**
     * @dev Initializes the contract setting the deployer as the initial minter.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _minter = msgSender;
        emit MintershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current minter.
     */
    function minter() public view returns (address) {
        return _minter;
    }

    /**
     * @dev Throws if called by any account other than the minter.
     */
    modifier onlyMinter() {
        require(_minter == _msgSender(), "Mintable: caller is not the minter");
        _;
    }

    /**
     * @dev Transfers mintership of the contract to a new account (`newMinter`).
     * Can only be called by the current minter.
     */
    function transferMintership(address newMinter) public virtual onlyMinter {
        require(newMinter != address(0), "Mintable: new minter is the zero address");
        emit MintershipTransferred(_minter, newMinter);
        _minter = newMinter;
    }
}

/*

website: boomswap.org

███   ████▄ ████▄ █▀▄▀█ ▀▄    ▄
█  █  █   █ █   █ █ █ █   █  █
█ ▀ ▄ █   █ █   █ █ ▄ █    ▀█
█  ▄▀ ▀████ ▀████ █   █    █
███                  █   ▄▀
                    ▀

*/
// BoomYswap
contract BoomYswap is ERC20("BoomYswap", "BoomY", 18, 2, 8642), Ownable, Mintable {
    /// @notice Creates `_amount` token to `_to`. Must only be called by the minter (BoomYMaster).
    function mint(address _to, uint256 _amount) public onlyMinter {
        _mint(_to, _amount);
    }

    function setBurnrate(uint8 burnrate_) public onlyOwner {
        _setupBurnrate(burnrate_);
    }

    function addWhitelistedAddress(address _address) public onlyOwner {
        _whitelistedAddresses[_address] = true;
    }

    function removeWhitelistedAddress(address _address) public onlyOwner {
        _whitelistedAddresses[_address] = false;
    }
}

/*

website: boomswap.org

███   ████▄ ████▄ █▀▄▀█ ▀▄    ▄
█  █  █   █ █   █ █ █ █   █  █
█ ▀ ▄ █   █ █   █ █ ▄ █    ▀█
█  ▄▀ ▀████ ▀████ █   █    █
███                  █   ▄▀
                    ▀

*/


contract BoomYMaster is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
        uint256 pendingRewards; // Pending rewards for user.
        uint lastHarvest; //Timestamp of last harvest, used for vesting
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. BoomYs to distribute per block.
        uint256 lastRewardBlock; // Last block number that BoomYs distribution occurs.
        uint256 accBoomYPerShare; // Accumulated BoomYs per share, times 1e12. See below.
        uint harvestVestingPeriod; // How much vesting for harvesting
    }

    // BoomY token
    BoomYswap public boomY;
    // BoomY tokens created per block.
    uint256 public boomYPerBlock;
    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    IMigrationMaster public migrator;
    //Has the minting rate halved?
    bool isMintingHalved;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when BoomY mining starts.
    uint256 public startBlock;

    // Events
    event Recovered(address token, uint256 amount);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);
    event ClaimAndStake(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(
        BoomYswap _boomY,
        uint256 _boomYPerBlock,
        uint256 _startBlock
    ) public {
        boomY = _boomY;
        boomYPerBlock = _boomYPerBlock;
        startBlock = _startBlock;
        isMintingHalved = false;

        // staking pool
        poolInfo.push(PoolInfo({
            lpToken: _boomY,
            allocPoint: 1000,
            lastRewardBlock: startBlock,
            accBoomYPerShare: 0,
            harvestVestingPeriod: 0
        }));

        totalAllocPoint = 1000;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate,
        uint _harvestVestingPeriod
    ) public onlyOwner {
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
                accBoomYPerShare: 0,
                harvestVestingPeriod: _harvestVestingPeriod
            })
        );
        updateStakingPool();
    }

    // Update the given pool's BoomY allocation point. Can only be called by the owner.
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
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            updateStakingPool();
        }
    }

    function updateStakingPool() internal {
        uint256 length = poolInfo.length;
        uint256 points = 0;
        for (uint256 pid = 1; pid < length; ++pid) {
            points = points.add(poolInfo[pid].allocPoint);
        }
        if (points != 0) {
            points = points.div(3);
            totalAllocPoint = totalAllocPoint.sub(poolInfo[0].allocPoint).add(points);
            poolInfo[0].allocPoint = points;
        }
    }

    // Migrate lp token to another lp contract. Can be called by anyone. 
    // We trust that migrator contract is good.
    function migrate(uint256 _pid) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    // View function to see pending BoomYs on frontend.
    function pendingBoomYs(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accBoomYPerShare = pool.accBoomYPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 boomYReward = boomYPerBlock
                .mul(pool.allocPoint)
                .div(totalAllocPoint);
            accBoomYPerShare = accBoomYPerShare.add(
                boomYReward.mul(1e12).div(lpSupply)
            );
        }
        return
            user.amount.mul(accBoomYPerShare).div(1e12).sub(user.rewardDebt).add(user.pendingRewards);
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
        uint256 boomYReward = boomYPerBlock
            .mul(pool.allocPoint)
            .div(totalAllocPoint);
        
        boomY.mint(address(this), boomYReward);
        pool.accBoomYPerShare = pool.accBoomYPerShare.add(
            boomYReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
        //Should we halve the minting?
        if(block.number >= startBlock.add(100000) && !isMintingHalved) {
            boomYPerBlock = boomYPerBlock.div(2);
            isMintingHalved = true;
        }
    }

    // Deposit LP tokens to BoomYMaster for BoomY allocation.
    function deposit(uint256 _pid, uint256 _amount, bool _withdrawRewards) public {
        require (_pid != 0, 'please deposit BoomY by staking');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(pool.accBoomYPerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            
            if (pending > 0) {
                user.pendingRewards = user.pendingRewards.add(pending);

                if (_withdrawRewards) {
                    safeBoomYTransfer(msg.sender, user.pendingRewards);
                    emit Claim(msg.sender, _pid, user.pendingRewards);
                    user.pendingRewards = 0;
                }
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accBoomYPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from BoomYMaster.
    function withdraw(uint256 _pid, uint256 _amount, bool _withdrawRewards) public {
        require (_pid != 0, 'please withdraw BOOMY by unstaking');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        require (block.timestamp >= user.lastHarvest.add(pool.harvestVestingPeriod), 'withdraw: you cant harvest yet');
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accBoomYPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            user.pendingRewards = user.pendingRewards.add(pending);

            if (_withdrawRewards) {
                safeBoomYTransfer(msg.sender, user.pendingRewards);
                emit Claim(msg.sender, _pid, user.pendingRewards);
                user.pendingRewards = 0;
            }
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accBoomYPerShare).div(1e12);
        user.lastHarvest = block.timestamp;
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        require (_pid != 0, 'please withdraw BOOMY by unstaking');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.pendingRewards = 0;
        user.lastHarvest = block.timestamp;
    }

    // Claim rewards from BoomYMaster.
    function claim(uint256 _pid) public {
        require (_pid != 0, 'please claim staking rewards on stake page');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require (block.timestamp >= user.lastHarvest.add(pool.harvestVestingPeriod), 'withdraw: you cant harvest yet');
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accBoomYPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0 || user.pendingRewards > 0) {
            user.pendingRewards = user.pendingRewards.add(pending);
            safeBoomYTransfer(msg.sender, user.pendingRewards);
            emit Claim(msg.sender, _pid, user.pendingRewards);
            user.pendingRewards = 0;
            user.lastHarvest = block.timestamp;
        }
        user.rewardDebt = user.amount.mul(pool.accBoomYPerShare).div(1e12);
    }

    // Claim rewards from BoomYMaster and deposit them directly to staking pool.
    function claimAndStake(uint256 _pid) public {
        require (_pid != 0, 'please claim and stake staking rewards on stake page');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accBoomYPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0 || user.pendingRewards > 0) {
            user.pendingRewards = user.pendingRewards.add(pending);
            transferToStake(user.pendingRewards);
            emit ClaimAndStake(msg.sender, _pid, user.pendingRewards);
            user.pendingRewards = 0;
        }
        user.rewardDebt = user.amount.mul(pool.accBoomYPerShare).div(1e12);
    }

    // Transfer rewards from LP pools to staking pool.
    function transferToStake(uint256 _amount) internal {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accBoomYPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                user.pendingRewards = user.pendingRewards.add(pending);
            }
        }
        if (_amount > 0) {
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accBoomYPerShare).div(1e12);

        emit Deposit(msg.sender, 0, _amount);
    }

    // Stake BoomY tokens to BoomYMaster.
    function enterStaking(uint256 _amount, bool _withdrawRewards) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accBoomYPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                user.pendingRewards = user.pendingRewards.add(pending);

                if (_withdrawRewards) {
                    safeBoomYTransfer(msg.sender, user.pendingRewards);
                    user.pendingRewards = 0;
                }
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accBoomYPerShare).div(1e12);

        emit Deposit(msg.sender, 0, _amount);
    }

    // Withdraw BoomY tokens from staking.
    function leaveStaking(uint256 _amount, bool _withdrawRewards) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        require(user.amount >= _amount, "unstake: not good");
        updatePool(0);
        uint256 pending = user.amount.mul(pool.accBoomYPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
                user.pendingRewards = user.pendingRewards.add(pending);

                if (_withdrawRewards) {
                    safeBoomYTransfer(msg.sender, user.pendingRewards);
                    user.pendingRewards = 0;
                }
            }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accBoomYPerShare).div(1e12);

        emit Withdraw(msg.sender, 0, _amount);
    }

    // Claim staking rewards from BoomYMaster.
    function claimStaking() public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        uint256 pending = user.amount.mul(pool.accBoomYPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0 || user.pendingRewards > 0) {
            user.pendingRewards = user.pendingRewards.add(pending);
            safeBoomYTransfer(msg.sender, user.pendingRewards);
            emit Claim(msg.sender, 0, user.pendingRewards);
            user.pendingRewards = 0;
        }
        user.rewardDebt = user.amount.mul(pool.accBoomYPerShare).div(1e12);
    }

    // Transfer staking rewards to staking pool.
    function stakeRewardsStaking() public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        uint256 rewardsToStake;
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accBoomYPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                user.pendingRewards = user.pendingRewards.add(pending);
            }
        }
        if (user.pendingRewards > 0) {
            rewardsToStake = user.pendingRewards;
            user.pendingRewards = 0;
            user.amount = user.amount.add(rewardsToStake);
        }
        user.rewardDebt = user.amount.mul(pool.accBoomYPerShare).div(1e12);

        emit Deposit(msg.sender, 0, rewardsToStake);
    }

    // Safe BoomY transfer function, just in case if rounding error causes pool to not have enough BoomYs.
    function safeBoomYTransfer(address _to, uint256 _amount) internal {
        uint256 boomYBal = boomY.balanceOf(address(this));
        if (_amount > boomYBal) {
            boomY.transfer(_to, boomYBal);
        } else {
            boomY.transfer(_to, _amount);
        }
    }

    // **** Additional functions to edit master attributes ****

    function setBoomYPerBlock(uint256 _boomYPerBlock) public onlyOwner {
        require(_boomYPerBlock > 0, "!boomYPerBlock-0");
        boomYPerBlock = _boomYPerBlock;
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigrationMaster _migrator) public onlyOwner {
        migrator = _migrator;
    }
}