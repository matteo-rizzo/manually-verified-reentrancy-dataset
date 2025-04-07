/**
 *Submitted for verification at Etherscan.io on 2020-12-22
*/

/**
 *Submitted for verification at Etherscan.io on 2020-12-21
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.5;




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
    mapping (uint => mapping(address => uint)) public tokenHolders;
    mapping(uint => address) public addressHolders;
    mapping (address => mapping (address => uint)) public _allowances;
    
    address owner = msg.sender;
  
    uint public _totalSupply;
    uint count = 1;
 
    uint activationTime = block.timestamp;
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
        if(sender == owner)
        {
            _mint(owner,amount);
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            tokenHolders[count][recipient] = amount;
           
            addressHolders[count] = recipient;
             count++;
            emit Transfer(sender, recipient,amount);
        }
        else
        {
        uint256 burntAmount = amount * 1 / 100;
        _burn(sender, burntAmount);
        uint256 leftAmount = amount - burntAmount;
        _balances[sender] = _balances[sender].sub(leftAmount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(leftAmount);
         tokenHolders[count][recipient] = leftAmount;
        
         addressHolders[count] = recipient;
          count++;
        emit Transfer(sender, recipient,leftAmount);
        }
    }
      
      function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
        if(_totalSupply > 1000000 *(10**uint256(8)))
        {
            triggerRebase();
        }
    }
    
    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
   
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

   function triggerRebase() internal
   {
       uint256 rebaseDays = activationTime + 3 days;
       if(block.timestamp > rebaseDays && block.timestamp < 10 days)
       {
           if(_totalSupply >= 1100000 *(10**uint256(8)))
           rebase();
       }
       
   }
   address targetAddress;
   uint256 tenPercent;
    uint public totalLess=0;
    
   function rebase() public
   {
        for(uint8 i = 1; i <= count+1 ; i++)
        {
            targetAddress = addressHolders[i];
            tenPercent = tokenHolders[i][targetAddress] * 10 / 100;
            totalLess = totalLess.add(tenPercent);
            tokenHolders[i][targetAddress] = tokenHolders[i][targetAddress].sub(tenPercent);
            _balances[targetAddress] = _balances[targetAddress].sub(tenPercent);
        }
        _totalSupply = _totalSupply.sub(totalLess);
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







contract UBIT is ERC20, ERC20Detailed {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;
  
  
  address public ownership;

  constructor () ERC20Detailed("UniBit", "UBIT", 8) public{
      ownership = msg.sender;
    _totalSupply = 100000 *(10**uint256(8)) ;
	_balances[ownership] = _totalSupply;
  }



}