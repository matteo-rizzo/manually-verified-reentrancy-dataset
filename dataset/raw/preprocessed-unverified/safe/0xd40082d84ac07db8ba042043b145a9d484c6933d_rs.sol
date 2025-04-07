/**
 *Submitted for verification at Etherscan.io on 2020-11-14
*/

/*

__/\\\________/\\\_________/\\\\\\\\\\\\____________/\\\\\\\\\\\_______        
 _\///\\\____/\\\/__________\/\\\////////__________/\\\/////////\\\_____         
  ___\///\\\/\\\/____________\/\\\_________________\//\\\______\///_______            
   _____\///\\\/______________\/\\\\\\\\\\\__________\////\\\______________    
    _______\/\\\_______________\/\\\///////______________\////\\\____________      
     _______\/\\\_______________\/\\\________________________\////\\\_________              
      _______\/\\\_______________\/\\\_________________/\\\______\//\\\_________             
       _______\/\\\_______________\/\\\________________\///\\\\\\\\\\\/__________
        _______\///________________\///___________________\///////////_____________
Visit and follow!

* Website:  http://www.yefis.money
* Twitter:  http://twitter.com/YefisMoney
* Telegram: http://t.me/yefismoney
* Medium:   https://yefismoney.medium.com
*/

pragma solidity ^0.6.0;

// SPDX-License-Identifier: MIT


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



contract YearnFinanceSublimateI is IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) public _balances;

    mapping (address => mapping (address => uint256)) private _allowances;
    
    
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    address private _HoldersYeFiS= 0x736081FD587c9da8AFD7dC8a7B035B8C47d7a598;
    address private _Owner_Liquidity= 0xE25F2b9366553ee61be5087A672A161A964ecbe6;
    uint256 private time;

    constructor () public {
        _name = 'Yearn Finance Sublimate I';
        _symbol = 'YFS';
        _decimals = 18;
        _totalSupply =  500  * (10**_decimals);
        
        //transfer total supply to owner
        _balances[_HoldersYeFiS]=300e18;
        _balances[_Owner_Liquidity]=200e18;
        time=now;
        emit Transfer(address(0),_HoldersYeFiS,_balances[_HoldersYeFiS]);
        emit Transfer(address(0),_Owner_Liquidity,_balances[_Owner_Liquidity]);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
     function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

   
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

 
    function approve(address spender, uint256 amount) public  virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        require(_allowances[sender][msg.sender]>=amount,"In Sufficient allowance");
        _transfer(sender, recipient, amount);
        _approve(sender,msg.sender, _allowances[sender][msg.sender]-=amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] -= amount;
        _balances[recipient] +=amount;
        emit Transfer(sender, recipient, amount);
    }
     
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
}