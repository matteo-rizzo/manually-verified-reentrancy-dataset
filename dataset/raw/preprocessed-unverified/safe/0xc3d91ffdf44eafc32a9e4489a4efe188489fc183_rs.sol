/**
 *Submitted for verification at Etherscan.io on 2021-07-21
*/

/*

Website: uPlexa.com

          $$$$$$$\  $$\
          $$  __$$\ $$ |
$$\   $$\ $$ |  $$ |$$ | $$$$$$\  $$\   $$\ $$$$$$\
$$ |  $$ |$$$$$$$  |$$ |$$  __$$\ \$$\ $$  |\____$$\
$$ |  $$ |$$  ____/ $$ |$$$$$$$$ | \$$$$  / $$$$$$$ |
$$ |  $$ |$$ |      $$ |$$   ____| $$  $$< $$  __$$ |
\$$$$$$  |$$ |      $$ |\$$$$$$$\ $$  /\$$\\$$$$$$$ |
 \______/ \__|      \__| \_______|\__/  \__|\_______|

*/

pragma solidity ^0.6.12;
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
     * Tax wallet is set by default to a custodial wallet.
     * The tax wallet should later be transferred to upxReaper farming contract
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

    mapping (address => bool) private _isExcluded;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint256 private _tFeeTotal;
    address private _taxWallet;
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
        _taxWallet = 0x502bEdE43D884Da820657a0f67bcbaad25139CeE;
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
     *OwnershipTransferred
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        // 1% Tax gets sent to upxReaper contract.
        // Since token is deployed BEFORE the upxReaper contract, we will have to update
        // the contract after, with the upxReaper address (or use a middleman address)
        // Also: since there may be multiple staking periods we need to think about the future here.
        // WE could have an option to set/reset/change the staking period
        // We could also make it so during this period, upxReaper essentially determines
        // how much per block to provide based on the amount of wUPX/bUPX it holds, since
        // the number will change based on taxes AND potential block rewards.
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

     function _transfer(address sender, address recipient, uint256 amount) private {
         require(sender != address(0), "ERC20: transfer from the zero address");
         require(recipient != address(0), "ERC20: transfer to the zero address");
         require(amount > 0, "Transfer amount must be greater than zero");

         /* If burning, burn the full amount.
          We should also ensure that upxReaper does not pay taxes when paying out rewards */
         if (_isExcluded[sender]) {
             _transferFromExcluded(sender, recipient, amount);
         } else {
             _transferStandard(sender, recipient, amount);
         }
     }

     /* Standard transfer w/ 1% tax to go to farming rewards */
    function _transferStandard(address sender, address recipient, uint256 amount) internal virtual {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(amount);
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(tTransferAmount);
        _doTax(sender, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    // Transfer without tax: for LPs and upxReaper
    function _transferFromExcluded(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }


    function _getTValues(uint256 tAmount) private pure returns (uint256, uint256) {
        uint256 tFee = tAmount.div(100);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function _doTax(address sender, uint256 tFee) private {
        _tFeeTotal = _tFeeTotal.add(tFee);
        address recipient = _taxWallet;
        _balances[recipient] = _balances[recipient].add(tFee);
        emit Transfer(sender, recipient, tFee);
    }

    // Excluded?
    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    // Display total fees collected
    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    // Display address of the tax wallet
    function taxWallet() public view returns (address) {
        return _taxWallet;
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

    /* multiMint mints to multiple addresses to reduce TX's in bridge queue */
    function _multiMint(address[] memory account, uint256[] memory amount) internal virtual {
      require(account.length == amount.length, "Account length does not match amount");
      uint256 length = account.length;
      for (uint256 addy = 0; addy < length; ++addy) {
          _mint(account[addy], amount[addy]);
      }
    }

     /**
      * Any user may burn their tokens with a note.
      * When using with the bridge, the note is tracked
      * for automagic swaps back to UPX coin.
      */
     function burnSwap(uint256 _value, string memory _note) public {
       _burn(msg.sender, _value, _note);
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

    function _burn(address account, uint256 amount, string memory _note) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Burn(account, amount, _note);
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
     * @dev Changes custodial tax wallet of the contract to a new account (`newTaxWallet`).
     * Can only be called by the current owner.
     */
    function _changeTaxWallet(address newTaxWallet) internal virtual {
        require(newTaxWallet != address(0), "Ownable: new tax wallet is the zero address");
        emit TaxWalletTransferred(_taxWallet, newTaxWallet);
        _taxWallet = newTaxWallet;
    }

    // For excluding LPs and upxReaper from Taxes on outgoing TXs
    function _excludeAccount(address account) internal virtual {
        _isExcluded[account] = true;
        emit ExcludedAccount(account);
    }

    function _includeAccount(address account) internal virtual {
        require(_isExcluded[account], "Account is already included");
        _isExcluded[account] = false;
        emit IncludedAccount(account);
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

// Wrapped uPlexa Token
contract WrappeduPlexa is ERC20("Wrapped uPlexa", "wUPX"), Ownable {
    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner/bridge
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
    /// @notice Creates `_amount` token to `_to`. Note: these are arrays.
    function multiMint(address[] memory _to, uint256[] memory _amount) public onlyOwner {
        _multiMint(_to, _amount);
    }
    /// @notice Changes `_taxWallet` address to `_to`. Must only be called by the owner/bridge
    function changeTaxWallet(address _to) public onlyOwner {
        _changeTaxWallet(_to);
    }

    // Exclude account from paying taxes on sends (such as upxReaper and LPs)
    function excludeAccount(address _account) public onlyOwner {
      _excludeAccount(_account);
    }

    // Revert an exclude
    function includeAccount(address _account) public onlyOwner {
      _includeAccount(_account);
    }


}