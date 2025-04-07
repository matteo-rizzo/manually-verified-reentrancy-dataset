/**

 *Submitted for verification at Etherscan.io on 2018-12-19

*/



pragma solidity ^0.4.24; 





 /**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */













contract ReentrancyGuard {



  /// @dev counter to allow mutex lock with only one SSTORE operation

  uint256 private _guardCounter;



  constructor() internal {

    // The counter starts at one to prevent changing it from zero to a non-zero

    // value, which is a more expensive operation.

    _guardCounter = 1;

  }



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * Calling a `nonReentrant` function from another `nonReentrant`

   * function is not supported. It is possible to prevent this from happening

   * by making the `nonReentrant` function external, and make it call a

   * `private` function that does the actual work.

   */

  modifier nonReentrant() {

    _guardCounter += 1;

    uint256 localCounter = _guardCounter;

    _;

    require(localCounter == _guardCounter);

  }



}



contract Crowdsale is ReentrancyGuard {

  using SafeMath for uint256;

  using SafeERC20 for IToken;



  // The token being sold

  IToken private _token;



  // Address where funds are collected

  address private _wallet;



  // How many token units a buyer gets per wei.

  // The rate is the conversion between wei and the smallest and indivisible token unit.

  // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK

  // 1 wei will give you 1 unit, or 0.001 TOK.

  uint256 private _rate;



  // Amount of wei raised

  uint256 private _weiRaised;



  /**

   * Event for token purchase logging

   * @param purchaser who paid for the tokens

   * @param beneficiary who got the tokens

   * @param value weis paid for purchase

   * @param amount amount of tokens purchased

   */

  event TokensPurchased(

    address indexed purchaser,

    address indexed beneficiary,

    uint256 value,

    uint256 amount

  );



  /**

   * @param rate Number of token units a buyer gets per wei

   * @dev The rate is the conversion between wei and the smallest and indivisible

   * token unit. So, if you are using a rate of 1 with a ERC20Detailed token

   * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.

   * @param wallet Address where collected funds will be forwarded to

   * @param token Address of the token being sold

   */

  constructor(uint256 rate, address wallet, IToken token) internal {

    require(rate > 0);

    require(wallet != address(0));

    require(token != address(0));



    _rate = rate;

    _wallet = wallet;

    _token = token;

  }



  // -----------------------------------------

  // Crowdsale external interface

  // -----------------------------------------



  /**

   * @dev fallback function ***DO NOT OVERRIDE***

   * Note that other contracts will transfer fund with a base gas stipend

   * of 2300, which is not enough to call buyTokens. Consider calling

   * buyTokens directly when purchasing tokens from a contract.

   */

  function () external payable {

    buyTokens(msg.sender);

  }



  /**

   * @return the token being sold.

   */

  function token() public view returns(IToken) {

    return _token;

  }



  /**

   * @return the address where funds are collected.

   */

  function wallet() public view returns(address) {

    return _wallet;

  }



  /**

   * @return the number of token units a buyer gets per wei.

   */

  function rate() public view returns(uint256) {

    return _rate;

  }



  /**

   * @return the amount of wei raised.

   */

  function weiRaised() public view returns (uint256) {

    return _weiRaised;

  }



  /**

   * @dev low level token purchase ***DO NOT OVERRIDE***

   * This function has a non-reentrancy guard, so it shouldn't be called by

   * another `nonReentrant` function.

   * @param beneficiary Recipient of the token purchase

   */

  function buyTokens(address beneficiary) public nonReentrant payable {



    uint256 weiAmount = msg.value;

    _preValidatePurchase(beneficiary, weiAmount);



    // calculate token amount to be created

    uint256 tokens = _getTokenAmount(weiAmount);



    // update state

    _weiRaised = _weiRaised.add(weiAmount);



    _processPurchase(beneficiary, tokens);

    emit TokensPurchased(

      msg.sender,

      beneficiary,

      weiAmount,

      tokens

    );



    _updatePurchasingState(beneficiary, weiAmount);



    _forwardFunds();

    _postValidatePurchase(beneficiary, weiAmount);

  }



  // -----------------------------------------

  // Internal interface (extensible)

  // -----------------------------------------



  /**

   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.

   * Example from CappedCrowdsale.sol's _preValidatePurchase method:

   *   super._preValidatePurchase(beneficiary, weiAmount);

   *   require(weiRaised().add(weiAmount) <= cap);

   * @param beneficiary Address performing the token purchase

   * @param weiAmount Value in wei involved in the purchase

   */

  function _preValidatePurchase(

    address beneficiary,

    uint256 weiAmount

  )

    internal

    view

  {

    require(beneficiary != address(0));

    require(weiAmount != 0);

  }



  /**

   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.

   * @param beneficiary Address performing the token purchase

   * @param weiAmount Value in wei involved in the purchase

   */

  function _postValidatePurchase(

    address beneficiary,

    uint256 weiAmount

  )

    internal

    view

  {

    // optional override

  }



  /**

   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.

   * @param beneficiary Address performing the token purchase

   * @param tokenAmount Number of tokens to be emitted

   */

  function _deliverTokens(

    address beneficiary,

    uint256 tokenAmount

  )

    internal

  {

    _token.safeTransfer(beneficiary, tokenAmount);

  }



  /**

   * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send tokens.

   * @param beneficiary Address receiving the tokens

   * @param tokenAmount Number of tokens to be purchased

   */

  function _processPurchase(

    address beneficiary,

    uint256 tokenAmount

  )

    internal

  {

    _deliverTokens(beneficiary, tokenAmount);

  }



  /**

   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)

   * @param beneficiary Address receiving the tokens

   * @param weiAmount Value in wei involved in the purchase

   */

  function _updatePurchasingState(

    address beneficiary,

    uint256 weiAmount

  )

    internal

  {

    // optional override

  }



  /**

   * @dev Override to extend the way in which ether is converted to tokens.

   * @param weiAmount Value in wei to be converted into tokens

   * @return Number of tokens that can be purchased with the specified _weiAmount

   */

  function _getTokenAmount(uint256 weiAmount)

    internal view returns (uint256)

  {

    return weiAmount.mul(_rate);

  }



  /**

   * @dev Determines how ETH is stored/forwarded on purchases.

   */

  function _forwardFunds() internal {

    _wallet.transfer(msg.value);

  }

}



