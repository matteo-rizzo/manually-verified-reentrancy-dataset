/**
 *Submitted for verification at Etherscan.io on 2020-12-28
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.8;


// Welcome to the Beast DAO Liquidity sale - Unleash the DeFi Beast. - https://beast.finance







contract BeastSale {
  using SafeMath for uint256;

  uint256 public totalSold;
  ERC20 public Token;
  address payable public owner;
  uint256 public collectedETH;
  uint256 public startDate;
  bool private saleClosed = false;

  constructor(address _wallet) public {
    owner = msg.sender;
    Token = ERC20(_wallet);
  }

  uint256 amount;
 

  receive () external payable {
    require(startDate > 0 && now.sub(startDate) <= 7 days);
    require(Token.balanceOf(address(this)) > 0);
    require(msg.value >= 0.1 ether && msg.value <= 60 ether);
    require(!saleClosed);
     
    //BEAST token sale amount
       amount = msg.value.mul(200);

    
    require(amount <= Token.balanceOf(address(this)));
    // Update Constants
    totalSold = totalSold.add(amount);
    collectedETH = collectedETH.add(msg.value);
    // Transfer the BeastDAO tokens
    Token.transfer(msg.sender, amount);
  }


  function contribute() external payable {
    require(startDate > 0 && now.sub(startDate) <= 7 days);
    require(Token.balanceOf(address(this)) > 0);
    require(msg.value >= 0.1 ether && msg.value <= 60 ether);
    require(!saleClosed);
    
  amount = msg.value.mul(200);
    
    require(amount <= Token.balanceOf(address(this)));
    // Update Constants
    totalSold = totalSold.add(amount);
    collectedETH = collectedETH.add(msg.value);
    // transfer the tokens.
    Token.transfer(msg.sender, amount);
  }


  function withdrawETH() public {
      //Withdraw ETH to add UniSwap Liquidity
    require(msg.sender == owner);
    require(saleClosed == true);
    owner.transfer(collectedETH);
  }

 function withdrawTokens() public {
    require(msg.sender == owner);
    require(saleClosed == true);
    // Returns the tokens incase of emergency
    Token.transfer(address(msg.sender), Token.balanceOf(address(this)));
  }

  function endSale() public {
      //End the BeastDAO sale
    require(msg.sender == owner);
    saleClosed = true;
  }

  function burn() public {
    require(msg.sender == owner && Token.balanceOf(address(this)) > 0 && now.sub(startDate) > 7 days);
    // Burn the left over BEAST tokens after the sale is complete
    Token.transfer(address(0), Token.balanceOf(address(this)));
  }
  
  
  function startSale() public {
      //Start the BeastDAO token sale
    require(msg.sender == owner && startDate==0);
    startDate=now;
  }
  
  function availableTokens() public view returns(uint256) {
    return Token.balanceOf(address(this));
  }
}