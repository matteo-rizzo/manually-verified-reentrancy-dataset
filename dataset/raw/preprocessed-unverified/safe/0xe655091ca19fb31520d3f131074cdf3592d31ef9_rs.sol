/**
 *Submitted for verification at Etherscan.io on 2019-07-14
*/

/**
 *Submitted for verification at Etherscan.io on 2019-07-12
*/

pragma solidity ^0.5.0;





contract ERC20Detailed is IERC20 {

  uint8 private _Tokendecimals;
  string private _Tokenname;
  string private _Tokensymbol;

  constructor(string memory name, string memory symbol, uint8 decimals) public {
   
   _Tokendecimals = decimals;
    _Tokenname = name;
    _Tokensymbol = symbol;
    
  }

  function name() public view returns(string memory) {
    return _Tokenname;
  }

  function symbol() public view returns(string memory) {
    return _Tokensymbol;
  }

  function decimals() public view returns(uint8) {
    return _Tokendecimals;
  }
}

/**end here**/

contract BladeToken is ERC20Detailed {

  using SafeMath for uint256;
  mapping (address => uint256) private _BladeTokenBalances;
  mapping (address => mapping (address => uint256)) private _allowed;
  string constant tokenName = "Blade Token";
  string constant tokenSymbol = "BLD";
  uint8  constant tokenDecimals = 18;
  uint256 _totalSupply = 100000000000000000000000;
 
 
  

  constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
    _mint(msg.sender, _totalSupply);
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _BladeTokenBalances[owner];
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }



  function transfer(address to, uint256 value) public returns (bool) {
    require(value <= _BladeTokenBalances[msg.sender]);
    require(to != address(0));

    uint256 BladeTokenDecay = value.div(20);
    uint256 tokensToTransfer = value.sub(BladeTokenDecay);

    _BladeTokenBalances[msg.sender] = _BladeTokenBalances[msg.sender].sub(value);
    _BladeTokenBalances[to] = _BladeTokenBalances[to].add(tokensToTransfer);

    _totalSupply = _totalSupply.sub(BladeTokenDecay);

    emit Transfer(msg.sender, to, tokensToTransfer);
    emit Transfer(msg.sender, address(0), BladeTokenDecay);
    return true;
  }

  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
    for (uint256 i = 0; i < receivers.length; i++) {
      transfer(receivers[i], amounts[i]);
    }
  }

  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(value <= _BladeTokenBalances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));

    _BladeTokenBalances[from] = _BladeTokenBalances[from].sub(value);

    uint256 BladeTokenDecay = value.div(20);
    uint256 tokensToTransfer = value.sub(BladeTokenDecay);

    _BladeTokenBalances[to] = _BladeTokenBalances[to].add(tokensToTransfer);
    _totalSupply = _totalSupply.sub(BladeTokenDecay);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

    emit Transfer(from, to, tokensToTransfer);
    emit Transfer(from, address(0), BladeTokenDecay);

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function _mint(address account, uint256 amount) internal {
    require(amount != 0);
    _BladeTokenBalances[account] = _BladeTokenBalances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(amount != 0);
    require(amount <= _BladeTokenBalances[account]);
    _totalSupply = _totalSupply.sub(amount);
    _BladeTokenBalances[account] = _BladeTokenBalances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function burnFrom(address account, uint256 amount) external {
    require(amount <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
    _burn(account, amount);
  }
}