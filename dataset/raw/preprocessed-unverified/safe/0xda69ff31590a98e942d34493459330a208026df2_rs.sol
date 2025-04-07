/**

 *Submitted for verification at Etherscan.io on 2018-08-31

*/



pragma solidity ^0.4.23;



/**

 * @title Helps contracts guard agains reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>

 * @notice If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {



  /**

   * @dev We use a single lock for the whole contract.

   */

  bool private reentrancyLock = false;



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * @notice If you mark a function `nonReentrant`, you should also

   * mark it `external`. Calling one nonReentrant function from

   * another is not supported. Instead, you can implement a

   * `private` function doing the actual work, and a `external`

   * wrapper marked as `nonReentrant`.

   */

  modifier nonReentrant() {

    require(!reentrancyLock);

    reentrancyLock = true;

    _;

    reentrancyLock = false;

  }



}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract PriceUpdaterInterface {

  enum Currency { ETH, BTC, WME, WMZ, WMR, WMX }



  uint public decimalPrecision = 3;



  mapping(uint => uint) public price;

}



contract CrowdsaleInterface {

  uint public rate;

  uint public minimumAmount;



  function externalBuyToken(address _beneficiary, PriceUpdaterInterface.Currency _currency, uint _amount, uint _tokens) external;

}



contract MerchantControllerInterface {

  mapping(uint => uint) public totalInvested;

  mapping(uint => bool) public paymentId;



  function calcPrice(PriceUpdaterInterface.Currency _currency, uint _tokens) public view returns(uint);

  function buyTokens(address _beneficiary, PriceUpdaterInterface.Currency _currency, uint _amount, uint _tokens, uint _paymentId) external;

}



contract MerchantController is MerchantControllerInterface, ReentrancyGuard, Ownable {

  using SafeMath for uint;



  PriceUpdaterInterface public priceUpdater;

  CrowdsaleInterface public crowdsale;



  constructor(PriceUpdaterInterface _priceUpdater, CrowdsaleInterface _crowdsale) public  {

    priceUpdater = _priceUpdater;

    crowdsale = _crowdsale;

  }



  function calcPrice(PriceUpdaterInterface.Currency _currency, uint _tokens) 

      public 

      view 

      returns(uint) 

  {

    uint priceInWei = _tokens.mul(1 ether).div(crowdsale.rate());

    if (_currency == PriceUpdaterInterface.Currency.ETH) {

      return priceInWei;

    }

    uint etherPrice = priceUpdater.price(uint(PriceUpdaterInterface.Currency.ETH));

    uint priceInEur = priceInWei.mul(etherPrice).div(1 ether);



    uint currencyPrice = priceUpdater.price(uint(_currency));

    uint tokensPrice = priceInEur.mul(currencyPrice);

    

    return tokensPrice;

  }



  function buyTokens(

    address _beneficiary,

    PriceUpdaterInterface.Currency _currency,

    uint _amount,

    uint _tokens,

    uint _paymentId)

      external

      onlyOwner

      nonReentrant

  {

    require(_beneficiary != address(0));

    require(_currency != PriceUpdaterInterface.Currency.ETH);

    require(_amount != 0);

    require(_tokens >= crowdsale.minimumAmount());

    require(_paymentId != 0);

    require(!paymentId[_paymentId]);

    paymentId[_paymentId] = true;

    crowdsale.externalBuyToken(_beneficiary, _currency, _amount, _tokens);

  }

}