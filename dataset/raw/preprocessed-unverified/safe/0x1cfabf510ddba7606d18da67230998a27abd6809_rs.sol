pragma solidity ^0.4.23;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



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

 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.

 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override

 * the methods to add functionality. Consider using 'super' where appropiate to concatenate

 * behavior.

 */

contract EmploySale is Ownable {

  using SafeMath for uint256;



  // The token being sold

  ERC20 public token;



  // Amount of wei raised

  uint256 public weiRaised;



  /**

   * Event for token purchase logging

   * @param purchaser who paid for the tokens

   * @param beneficiary who got the tokens

   * @param value weis paid for purchase

   * @param amount amount of tokens purchased

   */

  event TokenPurchase(

    address indexed purchaser,

    address indexed beneficiary,

    uint256 value,

    uint256 amount

  );



  /**

   * @param _token Address of the token being sold

   */

  constructor(ERC20 _token) public {

    token = _token;

  }



  // -----------------------------------------

  // Crowdsale external interface

  // -----------------------------------------



  /**

   * @dev low level token purchase ***DO NOT OVERRIDE***

   * @param _beneficiary Address performing the token purchase

   */

  function buyTokens(address _beneficiary, uint256 _rate, address _wallet) public payable {

    require(_wallet != address(0));

    require(_rate != 0);



    uint256 weiAmount = msg.value;

    _preValidatePurchase(_beneficiary, weiAmount);



    // calculate token amount to be created

    uint256 tokens = _getTokenAmount(weiAmount, _rate);



    // update state

    weiRaised = weiRaised.add(weiAmount);



    _processPurchase(_beneficiary, tokens);

    emit TokenPurchase(

      msg.sender,

      _beneficiary,

      weiAmount,

      tokens

    );



    _forwardFunds(_wallet);

  }



  // -----------------------------------------

  // Internal interface (extensible)

  // -----------------------------------------



  /**

   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.

   * @param _beneficiary Address performing the token purchase

   * @param _weiAmount Value in wei involved in the purchase

   */

  function _preValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

  {

    require(_beneficiary != address(0));

    require(_weiAmount != 0);

  }



  /**

   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.

   * @param _beneficiary Address performing the token purchase

   * @param _tokenAmount Number of tokens to be emitted

   */

  function _deliverTokens(

    address _beneficiary,

    uint256 _tokenAmount

  )

    internal

  {

    token.transfer(_beneficiary, _tokenAmount);

  }



  /**

   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.

   * @param _beneficiary Address receiving the tokens

   * @param _tokenAmount Number of tokens to be purchased

   */

  function _processPurchase(

    address _beneficiary,

    uint256 _tokenAmount

  )

    internal

  {

    _deliverTokens(_beneficiary, _tokenAmount);

  }





  /**

   * @dev Override to extend the way in which ether is converted to tokens.

   * @param _weiAmount Value in wei to be converted into tokens

   * @param _rate It is number of tokens transfered per ETH investment 

   * @return Number of tokens that can be purchased with the specified _weiAmount

   */

  function _getTokenAmount(uint256 _weiAmount, uint256 _rate)

    internal pure returns (uint256)

  {

    return _weiAmount.mul(_rate);

  }



  /**

   * @dev Determines how ETH is stored/forwarded on purchases.

   */

  function _forwardFunds(address _wallet) internal {

    _wallet.transfer(msg.value);

  }



  function withdrawToken() onlyOwner external returns(bool) {

    require(token.transfer(owner, token.balanceOf(address(this))));

    return true;

  }



}