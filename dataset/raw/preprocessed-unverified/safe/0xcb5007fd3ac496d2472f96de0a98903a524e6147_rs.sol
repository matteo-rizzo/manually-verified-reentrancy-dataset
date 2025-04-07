/**
 *Submitted for verification at Etherscan.io on 2021-03-17
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.12;


// 
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


// 
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

// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
/**
 * @dev Collection of functions related to the address type
 */


// 
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

// 
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// 




// 


// 
/**
 * @title ContinuousRewardToken contract
 * @notice ERC20 token which wraps underlying protocol rewards
 * @author
 */
abstract contract ContinuousRewardToken is ERC20, IContinuousRewardToken {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  /// @notice The address of underlying token
  address public override underlying;
  /// @notice The admin of reward token
  address public override admin;
  /// @notice The current owner of all rewards
  address public override delegate;
  /// @notice Unclaimed rewards of all previous owners: reward token => (owner => amount)
  mapping(address => mapping(address => uint256)) public unclaimedRewards;
  /// @notice Total amount of unclaimed rewards: (reward token => amount)
  mapping(address => uint256) public totalUnclaimedRewards;

  /**
   * @notice Construct a new Continuous reward token
   * @param _underlying The address of underlying token
   * @param _delegate The address of reward owner
   */
  constructor(address _underlying, address _delegate) public {
    admin = msg.sender;
    require(_underlying != address(0), "ContinuousRewardToken: invalid underlying address");
    require(_delegate != address(0), "ContinuousRewardToken: invalid delegate address");

    delegate = _delegate;
    underlying = _underlying;
  }

  /**
   * @notice Supply a specified amount of underlying tokens and receive back an equivalent quantity of CB-CR-XX-XX tokens
   * @param receiver Account to credit CB-CR-XX-XX tokens to
   * @param amount Amount of underlying token to supply
   */
  function supply(address receiver, uint256 amount) override external {
    IERC20(underlying).safeTransferFrom(msg.sender, address(this), amount);

    _mint(receiver, amount);
    _supply(amount);

    emit Supply(msg.sender, receiver, amount);
  }

  function _supply(uint256 amount) virtual internal;

  /**
   * @notice Reward tokens that may be accrued as rewards
   * @return Exhaustive list of all reward token addresses
   */
  function rewardTokens() override external view returns (address[] memory) {
    return _rewardTokens();
  }

  function _rewardTokens() virtual internal view returns (address[] memory);

  /**
   * @notice Amount of reward for the given reward token
   * @param rewardToken The address of reward token
   * @param account The account for which reward balance is checked
   * @return reward balance of token the specified account has
   */
  function balanceOfReward(address rewardToken, address account) override public view returns (uint256) {
    if (account == delegate) {
      return _balanceOfReward(rewardToken).sub(totalUnclaimedRewards[rewardToken]);
    }
    return unclaimedRewards[rewardToken][account];
  }

  function _balanceOfReward(address rewardToken) virtual internal view returns (uint256);

  /**
   * @notice Redeem a specified amount of underlying tokens by burning an equivalent quantity of CB-CR-XX-XX tokens. Does not redeem reward tokens
   * @param receiver Account to credit underlying tokens to
   * @param amount Amount of underlying token to redeem
   */
  function redeem(
    address receiver,
    uint256 amount
  ) override public {
    _burn(msg.sender, amount);
    _redeem(amount);

    IERC20(underlying).safeTransfer(receiver, amount);

    emit Redeem(msg.sender, receiver, amount);
  }

  function _redeem(uint256 amount) virtual internal;

  /**
   * @notice Claim accrued reward in one or more reward tokens
   * @dev All params must have the same array length
   * @param receivers List of accounts to credit claimed tokens to
   * @param tokens Reward token addresses
   * @param amounts Amounts of each reward token to claim
   */
  function claim(
    address[] calldata receivers,
    address[] calldata tokens,
    uint256[] calldata amounts
  ) override public {
    require(receivers.length == tokens.length && receivers.length == amounts.length, "ContinuousRewardToken: lengths dont match");

    for (uint256 i = 0; i < receivers.length; i++) {
      address receiver = receivers[i];
      address claimToken = tokens[i];
      uint256 amount = amounts[i];
      uint256 rewardBalance = balanceOfReward(claimToken, msg.sender);

      uint256 claimAmount = amount == uint256(-1) ? rewardBalance : amount;
      require(rewardBalance >= claimAmount, "ContinuousRewardToken: insufficient claimable");

      // If caller is one of previous owners, update unclaimed rewards data
      if (msg.sender != delegate) {
        unclaimedRewards[claimToken][msg.sender] = rewardBalance.sub(claimAmount);
        totalUnclaimedRewards[claimToken] = totalUnclaimedRewards[claimToken].sub(claimAmount);
      }

      _claim(claimToken, claimAmount);

      IERC20(claimToken).safeTransfer(receiver, claimAmount);

      emit Claim(msg.sender, receiver, claimToken, claimAmount);
    }
  }

  function _claim(address claimToken, uint256 amount) virtual internal;

  /**
   * @notice Atomic redeem and claim in a single transaction
   * @dev receivers[0] corresponds to the address that the underlying token is redeemed to. receivers[1:n-1] hold the to addresses for the reward tokens respectively.
   * @param receivers       List of accounts to credit tokens to
   * @param amounts         List of amounts to credit
   * @param claimTokens     Reward token addresses
   */
  function redeemAndClaim(
    address[] calldata receivers,
    uint256[] calldata amounts,
    address[] calldata claimTokens
  ) override external {
    redeem(receivers[0], amounts[0]);
    claim(receivers[1:], claimTokens, amounts[1:]);
  }

  /**
   * @notice Updates reward owner address
   * @dev Only callable by admin
   * @param newDelegate New reward owner address
   */
  function updateDelegate(address newDelegate) override external onlyAdmin {
    require(newDelegate != delegate, "ContinuousRewardToken: new reward owner is the same as old one");
    require(newDelegate != address(0), "ContinuousRewardToken: invalid new delegate address");

    address oldDelegate = delegate;

    address[] memory allRewardTokens = _rewardTokens();
    for (uint256 i = 0; i < allRewardTokens.length; i++) {
      address rewardToken = allRewardTokens[i];

      uint256 rewardBalance = balanceOfReward(rewardToken, oldDelegate);
      unclaimedRewards[rewardToken][oldDelegate] = rewardBalance;
      totalUnclaimedRewards[rewardToken] = totalUnclaimedRewards[rewardToken].add(rewardBalance);

      // If new owner used to be reward owner in the past, transfer back his unclaimed rewards to himself
      uint256 prevBalance = unclaimedRewards[rewardToken][newDelegate];
      if (prevBalance > 0) {
        unclaimedRewards[rewardToken][newDelegate] = 0;
        totalUnclaimedRewards[rewardToken] = totalUnclaimedRewards[rewardToken].sub(prevBalance);
      }
    }

    delegate = newDelegate;

    emit DelegateUpdated(oldDelegate, newDelegate);
  }

  /**
   * @notice Updates the admin address
   * @dev Only callable by admin
   * @param newAdmin New admin address
   */
  function transferAdmin(address newAdmin) override external onlyAdmin {
    require(newAdmin != admin, "ContinuousRewardToken: new admin is the same as old one");
    address previousAdmin = admin;

    admin = newAdmin;

    emit AdminTransferred(previousAdmin, newAdmin);
  }

  modifier onlyAdmin {
    require(msg.sender == admin, "ContinuousRewardToken: not an admin");
    _;
  }
}

