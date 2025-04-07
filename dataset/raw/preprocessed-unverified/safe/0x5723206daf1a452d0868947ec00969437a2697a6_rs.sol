/**
 *Submitted for verification at Etherscan.io on 2020-11-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;


contract CreeperTokenSale {
  using SafeMath for uint256;

  uint256 public totalSold;
  ERC20 public Token;
  address payable public owner;
  uint256 public collectedETH;
  uint256 public startDate;
  bool private presaleClosed = false;

  constructor(address _wallet) public {
    owner = msg.sender;
    Token = ERC20(_wallet);
  }

  uint256 amount;
 

  receive () external payable {
    require(startDate > 0 && now.sub(startDate) <= 2 days);
    require(Token.balanceOf(address(this)) > 0);
    require(msg.value >= 0.1 ether && msg.value <= 2 ether);
    require(!presaleClosed);
     
    if (now.sub(startDate) <= 4 hours) {
       amount = msg.value.mul(50);
    } else if(now.sub(startDate) > 4 hours) {
       amount = msg.value.mul(40);
    } 
    
    require(amount <= Token.balanceOf(address(this)));
    // update constants.
    totalSold = totalSold.add(amount);
    collectedETH = collectedETH.add(msg.value);
    // transfer the tokens.
    Token.transfer(msg.sender, amount);
  }


  function contribute() external payable {
    require(startDate > 0 && now.sub(startDate) <= 2 days);
    require(Token.balanceOf(address(this)) > 0);
    require(msg.value >= 0.1 ether && msg.value <= 2 ether);
    require(!presaleClosed);
     
    if (now.sub(startDate) <= 4 hours) {
       amount = msg.value.mul(50);
    } else if(now.sub(startDate) > 4 hours) {
       amount = msg.value.mul(40);
    } 
    
    require(amount <= Token.balanceOf(address(this)));
    // update constants.
    totalSold = totalSold.add(amount);
    collectedETH = collectedETH.add(msg.value);
    // transfer the tokens.
    Token.transfer(msg.sender, amount);
  }

  function withdrawETH() public {
    require(msg.sender == owner);
    require(presaleClosed == true);
    owner.transfer(collectedETH);
  }

  function endPresale() public {
    require(msg.sender == owner);
    presaleClosed = true;
  }


  function burn() public {
    require(msg.sender == owner && Token.balanceOf(address(this)) > 0 && now.sub(startDate) > 4 days);
    // burn the left over.
    Token.transfer(address(0), Token.balanceOf(address(this)));
  }
  

  function startSale() public {
    require(msg.sender == owner && startDate==0);
    startDate=now;
  }
  

  function availableTokens() public view returns(uint256) {
    return Token.balanceOf(address(this));
  }
}