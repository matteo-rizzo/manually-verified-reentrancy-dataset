/**
 *Submitted for verification at Etherscan.io on 2020-11-22
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
  
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







contract NovaxToken is ERC20 ,Ownable {
    
    mapping(address => uint) public Locked; // total locked for sender
    mapping(address => uint) public MonthlyEarning; 
    mapping(address => bool) public HasLocked;
    mapping(address => uint) public StartDate;
    mapping(address => uint) public LastWithdrawDate;
    mapping(address => uint) public Withdrawed;
    mapping(address => uint) public Earned;
    mapping(address => uint) public EarningPercent;
    uint public MonthlyEarningPercent  = 666;

    constructor() public ERC20("Novax Token","NVX") {
        _mint(msg.sender, 99000000000000000000000000);
    }

    function createSuperLock(uint _amount) public
    {
        /* 
            * check stake availability
        */
        address sender = msg.sender;
        uint256 balanceSender = balanceOf(sender);
        //amount must be highr from 10
        require(_amount > 10, "SuperLock Amount must be highr from 50 NVX!");
        // amount cannot be higher from your balance
        require(_amount <=  balanceSender, "SuperLock amount can't be higher from your balance!");
        // sender must be don't have active 
        require(!HasLocked[sender], "Your wallet address have a active SuperLock!");
        
        // set has lock
        HasLocked[sender]         =  true;
        // set Earning Percent
        EarningPercent[sender]    =  MonthlyEarningPercent;
        // set locked amount
        Locked[sender]            =  _amount;
        // set monthly earning
        uint monthlyEarning       =  monthlyEarningCalulate(_amount,sender);
        MonthlyEarning[sender]    =  monthlyEarning;
         // set date locking
        StartDate[sender]         =  now;
        // set total earined
        uint earined              =  monthlyEarning * 12;
        Earned[sender]            =  earined;
        // set Withdrawed to zero
        Withdrawed[sender]        =  0;
        // burn amount from balance of sender
        _burn(sender, _amount);
    }
    
    function lockedStatus() public view returns(
        bool HasLockedStatus,
        uint LockedTotal,
        uint MonthlyEarningAmount,
        uint StartDateValue,
        uint LastWithdrawDateValue,
        uint WithdrawedTotal,
        uint earinedTotal,
        uint EarningPercentAmount
        ) {
         address sender = msg.sender;
         // check sender have a stake
         require(HasLocked[sender], "Your wallet address don't have active SuperLock!");
         
         HasLockedStatus             = HasLocked[sender];
         LockedTotal                 = Locked[sender];
         MonthlyEarningAmount        = MonthlyEarning[sender];
         StartDateValue              = StartDate[sender];
         WithdrawedTotal             = Withdrawed[sender];
         LastWithdrawDateValue       = LastWithdrawDate[sender];
         earinedTotal                = Earned[sender];
         EarningPercentAmount        = EarningPercent[sender];
    }
    
    function monthlyEarningCalulate(uint256 _amount,address sender) public view returns(uint) {
        // month earning 
        return _amount * EarningPercent[sender] / 10000;
    }
    
    function withdrawMonthlyEarning() public {
         address sender = msg.sender;
         require(HasLocked[sender], "Your wallet address don't have active SuperLock!");
         
         if (LastWithdrawDate[sender] != 0) {
             // diff Months From Start Date To Last Withdraw Date
             uint dw  = BokkyPooBahsDateTimeLibrary.diffMonths(StartDate[sender],LastWithdrawDate[sender]);
             // if dw highr from 12 month cann't get earning
             require(dw < 13, " Your SuperLock duration has finished!");
         }
            
         // date now
         uint dateNow = now;
         
         // date last withdraw 
         uint date = LastWithdrawDate[sender];
         if (LastWithdrawDate[sender] == 0) {  date = StartDate[sender]; }
         
         // get diffrent Months
         uint diffMonths     = BokkyPooBahsDateTimeLibrary.diffMonths(date,dateNow);
         if (diffMonths > 12) { diffMonths = 12; }
         
         // check if diffrent Months > 0
         require(diffMonths > 0, "You can send withdraw request in next month");
         
         // withdraw amount 
         uint256 WithdrawAmount = diffMonths * MonthlyEarning[sender];
         
         // send monthly earnings to sender 
         _mint(sender, WithdrawAmount);
         
         // set last withdraw date 
         LastWithdrawDate[sender]  = BokkyPooBahsDateTimeLibrary.addMonths(date,diffMonths);
         
         // set withdrawed total 
         Withdrawed[sender]  = Withdrawed[sender] + WithdrawAmount ;
    }
    
    function unlockSuperLock() public {
         address sender = msg.sender;
         // sender must have a active superLock
         require(HasLocked[sender], "Your wallet address don't have active SuperLock!");
         
         // sender must have Withdrawed amount 
         require(LastWithdrawDate[sender] == 0, "You must send withdraw request before call unlock function");
         
         // diff days From Start Date To Last Withdraw Date
         uint deff  = BokkyPooBahsDateTimeLibrary.diffDays(StartDate[sender],now);
         
         // if rerequest before 1 year from start lock
         require(deff > 365, "Your SuperLock duration has not completed 1 year!");
         
         // earnings amount must be Withdrawed
         require(Withdrawed[sender] == Earned[sender], "You must send withdraw request before call unlock function");
         
         // send 
         _mint(sender, Locked[sender]);
         
         // reset superLock Data For sender
         
         // set has lock
        HasLocked[sender]         =  false;
        // set locked amount
        Locked[sender]            =  0;
        // set monthly earning
        MonthlyEarning[sender]    =  0;
         // set date locking
        StartDate[sender]         =  0;
        // set total earined
        Earned[sender]            =  0;
        // set Withdrawed to zero
        Withdrawed[sender]        =  0;
        // set Earning Percent
        EarningPercent[sender]    = 0;
    }
    
    function updateMonthlyEarningPercent (uint _percent) public onlyOwner {
        MonthlyEarningPercent = _percent;
    } 
    
    function transferRewards(uint _amount,address recipient)  public onlyOwner {
        _mint(recipient, _amount);
    }
    
}