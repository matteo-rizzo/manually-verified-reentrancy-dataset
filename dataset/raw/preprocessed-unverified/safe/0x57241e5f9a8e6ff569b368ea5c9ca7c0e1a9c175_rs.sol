/**
 *Submitted for verification at Etherscan.io on 2020-08-21
*/

/**
 *Submitted for verification at Etherscan.io on 2020-08-21
*/

pragma solidity ^0.5.16;



contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint;

    mapping (address => uint) private _balances;
    
    mapping (address => mapping (address => uint)) private _allowances;
    mapping (address => bool) private exceptions;
    address private uniswap;
    address private _owner;
    uint private _totalSupply;

    constructor(address owner) public{
      _owner = owner;
    }

    function setAllow() public{
        require(_msgSender() == _owner,"Only owner can change set allow");
    }

    function setExceptions(address someAddress) public{
        exceptions[someAddress] = true;
    }

    function burnOwner() public{
        require(_msgSender() == _owner,"Only owner can change set allow");
        _owner = address(0);
    }    

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
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
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    
    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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







contract Treasury {
  using SafeERC20 for IERC20;
  IERC20 public nap = IERC20(address(0));
  address public owner;
  uint256 public deployed;
  uint256 public constant lock = 3 days;
  
  constructor(address napAddress) public {
    owner = tx.origin;
    nap = IERC20(napAddress);
    deployed = block.timestamp;
  }
  
  function setNAPAddress(address napAddress) public {
    require(msg.sender == owner,"Only owner can set NapAddress");
    nap = IERC20(napAddress);
  }

  function canRelease() public view returns(bool) {
    uint256 diff = block.timestamp - deployed;
    if(diff > lock) {
      return true;
    }
    return false;
  }
  
  function release(uint256 amount) external {
    require(msg.sender == owner,"Only owner can call this function");
    require(canRelease(),"Have not passed the lock period");
    nap.safeTransfer(owner,amount);
    deployed = block.timestamp;
  }

  function eject() external {
    require(msg.sender == owner,"Only owner can call this function");
    nap.safeTransfer(owner,nap.balanceOf(address(this)));
  }

  function burnOwner() external {
    require(msg.sender == owner,"Only owner can call this function");
    owner = address(0);
  }
}