/**
 *Submitted for verification at Etherscan.io on 2021-08-07
*/

pragma solidity 0.6.12;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the `nonReentrant` modifier
 * available, which can be aplied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}





// Forked from the original yearn yVault (https://github.com/yearn/yearn-protocol/blob/develop/contracts/vaults/yVault.sol) with the following changes:
// - Introduce reward token of which the user can claim from the underlying strategy
// - Keeper fees for farm and harvest
// - Overriding transfer function to avoid reward token accumulation in TokenMaster (e.g when user stake Vault token into TokenMaster)
abstract contract BaseVault is ERC20, ReentrancyGuard {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  /* ========== STATE VARIABLES ========== */

  IERC20 public token;
  IERC20 public rewardToken;

  uint public availableMin = 9500;
  uint public farmKeeperFeeMin = 0;
  uint public harvestKeeperFeeMin = 0;
  uint public constant MAX = 10000;

  uint public rewardsPerShareStored;
  mapping(address => uint256) public userRewardPerSharePaid;
  mapping(address => uint256) public rewards;

  address public governance;
  address public controller;
  address public tokenMaster;
  mapping(address => bool) public keepers;

  /* ========== CONSTRUCTOR ========== */

  constructor (
      address _token,
      address _rewardToken,
      address _controller,
      address _tokenMaster)
      public
      ERC20 (
        string(abi.encodePacked("aladdin ", ERC20(_token).name())),
        string(abi.encodePacked("ald", ERC20(_token).symbol())
      )
  ) {
      _setupDecimals(ERC20(_token).decimals());
      token = IERC20(_token);
      rewardToken = IERC20(_rewardToken);
      controller = _controller;
      governance = msg.sender;
      tokenMaster = _tokenMaster;
  }

  /* ========== VIEWS ========== */

  function balance() public view returns (uint) {
      return token.balanceOf(address(this))
             .add(IController(controller).balanceOf(address(this)));
  }

  // Custom logic in here for how much the vault allows to be borrowed
  // Sets minimum required on-hand to keep small withdrawals cheap
  function available() public view returns (uint) {
      return token.balanceOf(address(this)).mul(availableMin).div(MAX);
  }

  function getPricePerFullShare() public view returns (uint) {
      return balance().mul(1e18).div(totalSupply());
  }

  // amount staked in token master
  function stakedBalanceOf(address _user) public view returns(uint) {
      return ITokenMaster(tokenMaster).userBalanceForPool(_user, address(this));
  }

  function earned(address account) public view returns (uint) {
      uint256 totalBalance = balanceOf(account).add(stakedBalanceOf(account));
      return totalBalance.mul(rewardsPerShareStored.sub(userRewardPerSharePaid[account])).div(1e18).add(rewards[account]);
  }

  /* ========== USER MUTATIVE FUNCTIONS ========== */

  function deposit(uint _amount) external nonReentrant {
      _updateReward(msg.sender);

      uint _pool = balance();
      token.safeTransferFrom(msg.sender, address(this), _amount);

      uint shares = 0;
      if (totalSupply() == 0) {
        shares = _amount;
      } else {
        shares = (_amount.mul(totalSupply())).div(_pool);
      }
      _mint(msg.sender, shares);
      emit Deposit(msg.sender, _amount);
  }

  // No rebalance implementation for lower fees and faster swaps
  function withdraw(uint _shares) public nonReentrant {
      _updateReward(msg.sender);

      uint r = (balance().mul(_shares)).div(totalSupply());
      _burn(msg.sender, _shares);

      // Check balance
      uint b = token.balanceOf(address(this));
      if (b < r) {
          uint _withdraw = r.sub(b);
          IController(controller).withdraw(address(this), _withdraw);
          uint _after = token.balanceOf(address(this));
          uint _diff = _after.sub(b);
          if (_diff < _withdraw) {
              r = b.add(_diff);
          }
      }

      token.safeTransfer(msg.sender, r);
      emit Withdraw(msg.sender, r);
  }

  function claim() public {
      _updateReward(msg.sender);

      uint reward = rewards[msg.sender];
      if (reward > 0) {
          rewards[msg.sender] = 0;
          rewardToken.safeTransfer(msg.sender, reward);
      }
      emit Claim(msg.sender, reward);
  }

  function exit() external {
      withdraw(balanceOf(msg.sender));
      claim();
  }

  // Override underlying transfer function to update reward before transfer, except on staking/withdraw to token master
  function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override
  {
      if (to != tokenMaster && from != tokenMaster) {
          _updateReward(from);
          _updateReward(to);
      }

      super._beforeTokenTransfer(from, to, amount);
  }

  /* ========== KEEPER MUTATIVE FUNCTIONS ========== */

  // Keepers call farm() to send funds to strategy
  function farm() external onlyKeeper {
      uint _bal = available();

      uint keeperFee = _bal.mul(farmKeeperFeeMin).div(MAX);
      if (keeperFee > 0) {
          token.safeTransfer(msg.sender, keeperFee);
      }

      uint amountLessFee = _bal.sub(keeperFee);
      token.safeTransfer(controller, amountLessFee);
      IController(controller).farm(address(this), amountLessFee);

      emit Farm(msg.sender, keeperFee, amountLessFee);
  }

  // Keepers call harvest() to claim rewards from strategy
  // harvest() is marked as onlyEOA to prevent sandwich/MEV attack to collect most rewards through a flash-deposit() follow by a claim
  function harvest() external onlyKeeper {
      uint _rewardBefore = rewardToken.balanceOf(address(this));
      IController(controller).harvest(address(this));
      uint _rewardAfter = rewardToken.balanceOf(address(this));

      uint harvested = _rewardAfter.sub(_rewardBefore);
      uint keeperFee = harvested.mul(harvestKeeperFeeMin).div(MAX);
      if (keeperFee > 0) {
          rewardToken.safeTransfer(msg.sender, keeperFee);
      }

      uint newRewardAmount = harvested.sub(keeperFee);
      // distribute new rewards to current shares evenly
      rewardsPerShareStored = rewardsPerShareStored.add(newRewardAmount.mul(1e18).div(totalSupply()));

      emit Harvest(msg.sender, keeperFee, newRewardAmount);
  }

  /* ========== INTERNAL FUNCTIONS ========== */

  function _updateReward(address account) internal {
      rewards[account] = earned(account);
      userRewardPerSharePaid[account] = rewardsPerShareStored;
  }

  /* ========== RESTRICTED FUNCTIONS ========== */

  function setAvailableMin(uint _availableMin) external {
      require(msg.sender == governance, "!governance");
      require(_availableMin < MAX, "over MAX");
      availableMin = _availableMin;
  }

  function setFarmKeeperFeeMin(uint _farmKeeperFeeMin) external {
      require(msg.sender == governance, "!governance");
      require(_farmKeeperFeeMin < MAX, "over MAX");
      farmKeeperFeeMin = _farmKeeperFeeMin;
  }

  function setHarvestKeeperFeeMin(uint _harvestKeeperFeeMin) external {
      require(msg.sender == governance, "!governance");
      require(_harvestKeeperFeeMin < MAX, "over MAX");
      harvestKeeperFeeMin = _harvestKeeperFeeMin;
  }

  function setGovernance(address _governance) external {
      require(msg.sender == governance, "!governance");
      governance = _governance;
  }

  function setController(address _controller) external {
      require(msg.sender == governance, "!governance");
      controller = _controller;
  }

  function setTokenMaster(address _tokenMaster) external {
      require(msg.sender == governance, "!governance");
      tokenMaster = _tokenMaster;
  }

  function addKeeper(address _address) external {
      require(msg.sender == governance, "!governance");
      keepers[_address] = true;
  }

  function removeKeeper(address _address) external {
      require(msg.sender == governance, "!governance");
      keepers[_address] = false;
  }

  /* ========== MODIFIERS ========== */

  modifier onlyKeeper() {
      require(keepers[msg.sender] == true, "!keeper");
       _;
  }

  /* ========== EVENTS ========== */

  event Deposit(address indexed user, uint256 amount);
  event Withdraw(address indexed user, uint256 amount);
  event Claim(address indexed user, uint256 amount);
  event Farm(address indexed keeper, uint256 keeperFee, uint256 farmedAmount);
  event Harvest(address indexed keeper, uint256 keeperFee, uint256 harvestedAmount);
}

contract VaultCurveRenWBTC is BaseVault {
    constructor (
          address _controller,
          address _tokenMaster)
        public
        BaseVault(
          address(0x49849C98ae39Fff122806C06791Fa73784FB3675), // crvRenWBTC
          address(0xD533a949740bb3306d119CC777fa900bA034cd52), // crv
          _controller,
          _tokenMaster
        )
    {}
}