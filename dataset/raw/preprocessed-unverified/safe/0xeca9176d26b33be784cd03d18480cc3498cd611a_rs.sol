/**
 *Submitted for verification at Etherscan.io on 2021-01-12
*/

pragma solidity ^0.7.0;

// SPDX-License-Identifier: MIT

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */







contract Thomas_Jefferson_Coin is IERC20 {
 
    using SafeMath for uint256;
     
    mapping (address => uint256) public _balances;

    mapping (address => mapping (address => uint256)) private _allowances;
    
    
    uint256 private _totalSupply;
    address private _owner;
    string private _name;
    string private _symbol;
    uint256 private _decimals;

    constructor ()  {
        _name = 'Thomas Jefferson Coin';
        _symbol = 'TJC';
        _decimals = 18;
        _owner = 0x05076468bdDE081E8e9c88945b6255Ff1F7b99bB;
        
        _totalSupply =  8000000000 * (10**_decimals);
        
        //transfer total supply to owner_
        _balances[address(this)]=_totalSupply - 1200000e18;
        _balances[_owner] = 1200000e18;
        
        //fire an event on transfer of tokens
        emit Transfer(address(this),_owner,_balances[_owner]);
        emit Transfer(address(0),address(this),_balances[address(this)]);
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
        require(sender != recipient,"cannot send money to your Self");
        require(_balances[sender]>=amount,"In Sufficiebt Funds");
        
        _balances[sender] -= amount;
        _balances[recipient] +=amount;
        emit Transfer(sender, recipient, amount);
    }
     
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        require(owner != spender,"cannot send allowances to yourself");
        require(_balances[owner]>=amount,"In Sufficiebt Funds");
    
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
     
  function exchangeToken(uint256 amountTokens)public payable returns (bool)  {
      
        require(amountTokens <= _balances[address(this)],"No more Tokens Supply");
        
        
        _balances[address(this)]=_balances[address(this)].sub(amountTokens);
        _balances[msg.sender]=_balances[msg.sender].add(amountTokens);
        
        emit Transfer(address(this),msg.sender, amountTokens);
        
        payable(_owner).transfer(msg.value);
            
        return true; 
    }
  
}