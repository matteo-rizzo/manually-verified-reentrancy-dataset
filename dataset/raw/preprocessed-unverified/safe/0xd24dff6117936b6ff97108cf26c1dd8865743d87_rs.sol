/**
 *Submitted for verification at Etherscan.io on 2019-10-11
*/

pragma solidity ^0.5.0;






contract ERC20 is IERC20 {
	using SafeMath for uint256;

	mapping (address => uint256) private _balances;
	mapping (address => mapping (address => uint256)) private _allowances;
	uint256 private _totalSupply;

	function totalSupply() public view returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) public view returns (uint256) {
		return _balances[account];
	}

	function transfer(address recipient, uint256 amount) public returns (bool) {
		_transfer(msg.sender, recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) public view returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 value) public returns (bool) {
		_approve(msg.sender, spender, value);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
		_approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
		_approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
		return true;
	}

	function _transfer(address sender, address recipient, uint256 amount) internal {
		require(sender != address(0), "ERC20: transfer from the zero address");
		require(recipient != address(0), "ERC20: transfer to the zero address");

		_balances[sender] = _balances[sender].sub(amount);
		_balances[recipient] = _balances[recipient].add(amount);
		emit Transfer(sender, recipient, amount);
	}

	function _mint(address account, uint256 amount) internal {
		require(account != address(0), "ERC20: mint to the zero address");

		_totalSupply = _totalSupply.add(amount);
		_balances[account] = _balances[account].add(amount);
		emit Transfer(address(0), account, amount);
	}

	function _burn(address account, uint256 value) internal {
		require(account != address(0), "ERC20: burn from the zero address");

		_totalSupply = _totalSupply.sub(value);
		_balances[account] = _balances[account].sub(value);
		emit Transfer(account, address(0), value);
	}

	function _approve(address owner, address spender, uint256 value) internal {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");

		_allowances[owner][spender] = value;
		emit Approval(owner, spender, value);
	}

	function _burnFrom(address account, uint256 amount) internal {
		_burn(account, amount);
		_approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
	}
}

contract ERC20Detailed is IERC20 {
	string private _name;
	string private _symbol;
	uint8 private _decimals;

	constructor (string memory name, string memory symbol, uint8 decimals) public {
		_name = name;
		_symbol = symbol;
		_decimals = decimals;
	}

	function name() public view returns (string memory) {
		return _name;
	}

	function symbol() public view returns (string memory) {
		return _symbol;
	}

	function decimals() public view returns (uint8) {
		return _decimals;
	}
}

contract ERC20Burnable is ERC20 {
	function burn(uint256 amount) public {
		_burn(msg.sender, amount);
	}

	function burnFrom(address account, uint256 amount) public {
		_burnFrom(account, amount);
	}
}



