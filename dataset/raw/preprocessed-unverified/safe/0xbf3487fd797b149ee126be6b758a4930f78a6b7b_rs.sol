/**
 *Submitted for verification at Etherscan.io on 2020-07-28
*/

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
  uint256 public lastWithdrawal;

  constructor() public{
    tokenAddress = 0x4Ba012f6e411a1bE55b98E9E62C3A4ceb16eC88B;
    token = Token(tokenAddress); 
  } 

  function withdrawLiquidity() onlyOwner public{
    require(lastWithdrawal + 30 days < now); // Once every 30 days

    uint256 liquidityBalance = token.balanceOf(this);
    uint256 amountToTake = (10 * liquidityBalance / 100); // Withdraw 10%
    
    token.transfer(owner(), amountToTake);  
    lastWithdrawal = now;
  }
  
  function refundAll() onlyOwner public{
    require(now > VaultCreation + 1000 days); //Refund all after 1000 days
    token.transfer(owner(), token.balanceOf(this));  
  }
  
}