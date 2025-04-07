/**
 *Submitted for verification at Etherscan.io on 2020-11-07
*/

/**
 *  DexKit (KIT) is the next generation dex kit’s that will use technology based on ZRX protocol, Uniswap, Kyber and other protocols to create an advanced trading, swap, atomic swaps, market making and decentralized erc20 and erc721 whitelabel solutions.
 *  DexKit will use the concept of “toolKIT’S” to help traders do you want they need, a well informed trade at the best price, you will be able to leverage, place decentralized stop/limit orders, run arbitrage bots, sell cards, found all 0x mesh liquidity and stats on current decentralized protocols, place private orders and earn from arbitraged orders (Arbitrage mining).
 *  DexKit is based on well-known open source technology and it will build next generation closed source technologies that will belong to the company, and it will use a network of affiliates to promote the project and have them earn passive income while they earn KIT.
 * 
 *  Official Website: 
 *  https://dexkit.com//
 * 
 * © DEXKIT ALL RIGHTS RESERVED
 */

pragma solidity ^0.6.0;


contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}



contract DexKit is Context, IERC20, Owned {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor () public {
    _name = "DexKit";
    _symbol = "KIT";
    _decimals = 18;
    _totalSupply = 10000000 * 10**18;
    _balances[owner] = _balances[owner].add(_totalSupply);
    emit Transfer(address(0), owner, _totalSupply);
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

  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal virtual {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    _beforeTokenTransfer(sender, recipient, amount);

    _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }


  function _approve(address owner, address spender, uint256 amount) internal virtual {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}