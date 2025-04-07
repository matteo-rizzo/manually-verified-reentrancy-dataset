/**
 *Submitted for verification at Etherscan.io on 2020-11-06
*/

pragma solidity ^0.5.13;


//* @dev Implementation of the basic standard token.
//* @dev https://github.com/ethereum/EIPs/issues/20
// ----------------------------------------------------------------------------
// 'DGF' 'DGF Bank' token contract
//
// Symbol      : DGF
// Deployed to : // TODO: update contract to address generated
// Name        : Digital Future Bank Token
// Total supply: 1,000,000,000.000000000000000000
// Decimals    : 18
//
//
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
contract ERC20Interface {
  function totalSupply() public view returns (uint);
  function balanceOf(address tokenOwner) public view returns (uint balance);
  function allowance(address tokenOwner, address spender) public view returns (uint remaining);
  function transfer(address to, uint tokens) public returns (bool success);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);

  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
contract DGFToken is ERC20Interface, Owned {

  using SafeMath for uint;

  bytes32 public symbol;
  bytes32 public  name;
  uint8 public decimals;
  uint _totalSupply;

  // pre-sale bonus
  uint public startDate;
  uint public bonusEnds;
  uint public endDate;

  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;


  // ------------------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------------------
  constructor() public {
    symbol = "DGF";
    name = "Digital Future Bank Token";
    decimals = 18;
    _totalSupply = 1000000000 * 10**uint(decimals);
    balances[owner] = _totalSupply;
    emit Transfer(address(0), owner, _totalSupply);
  }


  // ------------------------------------------------------------------------
  // Total supply
  // ------------------------------------------------------------------------
  function totalSupply() public view returns (uint) {
    return _totalSupply.sub(balances[address(0)]);
  }


  // ------------------------------------------------------------------------
  // ------------------------------------------------------------------------
  function balanceOf(address tokenOwner) public view returns (uint balance) {
    return balances[tokenOwner];
  }


  // ------------------------------------------------------------------------
  // ------------------------------------------------------------------------
  function transfer(address to, uint tokens) public returns (bool success) {
    balances[msg.sender] = balances[msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(msg.sender, to, tokens);
    return true;
  }


  // ------------------------------------------------------------------------
  // ------------------------------------------------------------------------
  function approve(address spender, uint tokens) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;
  }


  // ------------------------------------------------------------------------
  // ------------------------------------------------------------------------
  function transferFrom(address from, address to, uint tokens) public returns (bool success) {
    balances[from] = balances[from].sub(tokens);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(from, to, tokens);
    return true;
  }


  // ------------------------------------------------------------------------
  // ------------------------------------------------------------------------
  function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
    return allowed[tokenOwner][spender];
  }


  // ------------------------------------------------------------------------
  // ------------------------------------------------------------------------
  function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
    return true;
  }

  // ------------------------------------------------------------------------
  // ------------------------------------------------------------------------
  function () external payable {
    assert(now >= startDate && now <= endDate);
    uint tokens;
    if (now <= bonusEnds) 
    balances[msg.sender] = SafeMath.add(balances[msg.sender], tokens);
    _totalSupply = SafeMath.add(_totalSupply, tokens);
    // sent to investor
    emit Transfer(address(0), msg.sender, tokens);
    // sent ETH to owner
    owner.transfer(msg.value);
  }


  // ------------------------------------------------------------------------
  // ------------------------------------------------------------------------
  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
    return ERC20Interface(tokenAddress).transfer(owner, tokens);
  }
}