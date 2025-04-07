/**

 *Submitted for verification at Etherscan.io on 2018-12-06

*/



pragma solidity ^0.4.24;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





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

contract Crowdsale is Ownable {

  using SafeMath for uint256;

  using SafeERC20Transfer for IERC20;



  // The token being sold

  IERC20 private _token;



  // Address where funds are collected

  address private _wallet;



  // Amount of wei raised

  uint256 private _weiRaised;



  // ICO configuration

  uint256 public privateICOrate = 4081; //tokens per ether

  uint256 public preICOrate = 3278; //tokens per ether

  uint256 public ICOrate = 1785; //tokens per ether

  uint32 public privateICObonus = 30; // private ICO bonus

  uint256 public privateICObonusLimit = 20000; // private ICO bonus limit

  uint32 public preICObonus = 25; // pre ICO bonus

  uint256 public preICObonusLimit = 10000; // pre ICO bonus limit

  uint32 public ICObonus = 15; // ICO bonus

  uint256 public ICObonusLimit = 10000; // ICO bonus limit

  uint256 public startPrivateICO = 1550188800; // Private ICO start 15/02/2019 00:00:00

  uint256 public startPreICO = 1551830400; // Pre ICO start 06/03/2019 00:00:00

  uint256 public startICO = 1554595200; // ICO start 07/04/2019 00:00:00

  uint256 public endICO = 1557273599; // ICO end 07/05/2019 23:59:59



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

   * Contract constructor

   * @param wallet Address where collected funds will be forwarded to

   * @param token Address of the token being sold

   */

  constructor(address newOwner, address wallet, IERC20 token) public {

    require(wallet != address(0));

    require(token != address(0));

    require(newOwner != address(0));

    transferOwnership(newOwner);

    _wallet = wallet;

    _token = token;

  }



  // -----------------------------------------

  // Crowdsale external interface

  // -----------------------------------------



  /**

   * @dev fallback function ***DO NOT OVERRIDE***

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

   * @return the amount of wei raised.

   */

  function weiRaised() public view returns (uint256) {

    return _weiRaised;

  }



  /**

   * send tokens sold for another currencies and bounty, advisors, etc

   * @param beneficiary address of purchaser

   * @param tokenAmount tokens amount

   */

  function sendTokens(address beneficiary, uint256 tokenAmount) public onlyOwner {

    require(beneficiary != address(0));

    require(tokenAmount > 0);

    _token.safeTransfer(beneficiary, tokenAmount);

  }



  /**

   * @dev low level token purchase ***DO NOT OVERRIDE***

   * @param beneficiary Address performing the token purchase

   */

  function buyTokens(address beneficiary) public payable {

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



    _forwardFunds(weiAmount);

  }



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

    internal pure

  {

    require(beneficiary != address(0));

    require(weiAmount > 0);

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

   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.

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

   * @dev The way in which ether is converted to tokens.

   * @param weiAmount Value in wei to be converted into tokens

   * @return Number of tokens that can be purchased with the specified _weiAmount

   */

  function _getTokenAmount(

    uint256 weiAmount

  )

    internal view returns (uint256)

  {

    uint256 tokens;

    uint256 bonusTokens;

    if (now >= startPrivateICO && now < startPreICO) {

      tokens = weiAmount.mul(privateICOrate).div(1e18);

      if (tokens > privateICObonusLimit) {

        bonusTokens = tokens.mul(privateICObonus).div(100);

        tokens = tokens.add(bonusTokens);

      }

    } else if (now >= startPreICO && now < startICO) {

      tokens = weiAmount.mul(preICOrate).div(1e18);

      if (tokens > preICObonusLimit) {

        bonusTokens = tokens.mul(preICObonus).div(100);

        tokens = tokens.add(bonusTokens);

      }

    } else if (now >= startICO && now <= endICO) {

      tokens = weiAmount.mul(ICOrate).div(1e18);

      if (tokens > ICObonusLimit) {

        bonusTokens = tokens.mul(ICObonus).div(100);

        tokens = tokens.add(bonusTokens);

      }      

    } else {

      tokens = weiAmount.mul(ICOrate).div(1e18);

    }

    return tokens;

  }



  /**

   * @dev Determines how ETH is stored/forwarded on purchases.

   */

  function _forwardFunds(uint256 weiAmount_) internal {

    _wallet.transfer(weiAmount_);

  }

}