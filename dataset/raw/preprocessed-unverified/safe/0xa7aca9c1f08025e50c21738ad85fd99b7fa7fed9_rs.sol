/**
 *Submitted for verification at Etherscan.io on 2020-12-18
*/

pragma solidity 0.6.8;





contract Sale {
  using SafeMath for uint256;

  uint256 public totalSold;
  ERC20 public Token;
  address payable public owner;
  uint256 public collectedETH;
  uint256 public startDate;
  uint256 public rate;
  bool public presaleClosed = false;

  constructor(address _token, uint256 _rate) public {
    owner = msg.sender;
    rate = _rate;
    Token = ERC20(_token);
  }

  uint256 amount;
 
  // Converts ETH to Tokens and sends new Tokens to the sender
  receive () external payable {
    require(startDate > 0);
    require(Token.balanceOf(address(this)) > 0);
    require(!presaleClosed);

    amount = msg.value.mul(rate);
    
    require(amount <= Token.balanceOf(address(this)));
    // update constants.
    totalSold = totalSold.add(amount);
    collectedETH = collectedETH.add(msg.value);
    // transfer the tokens.
    Token.transfer(msg.sender, amount);
  }

  // Converts ETH to Tokens 1and sends new Tokens to the sender
  function contribute() external payable {
    require(startDate > 0);
    require(Token.balanceOf(address(this)) > 0);
    require(!presaleClosed);

    amount = msg.value.mul(rate);
    
    require(amount <= Token.balanceOf(address(this)));
    // update constants.
    totalSold = totalSold.add(amount);
    collectedETH = collectedETH.add(msg.value);
    // transfer the tokens.
    Token.transfer(msg.sender, amount);
  }

  // Only the contract owner can call this function
  function withdrawETH() public {
    require(msg.sender == owner);
    require(presaleClosed == true);
    owner.transfer(collectedETH);
  }

  function endPresale() public {
    require(msg.sender == owner);
    presaleClosed = true;
  }

  // Only the contract owner can call this function
  function burn() public {
    require(msg.sender == owner && Token.balanceOf(address(this)) > 0);
    // burn the left over.
    Token.transfer(address(0), Token.balanceOf(address(this)));
  }
  
  // Only the contract owner can call this function
  function startSale() public {
    require(msg.sender == owner && startDate == 0);
    startDate = now;
  }
  
  // Function to query the supply of Tokens in the contract
  function availableTokens() public view returns(uint256) {
    return Token.balanceOf(address(this));
  }
}