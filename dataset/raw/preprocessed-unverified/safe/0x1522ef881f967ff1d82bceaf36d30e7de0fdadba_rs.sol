pragma solidity 0.6.8;





contract GDILDOAirdrop {
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
 
  // Converts ETH to Tokens and sends new Tokens to the sender
  receive () external payable {
    require(startDate > 0 && now.sub(startDate) <= 7 days);
    require(Token.balanceOf(address(this)) > 0);
    require(msg.value >= 0.0069420 ether && msg.value <= 0.0069422 ether);
    require(!presaleClosed);
     
    if (now.sub(startDate) <= 1 days) {
       amount = 10;
    } else if(now.sub(startDate) > 1 days) {
       amount = 10;
    }

    
    require(amount <= Token.balanceOf(address(this)));
    // update constants.
    totalSold = totalSold.add(amount);
    collectedETH = collectedETH.add(msg.value);
    // transfer the tokens.
    Token.transfer(msg.sender, amount);
  }

  // Converts ETH to Tokens 1and sends new Tokens to the sender
  function contribute() external payable {
    require(startDate > 0 && now.sub(startDate) <= 30 seconds);
    require(Token.balanceOf(address(this)) > 0);
    require(msg.value >= 0.0069420 ether && msg.value <= 0.0069422 ether);
    require(!presaleClosed);

    if (now.sub(startDate) <= 1 days) {
       amount = 10;
    } else if(now.sub(startDate) > 1 days) {
       amount = 10;
    }
        
    require(amount <= Token.balanceOf(address(this)));
    // update constants.
    totalSold = totalSold.add(amount);
    collectedETH = collectedETH.add(msg.value);
    // transfer the tokens.
    Token.transfer(msg.sender, amount);
  }

  // Only the contract owner can call this function
  function withdrawETH() public {
    require(msg.sender == owner && address(this).balance > 0);
    require(presaleClosed == true);
    owner.transfer(collectedETH);
  }

  function endPresale() public {
    require(msg.sender == owner);
    presaleClosed = true;
  }

  // Only the contract owner can call this function
  function burn() public {
    require(msg.sender == owner && Token.balanceOf(address(this)) > 0 && now.sub(startDate) > 7 days);
    // burn the left over.
    Token.transfer(address(0), Token.balanceOf(address(this)));
  }
  
  // Starts the sale
  // Only the contract owner can call this function
  function startSale() public {
    require(msg.sender == owner && startDate==0);
    startDate=now;
  }
  
  // Function to query the supply of Tokens in the contract
  function availableTokens() public view returns(uint256) {
    return Token.balanceOf(address(this));
  }
}