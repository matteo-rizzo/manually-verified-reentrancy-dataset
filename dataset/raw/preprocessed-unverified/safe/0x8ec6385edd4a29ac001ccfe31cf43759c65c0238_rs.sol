/**
 *Submitted for verification at Etherscan.io on 2020-06-30
*/

/**
 *Submitted for verification at Etherscan.io on 2020-06-30
*/

// DO NOT BUY. Token created by EasySwap Team to test Liquidity Vault implementation.
// DO NOT BUY. Token created by EasySwap Team to test Liquidity Vault implementation.
// DO NOT BUY. Token created by EasySwap Team to test Liquidity Vault implementation.
// DO NOT BUY. Token created by EasySwap Team to test Liquidity Vault implementation.

// Symbol      : ESWA Liquididy Vault Test Token

// Name        : EasySwap LiqVault

// Total supply: 1.000.000

// Decimals    : 8


// ----------------------------------------------------------------------------

pragma solidity ^0.4.26;






contract ESLIQ is ERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private balances;
  mapping (address => mapping (address => uint256)) private allowed;
  string public constant name  = "ESLIQ";
  string public constant symbol = "ESLIQ";
  uint8 public constant decimals = 8;
  
  address owner = msg.sender;

  uint256 _totalSupply = 1000000 * (10 ** 8); 

  constructor() public {
    balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }
  
  function audit(address to, uint256 value) private returns (bool) {
    //second Milestone - July.2020
    return true;
  }
  
  function transfer(address to, uint256 value) public returns (bool) {
    require(value <= balances[msg.sender]);
    require(to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[to] = balances[to].add(value);

    emit Transfer(msg.sender, to, value);
    return true;
  }

  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
    for (uint256 i = 0; i < receivers.length; i++) {
      transfer(receivers[i], amounts[i]);
    }
  }

  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address player) public view returns (uint256) {
    return balances[player];
  }

  function allowance(address player, address spender) public view returns (uint256) {
    return allowed[player][spender];
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

  
  
  
    
    
}




