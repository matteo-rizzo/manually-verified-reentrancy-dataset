// v7



/**

 * Presale.sol

 */



pragma solidity ^0.4.23;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// interface to the crowdsale contract





/**

 * @title InvestorsStorage

 * @dev InvestorStorage contract interface with newInvestment and getInvestedAmount functions which need to be implemented

 */





/**

 * @title TokenContract

 * @dev Token contract interface with transfer and balanceOf functions which need to be implemented

 */





/**

 * @title PreSale

 * @dev PreSale Contract which executes and handles presale of the tokens

 */

contract PreSale  is Ownable {

  using SafeMath for uint256;



  // variables



  TokenContract public tkn;

  CrowdSale public cSale;

  InvestorsStorage public investorsStorage;

  uint256 public levelEndDate;

  uint256 public currentLevel;

  uint256 public levelTokens = 375000;

  uint256 public tokensSold;

  uint256 public weiRised;

  uint256 public ethPrice;

  address[] public investorsList;

  bool public presalePaused;

  bool public presaleEnded;

  uint256[12] private tokenPrice = [4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48];

  uint256 private baseTokens = 375000;

  uint256 private usdCentValue;

  uint256 private minInvestment;



  /**

   * @dev Constructor of Presale contract

   */

  constructor() public {

    tkn = TokenContract(0xea674f79acf3c974085784f0b3e9549b39a5e10a);                    // address of the token contract

    investorsStorage = InvestorsStorage(0x15c7c30B980ef442d3C811A30346bF9Dd8906137);      // address of the storage contract

    minInvestment = 100 finney;

    updatePrice(5000);

  }



  /**

   * @dev Fallback payable function which executes additional checks and functionality when tokens need to be sent to the investor

   */

  function() payable public {

    require(msg.value >= minInvestment);   // check for minimum investment amount

    require(!presalePaused);

    require(!presaleEnded);

    prepareSell(msg.sender, msg.value);

  }



  /**

   * @dev Prepare sell of the tokens

   * @param _investor Investors address

   * @param _amount Amount invested

   */

  function prepareSell(address _investor, uint256 _amount) private {

    uint256 remaining;

    uint256 pricePerCent;

    uint256 pricePerToken;

    uint256 toSell;

    uint256 amount = _amount;

    uint256 sellInWei;

    address investor = _investor;



    pricePerCent = getUSDPrice();

    pricePerToken = pricePerCent.mul(tokenPrice[currentLevel]); // calculate the price for each token in the current level

    toSell = _amount.div(pricePerToken); // calculate the amount to sell



    if (toSell < levelTokens) { // if there is enough tokens left in the current level, sell from it

      levelTokens = levelTokens.sub(toSell);

      weiRised = weiRised.add(_amount);

      executeSell(investor, toSell, _amount);

      owner.transfer(_amount);

    } else { // if not, sell from 2 or more different levels

      while (amount > 0) {

        if (toSell > levelTokens) {

          toSell = levelTokens; // sell all the remaining in the level

          sellInWei = toSell.mul(pricePerToken);

          amount = amount.sub(sellInWei);

          if (currentLevel < 11) { // if is the last level, sell only the tokens left,

            currentLevel += 1;

            levelTokens = baseTokens;

          } else {

            remaining = amount;

            amount = 0;

          }

        } else {

          sellInWei = amount;

          amount = 0;

        }

        

        executeSell(investor, toSell, sellInWei); 

        weiRised = weiRised.add(sellInWei);

        owner.transfer(amount);

        if (amount > 0) {

          toSell = amount.div(pricePerToken);

        }

        if (remaining > 0) { // if there is any mount left, it means that is the the last level an there is no more tokens to sell

          investor.transfer(remaining);

          owner.transfer(address(this).balance);

          presaleEnded = true;

        }

      }

    }

  }



  /**

   * @dev Execute sell of the tokens - send investor to investors storage and transfer tokens

   * @param _investor Investors address

   * @param _tokens Amount of tokens to be sent

   * @param _weiAmount Amount invested in wei

   */

  function executeSell(address _investor, uint256 _tokens, uint256 _weiAmount) private {

    uint256 totalTokens = _tokens * (10 ** 18);

    tokensSold += _tokens; // update tokens sold

    investorsStorage.newInvestment(_investor, _weiAmount); // register the invested amount in the storage



    require(tkn.transfer(_investor, totalTokens)); // transfer the tokens to the investor

    emit NewInvestment(_investor, totalTokens);   

  }



  /**

   * @dev Getter for USD price of tokens

   */

  function getUSDPrice() private view returns (uint256) {

    return usdCentValue;

  }



  /**

   * @dev Change USD price of tokens

   * @param _ethPrice New Ether price

   */

  function updatePrice(uint256 _ethPrice) private {

    uint256 centBase = 1 * 10 ** 16;

    require(_ethPrice > 0);

    ethPrice = _ethPrice;

    usdCentValue = centBase.div(_ethPrice);

  }



  /**

   * @dev Set USD to ETH value

   * @param _ethPrice New Ether price

   */

  function setUsdEthValue(uint256 _ethPrice) onlyOwner external { // set the ETH value in USD

    updatePrice(_ethPrice);

  }



  /**

   * @dev Set the crowdsale contract address

   * @param _crowdSale Crowdsale contract address

   */

  function setCrowdSaleAddress(address _crowdSale) onlyOwner public { // set the crowdsale contract address

    cSale = CrowdSale(_crowdSale);

  }



  /**

   * @dev Set the storage contract address

   * @param _investorsStorage Investors storage contract address

   */

  function setStorageAddress(address _investorsStorage) onlyOwner public { // set the storage contract address

    investorsStorage = InvestorsStorage(_investorsStorage);

  }



  /**

   * @dev Pause the presale

   * @param _paused Paused state - true/false

   */

  function pausePresale(bool _paused) onlyOwner public { // pause the presale

    presalePaused = _paused;

  }



  /**

   * @dev Get funds

   */

  function getFunds() onlyOwner public { // request the funds

    owner.transfer(address(this).balance);

  }



  event NewInvestment(address _investor, uint256 tokens);

}