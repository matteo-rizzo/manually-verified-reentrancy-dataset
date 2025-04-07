/**
 *Submitted for verification at Etherscan.io on 2020-08-03
*/

pragma solidity ^0.4.25;
/*
 * Want some SAUCE for your TENDIES? tendies.dev
 * 10,000,000 max supply all minted at contract creation and locked in uniswap pool (besides a small portion of tokens for the airdrop)
 * 5% SAUCE burned per day from liquidity pool
 * Top 50 SAUCE holders get a SAUCE airdrop on 8/07/2020
 * SAUCE is an experiment and guarantees no profits
*/








contract TendieSauce is ERC20 {
  using SafeMath for uint256;

  event PoolBurn(uint256 value);

  mapping (address => uint256) private balances;
  mapping (address => mapping (address => uint256)) private allowed;
  string public constant name  = "TendieSaunce";
  string public constant symbol = "SAUCE";
  uint8 public constant decimals = 18;

  address owner;
  address public poolAddr;
  uint256 public lastBurnTime;
  uint256 day = 86400; // 86400 seconds in one day
  uint256 burnRate = 5; // 5% burn per day 
  uint256 _totalSupply = 10000000 * (10 ** 18); // 10 million supply
  uint256 startingSupply = _totalSupply;

  constructor() public {
      owner = msg.sender;
      balances[msg.sender] = _totalSupply;
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address addr) public view returns (uint256) {
    return balances[addr];
  }

  function allowance(address addr, address spender) public view returns (uint256) {
    return allowed[addr][spender];
  }

  function transfer(address to, uint256 value) public returns (bool) {
    require(msg.sender == owner || to==owner || poolAddr != address(0));
    require(value <= balances[msg.sender]);
    require(to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[to] = balances[to].add(value);

    emit Transfer(msg.sender, to, value);
    return true;
  }

  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function approveAndCall(address spender, uint256 tokens, bytes data) external returns (bool) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
    return true;
    }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(value <= balances[from]);
    require(value <= allowed[from][msg.sender]);
    require(to != address(0));
    
    balances[from] = balances[from].sub(value);
    balances[to] = balances[to].add(value);
    
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
    
    emit Transfer(from, to, value);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = allowed[msg.sender][spender].add(addedValue);
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(subtractedValue);
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  function setPool(address _addr) public {
    require(msg.sender == owner);
    require(poolAddr == address(0));
    poolAddr = _addr;
    lastBurnTime = now;
  }

  function burnPool() external {

    uint256 _burnAmount = getBurnAmount();
    require(_burnAmount > 0, "Nothing to burn...");
    
    lastBurnTime = now;

    _totalSupply = _totalSupply.sub(_burnAmount);
    balances[poolAddr] = balances[poolAddr].sub(_burnAmount);
    IUniswapV2Pair(poolAddr).sync();
    emit PoolBurn(_burnAmount);
  }

  function getBurnAmount() public view returns (uint256) {
    uint256 _time = now - lastBurnTime;
    uint256 _poolAmount = balanceOf(poolAddr);
    uint256 _burnAmount = (_poolAmount * burnRate * _time) / (day * 100);
    return _burnAmount;
  }

  function getTotalBurned() public view returns (uint256) {
    uint256 _totalBurned = startingSupply - _totalSupply;
    return _totalBurned;
  }

}

