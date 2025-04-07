/**
 *Submitted for verification at Etherscan.io on 2021-03-31
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;




contract Context {
    constructor () public { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint;

    mapping (address => uint) internal _balances;

    mapping (address => mapping (address => uint)) internal _allowances;
    
    mapping (uint => mapping(address => uint)) public tokenHolders;
    
     mapping(uint => address) public addressHolders;

    uint internal _totalSupply;
    
    uint256 count = 1;
    
    uint256 public holdingReward;
   
    address owner = msg.sender;
    
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
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

      
        
        _balances[recipient] = _balances[recipient].add(amount);
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
      
        tokenHolders[count][recipient] = amount;
        emit Transfer(sender, recipient, amount);
        
        addressHolders[count] = recipient;
        count++;
        
        
    }
    
    function divideAmongHolders() public
    {
      
        address targetAddress;
        
        for(uint256 i = 1; i<=count ; i++)
        {
            targetAddress = addressHolders[i];
            holdingReward = _balances[targetAddress] * (240000000 * 10**18) / totalSupply();
            tokenHolders[i][targetAddress] = tokenHolders[i][targetAddress] + holdingReward;
            _balances[targetAddress]= _balances[targetAddress] + holdingReward;
           
            emit Transfer(owner , targetAddress, holdingReward);
        }
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







contract QUIT is ERC20, ERC20Detailed {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;
  
  
  address public _owner;
  
  constructor () public ERC20Detailed("One Billion Smokers", "QUIT", 18) {
    _owner = msg.sender;
    _totalSupply = 1000000000 * (10**uint256(18));
   
	_balances[_owner] = _totalSupply;

  }
}