contract CappedCrowdsale is Crowdsale {

  using SafeMath for uint256;



  uint256 private _cap;



  /**

   * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.

   * @param cap Max amount of wei to be contributed

   */

  constructor(uint256 cap) internal {

    require(cap > 0);

    _cap = cap;

  }



  /**

   * @return the cap of the crowdsale.

   */

  function cap() public view returns(uint256) {

    return _cap;

  }



  /**

   * @dev Checks whether the cap has been reached.

   * @return Whether the cap was reached

   */

  function capReached() public view returns (bool) {

    return weiRaised() >= _cap;

  }



  /**

   * @dev Extend parent behavior requiring purchase to respect the funding cap.

   * @param beneficiary Token purchaser

   * @param weiAmount Amount of wei contributed

   */

  function _preValidatePurchase(

    address beneficiary,

    uint256 weiAmount

  )

    internal

    view

  {

    super._preValidatePurchase(beneficiary, weiAmount);

    require(weiRaised().add(weiAmount) <= _cap);

  }



}



contract TimedCrowdsale is Crowdsale {

  using SafeMath for uint256;



  uint256 private _openingTime;

  uint256 private _closingTime;



  /**

   * @dev Reverts if not in crowdsale time range.

   */

  modifier onlyWhileOpen {

    require(isOpen());

    _;

  }



  /**

   * @dev Constructor, takes crowdsale opening and closing times.

   * @param openingTime Crowdsale opening time

   * @param closingTime Crowdsale closing time

   */

  constructor(uint256 openingTime, uint256 closingTime) internal {

    // solium-disable-next-line security/no-block-members

    require(openingTime >= block.timestamp);

    require(closingTime > openingTime);



    _openingTime = openingTime;

    _closingTime = closingTime;

  }



  /**

   * @return the crowdsale opening time.

   */

  function openingTime() public view returns(uint256) {

    return _openingTime;

  }



  /**

   * @return the crowdsale closing time.

   */

  function closingTime() public view returns(uint256) {

    return _closingTime;

  }



  /**

   * @return true if the crowdsale is open, false otherwise.

   */

  function isOpen() public view returns (bool) {

    // solium-disable-next-line security/no-block-members

    return block.timestamp >= _openingTime && block.timestamp <= _closingTime;

  }



  /**

   * @dev Checks whether the period in which the crowdsale is open has already elapsed.

   * @return Whether crowdsale period has elapsed

   */

  function hasClosed() public view returns (bool) {

    // solium-disable-next-line security/no-block-members

    return block.timestamp > _closingTime;

  }



  /**

   * @dev Extend parent behavior requiring to be within contributing period

   * @param beneficiary Token purchaser

   * @param weiAmount Amount of wei contributed

   */

  function _preValidatePurchase(

    address beneficiary,

    uint256 weiAmount

  )

    internal

    onlyWhileOpen

    view

  {

    super._preValidatePurchase(beneficiary, weiAmount);

  }



}



