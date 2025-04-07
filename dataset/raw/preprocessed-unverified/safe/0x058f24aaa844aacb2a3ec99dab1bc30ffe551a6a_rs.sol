/**
 *Submitted for verification at Etherscan.io on 2020-11-25
*/

pragma solidity 0.6.0;





contract PreSale {
  using SafeMath for uint256;

  ERC20 private timeToken;
  address payable private owner;
 
  constructor(address token) public {
    owner = msg.sender;
    timeToken = ERC20(token);
  }

  //Buy tokens
  function buyTokensByETH() external payable {
    require(msg.value <= 0.01 ether);
    
    uint256 amountOfTokens = msg.value;
    
    amountOfTokens = amountOfTokens.mul(700); //adjust tokens count to eth
    
    owner.transfer(msg.value);
        
    timeToken.transfer(msg.sender, amountOfTokens);
  }
  
  // Not sold tokens
  function returnNotSoldTokens() public returns (bool success) {
    require(msg.sender == owner);
    timeToken.transfer(msg.sender, timeToken.balanceOf(address(this)));
    return true;
  }
  
  // Wrong Send Various Tokens
  function returnVariousTokenFromContract(address tokenAddress) public returns (bool success) {
      require(msg.sender == owner);
      ERC20 tempToken = ERC20(tokenAddress);
      tempToken.transfer(msg.sender, tempToken.balanceOf(address(this)));
      return true;
  }
  
  // Wrong Send ETH
  function returnETHFromContract(uint256 value) public returns (bool success) {
      require(msg.sender == owner);
      msg.sender.transfer(value);
      return true;
  }
}