contract Lockable is Ownable, ERC20 {
	using SafeMath for uint256;

	uint256 constant INFINITY = 300000000000;

	struct UsableLimitInfo{
		bool isEnable;
		uint256 usableAmount;
	}

	bool private _tokenLocked;
	mapping(address => uint256) private _accountLocked;
	mapping(address => UsableLimitInfo) private _amountLocked;

	event TokenLocked();
	event TokenUnlocked();

	event AccountLocked(address account, uint256 time);
	event AccountUnlocked(address account, uint256 time);

	event EnableAmountLimit(address account, uint256 usableAmount);
	event DisableAmountLimit(address account);

	constructor() internal {
		_tokenLocked = false;
	}

	modifier whenUnlocked(address originator, address from, address to) {
		require(!_tokenLocked, 'Lockable: Token is locked.');
		require(!isAccountLocked(originator), 'Lockable: Account is locked.');

		if (originator != from) {
			require(!isAccountLocked(from), 'Lockable: Account is locked.');
		}

		require(!isAccountLocked(to), 'Lockable: Account is locked.');
		_;
	}

	modifier checkAmountLimit(address from, uint256 amount) {
		if(_amountLocked[from].isEnable == true) {
			require(_amountLocked[from].usableAmount >= amount, 'Lockable: check usable amount');
		}
		_;
		if(_amountLocked[from].isEnable == true) {
			_decreaseUsableAmount(from, amount);
		}
	}

	function isAccountLocked(address account) internal view returns (bool) {
		if (_accountLocked[account] >= block.timestamp) {
			return true;
		} else {
			return false;
		}
	}

	function getTokenLockState() public onlyOwner view returns (bool) {
		return _tokenLocked;
	}

	function getAccountLockState(address account) public onlyOwner view returns (uint256) {
		return _accountLocked[account];
	}

	function getAccountLockState() public view returns (uint256) {
		return _accountLocked[msg.sender];
	}

	function lockToken() public onlyOwner {
		_tokenLocked = true;
		emit TokenLocked();
	}

	function unlockToken() public onlyOwner {
		_tokenLocked = false; 
		emit TokenUnlocked();
	}

	function lockAccount(address account) public onlyOwner {
		_lockAccount(account, INFINITY);
	}

	function lockAccount(address account, uint256 time) public onlyOwner {
		_lockAccount(account, time);
	}

	function _lockAccount(address account, uint256 time) private onlyOwner {
		_accountLocked[account] = time;
		emit AccountLocked(account, time);
	}

	function unlockAccount(address account) public onlyOwner {
		if (_accountLocked[account] != 0) {
			uint256 lockedTimestamp = _accountLocked[account];
			delete _accountLocked[account];
			emit AccountUnlocked(account, lockedTimestamp);
		}
	}

	function getUsableLimitInfo(address account) onlyOwner public  view returns (bool, uint256) {
		return (_amountLocked[account].isEnable, _amountLocked[account].usableAmount);
	}

	
	
	

	function setUsableLimitMode(address account, uint256 amount) public onlyOwner {
		_setUsableAmount(account, amount);
	}

	function disableUsableLimitMode(address account) public onlyOwner {
		require(_amountLocked[account].isEnable == true, "Lockable: Already disabled.");

		_amountLocked[account].isEnable = false;
		_amountLocked[account].usableAmount = 0;
		emit DisableAmountLimit(account);
	}

	function increaseUsableAmountLimit(address account, uint256 amount) public onlyOwner {
		require(_amountLocked[account].isEnable == true, "Lockable: This account is not set Usable amount limit mode.");
		_increaseUsableAmount(account, amount);
	}

	function decreaseUsableAmountLimit(address account, uint256 amount) public onlyOwner {
		require(_amountLocked[account].isEnable == true, "Lockable: This account is not set Usable amount limit mode.");
		_decreaseUsableAmount(account, amount);
	}

	function _increaseUsableAmount(address account, uint256 amount) private {
		uint256 val = amount + _amountLocked[account].usableAmount;

		_setUsableAmount(account, val);
	}

	function _decreaseUsableAmount(address account, uint256 amount) private {
		uint256 val = _amountLocked[account].usableAmount - amount;

		_setUsableAmount(account, val);
	}

	function _setUsableAmount(address account, uint256 usableAmount) private {
		require(balanceOf(account) >= usableAmount, "Lockable: It must not bigger than balance");

		if(_amountLocked[account].isEnable == false) {
			_amountLocked[account].isEnable = true;
		}
		_amountLocked[account].usableAmount = usableAmount;
		emit EnableAmountLimit(account, usableAmount);
	}
}

contract ERC20Lockable is ERC20, Lockable {
	function transfer(address to, uint256 value)
	public
	whenUnlocked(msg.sender, msg.sender, to)
	checkAmountLimit(msg.sender, value)
	returns (bool)
	{
		return super.transfer(to, value);
	}

	function transferFrom(address from, address to, uint256 value)
	public
	whenUnlocked(msg.sender, from, to)
	checkAmountLimit(from, value)
	returns (bool)
	{
		return super.transferFrom(from, to, value);
	}

	function approve(address spender, uint256 value) public whenUnlocked(msg.sender, msg.sender, spender) returns (bool) {
		return super.approve(spender, value);
	}

	function increaseAllowance(address spender, uint addedValue) public whenUnlocked(msg.sender, msg.sender, spender) returns (bool) {
		return super.increaseAllowance(spender, addedValue);
	}

	function decreaseAllowance(address spender, uint subtractedValue) public whenUnlocked(msg.sender, msg.sender, spender) returns (bool) {
		return super.decreaseAllowance(spender, subtractedValue);
	}
}

contract MediumToken is ERC20, ERC20Detailed, ERC20Burnable, ERC20Lockable {
	uint256 private _INITIAL_SUPPLY = 1000000000e18;
	string private _TOKEN_NAME = "Medium Token";
	string private _TOKEN_SYMBOL = "MDM";
	uint8 _DECIMALS = 18;

	constructor(address initialWallet) ERC20Detailed(_TOKEN_NAME, _TOKEN_SYMBOL, _DECIMALS) public {
		_mint(initialWallet, _INITIAL_SUPPLY);
	}
}