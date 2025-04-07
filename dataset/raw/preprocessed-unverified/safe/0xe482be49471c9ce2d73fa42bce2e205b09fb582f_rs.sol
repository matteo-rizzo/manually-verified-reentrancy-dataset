/**
 *Submitted for verification at Etherscan.io on 2021-03-25
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.12;

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
 * @dev Interface of the ERC20 standard as defined in the EIP.
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

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor (address owner) internal {
    _owner = owner;
    emit OwnershipTransferred(address(0), owner);
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
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
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
contract ERC20 is Ownable, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 6.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (address owner_, string memory name_, string memory symbol_) public Ownable(owner_) {
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
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
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
     * Requirements:
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
     * Requirements:
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


contract adJASMY is ERC20
{
    using SafeERC20 for IERC20;
    
    bool public isSwapPaused;
    address public revenueOwner;
    uint32 public interestBasisPoints; // 1 basis point = 0.01%; 10000 basis points = 100%
    IERC20 public lockedToken;
    uint256 public unlockTimestamp;
    mapping(address/*asset*/ => uint256/*price*/) public assets; // address(0) = ETH
    
    uint256 private constant ONE = 10**18;
    
    event Swap(address indexed buyer,
               address indexed fromAsset, // address(0) = ETH
               uint256 fromAmount,
               uint256 toAmount,
               uint32 indexed refCode);
    event GetUnlocked(address indexed buyer, uint256 burnAmount, uint256 unlockedAmount);
    event Withdraw(address indexed msgSender, bool isMsgSenderRevenueOwner, bool isEth, address indexed to, uint256 amount);
    event SetPrice(address indexed asset, uint256 price);
    event SwapPause(bool on);
    event SetRevenueOwner(address indexed msgSender, address indexed newRevenueOwner);
    
    // Constructor:
    //--------------------------------------------------------------------------------------------------------------------------
    constructor(address _owner,
                string memory _name,
                string memory _symbol,
                address _revenueOwner,
                uint32 _interestBasisPoints,
                IERC20 _lockedToken,
                uint256 _unlockTimestamp,
                address[] memory _assetAddresses,
                uint256[] memory _assetPrices) public ERC20(_owner, _name, _symbol)
    {
        require(_assetAddresses.length == _assetPrices.length);
        
        revenueOwner = _revenueOwner;
        
        emit SetRevenueOwner(_msgSender(), _revenueOwner);
        
        interestBasisPoints = _interestBasisPoints;
        lockedToken = _lockedToken;
        unlockTimestamp = _unlockTimestamp;
                
        for(uint32 i = 0; i < _assetPrices.length; ++i)
        {
            assets[_assetAddresses[i]] = _assetPrices[i];
            
            emit SetPrice(_assetAddresses[i], _assetPrices[i]);
        }
        
        emit SwapPause(false);
    }
    //--------------------------------------------------------------------------------------------------------------------------
    
    // Revenue owner methods:
    //--------------------------------------------------------------------------------------------------------------------------
    modifier onlyRevenueOwner()
    {
        require(revenueOwner == _msgSender(), "ERR_MSG_SENDER_NOT_REVENUE_OWNER");
        _;
    }
    
    function setRevenueOwner(address payable _newRevenueOwner) external onlyRevenueOwner
    {
        revenueOwner = _newRevenueOwner;
        
        emit SetRevenueOwner(_msgSender(), _newRevenueOwner);
    }
    
    function withdrawEth(address payable _to, uint256 _amount) external onlyRevenueOwner
    {
        _withdrawEth(_to, _amount);
    }
    
    function withdrawLockedToken(address _to, uint256 _amount) external onlyRevenueOwner
    {
        _withdrawLockedToken(_to, _amount);
    }
    //--------------------------------------------------------------------------------------------------------------------------
    
    // Owner methods:
    //--------------------------------------------------------------------------------------------------------------------------
    function withdrawEth(uint256 _amount) external onlyOwner
    {
        _withdrawEth(payable(revenueOwner), _amount);
    }
    
    function withdrawLockedToken(uint256 _amount) external onlyOwner
    {
        _withdrawLockedToken(revenueOwner, _amount);
    }
    
    function setPrices(address[] calldata _assetAddresses, uint256[] calldata _assetPrices) external onlyOwner
    {
        require(_assetAddresses.length == _assetPrices.length, "ERR_ARRAYS_LENGTHS_DONT_MATCH");
        
        for(uint32 i = 0; i < _assetAddresses.length; ++i)
        {
            assets[_assetAddresses[i]] = _assetPrices[i];
            
            emit SetPrice(_assetAddresses[i], _assetPrices[i]);
        }
    }
    
    function swapPause(bool _on) external onlyOwner
    {
        require(isSwapPaused != _on);
        
        isSwapPaused = _on;
        
        emit SwapPause(_on);
    }
    //--------------------------------------------------------------------------------------------------------------------------
    
    // Withdraw helpers:
    //--------------------------------------------------------------------------------------------------------------------------
    function _withdrawEth(address payable _to, uint256 _amount) private
    {
        if(_amount == 0)
        {
            _amount = address(this).balance;
        }
        
        _to.transfer(_amount);
        
        emit Withdraw(_msgSender(), _msgSender() == revenueOwner, true, _to, _amount);
    }
    
    function _withdrawLockedToken(address _to, uint256 _amount) private
    {
        uint256 collateralAmount = collateralAmount();
        
        if(_amount == 0)
        {
            _amount = lockedToken.balanceOf(address(this)) - collateralAmount;
        }
        
        lockedToken.safeTransfer(_to, _amount);
        
        require(lockedToken.balanceOf(address(this)) >= collateralAmount, "ERR_INVALID_AMOUNT");
        
        emit Withdraw(_msgSender(), _msgSender() == revenueOwner, false, _to, _amount);
    }
    //--------------------------------------------------------------------------------------------------------------------------
    
    // Price calculator:
    //--------------------------------------------------------------------------------------------------------------------------
    function calcPrice(address _fromAsset, uint256 _fromAmount) public view returns (uint256 toActualAmount_, uint256 fromActualAmount_)
    {
        require(_fromAmount > 0, "ERR_ZERO_PAYMENT");
        
        uint256 fromAssetPrice = assets[_fromAsset];
        require(fromAssetPrice > 0, "ERR_ASSET_NOT_SUPPORTED");
        
        if(isSwapPaused) return (0, 0);
        
        uint256 toAvailableForSell = availableForSellAmount();
        
        fromActualAmount_ = _fromAmount;

        toActualAmount_ = _fromAmount.mul(ONE).div(fromAssetPrice);
        
        if(toActualAmount_ > toAvailableForSell)
        {
            toActualAmount_ = toAvailableForSell;
            fromActualAmount_ = toAvailableForSell.mul(fromAssetPrice).div(ONE);
        }
    }
    //--------------------------------------------------------------------------------------------------------------------------
    
    // Swap:
    //--------------------------------------------------------------------------------------------------------------------------
    function swapFromEth(uint256 _toExpectedAmount, uint32 _refCode) external payable
    {
        _swap(address(0), msg.value, _toExpectedAmount, _refCode);
    }
    
    function swapFromErc20(IERC20 _fromAsset, uint256 _toExpectedAmount, uint32 _refCode) external
    {
        require(address(_fromAsset) != address(0), "ERR_WRONG_SWAP_FUNCTION");
        
        uint256 fromAmount = _fromAsset.allowance(_msgSender(), address(this));
        _fromAsset.safeTransferFrom(_msgSender(), revenueOwner, fromAmount);
        
        _swap(address(_fromAsset), fromAmount, _toExpectedAmount, _refCode);
    }
    
    function _swap(address _fromAsset, uint256 _fromAmount, uint256 _toExpectedAmount, uint32 _refCode) private
    {
        require(!isSwapPaused, "ERR_SWAP_PAUSED");
        require(_toExpectedAmount > 0, "ERR_ZERO_EXPECTED_AMOUNT");
        
        (uint256 toActualAmount, uint256 fromActualAmount) = calcPrice(_fromAsset, _fromAmount);
            
        require(_validateAmount(toActualAmount, _toExpectedAmount), "ERR_EXPECTED_AMOUNT_MISMATCH");
        require(_fromAmount == fromActualAmount, "ERR_WRONG_PAYMENT_AMOUNT");
        
        _mint(_msgSender(), toActualAmount);
     
        emit Swap(_msgSender(), _fromAsset, _fromAmount, toActualAmount, _refCode);
    }
    
    function _validateAmount(uint256 _a, uint256 _b) private pure returns (bool)
    {
        return _a > _b ? (_a - _b <= 10**14) : (_b - _a <= 10**14);
    }
    //--------------------------------------------------------------------------------------------------------------------------
    
    // Get unlocked:
    //--------------------------------------------------------------------------------------------------------------------------
    function getUnlocked(uint256 _amount) external
    {
        require(unlockTimestamp <= now, "ERR_NOT_YET_UNLOCKED");
        
        if(_amount == 0) _amount = balanceOf(_msgSender());
        
        _burn(_msgSender(), _amount);
        
        uint256 unlockedAmount = _getAmountWithInterest(_amount);
        lockedToken.safeTransfer(_msgSender(), unlockedAmount);
        
        emit GetUnlocked(_msgSender(), _amount, unlockedAmount);
    }
    //--------------------------------------------------------------------------------------------------------------------------
    
    // Interest and collateral:
    //--------------------------------------------------------------------------------------------------------------------------
    function _getAmountWithInterest(uint256 _amount) private view returns (uint256)
    {
        return _amount.add(_amount.mul(interestBasisPoints) / 10000);
    }
    
    function collateralAmount() public view returns (uint256)
    {
        return _getAmountWithInterest(totalSupply());
    }
    
    function availableForSellAmount() public view returns (uint256)
    {
        return (lockedToken.balanceOf(address(this)).sub(collateralAmount())).mul(10000) / (10000 + interestBasisPoints);
    }
    //--------------------------------------------------------------------------------------------------------------------------
}