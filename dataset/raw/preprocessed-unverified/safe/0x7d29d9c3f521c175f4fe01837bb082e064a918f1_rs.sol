/**
 *Submitted for verification at Etherscan.io on 2020-12-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



/**
 * @dev Collection of functions related to the address type
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

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
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
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
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

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
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
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
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
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
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
    constructor () {
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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


contract NovaToken is ERC20("NOVA", "NOVA"), Ownable {
    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterUniverse).
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}

// MasterUniverse is the master of Nova. He can make Nova and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once NOVA is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterUniverse is Ownable {
    using SafeMath for uint256;
    using SafeMath for uint8;
    using SafeERC20 for IERC20;

    address private constant GUARD = address(0);

    // Info of each user.
    struct UserInfo {
        uint256 lastStakedTime;
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        address next;
        //
        // We do some fancy math here. Basically, any point in time, the amount of NOVAs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accNovaPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accNovaPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. NOVAs to distribute per block.
        uint256 lastRewardBlock; // Last block number that NOVAs distribution occurs.
        uint256 accNovaPerShare; // Accumulated NOVAs per share, times 1e12. See below.
        uint256 totalLpStaked; // Total Amount of LP Tokens Staked.
        uint256 startTimestamp; // Timestamp of the pool start
        uint256 totalPlasma; // cached totalPlasma calcul - too much gas consumption
    }

    // The NOVA TOKEN!
    NovaToken public nova;
    // Dev address.
    address public devaddr;
    // Block number when bonus NOVA period ends.
    uint256 public bonusEndBlock;
    // NOVA tokens created per block.
    uint256 public novaPerBlock;
    // Bonus muliplier for early nova makers.
    uint256 public constant BONUS_MULTIPLIER = 2;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when NOVA mining starts.
    uint256 public startBlock;
    // The timestamp when NOVA mining starts
    uint256 public startTimestamp;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(
        NovaToken _nova,
        address _devaddr,
        uint256 _novaPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) {
        nova = _nova;
        devaddr = _devaddr;
        novaPerBlock = _novaPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
        startTimestamp = block.timestamp;
    }

    function poolLength() public view returns (uint256) {
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
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accNovaPerShare: 0,
                totalLpStaked: 0,
                startTimestamp: block.timestamp,
                totalPlasma: 0
            })
        );
    }

    enum Range {Unknown, Tiny, Common}

    uint256 private constant tinyLimit = 10;
    uint256 private constant commonLimit = 100;
    uint256 private constant scaleUp = 10000;

    function maxBuffRate(uint256 _pid,address _user)
        public
        view
        returns (uint16)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        require(pool.totalLpStaked > 0, "0 div");
        uint256 percentage = user.amount.mul(scaleUp).div(
            pool.totalLpStaked
        );

        if (percentage <= tinyLimit) {
            return 90;
        } else if (percentage > tinyLimit && percentage < commonLimit) {
            return 150;
        } else if (percentage >= commonLimit) {
            return 40;
        }

        revert("bad");
    }

    // Update the given pool's NOVA allocation point. Can only be called by the owner.
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
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return
                bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                    _to.sub(bonusEndBlock)
                );
        }
    }

    function calculateBuffRate(
        uint256 _pid,
        address _user,
        uint256 _now_
    ) public
      view
      returns (uint16) {
        UserInfo storage user = userInfo[_pid][_user];
        uint16 buffRate = 10;
        for (
            uint256 d = user.lastStakedTime;
            d + 1 days <= _now_;
            d += 1 days
        ) {
            buffRate += (buffRate * 50) / 100;
        }

        uint16 max = maxBuffRate(_pid, _user);
        if(buffRate > max){
            buffRate = max;
        }
        return buffRate;
    }

    function calculateNovaPerBlock() public view returns (uint256)
    {
        uint currentTimestamp = block.timestamp; 
        uint daysSinceStartStaking = (currentTimestamp - startTimestamp).mul(100).div(60).div(60).div(24);
        uint8 halvingDiv = 0;

        if(daysSinceStartStaking >= 15000){
            return 0;
        }

        if(daysSinceStartStaking >= 7000){
            halvingDiv = 8;
        } else if(daysSinceStartStaking >= 3000){
            halvingDiv = 4;
        } else if(daysSinceStartStaking >= 1000){
            halvingDiv = 2;
        } 

        uint256 novaPerBlockNow = novaPerBlock;
        if (halvingDiv > 0){
            novaPerBlockNow = novaPerBlockNow.div(halvingDiv);
        }

        return novaPerBlockNow;
    }

    function plasmaPower(
        uint256 _pid,
        address _user,
        uint256 _now_
    ) private
      view
      returns (uint256) {
        UserInfo storage user = userInfo[_pid][_user];
        uint16 buffRate = calculateBuffRate(_pid, _user, _now_);
        return user.amount.mul(buffRate);
    }

    function totalPlasmaPower(uint256 _pid)
        public
        view
        returns (uint256)
    {
        uint256 total;
        uint256 _now_ = block.timestamp;

        for (
            address iter = userInfo[_pid][GUARD].next;
            iter != GUARD;
            iter = userInfo[_pid][iter].next
        ) {
            if(userInfo[_pid][iter].amount == 0) continue;
            total += plasmaPower(_pid, iter, _now_);
        }

        return total;
    }

    // View function to see pending NOVAs on frontend.
    function pendingNova(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accNovaPerShare = pool.accNovaPerShare;
        uint256 plasma = plasmaPower(_pid, _user, block.timestamp);

        if (block.number > pool.lastRewardBlock && pool.totalPlasma > 0) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint256 novaReward = multiplier
                .mul(calculateNovaPerBlock())
                .mul(pool.allocPoint)
                .div(totalAllocPoint);

            accNovaPerShare = accNovaPerShare.add(
                novaReward.mul(1e12).div(pool.totalPlasma)
            );
        }

        return plasma.mul(accNovaPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function calculateFeesPercentage(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        UserInfo storage user = userInfo[_pid][_user];
        uint currentTimestamp = block.timestamp; 
        uint daysSinceStartStaking = (currentTimestamp - user.lastStakedTime).div(60).div(60).div(24);
        uint feesPercentage = max(30 - daysSinceStartStaking.div(2), 1); // -0.5% by day - start to 30, and min to 1
        return feesPercentage;
    }

    function max(uint a, uint b) private pure returns (uint) {
        return a > b ? a : b;
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) private {
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
        uint256 novaReward = multiplier
            .mul(calculateNovaPerBlock())
            .mul(pool.allocPoint)
            .div(totalAllocPoint);
        nova.mint(devaddr, novaReward.div(10));
        nova.mint(address(this), novaReward);
        uint256 totalPlasma = totalPlasmaPower(_pid);
        pool.totalPlasma = totalPlasma;
        pool.accNovaPerShare = pool.accNovaPerShare.add(
            novaReward.mul(1e12).div(totalPlasma)
        );
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterUniverse for NOVA allocation.
    function deposit(uint256 _pid, uint256 _amount) external {
        require(_pid < poolLength(), "bad pid");
        require(_amount > 0, "amount could'n be 0");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);

        // this is the first time we see this new staker - so we make them
        // the head of the list
        if (user.amount == 0) {
            // actually now should record the time
            user.lastStakedTime = block.timestamp; 
            user.next = userInfo[_pid][GUARD].next;
            userInfo[_pid][GUARD].next = msg.sender;
        }

        // they already staked so let's harvest
        if (user.amount > 0 && block.number > bonusEndBlock) {
            uint256 pending = pendingNova(_pid, msg.sender);
            if (pending > 0) {
                uint feesPercentage = calculateFeesPercentage(_pid, msg.sender);
                uint256 fees = pending.mul(feesPercentage).div(100);
                uint256 gain = pending.sub(fees);
                safeNovaTransfer(devaddr, fees);
                safeNovaTransfer(msg.sender, gain);
            }
        }

        if (_amount > 0) {
            user.amount = user.amount.add(_amount);
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
        }

        pool.totalLpStaked = pool.totalLpStaked.add(_amount);
        uint256 plasma = plasmaPower(_pid, msg.sender, block.timestamp);
        user.rewardDebt = plasma.mul(pool.accNovaPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterUniverse.
    function withdraw(uint256 _pid, uint256 _amount) external {
        require(_pid < poolLength(), "bad pid");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(block.number > bonusEndBlock, "withdraw: Withdrawals are not available yet, it's lock during 24h after the launch.");
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = pendingNova(_pid, msg.sender);
        if (pending > 0) {
            uint feesPercentage = calculateFeesPercentage(_pid, msg.sender);
            uint256 fees = pending.mul(feesPercentage).div(100);
            uint256 gain = pending.sub(fees);
            safeNovaTransfer(devaddr, fees);
            safeNovaTransfer(msg.sender, gain);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.totalLpStaked = pool.totalLpStaked.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }

        uint256 plasma = 0;
        if(pool.totalLpStaked > 0){
            plasma = plasmaPower(_pid, msg.sender, block.timestamp);
        }
        user.rewardDebt = plasma.mul(pool.accNovaPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Safe nova transfer function, just in case
    // if rounding error causes pool to not have enough NOVAs.
    function safeNovaTransfer(address _to, uint256 _amount) private {
        uint256 novaBal = nova.balanceOf(address(this));
        nova.transfer(_to, _amount > novaBal ? novaBal : _amount);
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }
}