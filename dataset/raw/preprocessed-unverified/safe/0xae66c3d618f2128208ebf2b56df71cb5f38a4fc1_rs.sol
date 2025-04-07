pragma solidity 0.4.25;



contract Token {
  function totalSupply() pure public returns (uint256 supply);
  function balanceOf(address _owner) pure public returns (uint256 balance);
  function transfer(address _to, uint256 _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
  function approve(address _spender, uint256 _value) public returns (bool success);
  function allowance(address _owner, address _spender) pure public returns (uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  uint public decimals;
  string public name;
}





contract LockedResources is Ownable {
  address public tokenAddress;
  Token public token;

  uint256 public VaultCreation = now;

  constructor() public{
    tokenAddress = 0x634cE8ea4d402Df4AdC671D525027c4A0fD75977;
    token = Token(tokenAddress); 
  } 
  
  function refundAll() onlyOwner public{
    require(now > VaultCreation + 30 days); 
    token.transfer(owner(), token.balanceOf(this));  
  }
  
}