/**
 *Submitted for verification at Etherscan.io on 2021-04-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract ERC20 is Context, IERC20 {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overloaded;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
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
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

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
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
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
     * - `to` cannot be the zero address.
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
        _balances[account] = accountBalance - amount;
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}


 
contract MyToken is ERC20{
 uint256 private _schedule_term;
 uint256 private _mint_term;
 address _owner;
 uint256 private _initSupplyPOC;
 uint256 private _addedSupplyToken;
 uint256 private _listingDate;
 struct Schedule{
   uint256 day;
   uint256 POC;
 }
 Schedule[] private schedule;
 
 constructor(uint listing_days) ERC20("PocketArena", "POC"){
  _schedule_term = 30 days;
  _mint_term = 730 days;
  //_schedule_term = 30 seconds;  
  //_mint_term = 730 seconds;

  _listingDate = block.timestamp + listing_days;
  _owner = msg.sender;
  _initSupplyPOC = 1000000000;
  _mint(_owner, SafeMath.mul(_initSupplyPOC, (10 ** uint256(decimals()))));
  _addedSupplyToken = 0;  
  
  schedule.push(Schedule(_listingDate, 501666667));  
  schedule.push(Schedule(SafeMath.add(_listingDate, _schedule_term), 503333334));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 2)), 505000001));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 3)), 506666668));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 4)), 508333335));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 5)), 510000002));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 6)), 526666669));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 7)), 528333336));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 8)), 552500003));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 9)), 554166670));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 10)), 578333337));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 11)), 580000004));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 12)), 754166671));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 13)), 755833338));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 14)), 780000005));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 15)), 781666672));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 16)), 805833339));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 17)), 807500006));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 18)), 831666673));  
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 19)), 1666667));
  schedule.push(Schedule(SafeMath.add(_listingDate, SafeMath.mul(_schedule_term, 119)), _initSupplyPOC));
 }
 function listingDateGet() public view virtual returns (uint256) {
  return _listingDate;
 }
 function scheduleGet(uint16 round) public virtual view returns (Schedule memory) {
   return schedule[round];
 }
 function lockedPOC(uint256 currentDate) public view returns (uint256) {
  if (schedule[SafeMath.sub(schedule.length, 1)].day <= currentDate) {
   //return SafeMath.sub(_initSupplyPOC, schedule[SafeMath.sub(schedule.length, 1)].POC);
   return 0;
  }
  else if (schedule[SafeMath.sub(schedule.length, 2)].day <= currentDate) { 
   uint dateDiff = SafeMath.div(SafeMath.sub(currentDate, schedule[SafeMath.sub(schedule.length, 2)].day), _schedule_term);
   uint256 newUnlockPOC = SafeMath.mul(schedule[SafeMath.sub(schedule.length, 2)].POC, SafeMath.add(dateDiff, 1));
   return SafeMath.sub(_initSupplyPOC, SafeMath.add(schedule[SafeMath.sub(schedule.length, 3)].POC, newUnlockPOC));
  }
  else {
   for (uint i=SafeMath.sub(schedule.length, 1); i>0; i--) {
    if (schedule[i-1].day <= currentDate) {
     return SafeMath.sub(_initSupplyPOC, schedule[i-1].POC);
    }
   }
   return _initSupplyPOC;
  }
 }
 function transferable() public view returns (uint256) {
   uint256 locked = SafeMath.mul(lockedPOC(block.timestamp), (10 ** uint256(decimals())));
   if (balanceOf(_owner) > locked) {
	   return SafeMath.sub(balanceOf(_owner), locked);
   }
   else {
      return 0;
   }
 }

 modifier listingDT() {
  require(_listingDate <= block.timestamp, "listing is not yet");
  _;
 }
 modifier onlyOwner() {
  require(msg.sender == _owner, "only owner is possible");
  _;
 }
 modifier unlocking(uint256 amount) {
  if (msg.sender != _owner){
   _;
  }
  else {
   require(transferable() >= amount, "lack of transferable token");
   _;
  }
 }
 function burn(uint256 burnToken) listingDT onlyOwner public returns (bool) {
   require(_addedSupplyToken >= burnToken, "you can burn newly added token only");
   require(balanceOf(msg.sender) >= burnToken, "you can burn in your balance only");
   _burn(msg.sender, burnToken);
   _addedSupplyToken = SafeMath.sub(_addedSupplyToken, burnToken);
   return true;
 }
 function mint(uint256 addedToken) listingDT onlyOwner public returns (bool) {
  require(SafeMath.add(_listingDate, _mint_term) <= block.timestamp, "creating new token is not yet");
  _mint(_owner, addedToken);
  _addedSupplyToken = SafeMath.add(_addedSupplyToken, addedToken);
  return true;
 }

 function transfer(address recipient, uint256 amount) listingDT unlocking(amount) public override returns (bool) {
   _transfer(_msgSender(), recipient, amount);
   return true;
 }
 function transferFrom(address sender, address recipient, uint256 amount) listingDT public virtual override returns (bool) {
   if (msg.sender == _owner){
     require(transferable() >= amount, "lack of transferable token");
   }
  if (super.transferFrom(sender, recipient, amount)) {
    return true;
  }
  else 
  {
    return false;
  }
}
}