/**
 *Submitted for verification at Etherscan.io on 2021-05-30
*/

// File: contracts/interfaces/ISaffronBase.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;



// File: contracts/interfaces/ISaffronPool.sol


pragma solidity ^0.7.1;

interface ISaffronPool is ISaffronBase {
  function add_liquidity(uint256 amount, Tranche tranche) external;
  function remove_liquidity(address v1_dsec_token_address, uint256 dsec_amount, address v1_principal_token_address, uint256 principal_amount) external;
  function get_base_asset_address() external view returns(address);
  function hourly_strategy(address adapter_address) external;
  function wind_down_epoch(uint256 epoch, uint256 amount_sfi) external;
  function set_governance(address to) external;
  function get_epoch_cycle_params() external view returns (uint256, uint256);
  function shutdown() external;
}

// File: contracts/lib/SafeMath.sol


pragma solidity ^0.7.1;

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


// File: contracts/lib/IERC20.sol


pragma solidity ^0.7.1;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/lib/Context.sol


pragma solidity ^0.7.1;

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

// File: contracts/lib/Address.sol


pragma solidity ^0.7.1;

/**
 * @dev Collection of functions related to the address type
 */


// File: contracts/lib/ERC20.sol


pragma solidity ^0.7.1;





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

// File: contracts/lib/SafeERC20.sol


pragma solidity ^0.7.1;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/SFI.sol


pragma solidity ^0.7.1;



contract SFI is ERC20 {
  using SafeERC20 for IERC20;

  address public governance;
  address public SFI_minter;
  uint256 public MAX_TOKENS = 100000 ether;

  constructor (string memory name, string memory symbol) ERC20(name, symbol) {
    // Initial governance is Saffron Deployer
    governance = msg.sender;
  }

  function mint_SFI(address to, uint256 amount) public {
    require(msg.sender == SFI_minter, "must be SFI_minter");
    require(this.totalSupply() + amount < MAX_TOKENS, "cannot mint more than MAX_TOKENS");
    _mint(to, amount);
  }

  function set_minter(address to) external {
    require(msg.sender == governance, "must be governance");
    SFI_minter = to;
  }

  function set_governance(address to) external {
    require(msg.sender == governance, "must be governance");
    governance = to;
  }

  event ErcSwept(address who, address to, address token, uint256 amount);
  function erc_sweep(address _token, address _to) public {
    require(msg.sender == governance, "must be governance");

    IERC20 tkn = IERC20(_token);
    uint256 tBal = tkn.balanceOf(address(this));
    tkn.safeTransfer(_to, tBal);

    emit ErcSwept(msg.sender, _to, _token, tBal);
  }
}

// File: contracts/SaffronLPBalanceToken.sol


pragma solidity ^0.7.1;


contract SaffronLPBalanceToken is ERC20 {
  address public pool_address;

  constructor (string memory name, string memory symbol) ERC20(name, symbol) {
    // Set pool_address to saffron pool that created token
    pool_address = msg.sender;
  }

  // Allow creating new tranche tokens
  function mint(address to, uint256 amount) public {
    require(msg.sender == pool_address, "must be pool");
    _mint(to, amount);
  }

  function burn(address account, uint256 amount) public {
    require(msg.sender == pool_address, "must be pool");
    _burn(account, amount);
  }

  function set_governance(address to) external {
    require(msg.sender == pool_address, "must be pool");
    pool_address = to;
  }
}

// File: contracts/SaffronERC20StakingPool.sol


pragma solidity ^0.7.1;








