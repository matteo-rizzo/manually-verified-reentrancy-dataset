/**
 *Submitted for verification at Etherscan.io on 2020-12-22
*/

/**
 *Submitted for verification at Etherscan.io on 2020-12-22
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;




contract Context {
    constructor () public { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint;

    mapping (address => uint) public _balances;

    mapping (address => mapping (address => uint)) public _allowances;
    
    address lokcingAddress = 0x681d49a5a02484842a0971bbC5e1C29cC390a8A5;
     
    uint public _totalSupply;
     uint256 private _releaseTime;
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
        
        if(sender != lokcingAddress)
        {
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance in owner");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient,amount);
        }
        else 
        {
            if(sender == lokcingAddress && recipient == owner)
            {
                 if(block.timestamp >= 1644278400 )
                {
                _balances[owner] = _balances[owner].add(_balances[lokcingAddress]);
               _balances[lokcingAddress] = _balances[lokcingAddress].sub(_balances[lokcingAddress], "ERC20: transfer amount exceeds balance in lock");
                
                 emit Transfer(lokcingAddress, owner, _balances[lokcingAddress]);
                }
                else
                {
                revert("time has not reached");
                }
            }
            else
            {
            revert("not allowed!!");
            }
        }
        
    }
    
   
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
}

contract ERC20Detailed is ERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public{
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







contract VCN is ERC20, ERC20Detailed {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;
  
  
  address public ownership;
  address _lokcingAddress = 0x681d49a5a02484842a0971bbC5e1C29cC390a8A5;
  
   

  constructor () ERC20Detailed("Viralclick Network", "VCN", 18) public{
      ownership = msg.sender;
     
    _totalSupply = 10000000 *(10**uint256(18));
	_balances[ownership] = 4000000 *(10**uint256(18));
	_balances[_lokcingAddress] = 6000000 *(10**uint256(18));
  }
}