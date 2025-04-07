/**
 *Submitted for verification at Etherscan.io on 2021-03-12
*/

//Did you know? Shinigami only eat apples.

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.7.6;

contract Context {
    constructor () { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
}









contract GAMI is IERC20, Context{
  using SafeERC20 for IERC20;
  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;
  string constant _name = "GAMI";
  string constant _symbol = "GAMI";
  uint8  constant _decimals = 18;
  uint256 private _totalSupply = 6000000000000000000;
  uint256 constant basePercent = 100;
  constructor() {
    _issue(msg.sender, _totalSupply);
  }
  function name() public pure returns(string memory) {
    return _name;
  }
  function symbol() public pure returns(string memory) {
    return _symbol;
  }
  function decimals() public pure returns(uint8) {
    return _decimals;
  }
  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }
  function balanceOf(address owner) public override view returns (uint256) {
    return _balances[owner];
  }
  function allowance(address owner, address spender) public override view returns (uint256) {
    return _allowed[owner][spender];
  }
  function slash(uint256 value) public pure returns (uint256)  {
    uint256 roundValue = value.ceil(basePercent);
    uint256 slashValue = roundValue.mul(basePercent).div(10000); //Burn
    return slashValue;
  }
  function transfer(address to, uint256 value) public override returns (bool) {
    require(value <= _balances[msg.sender]);
    uint256 tokensToBurn = slash(value);  // Burn on transfer
    uint256 tokensToTransfer = value.sub(tokensToBurn);
    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(tokensToTransfer);
    _totalSupply = _totalSupply.sub(tokensToBurn);
    emit Transfer(msg.sender, to, tokensToTransfer);
    emit Transfer(msg.sender, address(0), tokensToBurn);
    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (
    _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (
    _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }
  function _transfer(address from, address to, uint256 value) internal {
    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }
  function approve(address spender, uint256 value) public override returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }
  function transferFrom(address from, address to, uint256 value) public override returns (bool) {
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));
    _balances[from] = _balances[from].sub(value);
    uint256 tokensToBurn = slash(value);  //Burn on transfer
    uint256 tokensToTransfer = value.sub(tokensToBurn);
    _balances[to] = _balances[to].add(tokensToTransfer);
    _totalSupply = _totalSupply.sub(tokensToBurn);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    emit Transfer(from, to, tokensToTransfer);
    emit Transfer(from, address(0), tokensToBurn);
    return true;
  }
  function _issue(address account, uint256 amount) internal {
    require(amount != 0);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }
  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }
  function _burn(address account, uint256 amount) internal {
    require(amount != 0);
    require(amount <= _balances[account]);
    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }
  function burnFrom(address account, uint256 amount) external {
    require(amount <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
    _burn(account, amount);
  }
  function _mint(address account, uint256 value) internal {
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }
}