contract MintedCrowdsale is Crowdsale {

  constructor() internal {}



  /**

   * @dev Overrides delivery by minting tokens upon purchase.

   * @param beneficiary Token purchaser

   * @param tokenAmount Number of tokens to be minted

   */

  function _deliverTokens(

    address beneficiary,

    uint256 tokenAmount

  )

    internal

  {

    require(token().mint(beneficiary, tokenAmount));

  }

}



contract SharesCrowdsale is Crowdsale {

  address[] public wallets;



  constructor(

    address[] _wallets

  ) internal {

    wallets = _wallets;

  }



  /**

   * @dev Reverts if payment amount is less than limit.

   */

  modifier canBuyOneToken() {

    uint256 calculatedRate = rate() + increaseRateValue - decreaseRateValue;

    uint256 priceOfTokenInWei = 1 ether / calculatedRate;

    require(msg.value >= priceOfTokenInWei);

    _;

  }



  event IncreaseRate(

    uint256 change,

    uint256 rate

  );



  event DecreaseRate(

    uint256 change,

    uint256 rate

  );



  uint256 public increaseRateValue = 0;

  uint256 public decreaseRateValue = 0;



  /**

   * @dev Call this method when price of ether increased

   * @param value Change in USD from start price

   * @return How much tokens investor will receive per 1 ether

   */

  function increaseRateBy(uint256 value)

    external returns (uint256)

  {

    require(token().isMinter(msg.sender));



    increaseRateValue = value;

    decreaseRateValue = 0;



    uint256 calculatedRate = rate() + increaseRateValue;



    emit IncreaseRate(value, calculatedRate);



    return calculatedRate;

  }



  /**

   * @dev Call this method when price of ether decreased

   * @param value Change in USD from start price

   * @return How much tokens investor will receive per 1 ether

   */

  function decreaseRateBy(uint256 value)

    external returns (uint256)

  {

    require(token().isMinter(msg.sender));



    increaseRateValue = 0;

    decreaseRateValue = value;



    uint256 calculatedRate = rate() - decreaseRateValue;



    emit DecreaseRate(value, calculatedRate);



    return calculatedRate;

  }



  /**

   * @param weiAmount Value in wei to be converted into tokens

   * @return Number of tokens that can be purchased with the specified _weiAmount

   */

  function _getTokenAmount(uint256 weiAmount)

    internal view returns (uint256)

  {

    uint256 calculatedRate = rate() + increaseRateValue - decreaseRateValue;

    uint256 tokensAmount = weiAmount.mul(calculatedRate).div(1 ether);



    uint256 charge = weiAmount.mul(calculatedRate).mod(1 ether);

    if (charge > 0) {

        tokensAmount += 1;

    }



    return tokensAmount;

  }



  /**

   * @dev Determines how ETH is stored/forwarded on purchases.

   */

  function _forwardFunds() internal {

    if (weiRaised() > 100 ether) {

        wallet().transfer(msg.value);

    } else {

        uint256 walletsNumber = wallets.length;

        uint256 amountPerWallet = msg.value.div(walletsNumber);



        for (uint256 i = 0; i < walletsNumber; i++) {

            wallets[i].transfer(amountPerWallet);

        }



        uint256 charge = msg.value.mod(walletsNumber);

        if (charge > 0) {

            wallets[0].transfer(charge);

        }

    }

  }



  function _preValidatePurchase(

    address beneficiary,

    uint256 weiAmount

  )

    internal

    canBuyOneToken()

    view

  {

    super._preValidatePurchase(beneficiary, weiAmount);

  }

}



contract Tokensale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, SharesCrowdsale {

  constructor(

    uint256 rate,

    address finalWallet,

    address token,

    uint256 cap,

    uint256 openingTime,

    uint256 closingTime,

    address[] wallets

  )

    public

    Crowdsale(rate, finalWallet, IToken(token))

    CappedCrowdsale(cap)

    TimedCrowdsale(openingTime, closingTime)

    SharesCrowdsale(wallets)

  {

  }

}