/**

 *Submitted for verification at Etherscan.io on 2018-09-26

*/



// GYM Ledger Token Sale Contract - Project website: www.gymledger.com



// GYM Reward, LLC



pragma solidity ^0.4.25;















contract LGRSale is Ownable {

  using SafeMath for uint256;



  address public walletAddress;

  TokenContract public tkn;

  uint256[3] public pricePerToken = [1400 szabo, 1500 szabo, 2000 szabo];

  uint256[3] public levelEndDate = [1539648000, 1541030400, 1546300740];

  uint256 public startDate = 1538352000;

  uint8 public currentLevel;

  uint256 public tokensSold;



  constructor() public {

    currentLevel = 0;

    tokensSold = 0;

    walletAddress = 0xE38cc3F48b4F98Cb3577aC75bB96DBBc87bc57d6;

    tkn = TokenContract(0x7172433857c83A68F6Dc98EdE4391c49785feD0B);

  }



  function() public payable {

    

    if (levelEndDate[currentLevel] < now) {

      currentLevel += 1;

      if (currentLevel > 2) {

        msg.sender.transfer(msg.value);

      } else {

        executeSell();

      }

    } else {

      executeSell();

    }

  }

  

  function executeSell() private {

    uint256 tokensToSell;

    require(msg.value >= pricePerToken[currentLevel], "Minimum amount is 1 token");

    tokensToSell = msg.value.div(pricePerToken[currentLevel]);

    tkn.mintTo(msg.sender, tokensToSell);

    tokensSold = tokensSold.add(tokensToSell);

    walletAddress.transfer(msg.value);

  }



  function killContract(bool _kill) public onlyOwner {

    if (_kill == true) {

      selfdestruct(owner);

    }

  }



  function setWallet(address _wallet) public onlyOwner {

    walletAddress = _wallet;

  }



  function setLevelEndDate(uint256 _level, uint256 _date) public onlyOwner {

    levelEndDate[_level] = _date;

  }



}