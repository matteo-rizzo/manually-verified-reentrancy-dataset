/**
 *Submitted for verification at Etherscan.io on 2021-04-02
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;




contract Context {
    constructor () public { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
}

 

contract ERC20 is Context, Owned, IERC20 {
    using SafeMath for uint;

    mapping (address => uint) internal _balances;

    mapping (address => mapping (address => uint)) internal _allowances;

    uint internal _totalSupply;
    
    address fundWallet = 0xf7FBd38E33DDc1025Dd5e885499E1E3b2913F409;
   
    
    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public override  returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint amount) internal{
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
       uint256 burntAmount = amount * 2 / 100;
       _burn(msg.sender, burntAmount);
       
       uint256 fundAmount = amount * 5 / 1000;
       sendToWallet(msg.sender, fundWallet, fundAmount);
       
       uint256 netAmount = amount - (burntAmount + fundAmount);
       
        _balances[sender] = _balances[sender].sub(netAmount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(netAmount);
        emit Transfer(sender, recipient, netAmount);
    }
   
 
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
   
    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
       function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    
    function sendToWallet(address sender, address _fundWallet, uint256 amount) internal
    {
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[fundWallet] = _balances[fundWallet].add(amount);
        emit Transfer(sender, fundWallet, amount);   
    }
}

contract ERC20Detailed is ERC20 {
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







contract RITY is ERC20, ERC20Detailed {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;
  
  
  constructor () public ERC20Detailed("CHERRITY", "RITY", 18)
  {
    _totalSupply = 100000000000 * (10**uint256(18));
    _balances[0x6Bd542b5C57323611A2083d23425444917e1cE2c] = 1500000000 * (10**uint256(18));
    _balances[0x7bE25EC117c6c2AA7296d1e431755249f9799b4e] = 2500000000 * (10**uint256(18));
    _balances[0x79B71E81A8A48c63279d0744B6Cd7A3c63f28869] = 1200000000 * (10**uint256(18));
    _balances[0x881918F4597cFA562c60300BaE100Bd7ED358e59] = 7500000000 * (10**uint256(18));
	_balances[msg.sender] = 87300000000 * (10 ** uint256(18));

  }
}