contract SaffronERC20StakingPool is ISaffronPool {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  address public governance;           // Governance (v3: add off-chain/on-chain governance)
  address public base_asset_address;   // Base asset managed by the pool (DAI, USDT, YFI...)
  address public SFI_address;          // SFI token
  uint256 public pool_principal;       // Current principal balance (added minus removed)

  bool public _shutdown = false;       // v0, v1: shutdown the pool after the final capital deploy to prevent burning funds

  /**** STRATEGY ****/
  address public strategy;

  /**** EPOCHS ****/
  epoch_params public epoch_cycle = epoch_params({
    start_date: 1604239200,   // 11/01/2020 @ 2:00pm (UTC)
    duration:   14 days       // 1210000 seconds
  });

  mapping(uint256=>bool) public epoch_wound_down; // True if epoch has been wound down already (governance)

  /**** EPOCH INDEXED STORAGE ****/
  uint256[] public epoch_principal;           // Total principal owned by the pool (all tranches)
  uint256[] public total_dsec;                // Total dsec (tokens + vdsec)
  uint256[] public SFI_earned;                // Total SFI earned (minted at wind_down_epoch)
  address[] public dsec_token_addresses;      // Address for each dsec token
  address[] public principal_token_addresses; // Address for each principal token

  /**** SAFFRON LP TOKENS ****/
  // If we just have a token address then we can look up epoch and tranche balance tokens using a mapping(address=>SaffronV1dsecInfo)
  // LP tokens are dsec (redeemable for interest+SFI) and principal (redeemable for base asset) tokens
  struct SaffronLPTokenInfo {
    bool        exists;
    uint256     epoch;
    LPTokenType token_type;
  }

  mapping(address=>SaffronLPTokenInfo) public saffron_LP_token_info;

  constructor(address _strategy, address _base_asset, address _SFI_address, bool epoch_cycle_reset) {
    governance = msg.sender;
    base_asset_address = _base_asset;
    SFI_address = _SFI_address;
    strategy = _strategy;
    epoch_cycle.duration = (epoch_cycle_reset ? 20 minutes : 14 days); // Make testing previous epochs easier
    epoch_cycle.start_date = (epoch_cycle_reset ? (block.timestamp) - (4 * epoch_cycle.duration) : 1604239200); // Make testing previous epochs easier
  }

  function new_epoch(uint256 epoch, address saffron_LP_dsec_token_address, address saffron_LP_principal_token_address) public {
    require(epoch_principal.length == epoch, "improper new epoch");
    require(msg.sender == governance, "must be governance");

    epoch_principal.push(0);
    total_dsec.push(0);
    SFI_earned.push(0);

    dsec_token_addresses.push(saffron_LP_dsec_token_address);
    principal_token_addresses.push(saffron_LP_principal_token_address);

    // Token info for looking up epoch and tranche of dsec tokens by token contract address
    saffron_LP_token_info[saffron_LP_dsec_token_address] = SaffronLPTokenInfo({
      exists: true,
      epoch: epoch,
      token_type: LPTokenType.dsec
    });

    // Token info for looking up epoch and tranche of PRINCIPAL tokens by token contract address
    saffron_LP_token_info[saffron_LP_principal_token_address] = SaffronLPTokenInfo({
      exists: true,
      epoch: epoch,
      token_type: LPTokenType.principal
    });
  }

  event DsecGeneration(uint256 time_remaining, uint256 amount, uint256 dsec, address dsec_address, uint256 epoch, uint256 tranche, address user_address, address principal_token_addr);
  event AddLiquidity(uint256 new_pool_principal, uint256 new_epoch_principal, uint256 new_total_dsec);
  // LP user adds liquidity to the pool
  // Pre-requisite (front-end): have user approve transfer on front-end to base asset using our contract address
  function add_liquidity(uint256 amount, Tranche tranche) external override {
    require(!_shutdown, "pool shutdown");
    require(tranche == Tranche.S, "ERC20 pool has no tranches");
    uint256 epoch = get_current_epoch();
    require(amount != 0, "can't add 0");
    require(epoch == 15, "v1.15: only epoch 15 only");

    // Calculate the dsec for deposited base_asset tokens
    uint256 dsec = amount.mul(get_seconds_until_epoch_end(epoch));

    // Update pool principal eternal and epoch state
    pool_principal = pool_principal.add(amount);                 // Add base_asset token amount to pool principal total 
    epoch_principal[epoch] = epoch_principal[epoch].add(amount); // Add base_asset token amount to principal epoch total

    // Update dsec and principal balance state
    total_dsec[epoch] = total_dsec[epoch].add(dsec);

    // Transfer base_asset tokens from LP to pool
    IERC20(base_asset_address).safeTransferFrom(msg.sender, address(this), amount);

    // Mint Saffron LP epoch 1 <base_asset_name> dsec tokens and transfer them to sender
    SaffronLPBalanceToken(dsec_token_addresses[epoch]).mint(msg.sender, dsec);

    // Mint Saffron LP epoch 1 <base_asset_name> principal tokens and transfer them to sender
    SaffronLPBalanceToken(principal_token_addresses[epoch]).mint(msg.sender, amount);

    emit DsecGeneration(get_seconds_until_epoch_end(epoch), amount, dsec, dsec_token_addresses[epoch], epoch, uint256(tranche), msg.sender, principal_token_addresses[epoch]);
    emit AddLiquidity(pool_principal, epoch_principal[epoch], total_dsec[epoch]);
  }


  event WindDownEpochState(uint256 previous_epoch, uint256 SFI_earned, uint256 epoch_dsec);
  function wind_down_epoch(uint256 epoch, uint256 amount_sfi) public override {
    require(msg.sender == address(strategy), "must be strategy");
    require(!epoch_wound_down[epoch], "epoch already wound down");
    uint256 current_epoch = get_current_epoch();
    require(epoch < current_epoch, "cannot wind down future epoch");

    uint256 previous_epoch = current_epoch - 1;
    require(block.timestamp >= get_epoch_end(previous_epoch), "can't call before epoch ended");

    SFI_earned[epoch] = amount_sfi;

    // Total dsec
    uint256 epoch_dsec = total_dsec[epoch];
    epoch_wound_down[epoch] = true;
    emit WindDownEpochState(previous_epoch, SFI_earned[epoch], epoch_dsec);
  }

  event RemoveLiquidityDsec(uint256 dsec_percent, uint256 SFI_owned);
  event RemoveLiquidityPrincipal(uint256 principal);
  function remove_liquidity(address dsec_token_address, uint256 dsec_amount, address principal_token_address, uint256 principal_amount) external override {
    require(dsec_amount > 0 || principal_amount > 0, "can't remove 0");
    uint256 SFI_owned;
    uint256 dsec_percent;

    // Update state for removal via dsec token
    if (dsec_token_address != address(0x0) && dsec_amount > 0) {
      // Get info about the v1 dsec token from its address and check that it exists
      SaffronLPTokenInfo memory token_info = saffron_LP_token_info[dsec_token_address];
      require(token_info.exists, "balance token lookup failed");
      SaffronLPBalanceToken sbt = SaffronLPBalanceToken(dsec_token_address);
      require(sbt.balanceOf(msg.sender) >= dsec_amount, "insufficient dsec balance");

      // Token epoch must be a past epoch
      uint256 token_epoch = token_info.epoch;
      require(token_info.token_type == LPTokenType.dsec, "bad dsec address");
      require(token_epoch == 15, "v1.15: bal token epoch must be 15");
      require(epoch_wound_down[token_epoch], "can't remove from wound up epoch");

      // Dsec gives user claim over a tranche's earned SFI and interest
      dsec_percent = dsec_amount.mul(1 ether).div(total_dsec[token_epoch]);
      SFI_owned = SFI_earned[token_epoch].mul(dsec_percent) / 1 ether;
      SFI_earned[token_epoch] = SFI_earned[token_epoch].sub(SFI_owned);
      total_dsec[token_epoch] = total_dsec[token_epoch].sub(dsec_amount);
    }

    // Update state for removal via principal token
    if (principal_token_address != address(0x0) && principal_amount > 0) {
      // Get info about the v1 dsec token from its address and check that it exists
      SaffronLPTokenInfo memory token_info = saffron_LP_token_info[principal_token_address];
      require(token_info.exists, "balance token info lookup failed");
      SaffronLPBalanceToken sbt = SaffronLPBalanceToken(principal_token_address);
      require(sbt.balanceOf(msg.sender) >= principal_amount, "insufficient principal balance");

      // Token epoch must be a past epoch
      uint256 token_epoch = token_info.epoch;
      require(token_info.token_type == LPTokenType.principal, "bad balance token address");
      require(token_epoch == 15, "v1.15: bal token epoch must be 15");
      require(epoch_wound_down[token_epoch], "can't remove from wound up epoch");

      epoch_principal[token_epoch] = epoch_principal[token_epoch].sub(principal_amount);
      pool_principal = pool_principal.sub(principal_amount);
    }

    // Transfer
    if (dsec_token_address != address(0x0) && dsec_amount > 0) {
      SaffronLPBalanceToken sbt = SaffronLPBalanceToken(dsec_token_address);
      require(sbt.balanceOf(msg.sender) >= dsec_amount, "insufficient dsec balance");
      sbt.burn(msg.sender, dsec_amount);
      IERC20(SFI_address).safeTransfer(msg.sender, SFI_owned);
      emit RemoveLiquidityDsec(dsec_percent, SFI_owned);
    }
    if (principal_token_address != address(0x0) && principal_amount > 0) {
      SaffronLPBalanceToken sbt = SaffronLPBalanceToken(principal_token_address);
      require(sbt.balanceOf(msg.sender) >= principal_amount, "insufficient principal balance");
      sbt.burn(msg.sender, principal_amount);
      IERC20(base_asset_address).safeTransfer(msg.sender, principal_amount);
      emit RemoveLiquidityPrincipal(principal_amount);
    }

    require((dsec_token_address != address(0x0) && dsec_amount > 0) || (principal_token_address != address(0x0) && principal_amount > 0), "no action performed");
  }

  function hourly_strategy(address) external pure override {
    return;
  }

  function shutdown() external override {
    require(msg.sender == strategy || msg.sender == governance, "must be strategy");
    require(block.timestamp > get_epoch_end(1) - 1 days, "trying to shutdown too early");
    _shutdown = true;
  }

  /*** GOVERNANCE ***/
  function set_governance(address to) external override {
    require(msg.sender == governance, "must be governance");
    governance = to;
  }

  function set_base_asset_address(address to) public {
    require(msg.sender == governance, "must be governance");
    base_asset_address = to;
  }

  /*** TIME UTILITY FUNCTIONS ***/
  function get_epoch_end(uint256 epoch) public view returns (uint256) {
    return epoch_cycle.start_date.add(epoch.add(1).mul(epoch_cycle.duration));
  }

  function get_current_epoch() public view returns (uint256) {
    require(block.timestamp > epoch_cycle.start_date, "before epoch 0");
    return (block.timestamp - epoch_cycle.start_date) / epoch_cycle.duration;
  }

  function get_seconds_until_epoch_end(uint256 epoch) public view returns (uint256) {
    return epoch_cycle.start_date.add(epoch.add(1).mul(epoch_cycle.duration)).sub(block.timestamp);
  }

  /*** GETTERS ***/
  function get_epoch_cycle_params() external view override returns (uint256, uint256) {
    return (epoch_cycle.start_date, epoch_cycle.duration);
  }

  function get_base_asset_address() external view override returns(address) {
    return base_asset_address;
  }

  event ErcSwept(address who, address to, address token, uint256 amount);
  function erc_sweep(address _token, address _to) public {
    require(msg.sender == governance, "must be governance");
    require(_token != base_asset_address, "cannot sweep pool assets");

    IERC20 tkn = IERC20(_token);
    uint256 tBal = tkn.balanceOf(address(this));
    tkn.safeTransfer(_to, tBal);

    emit ErcSwept(msg.sender, _to, _token, tBal);
  }

  function set_strategy(address to) external {
    require(msg.sender == governance, "must be governance");
    strategy = to;
  }
}