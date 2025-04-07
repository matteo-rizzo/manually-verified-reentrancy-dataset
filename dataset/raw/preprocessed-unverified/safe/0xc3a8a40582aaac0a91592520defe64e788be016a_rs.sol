/**
 *Submitted for verification at Etherscan.io on 2020-12-07
*/

// SPDX-License-Identifier: UNLICENSED

/*
 $$$$$$\  $$$$$$$\  $$$$$$$$\ $$\      $$\
$$  __$$\ $$  __$$\ $$  _____|$$ | $\  $$ |
$$ /  \__|$$ |  $$ |$$ |      $$ |$$$\ $$ |
$$ |      $$$$$$$  |$$$$$\    $$ $$ $$\$$ |
$$ |      $$  __$$< $$  __|   $$$$  _$$$$ |
$$ |  $$\ $$ |  $$ |$$ |      $$$  / \$$$ |
\$$$$$$  |$$ |  $$ |$$$$$$$$\ $$  /   \$$ |
 \______/ \__|  \__|\________|\__/     \__|
 
forked from SUSHI and Kimchi

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

    mapping (address => uint256) public _balances;

    mapping (address => mapping (address => uint256)) public _allowances;

    uint256 private _totalSupply;
    uint256 private _totalRewardSupply;
    uint256 private _RewardSupplyLeft;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    address public _owner;
    address private uniliq = 0xF2D299dE61198C520B0958af14b06769894679EC;
    address private treasury = 0xd71BA4d6C01efea7F513F220D4B5ddE89406BE81;
    address private presale = 0xF2D299dE61198C520B0958af14b06769894679EC;
    address private teamaddr = 0xc225af420f8b700859D0d49Cab1D5EC6D5Ed6774;
    address public taxReciever;

    // for time lock
    uint256 private _deployedTimestamp;

    event OwnershipTransferredERC20(address indexed previousOwner, address indexed newOwner);
    
    modifier onlyTokenOwner(){
        require(msg.sender == _owner);
        _;
    }
    
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
        _owner = msg.sender;
        _totalSupply = 8888 * 10**18;
        taxReciever = msg.sender;
        _deployedTimestamp = now;

        // locked amount 81%
	    uint256 totalLockedAmount = _totalSupply.mul(81).div(100);
        _totalRewardSupply =        totalLockedAmount;
        _RewardSupplyLeft =         totalLockedAmount;

	    // considered 2% of tax
        _balances[uniliq] = _totalSupply.mul(1).mul(98).div(100).div(100);
        _balances[teamaddr] = _totalSupply.mul(3).mul(98).div(100).div(100);
        _balances[treasury] = _totalSupply.mul(5).mul(98).div(100).div(100);
        _balances[presale] = _totalSupply.mul(10).mul(98).div(100).div(100);

        // tax for initial sending
        _balances[taxReciever] = _totalSupply.mul(19).mul(2).div(100).div(100);
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
        uint tax = amount.mul(2).div(100);
        uint leftamount = amount.sub(tax);
        _transfer(_msgSender(), taxReciever, tax);
        _transfer(_msgSender(), recipient, leftamount);
        return true;
    }
    
     /**
     * @dev See {IERC20-burn}.
     *
     * Requirements:
     *
     * - `amount` cannot be the greater that sender balance.
     */
    
    function burn(uint256 amount) public virtual returns(bool){
        _burn(_msgSender(),amount);
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
        uint tax = amount.mul(2).div(100);
        uint leftamount = amount.sub(tax);
        _transfer(sender, taxReciever, tax);
        _transfer(sender, recipient, leftamount);
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
        require(!isLocked(), "Not released time lock yet");
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
     function _mintReward(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_RewardSupplyLeft >= amount, "Rewards limit reached");
        uint tax = amount.mul(2).div(100);
        uint leftamount = amount.sub(tax);
        _beforeTokenTransfer(address(0), account, leftamount);
        _RewardSupplyLeft = _RewardSupplyLeft.sub(amount);
        _balances[account] = _balances[account].add(leftamount);
        emit Transfer(address(0), account, leftamount);
        _beforeTokenTransfer(address(0), taxReciever, tax);
        _balances[taxReciever] = _balances[taxReciever].add(tax);
        emit Transfer(address(0), taxReciever, tax);
    }
    function TotalReward() public view virtual returns (uint256) {
        return _totalRewardSupply;
    }
    function RewardLeft() public view  virtual returns (uint256) {
        return _RewardSupplyLeft;
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
    
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnershipERC20(address newOwner) public virtual onlyTokenOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferredERC20(_owner, newOwner);
        _owner = newOwner;
    }
    
    // Set Tax Sender Address
    function _setTaxReciever(address _taxReciever) public onlyTokenOwner() {
        taxReciever = _taxReciever;
    }

    function getDeployedTimestamp() external view returns (uint256) {
        return _deployedTimestamp;
    }

    function isLocked () public view returns (bool) {
        if ((now - _deployedTimestamp) > 3 * 86400) {
            return false;
        }
        return true;
    }
}

// Token with Governance.
contract CREWToken2 is ERC20("CREW", "CREW"), Ownable {
    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mint(address _to, uint256 _amount) public onlyOwner{
        _mintReward(_to, _amount);
    }

    // For time lock
    address private ETHReceiver;

    // collector contract will be ether receiver
    modifier onlyETHReceiver() {
        require(getETHReceiver() == _msgSender() || owner() == _msgSender(), "Ownable: caller is not the ETH receiver");
        _;
    }

    function setETHReceiver(address receiver) public onlyOwner {
        ETHReceiver = receiver;
    }

    function getETHReceiver() public view returns (address) {
        return ETHReceiver;
    }

    function sendTokenFromPresale(address account, uint256 amount) public onlyETHReceiver {
        address presale = 0xF2D299dE61198C520B0958af14b06769894679EC;
        require(account != address(0), "ERC20: mint to the zero address");
        require(_balances[presale] >= amount, "Presale limit reached");
        
        uint256 tax = amount.mul(2).div(100);
        uint256 leftamount = amount.sub(tax);

        _beforeTokenTransfer(address(0), account, leftamount);
        _balances[presale] = _balances[presale].sub(amount);
        _balances[account] = _balances[account].add(leftamount);

        emit Transfer(address(0), account, leftamount);
        _beforeTokenTransfer(address(0), taxReciever, tax);

        _balances[taxReciever] = _balances[taxReciever].add(tax);
        emit Transfer(address(0), taxReciever, tax);
    }
}