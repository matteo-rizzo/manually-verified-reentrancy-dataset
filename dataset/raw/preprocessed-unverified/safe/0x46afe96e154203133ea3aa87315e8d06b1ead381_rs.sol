/**

 *Submitted for verification at Etherscan.io on 2019-03-03

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





// File: openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol



/**

 * @title Helps contracts guard against reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>

 * @dev If you mark a function `nonReentrant`, you should also

 * mark it `external`.

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



// File: openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol



/**

 * @title Crowdsale

 * @dev Crowdsale is a base contract for managing a token crowdsale,

 * allowing investors to purchase tokens with ether. This contract implements

 * such functionality in its most fundamental form and can be extended to provide additional

 * functionality and/or custom behavior.

 * The external interface represents the basic interface for purchasing tokens, and conform

 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.

 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override

 * the methods to add functionality. Consider using 'super' where appropriate to concatenate

 * behavior.

 */

contract Crowdsale is ReentrancyGuard {

  using SafeMath for uint256;

  using SafeERC20 for IERC20;



  // The token being sold

  IERC20 private _token;



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

  constructor(uint256 rate, address wallet, IERC20 token) internal {

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

  function token() public view returns(IERC20) {

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



// File: openzeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol



/**

 * @title TimedCrowdsale

 * @dev Crowdsale accepting contributions only within a time frame.

 */

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



// File: openzeppelin-solidity/contracts/crowdsale/distribution/PostDeliveryCrowdsale.sol



/**

 * @title PostDeliveryCrowdsale

 * @dev Crowdsale that locks tokens from withdrawal until it ends.

 */

contract PostDeliveryCrowdsale is TimedCrowdsale {

  using SafeMath for uint256;



  mapping(address => uint256) private _balances;



  constructor() internal {}



  /**

   * @dev Withdraw tokens only after crowdsale ends.

   * @param beneficiary Whose tokens will be withdrawn.

   */

  function withdrawTokens(address beneficiary) public {

    require(hasClosed());

    uint256 amount = _balances[beneficiary];

    require(amount > 0);

    _balances[beneficiary] = 0;

    _deliverTokens(beneficiary, amount);

  }



  /**

   * @return the balance of an account.

   */

  function balanceOf(address account) public view returns(uint256) {

    return _balances[account];

  }



  /**

   * @dev Overrides parent by storing balances instead of issuing tokens right away.

   * @param beneficiary Token purchaser

   * @param tokenAmount Amount of tokens purchased

   */

  function _processPurchase(

    address beneficiary,

    uint256 tokenAmount

  )

    internal

  {

    _balances[beneficiary] = _balances[beneficiary].add(tokenAmount);

  }



}



// File: openzeppelin-solidity/contracts/crowdsale/price/IncreasingPriceCrowdsale.sol



/**

 * @title IncreasingPriceCrowdsale

 * @dev Extension of Crowdsale contract that increases the price of tokens linearly in time.

 * Note that what should be provided to the constructor is the initial and final _rates_, that is,

 * the amount of tokens per wei contributed. Thus, the initial rate must be greater than the final rate.

 */

contract IncreasingPriceCrowdsale is TimedCrowdsale {

  using SafeMath for uint256;



  uint256 private _initialRate;

  uint256 private _finalRate;



  /**

   * @dev Constructor, takes initial and final rates of tokens received per wei contributed.

   * @param initialRate Number of tokens a buyer gets per wei at the start of the crowdsale

   * @param finalRate Number of tokens a buyer gets per wei at the end of the crowdsale

   */

  constructor(uint256 initialRate, uint256 finalRate) internal {

    require(finalRate > 0);

    require(initialRate > finalRate);

    _initialRate = initialRate;

    _finalRate = finalRate;

  }



  /**

   * The base rate function is overridden to revert, since this crowdsale doens't use it, and

   * all calls to it are a mistake.

   */

  function rate() public view returns(uint256) {

    revert();

  }



  /**

   * @return the initial rate of the crowdsale.

   */

  function initialRate() public view returns(uint256) {

    return _initialRate;

  }



  /**

   * @return the final rate of the crowdsale.

   */

  function finalRate() public view returns (uint256) {

    return _finalRate;

  }



  /**

   * @dev Returns the rate of tokens per wei at the present time.

   * Note that, as price _increases_ with time, the rate _decreases_.

   * @return The number of tokens a buyer gets per wei at a given time

   */

  function getCurrentRate() public view returns (uint256) {

    if (!isOpen()) {

      return 0;

    }



    // solium-disable-next-line security/no-block-members

    uint256 elapsedTime = block.timestamp.sub(openingTime());

    uint256 timeRange = closingTime().sub(openingTime());

    uint256 rateRange = _initialRate.sub(_finalRate);

    return _initialRate.sub(elapsedTime.mul(rateRange).div(timeRange));

  }



  /**

   * @dev Overrides parent method taking into account variable rate.

   * @param weiAmount The value in wei to be converted into tokens

   * @return The number of tokens _weiAmount wei will buy at present time

   */

  function _getTokenAmount(uint256 weiAmount)

    internal view returns (uint256)

  {

    uint256 currentRate = getCurrentRate();

    return currentRate.mul(weiAmount);

  }



}



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/ICO1.sol



/**

 * @title IncreasingPriceCrowdsale

 * @dev Extension of Crowdsale contract that increases the price of tokens linearly in time.

 * Note that what should be provided to the constructor is the initial and final _rates_, that is,

 * the amount of tokens per wei contributed. Thus, the initial rate must be greater than the final rate.

 */

contract ICO1 is IncreasingPriceCrowdsale, PostDeliveryCrowdsale, Ownable  {

  IERC20 private _token;

  uint256 private _weiRaised;

  uint256 private _tokenSold;



  constructor(address wallet, IERC20 token, uint8 daysAfter, uint256 openingRate, uint256 closingRate)

  Crowdsale(openingRate, wallet, token)

  TimedCrowdsale(now, now + daysAfter * 1 days)

  IncreasingPriceCrowdsale(openingRate, closingRate)

  public {

    _token = IERC20(token);

  }



  function buyTokens(address beneficiary) public nonReentrant payable {

    uint256 weiAmount = msg.value;

    uint256 maxWeiAmount = _getMaxWeiAmount();

    require(maxWeiAmount > 0);

    if (weiAmount >= maxWeiAmount) {

      weiAmount = maxWeiAmount;

    }

    _preValidatePurchase(beneficiary, weiAmount);



    // calculate token amount to be created

    uint256 tokens = _getTokenAmount(weiAmount);



    // update state

    _weiRaised = _weiRaised.add(weiAmount);

    _tokenSold = _tokenSold.add(tokens);



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



  function _getTokenAmount(uint256 weiAmount)

    internal view returns (uint256)

  {

    uint256 currentRate = getCurrentRate();

    return currentRate.mul(weiAmount).div(10**13);

  }



  function _getMaxWeiAmount()

    internal view returns (uint256)

  {

    uint256 currentRate = getCurrentRate();

    uint256 icoBalance = _token.balanceOf(address(this));

    uint256 availableBalance = icoBalance - _tokenSold;

    return availableBalance.mul(10**13).div(currentRate);

  }



  function recoverToken(address _tokenAddress) public onlyOwner {

    IERC20 token = IERC20(_tokenAddress);

    uint balance = token.balanceOf(this);

    token.transfer(msg.sender, balance);

  }



  function tokenSold()

    public view returns (uint256)

  {

    return _tokenSold;

  }

}