// 
/**
 * @title CompoundRewardToken contract
 * @notice ERC20 token which wraps Compound underlying and COMP rewards
 * @author
 */
contract CompoundRewardToken is ContinuousRewardToken {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  uint256 constant private BASE = 1e18;
  uint256 constant private DAYS_PER_YEAR = 365;
  uint256 constant private BLOCKS_PER_DAY = 5760;// at a rate of 15 seconds per block, https://github.com/compound-finance/compound-protocol/blob/23eac9425accafb82551777c93896ee7678a85a3/contracts/JumpRateModel.sol#L18
  uint256 constant private BLOCKS_PER_YEAR = BLOCKS_PER_DAY * DAYS_PER_YEAR;

  /// @notice The address of cToken contract
  ICToken public cToken;
  /// @notice The address of COMP token
  address public comp;

  /**
   * @notice Construct a new Compound reward token
   * @param name ERC-20 name of this token
   * @param symbol ERC-20 symbol of this token
   * @param _cToken The address of cToken contract
   * @param delegate The address of reward owner
   */
  constructor(
    string memory name,
    string memory symbol,
    ICToken _cToken,
    address delegate
  ) ERC20(name, symbol) ContinuousRewardToken(_cToken.underlying(), delegate) public {
    cToken = _cToken;
    comp = cToken.comptroller().getCompAddress();

    // This contract doesn't support cComp or cEther, use special case contract for them
    require(underlying != comp, "CompoundRewardToken: does not support cComp usecase");

    IERC20(underlying).approve(address(cToken), uint256(-1));
  }

  function _rewardTokens() override internal view returns (address[] memory) {
    address[] memory tokens = new address[](2);
    (tokens[0], tokens[1]) = (underlying, comp);
    return tokens;
  }

  function _balanceOfReward(address rewardToken) override internal view returns (uint256) {
    require(rewardToken == underlying || rewardToken == comp, "CompoundRewardToken: not reward token");
    if (rewardToken == underlying) {
      // get the value of this contract's cTokens in the underlying, and subtract total CRT mint amount to get interest
      uint256 underlyingBalance = balanceOfCTokenUnderlying(address(this));
      uint256 totalSupply = totalSupply();
      // Due to rounding errors, it is possible the total supply is greater than the underlying balance by 1 wei, return 0 in this case
      // This is a transient case which will resolve itself once rewards are earned
      return totalSupply > underlyingBalance ? 0 : underlyingBalance.sub(totalSupply);
    } else {
      return getCompRewards();
    }
  }

  /**
   * @notice Annual Percentage Reward for the specific reward token. Measured in relation to the base units of the underlying asset vs base units of the accrued reward token.
   * @param rewardToken Reward token address
   * @dev Underlying asset rate is an APY, Comp rate is an APR
   * @return APY times 10^18
   */
  function rate(address rewardToken) override external view returns (uint256) {
    require(rewardToken == underlying || rewardToken == comp, "CompoundRewardToken: not reward token");
    if (rewardToken == underlying) {
      return getUnderlyingRate();
    } else {
      return getCompRate();
    }
  }

  function _supply(uint256 amount) override internal {
    require(cToken.mint(amount) == 0, "CompoundRewardToken: minting cToken failed");
  }

  function _redeem(uint256 amount) override internal {
    require(cToken.redeemUnderlying(amount) == 0, "CompoundRewardToken: redeeming cToken failed");
  }

  function _claim(address claimToken, uint256 amount) override internal {
    require(claimToken == underlying || claimToken == comp, "CompoundRewardToken: not reward token");
    if (claimToken == underlying) {
      require(cToken.redeemUnderlying(amount) == 0, "CompoundRewardToken: redeemUnderlying failed");
    } else {
      claimComp();
    }
  }

  /*** Compound Interface ***/

  //@dev Only shows the COMP accrued up until the last interaction with the cToken.
  function getCompRewards() internal view returns (uint256) {
    uint256 compAccrued = cToken.comptroller().compAccrued(address(this));
    return IERC20(comp).balanceOf(address(this)).add(compAccrued);
  }

  function claimComp() internal {
    ICToken[] memory cTokens = new ICToken[](1);
    cTokens[0] = cToken;
    cToken.comptroller().claimComp(address(this), cTokens);
  }

  function getUnderlyingRate() internal view returns (uint256) {
    uint256 supplyRatePerBlock = cToken.supplyRatePerBlock();
    return rateToAPY(supplyRatePerBlock);
  }

  // @dev APY = (1 + rate) ^ 365 - 1
  function rateToAPY(uint apr) internal pure returns (uint256) {
    uint256 ratePerDay = apr.mul(BLOCKS_PER_DAY).add(BASE);
    uint256 acc = ratePerDay;
    for (uint256 i = 1; i < DAYS_PER_YEAR; i++) {
      acc = acc.mul(ratePerDay).div(BASE);
    }
    return acc.sub(BASE);
  }

  function getCompRate() internal view returns (uint256) {
    IComptroller comptroller = cToken.comptroller();
    uint256 compForMarketPerYear = comptroller.compSpeeds(address(cToken)).mul(BLOCKS_PER_YEAR);
    uint256 exchangeRate = cToken.exchangeRateStored();
    uint256 totalSupply = cToken.totalSupply();
    uint256 totalUnderlying = totalSupply.mul(exchangeRate).div(BASE);
    return compForMarketPerYear.mul(BASE).div(totalUnderlying);
  }

  // @dev returns the amount of underlying that this contract's cTokens can be redeemed for
  function balanceOfCTokenUnderlying(address owner) internal view returns (uint256) {
    uint256 exchangeRate = cToken.exchangeRateStored();
    uint256 scaledMantissa = exchangeRate.mul(cToken.balanceOf(owner));
    // Note: We are not using careful math here as we're performing a division that cannot fail
    return scaledMantissa /  BASE;
  }
}