pragma solidity ^0.4.23;







contract Exchange is Ownable {
  using SafeMath for uint256;

  uint256 public buyPrice;
  uint256 public sellPrice;
  address public tokenAddress;
  uint256 private fullEther = 1 ether;


  constructor() public {
    buyPrice = 600;
    sellPrice = 400;
    tokenAddress = 0x0;
  }

  function setBuyPrice(uint256 _price) onlyOwner public {
    buyPrice = _price;
  }

  function setSellPrice(uint256 _price) onlyOwner public {
    sellPrice = _price;
  }

  function() payable public {
    sellTokens();
  }

  function sellTokens() payable public {
    TokenContract tkn = TokenContract(tokenAddress);
    uint256 tokensToSell = msg.value.mul(sellPrice);
    require(tkn.balanceOf(address(this)) >= tokensToSell);
    tkn.transfer(msg.sender, tokensToSell);
    emit SellTransaction(msg.value, tokensToSell);
  }

  function buyTokens(uint256 _amount) public {
    address seller = msg.sender;
    TokenContract tkn = TokenContract(tokenAddress);
    uint256 transactionPrice = _amount.div(buyPrice);
    require (address(this).balance >= transactionPrice);
    require (tkn.transferFrom(msg.sender, address(this), _amount));
    seller.transfer(transactionPrice);
    emit BuyTransaction(transactionPrice, _amount);
  }

  function getBalance(uint256 _amount) onlyOwner public {
    msg.sender.transfer(_amount);
  }

  function getTokens(uint256 _amount) onlyOwner public {
    TokenContract tkn = TokenContract(tokenAddress);
    tkn.transfer(msg.sender, _amount);
  }

  function killMe() onlyOwner public {
    TokenContract tkn = TokenContract(tokenAddress);
    uint256 tokensLeft = tkn.balanceOf(address(this));
    tkn.transfer(msg.sender, tokensLeft);
    msg.sender.transfer(address(this).balance);
    selfdestruct(owner);
  }

  function changeToken(address _address) onlyOwner public {
    tokenAddress = _address;
  }

  event SellTransaction(uint256 ethAmount, uint256 tokenAmount);
  event BuyTransaction(uint256 ethAmount, uint256 tokenAmount);
}