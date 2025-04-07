/**
 *Submitted for verification at Etherscan.io on 2021-09-07
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Collection of functions related to the address type
 */


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name}, {symbol} and {desimals}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
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
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
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

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

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
    ) internal virtual {}
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


struct User {
    uint256 totalOriginalTaken;
    uint256 lastUpdateTick;
    uint256 goldenBalance;
    uint256 cooldownAmount;
    uint256 cooldownTick;
}



struct Vesting {
    uint256 totalAmount;
    uint256 startBlock;
    uint256 endBlock;
}



struct Price {
    address asset;
    uint256 value;
}

contract DeferredVestingPool is ERC20 {
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;
    using UserLib for User;
    using VestingLib for Vesting;

    bool public isSalePaused_;
    address public admin_;
    address public revenueOwner_;
    IERC20Metadata public originalToken_;
    address public originalTokenOwner_;
    uint256 public precisionDecimals_;
    mapping(address => User) public users_;
    mapping(address => uint256) public assets_;
    Vesting public vesting_;
    
    string private constant ERR_AUTH_FAILED = "auth failed";
    
    event WithdrawCoin(address indexed msgSender, bool isMsgSenderAdmin, address indexed to, uint256 amount);
    event WithdrawOriginalToken(address indexed msgSender, bool isMsgSenderAdmin, address indexed to, uint256 amount);
    event SetPrice(address indexed asset, uint256 price);
    event PauseCollateralizedSale(bool on);
    event SetRevenueOwner(address indexed msgSender, address indexed newRevenueOwner);
    event SetOriginalTokenOwner(address indexed msgSender, address indexed newOriginalTokenOwner);
    event SwapToCollateralized(address indexed msgSender, address indexed fromAsset, uint256 fromAmount, uint256 toAmount, uint32 indexed refCode);
    event SwapCollateralizedToOriginal(address indexed msgSender, uint256 amount);
    
    constructor(
        string memory _name,
        string memory _symbol,
        address _admin,
        address _revenueOwner,
        IERC20Metadata _originalToken,
        address _originalTokenOwner,
        uint256 _precisionDecimals,
        Price[] memory _prices) ERC20(_name, _symbol, _originalToken.decimals()) {
            
        _originalToken.validate();
        
        admin_ = _admin;
        revenueOwner_ = _revenueOwner;
        originalToken_ = _originalToken;
        originalTokenOwner_ = _originalTokenOwner;
        precisionDecimals_ = _precisionDecimals;
        
        emit SetRevenueOwner(_msgSender(), _revenueOwner);
        emit SetOriginalTokenOwner(_msgSender(), _originalTokenOwner);
        
         for(uint32 i = 0; i < _prices.length; ++i) {
            assets_[_prices[i].asset] = _prices[i].value;
            emit SetPrice(_prices[i].asset, _prices[i].value);
        }
        
        emit PauseCollateralizedSale(false);
    }
    
    function totalOriginalBalance() external view returns (uint256) {
        return originalToken_.balanceOf(address(this));
    }
    
    function availableForSellCollateralizedAmount() public view returns (uint256) {
        if(isSalePaused_) return 0;
        
        if(vesting_.isInitialized()) return 0;
        
        return originalToken_.balanceOf(address(this)) - totalSupply();
    }
    
    function unusedCollateralAmount() public view returns (uint256) {
        return originalToken_.balanceOf(address(this)) - totalSupply();
    }
    
    modifier onlyAdmin() {
        require(admin_ == _msgSender(), ERR_AUTH_FAILED);
        _;
    }
    
    function initializeVesting(uint256 _startBlock, uint256 _endBlock) external onlyAdmin {
        require(!vesting_.isInitialized(), "already initialized");
        
        vesting_.totalAmount = totalSupply();
        vesting_.startBlock = _startBlock;
        vesting_.endBlock = _endBlock;

        vesting_.validate();
    }
    
    function withdrawCoin(uint256 _amount) external onlyAdmin {
        _withdrawCoin(payable(revenueOwner_), _amount);
    }
    
    function withdrawOriginalToken(uint256 _amount) external onlyAdmin {
        _withdrawOriginalToken(originalTokenOwner_, _amount);
    }
    
    function setPrices(Price[] calldata _prices) external onlyAdmin {
        for(uint32 i = 0; i < _prices.length; ++i) {
            assets_[_prices[i].asset] = _prices[i].value;
            emit SetPrice(_prices[i].asset, _prices[i].value);
        }
    }
    
    function pauseCollateralizedSale(bool _on) external onlyAdmin {
        require(isSalePaused_ != _on);
        isSalePaused_ = _on;
        emit PauseCollateralizedSale(_on);
    }
    
    modifier onlyRevenueOwner() {
        require(revenueOwner_ == _msgSender(), ERR_AUTH_FAILED);
        _;
    }
    
    function setRevenueOwner(address _newRevenueOwner) external onlyRevenueOwner {
        revenueOwner_ = _newRevenueOwner;
        
        emit SetRevenueOwner(_msgSender(), _newRevenueOwner);
    }
    
    function withdrawCoin(address payable _to, uint256 _amount) external onlyRevenueOwner {
        _withdrawCoin(_to, _amount);
    }
    
    modifier onlyOriginalTokenOwner() {
        require(originalTokenOwner_ == _msgSender(), ERR_AUTH_FAILED);
        _;
    }
    
    function setOriginalTokenOwner(address _newOriginalTokenOwner) external onlyOriginalTokenOwner {
        originalTokenOwner_ = _newOriginalTokenOwner;
        
        emit SetOriginalTokenOwner(_msgSender(), _newOriginalTokenOwner);
    }
    
    function withdrawOriginalToken(address _to, uint256 _amount) external onlyOriginalTokenOwner {
        _withdrawOriginalToken(_to, _amount);
    }
    
    function _withdrawCoin(address payable _to, uint256 _amount) private {
        if(_amount == 0) {
            _amount = address(this).balance;
        }
        
        _to.transfer(_amount);
        
        emit WithdrawCoin(_msgSender(), _msgSender() == admin_, _to, _amount);
    }
    
    function _withdrawOriginalToken(address _to, uint256 _amount) private {
        uint256 maxWithdrawAmount = unusedCollateralAmount();
        
        if(_amount == 0) {
            _amount = maxWithdrawAmount;
        }
        
        require(_amount > 0, "zero withdraw amount");
        require(_amount <= maxWithdrawAmount, "invalid withdraw amount");
        
        originalToken_.safeTransfer(_to, _amount);
        
        emit WithdrawOriginalToken(_msgSender(), _msgSender() == admin_, _to, _amount);
    }
    
    function calcCollateralizedPrice(address _fromAsset, uint256 _fromAmount) public view
        returns (uint256 toActualAmount_, uint256 fromActualAmount_) {

        require(_fromAmount > 0, "zero payment");
        
        uint256 fromAssetPrice = assets_[_fromAsset];
        require(fromAssetPrice > 0, "asset not supported");
        
        if(isSalePaused_) return (0, 0);
        
        uint256 toAvailableForSell = availableForSellCollateralizedAmount();
        uint256 oneOriginalToken = 10 ** originalToken_.decimals();
        
        fromActualAmount_ = _fromAmount;
        toActualAmount_ = (_fromAmount * oneOriginalToken) / fromAssetPrice;
        
        if(toActualAmount_ > toAvailableForSell) {
            toActualAmount_ = toAvailableForSell;
            fromActualAmount_ = (toAvailableForSell * fromAssetPrice) / oneOriginalToken;
        }
    }
    
    function swapCoinToCollateralized(uint256 _toExpectedAmount, uint32 _refCode) external payable {
        _swapToCollateralized(address(0), msg.value, _toExpectedAmount, _refCode);
    }
    
    function swapTokenToCollateralized(IERC20 _fromAsset, uint256 _fromAmount, uint256 _toExpectedAmount, uint32 _refCode) external {
        require(address(_fromAsset) != address(0), "wrong swap function");
        
        uint256 fromAmount = _fromAmount == 0 ? _fromAsset.allowance(_msgSender(), address(this)) : _fromAmount;
        _fromAsset.safeTransferFrom(_msgSender(), revenueOwner_, fromAmount);
        
        _swapToCollateralized(address(_fromAsset), fromAmount, _toExpectedAmount, _refCode);
    }
    
    function _swapToCollateralized(address _fromAsset, uint256 _fromAmount, uint256 _toExpectedAmount, uint32 _refCode) private {
        require(!isSalePaused_, "swap paused");
        require(!vesting_.isInitialized(), "can't do this after vesting init");
        require(_toExpectedAmount > 0, "zero expected amount");
        
        (uint256 toActualAmount, uint256 fromActualAmount) = calcCollateralizedPrice(_fromAsset, _fromAmount);
        
        toActualAmount = _fixAmount(toActualAmount, _toExpectedAmount);
            
        require(_fromAmount >= fromActualAmount, "wrong payment amount");
        
        _mint(_msgSender(), toActualAmount);
     
        emit SwapToCollateralized(_msgSender(), _fromAsset, _fromAmount, toActualAmount, _refCode);
    }
    
    function _fixAmount(uint256 _actual, uint256 _expected) private view returns (uint256) {
        if(_expected < _actual) return _expected;
        
        require(_expected - _actual <= 10 ** precisionDecimals_, "expected amount mismatch");
        
        return _actual;
    }
    
    function collateralizedBalance(address _userAddr) external view
        returns (
            uint256 blockNumber,
            uint256 totalOriginalTakenAmount,
            uint256 totalCollateralizedAmount,
            uint256 goldenAmount,
            uint256 grayAmount,
            uint256 cooldownAmount) {

        uint256 currentTick = vesting_.currentTick();

        blockNumber = block.number;
        totalOriginalTakenAmount = users_[_userAddr].totalOriginalTaken;
        totalCollateralizedAmount = balanceOf(_userAddr);
        goldenAmount = users_[_userAddr].goldenBalance + _calcNewGoldenAmount(_userAddr, currentTick);
        grayAmount = totalCollateralizedAmount - goldenAmount;
        cooldownAmount = _getCooldownAmount(users_[_userAddr], currentTick);
    }

    function swapCollateralizedToOriginal(uint256 _amount) external {
        address msgSender = _msgSender();

        _updateUserGoldenBalance(msgSender, vesting_.currentTick());

        User storage user = users_[msgSender];

        if(_amount == 0) _amount = user.goldenBalance;

        require(_amount > 0, "zero swap amount");
        require(_amount <= user.goldenBalance, "invalid amount");

        user.totalOriginalTaken += _amount;
        user.goldenBalance -= _amount;

        _burn(msgSender, _amount);
        originalToken_.safeTransfer(msgSender, _amount);
        
        emit SwapCollateralizedToOriginal(msgSender, _amount);
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal virtual override {
        // mint or burn
        if(_from == address(0) || _to == address(0)) return;

        uint256 currentTick = vesting_.currentTick();

        _updateUserGoldenBalance(_from, currentTick);
        _updateUserGoldenBalance(_to, currentTick);

        User storage userTo = users_[_to];
        User storage userFrom = users_[_from];

        uint256 fromGoldenAmount = userFrom.goldenBalance;
        uint256 fromGrayAmount = balanceOf(_from) - fromGoldenAmount;

        // change cooldown amount of sender
        if(fromGrayAmount > 0
            && userFrom.cooldownTick == currentTick
            && userFrom.cooldownAmount > 0) {

            if(_getCooldownAmount(userFrom, currentTick) > _amount) {
                userFrom.cooldownAmount -= _amount;
            } else {
                userFrom.cooldownAmount = 0;
            }
        }

        if(_amount > fromGrayAmount) { // golden amount is also transfered
            uint256 transferGoldenAmount = _amount - fromGrayAmount;
            //require(transferGoldenAmount <= fromGoldenAmount, "math error");
            
            userTo.addCooldownAmount(currentTick, fromGrayAmount);
            
            userFrom.goldenBalance -= transferGoldenAmount;
            userTo.goldenBalance += transferGoldenAmount;
        } else { // only gray amount is transfered
            userTo.addCooldownAmount(currentTick, _amount);
        }
    }

    function _updateUserGoldenBalance(address _userAddr, uint256 _currentTick) private {
        if(_currentTick == 0) return;
        
        User storage user = users_[_userAddr];
        
        if(user.lastUpdateTick == vesting_.lastTick()) return;

        user.goldenBalance += _calcNewGoldenAmount(_userAddr, _currentTick);
        user.lastUpdateTick = _currentTick;
    }

    function _calcNewGoldenAmount(address _userAddr, uint256 _currentTick) private view returns (uint256) {
        if(_currentTick == 0) return 0;
        
        User storage user = users_[_userAddr];

        if(user.goldenBalance == balanceOf(_userAddr)) return 0;

        if(_currentTick >= vesting_.lastTick()) {
            return balanceOf(_userAddr) - user.goldenBalance;
        }

        uint256 result = balanceOf(_userAddr) - _getCooldownAmount(user, _currentTick) + user.totalOriginalTaken;
        result *= _currentTick - user.lastUpdateTick;
        result *= vesting_.unlockAtATickAmount();
        result /= vesting_.totalAmount;
        result = _min(result, balanceOf(_userAddr) - user.goldenBalance);

        return result;
    }

    function _getCooldownAmount(User storage _user, uint256 _currentTick) private view returns (uint256) {
        if(_currentTick >= vesting_.lastTick()) return 0;

        return _currentTick == _user.cooldownTick ? _user.cooldownAmount : 0;
    }

    function _min(uint256 a, uint256 b) private pure returns (uint256) {
        return a <= b ? a : b;
    }
}