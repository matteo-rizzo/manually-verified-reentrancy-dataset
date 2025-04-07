pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



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



// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





// File: openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol



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

contract Crowdsale {

  using SafeMath for uint256;

  using SafeERC20 for ERC20;



  // The token being sold

  ERC20 public token;



  // Address where funds are collected

  address public wallet;



  // How many token units a buyer gets per wei.

  // The rate is the conversion between wei and the smallest and indivisible token unit.

  // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK

  // 1 wei will give you 1 unit, or 0.001 TOK.

  uint256 public rate;



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

   * @param _rate Number of token units a buyer gets per wei

   * @param _wallet Address where collected funds will be forwarded to

   * @param _token Address of the token being sold

   */

  constructor(uint256 _rate, address _wallet, ERC20 _token) public {

    require(_rate > 0);

    require(_wallet != address(0));

    require(_token != address(0));



    rate = _rate;

    wallet = _wallet;

    token = _token;

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

   * @dev low level token purchase ***DO NOT OVERRIDE***

   * @param _beneficiary Address performing the token purchase

   */

  function buyTokens(address _beneficiary) public payable {



    uint256 weiAmount = msg.value;

    _preValidatePurchase(_beneficiary, weiAmount);



    // calculate token amount to be created

    uint256 tokens = _getTokenAmount(weiAmount);



    // update state

    weiRaised = weiRaised.add(weiAmount);



    _processPurchase(_beneficiary, tokens);

    emit TokenPurchase(

      msg.sender,

      _beneficiary,

      weiAmount,

      tokens

    );



    _updatePurchasingState(_beneficiary, weiAmount);



    _forwardFunds();

    _postValidatePurchase(_beneficiary, weiAmount);

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

   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.

   * @param _beneficiary Address performing the token purchase

   * @param _weiAmount Value in wei involved in the purchase

   */

  function _postValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

  {

    // optional override

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

    token.safeTransfer(_beneficiary, _tokenAmount);

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

   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)

   * @param _beneficiary Address receiving the tokens

   * @param _weiAmount Value in wei involved in the purchase

   */

  function _updatePurchasingState(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

  {

    // optional override

  }



  /**

   * @dev Override to extend the way in which ether is converted to tokens.

   * @param _weiAmount Value in wei to be converted into tokens

   * @return Number of tokens that can be purchased with the specified _weiAmount

   */

  function _getTokenAmount(uint256 _weiAmount)

    internal view returns (uint256)

  {

    return _weiAmount.mul(rate);

  }



  /**

   * @dev Determines how ETH is stored/forwarded on purchases.

   */

  function _forwardFunds() internal {

    wallet.transfer(msg.value);

  }

}



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: openzeppelin-solidity/contracts/ownership/rbac/Roles.sol



/**

 * @title Roles

 * @author Francisco Giordano (@frangio)

 * @dev Library for managing addresses assigned to a Role.

 * See RBAC.sol for example usage.

 */





// File: openzeppelin-solidity/contracts/ownership/rbac/RBAC.sol



/**

 * @title RBAC (Role-Based Access Control)

 * @author Matt Condon (@Shrugs)

 * @dev Stores and provides setters and getters for roles and addresses.

 * Supports unlimited numbers of roles and addresses.

 * See //contracts/mocks/RBACMock.sol for an example of usage.

 * This RBAC method uses strings to key roles. It may be beneficial

 * for you to write your own implementation of this interface using Enums or similar.

 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,

 * to avoid typos.

 */

contract RBAC {

  using Roles for Roles.Role;



  mapping (string => Roles.Role) private roles;



  event RoleAdded(address indexed operator, string role);

  event RoleRemoved(address indexed operator, string role);



  /**

   * @dev reverts if addr does not have role

   * @param _operator address

   * @param _role the name of the role

   * // reverts

   */

  function checkRole(address _operator, string _role)

    view

    public

  {

    roles[_role].check(_operator);

  }



  /**

   * @dev determine if addr has role

   * @param _operator address

   * @param _role the name of the role

   * @return bool

   */

  function hasRole(address _operator, string _role)

    view

    public

    returns (bool)

  {

    return roles[_role].has(_operator);

  }



  /**

   * @dev add a role to an address

   * @param _operator address

   * @param _role the name of the role

   */

  function addRole(address _operator, string _role)

    internal

  {

    roles[_role].add(_operator);

    emit RoleAdded(_operator, _role);

  }



  /**

   * @dev remove a role from an address

   * @param _operator address

   * @param _role the name of the role

   */

  function removeRole(address _operator, string _role)

    internal

  {

    roles[_role].remove(_operator);

    emit RoleRemoved(_operator, _role);

  }



  /**

   * @dev modifier to scope access to a single role (uses msg.sender as addr)

   * @param _role the name of the role

   * // reverts

   */

  modifier onlyRole(string _role)

  {

    checkRole(msg.sender, _role);

    _;

  }



  /**

   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)

   * @param _roles the names of the roles to scope access to

   * // reverts

   *

   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this

   *  see: https://github.com/ethereum/solidity/issues/2467

   */

  // modifier onlyRoles(string[] _roles) {

  //     bool hasAnyRole = false;

  //     for (uint8 i = 0; i < _roles.length; i++) {

  //         if (hasRole(msg.sender, _roles[i])) {

  //             hasAnyRole = true;

  //             break;

  //         }

  //     }



  //     require(hasAnyRole);



  //     _;

  // }

}



// File: openzeppelin-solidity/contracts/access/Whitelist.sol



/**

 * @title Whitelist

 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.

 * This simplifies the implementation of "user permissions".

 */

contract Whitelist is Ownable, RBAC {

  string public constant ROLE_WHITELISTED = "whitelist";



  /**

   * @dev Throws if operator is not whitelisted.

   * @param _operator address

   */

  modifier onlyIfWhitelisted(address _operator) {

    checkRole(_operator, ROLE_WHITELISTED);

    _;

  }



  /**

   * @dev add an address to the whitelist

   * @param _operator address

   * @return true if the address was added to the whitelist, false if the address was already in the whitelist

   */

  function addAddressToWhitelist(address _operator)

    onlyOwner

    public

  {

    addRole(_operator, ROLE_WHITELISTED);

  }



  /**

   * @dev getter to determine if address is in whitelist

   */

  function whitelist(address _operator)

    public

    view

    returns (bool)

  {

    return hasRole(_operator, ROLE_WHITELISTED);

  }



  /**

   * @dev add addresses to the whitelist

   * @param _operators addresses

   * @return true if at least one address was added to the whitelist,

   * false if all addresses were already in the whitelist

   */

  function addAddressesToWhitelist(address[] _operators)

    onlyOwner

    public

  {

    for (uint256 i = 0; i < _operators.length; i++) {

      addAddressToWhitelist(_operators[i]);

    }

  }



  /**

   * @dev remove an address from the whitelist

   * @param _operator address

   * @return true if the address was removed from the whitelist,

   * false if the address wasn't in the whitelist in the first place

   */

  function removeAddressFromWhitelist(address _operator)

    onlyOwner

    public

  {

    removeRole(_operator, ROLE_WHITELISTED);

  }



  /**

   * @dev remove addresses from the whitelist

   * @param _operators addresses

   * @return true if at least one address was removed from the whitelist,

   * false if all addresses weren't in the whitelist in the first place

   */

  function removeAddressesFromWhitelist(address[] _operators)

    onlyOwner

    public

  {

    for (uint256 i = 0; i < _operators.length; i++) {

      removeAddressFromWhitelist(_operators[i]);

    }

  }



}



// File: openzeppelin-solidity/contracts/crowdsale/validation/WhitelistedCrowdsale.sol



/**

 * @title WhitelistedCrowdsale

 * @dev Crowdsale in which only whitelisted users can contribute.

 */

contract WhitelistedCrowdsale is Whitelist, Crowdsale {

  /**

   * @dev Extend parent behavior requiring beneficiary to be in whitelist.

   * @param _beneficiary Token beneficiary

   * @param _weiAmount Amount of wei contributed

   */

  function _preValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    onlyIfWhitelisted(_beneficiary)

    internal

  {

    super._preValidatePurchase(_beneficiary, _weiAmount);

  }



}



// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

  event Pause();

  event Unpause();



  bool public paused = false;





  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() onlyOwner whenNotPaused public {

    paused = true;

    emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() onlyOwner whenPaused public {

    paused = false;

    emit Unpause();

  }

}



// File: contracts/WhitelistedPausableCrowdsale.sol



contract WhitelistedPausableCrowdsale is WhitelistedCrowdsale, Pausable

{



    constructor() public

    {}



    function _preValidatePurchase(

        address _beneficiary,

        uint256 _weiAmount

    )

    internal

    whenNotPaused

    {

        super._preValidatePurchase(_beneficiary, _weiAmount);

    }



}



// File: contracts/BonusCrowdsale.sol



/**

 * @dev Allows better rates for tokens, based on Ether amounts.

 * Thresholds must be in decending order.

 */

contract BonusCrowdsale is WhitelistedPausableCrowdsale

{

    uint256[] public bonuses;

    uint256[] public thresholds;



    constructor(uint256[] _thresholds, uint256[] _bonuses) public

    {

        setBonusThresholds(_thresholds, _bonuses);

    }



    function setBonusThresholds(uint256[] _thresholds, uint256[] _bonuses) onlyOwner public

    {

        require(_thresholds.length == _bonuses.length);



        thresholds = _thresholds;

        bonuses = _bonuses;

    }



    function getBonusCount() view public returns(uint256)

    {

        return bonuses.length;

    }



    /**

     * @dev Overrides parent method taking into account variable rate.

     * @param _weiAmount The value in wei to be converted into tokens

     * @return The number of tokens _weiAmount wei will buy at present time

     */

    function _getTokenAmount(uint256 _weiAmount)

    internal view returns(uint256)

    {

        for (uint i = 0; i < thresholds.length; i++)

        {

            if (_weiAmount >= thresholds[i])

            {

                return _weiAmount.mul(rate.mul(100 + bonuses[i]).div(100));

            }

        }



        return _weiAmount.mul(rate);

    }

}



// File: openzeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol



/**

 * @title CappedCrowdsale

 * @dev Crowdsale with a limit for total contributions.

 */

contract CappedCrowdsale is Crowdsale {

  using SafeMath for uint256;



  uint256 public cap;



  /**

   * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.

   * @param _cap Max amount of wei to be contributed

   */

  constructor(uint256 _cap) public {

    require(_cap > 0);

    cap = _cap;

  }



  /**

   * @dev Checks whether the cap has been reached.

   * @return Whether the cap was reached

   */

  function capReached() public view returns (bool) {

    return weiRaised >= cap;

  }



  /**

   * @dev Extend parent behavior requiring purchase to respect the funding cap.

   * @param _beneficiary Token purchaser

   * @param _weiAmount Amount of wei contributed

   */

  function _preValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

  {

    super._preValidatePurchase(_beneficiary, _weiAmount);

    require(weiRaised.add(_weiAmount) <= cap);

  }



}



// File: openzeppelin-solidity/contracts/lifecycle/TokenDestructible.sol



/**

 * @title TokenDestructible:

 * @author Remco Bloemen <[email protected]π.com>

 * @dev Base contract that can be destroyed by owner. All funds in contract including

 * listed tokens will be sent to the owner.

 */

contract TokenDestructible is Ownable {



  constructor() public payable { }



  /**

   * @notice Terminate contract and refund to owner

   * @param tokens List of addresses of ERC20 or ERC20Basic token contracts to

   refund.

   * @notice The called token contracts could try to re-enter this contract. Only

   supply token contracts you trust.

   */

  function destroy(address[] tokens) onlyOwner public {



    // Transfer tokens to owner

    for (uint256 i = 0; i < tokens.length; i++) {

      ERC20Basic token = ERC20Basic(tokens[i]);

      uint256 balance = token.balanceOf(this);

      token.transfer(owner, balance);

    }



    // Transfer Eth to owner and terminate contract

    selfdestruct(owner);

  }

}



// File: contracts/EctoCrowdsale.sol



//contract EctoCrowdsale is WhitelistedCrowdsale, CappedCrowdsale, BonusTokenSale, PausableTokenSale, TokenDestructible





//BonusTokenSale, TokenDestructible

contract EctoCrowdsale is BonusCrowdsale, CappedCrowdsale, TokenDestructible  

 {



    constructor(uint256 _cap, uint256 _rate, address _wallet, ERC20 _token, uint256[] _thresholds, uint256[] _bonuses) public



    CappedCrowdsale(_cap)

    BonusCrowdsale(_thresholds, _bonuses)

    Crowdsale(_rate, _wallet, _token)

    {

    }

}



/*

PausableTokenSale 				= Crowdsale, Pausable, Ownable

WhitelistedCrowdsale 			= Ownable, RBAC, Crowdsale



*/