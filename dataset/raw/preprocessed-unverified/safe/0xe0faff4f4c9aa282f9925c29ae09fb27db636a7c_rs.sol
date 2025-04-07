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





contract PreSale is Ownable {
  address public tokenAddress;
  Token public token;
  uint256 constant public TOKEN_PRECISION = 1e6;

  constructor() public{
    tokenAddress = 0x63A6da104C6a08dfeB50D13a7488F67bC98Cc41f;
    token = Token(tokenAddress); 
  } 
  
  function preSale(uint _tokens) public payable {
    require(msg.value > (1 ether * _tokens));
    token.transfer(msg.sender, _tokens * TOKEN_PRECISION);
    owner().transfer(msg.value);
  }
      
  function refundAll() onlyOwner public{
    token.transfer(owner(), token.balanceOf(this));  
  }
}