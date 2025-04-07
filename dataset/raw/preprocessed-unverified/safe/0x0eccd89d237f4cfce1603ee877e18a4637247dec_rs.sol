/**
 *Submitted for verification at Etherscan.io on 2021-02-02
*/

pragma solidity 0.5.8;


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
contract Context {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
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
  mapping (address => bool) public farmAddresses;

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
    require(_owner == _msgSender(), 'Ownable: caller is not the owner');
    _;
  }

  modifier onlyFarmContract() {
    require(isOwner() || isFarmContract(), 'Ownable: caller is not the farm or owner');
    _;
  }

  function isOwner() private view returns (bool) {
    return _owner == _msgSender();
  }

  function isFarmContract() public view returns (bool) {
    return farmAddresses[_msgSender()];
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(
      newOwner != address(0),
      'Ownable: new owner is the zero address'
    );
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  function setFarmAddress(address _farmAddress, bool _status) public onlyOwner {
    require(
      _farmAddress != address(0),
      'Ownable: farm address is the zero address'
    );
    farmAddresses[_farmAddress] = _status;
  }
}


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
contract ERC20 is Context {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

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
    constructor(string memory name, string memory symbol, uint totalSupply, address tokenContractAddress) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
        _totalSupply = totalSupply;

        _balances[tokenContractAddress] = _totalSupply;

        emit Transfer(address(0), tokenContractAddress, _totalSupply);
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
     * Ether and Wei.
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
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                'ERC20: transfer amount exceeds allowance'
            )
        );
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                'ERC20: decreased allowance below zero'
            )
        );
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), 'ERC20: transfer from the zero address');
        require(recipient != address(0), 'ERC20: transfer to the zero address');

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            'ERC20: transfer amount exceeds balance'
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'ERC20: burn from the zero address');

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            'ERC20: burn amount exceeds balance'
        );
        _totalSupply = _totalSupply.sub(amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), 'ERC20: approve from the zero address');
        require(spender != address(0), 'ERC20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}




contract GourmetGalaxy is ERC20('GourmetGalaxy', 'GUM', 20e6 * 1e18, address(this)), Ownable {

  uint private constant adviserAllocation = 1e6 * 1e18;
  uint private constant communityAllocation = 5e4 * 1e18;
  uint private constant farmingAllocation = 9950000 * 1e18;
  uint private constant marketingAllocation = 5e5 * 1e18;
  uint private constant publicSaleAllocation = 5e5 * 1e18;
  uint private constant privateSaleAllocation = 5e6 * 1e18;
  uint private constant teamAllocation = 3e6 * 1e18;

  uint private communityReleased = 0;
  uint private adviserReleased = 0;
  uint private farmingReleased = 0;
  uint private marketingReleased = 125000 * 1e18; // TGE
  uint private privateSaleReleased = 2e6 * 1e18;
  uint private teamReleased = 0;

  uint private lastCommunityReleased = now + 30 days;
  uint private lastAdviserReleased = now + 30 days;
  uint private lastMarketingReleased = now + 30 days;
  uint private lastPrivateSaleReleased = now + 30 days;
  uint private lastTeamReleased = now + 30 days;

  uint private constant amountEachAdviserRelease = 50000 * 1e18;
  uint private constant amountEachCommunityRelease = 2500 * 1e18;
  uint private constant amountEachMarketingRelease = 125000 * 1e18;
  uint private constant amountEachPrivateSaleRelease = 1e6 * 1e18;
  uint private constant amountEachTeamRelease = 150000 * 1e18;

  constructor(
    address _marketingTGEAddress,
    address _privateSaleTGEAddress,
    address _publicSaleTGEAddress
  ) public {
    _transfer(address(this), _marketingTGEAddress, marketingReleased);
    _transfer(address(this), _privateSaleTGEAddress, privateSaleReleased);
    _transfer(address(this), _publicSaleTGEAddress, publicSaleAllocation);
  }

  function releaseAdviserAllocation(address _receiver) public onlyOwner {
    require(adviserReleased.add(amountEachAdviserRelease) <= adviserAllocation, 'Max adviser allocation released!!!');
    require(now - lastAdviserReleased >= 30 days, 'Please wait to next checkpoint!');
    _transfer(address(this), _receiver, amountEachAdviserRelease);
    adviserReleased = adviserReleased.add(amountEachAdviserRelease);
    lastAdviserReleased = lastAdviserReleased + 30 days;
  }

  function releaseCommunityAllocation(address _receiver) public onlyOwner {
    require(communityReleased.add(amountEachCommunityRelease) <= communityAllocation, 'Max community allocation released!!!');
    require(now - lastCommunityReleased >= 90 days, 'Please wait to next checkpoint!');
    _transfer(address(this), _receiver, amountEachCommunityRelease);
    communityReleased = communityReleased.add(amountEachCommunityRelease);
    lastCommunityReleased = lastCommunityReleased + 90 days;
  }

  function releaseFarmAllocation(address _farmAddress, uint256 _amount) public onlyFarmContract {
    require(farmingReleased.add(_amount) <= farmingAllocation, 'Max farming allocation released!!!');
    _transfer(address(this), _farmAddress, _amount);
    farmingReleased = farmingReleased.add(_amount);
  }

  function releaseMarketingAllocation(address _receiver) public onlyOwner {
    require(marketingReleased.add(amountEachMarketingRelease) <= marketingAllocation, 'Max marketing allocation released!!!');
    require(now - lastMarketingReleased >= 90 days, 'Please wait to next checkpoint!');
    _transfer(address(this), _receiver, amountEachMarketingRelease);
    marketingReleased = marketingReleased.add(amountEachMarketingRelease);
    lastMarketingReleased = lastMarketingReleased + 90 days;
  }

  function releasePrivateSaleAllocation(address _receiver) public onlyOwner {
    require(privateSaleReleased.add(amountEachPrivateSaleRelease) <= privateSaleAllocation, 'Max privateSale allocation released!!!');
    require(now - lastPrivateSaleReleased >= 90 days, 'Please wait to next checkpoint!');
    _transfer(address(this), _receiver, amountEachPrivateSaleRelease);
    privateSaleReleased = privateSaleReleased.add(amountEachPrivateSaleRelease);
    lastPrivateSaleReleased = lastPrivateSaleReleased + 90 days;
  }

  function releaseTeamAllocation(address _receiver) public onlyOwner {
    require(teamReleased.add(amountEachTeamRelease) <= teamAllocation, 'Max team allocation released!!!');
    require(now - lastTeamReleased >= 30 days, 'Please wait to next checkpoint!');
    _transfer(address(this), _receiver, amountEachTeamRelease);
    teamReleased = teamReleased.add(amountEachTeamRelease);
    lastTeamReleased = lastTeamReleased + 30 days;
  }
}







contract Galaxy is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  struct UserInfo {
    uint256 amount;
    uint256 rewardDebt;
  }

  struct PoolInfo {
    IERC20 lpToken;
    uint256 allocPoint;
    uint256 lastRewardBlock;
    uint256 accGumPerShare;
  }

  GourmetGalaxy public gum;
  uint256 public bonusEndBlock;
  uint256 public rewardsEndBlock;
  uint256 public constant gumPerBlock = 1e18;
  uint256 public constant BONUS_MULTIPLIER = 3;

  PoolInfo[] public poolInfo;
  mapping(address => bool) public lpTokenExistsInPool;
  mapping(uint256 => mapping(address => UserInfo)) public userInfo;
  uint256 public totalAllocPoint;
  uint256 public startBlock;

  uint256 public constant blockIn2Weeks = 80640;
  uint256 public constant blockIn2Years = 4204800;

  event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
  event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
  event EmergencyWithdraw(
    address indexed user,
    uint256 indexed pid,
    uint256 amount
  );

  constructor(
    GourmetGalaxy _gum
  ) public {
    gum = _gum;
    startBlock = block.number;
    bonusEndBlock = startBlock + blockIn2Weeks;
    rewardsEndBlock = startBlock + blockIn2Years;
  }

  function poolLength() external view returns (uint256) {
    return poolInfo.length;
  }

  function add(
    uint256 _allocPoint,
    IERC20 _lpToken,
    bool _withUpdate
  ) public onlyOwner {
    require(
      !lpTokenExistsInPool[address(_lpToken)],
      'Galaxy: LP Token Address already exists in pool'
    );
    if (_withUpdate) {
      massUpdatePools();
    }
    uint256 blockNumber = min(block.number, rewardsEndBlock);
    uint256 lastRewardBlock = blockNumber > startBlock
    ? blockNumber
    : startBlock;
    totalAllocPoint = totalAllocPoint.add(_allocPoint);
    poolInfo.push(
      PoolInfo({
      lpToken: _lpToken,
      allocPoint: _allocPoint,
      lastRewardBlock: lastRewardBlock,
      accGumPerShare: 0
      })
    );
    lpTokenExistsInPool[address(_lpToken)] = true;
  }

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

  function pendingGum(uint256 _pid, address _user)
  external
  view
  returns (uint256)
  {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][_user];
    uint256 accGumPerShare = pool.accGumPerShare;
    uint256 blockNumber = min(block.number, rewardsEndBlock);
    uint256 lpSupply = pool.lpToken.balanceOf(address(this));
    if (blockNumber > pool.lastRewardBlock && lpSupply != 0) {
      uint256 multiplier = getMultiplier(
        pool.lastRewardBlock,
        blockNumber
      );
      uint256 gumReward = multiplier
      .mul(gumPerBlock)
      .mul(pool.allocPoint)
      .div(totalAllocPoint);
      accGumPerShare = accGumPerShare.add(
        gumReward.mul(1e12).div(lpSupply)
      );
    }
    return user.amount.mul(accGumPerShare).div(1e12).sub(user.rewardDebt);
  }

  function massUpdatePools() public {
    uint256 length = poolInfo.length;
    for (uint256 pid = 0; pid < length; ++pid) {
      updatePool(pid);
    }
  }

  function updatePool(uint256 _pid) public {
    PoolInfo storage pool = poolInfo[_pid];
    uint256 blockNumber = min(block.number, rewardsEndBlock);
    if (blockNumber <= pool.lastRewardBlock) {
      return;
    }
    uint256 lpSupply = pool.lpToken.balanceOf(address(this));
    if (lpSupply == 0) {
      pool.lastRewardBlock = blockNumber;
      return;
    }
    uint256 multiplier = getMultiplier(pool.lastRewardBlock, blockNumber);
    uint256 gumReward = multiplier
    .mul(gumPerBlock)
    .mul(pool.allocPoint)
    .div(totalAllocPoint);
    gum.releaseFarmAllocation(address(this), gumReward);
    pool.accGumPerShare = pool.accGumPerShare.add(
      gumReward.mul(1e12).div(lpSupply)
    );
    pool.lastRewardBlock = blockNumber;
  }

  function deposit(uint256 _pid, uint256 _amount) public {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];
    updatePool(_pid);
    if (user.amount > 0) {
      uint256 pending = user.amount.mul(pool.accGumPerShare).div(1e12).sub(user.rewardDebt);
      safeGumTransfer(msg.sender, pending);
    }
    pool.lpToken.safeTransferFrom(
      address(msg.sender),
      address(this),
      _amount
    );
    user.amount = user.amount.add(_amount);
    user.rewardDebt = user.amount.mul(pool.accGumPerShare).div(1e12);
    emit Deposit(msg.sender, _pid, _amount);
  }

  function withdraw(uint256 _pid, uint256 _amount) public {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];
    require(user.amount >= _amount, 'Galaxy: Insufficient Amount to withdraw');
    updatePool(_pid);
    uint256 pending = user.amount.mul(pool.accGumPerShare).div(1e12).sub(user.rewardDebt);
    if(pending > 0) {
      safeGumTransfer(msg.sender, pending);
    }
    if(_amount > 0) {
      user.amount = user.amount.sub(_amount);
      pool.lpToken.safeTransfer(address(msg.sender), _amount);
    }
    user.rewardDebt = user.amount.mul(pool.accGumPerShare).div(1e12);
    emit Withdraw(msg.sender, _pid, _amount);
  }

  function emergencyWithdraw(uint256 _pid) public {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];
    uint256 amount = user.amount;
    require(amount > 0, 'Galaxy: insufficient balance');
    user.amount = 0;
    user.rewardDebt = 0;
    pool.lpToken.safeTransfer(address(msg.sender), amount);
    emit EmergencyWithdraw(msg.sender, _pid, amount);
  }

  function safeGumTransfer(address _to, uint256 _amount) internal {
    uint256 gumBalance = gum.balanceOf(address(this));
    if (_amount > gumBalance) {
      gum.transfer(_to, gumBalance);
    } else {
      gum.transfer(_to, _amount);
    }
  }

  function isRewardsActive() public view returns (bool) {
    return rewardsEndBlock > block.number;
  }

  function min(uint256 a, uint256 b) public pure returns (uint256) {
    if (a > b) {
      return b;
    }
    return a;
  }
}