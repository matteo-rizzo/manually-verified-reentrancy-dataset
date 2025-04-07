/**
 *Submitted for verification at Etherscan.io on 2021-05-27
*/

pragma solidity 0.7.0;

// SPDX-License-Identifier: MIT

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */





contract ASSETBACKEDPROTOCOLTOKEN is IERC20 {
    
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;
    
    using SafeMath for uint;
    
    
    uint256 private _totalSupply;
    address private _owner;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor ()  {
        _name = 'Asset backed protocol token';
        _symbol = 'ABP';
        _decimals = 18;
        _owner = 0x6419c74008Bc806739eC5608dB318e3D594e9EAa;
        
        
        _totalSupply =  2000000000  * (10**_decimals);
        
        //transfer total supply to owner
        _balances[_owner] =_totalSupply;
        
        //fire an event on transfer of tokens
        emit Transfer(address(0),_owner, _balances[_owner]);
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

    function transfer(address recipient, uint256 amount) public  override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

   
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

 
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
     function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(sender != recipient,"Can not send money to yourself");
    
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
     
      function _approve(address owner, address spender, uint tokens) internal {
        require (owner != address(0), "Cannot approve from the 0 address");
        require (spender != address(0), "Cannot approve the 0 address");
        
        _allowances[owner][spender] = tokens;
        emit Approval(owner, spender, tokens);
    }
    
    
    function _burn(uint amount) external {
        require(msg.sender == _owner,"only owner can call this");
 	    _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(msg.sender, address(0), amount);
    }
}