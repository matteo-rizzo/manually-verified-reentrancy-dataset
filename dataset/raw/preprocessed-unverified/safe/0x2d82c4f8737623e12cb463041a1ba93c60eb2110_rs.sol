/**

 *Submitted for verification at Etherscan.io on 2018-11-17

*/



/*

Copyright 2018 Subramanian Venkatesan, Binod Nirvan



Licensed under the Apache License, Version 2.0 (the "License");

you may not use this file except in compliance with the License.

You may obtain a copy of the License at



    http://www.apache.org/licenses/LICENSE-2.0



Unless required by applicable law or agreed to in writing, software

distributed under the License is distributed on an "AS IS" BASIS,

WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and

limitations under the License.

 */

pragma solidity ^0.4.22;









/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */



















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

 * @title Helps contracts guard against reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]tes.io>

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





/**

 * @title FinalizableCrowdsale

 * @dev Extension of Crowdsale with a one-off finalization action, where one

 * can do extra work after finishing.

 */

contract FinalizableCrowdsale is TimedCrowdsale {

  using SafeMath for uint256;



  bool private _finalized;



  event CrowdsaleFinalized();



  constructor() internal {

    _finalized = false;

  }



  /**

   * @return true if the crowdsale is finalized, false otherwise.

   */

  function finalized() public view returns (bool) {

    return _finalized;

  }



  /**

   * @dev Must be called after crowdsale ends, to do some extra finalization

   * work. Calls the contract's finalization function.

   */

  function finalize() public {

    require(!_finalized);

    require(hasClosed());



    _finalized = true;



    _finalization();

    emit CrowdsaleFinalized();

  }



  /**

   * @dev Can be overridden to add finalization logic. The overriding function

   * should call super._finalization() to ensure the chain of finalization is

   * executed entirely.

   */

  function _finalization() internal {

  }

}













/**

 * @title CappedCrowdsale

 * @dev Crowdsale with a limit for total contributions.

 */

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





/*

Copyright 2018 Binod Nirvan



Licensed under the Apache License, Version 2.0 (the "License");

you may not use this file except in compliance with the License.

You may obtain a copy of the License at



    http://www.apache.org/licenses/LICENSE-2.0



Unless required by applicable law or agreed to in writing, software

distributed under the License is distributed on an "AS IS" BASIS,

WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and

limitations under the License.

 */





/*

Copyright 2018 Binod Nirvan



Licensed under the Apache License, Version 2.0 (the "License");

you may not use this file except in compliance with the License.

You may obtain a copy of the License at



    http://www.apache.org/licenses/LICENSE-2.0



Unless required by applicable law or agreed to in writing, software

distributed under the License is distributed on an "AS IS" BASIS,

WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and

limitations under the License.

 */







/*

Copyright 2018 Binod Nirvan



Licensed under the Apache License, Version 2.0 (the "License");

you may not use this file except in compliance with the License.

You may obtain a copy of the License at



    http://www.apache.org/licenses/LICENSE-2.0



Unless required by applicable law or agreed to in writing, software

distributed under the License is distributed on an "AS IS" BASIS,

WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and

limitations under the License.

 */











/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */









///@title This contract enables to create multiple contract administrators.

contract CustomAdmin is Ownable {

  ///@notice List of administrators.

  mapping(address => bool) public admins;



  event AdminAdded(address indexed _address);

  event AdminRemoved(address indexed _address);



  ///@notice Validates if the sender is actually an administrator.

  modifier onlyAdmin() {

    require(isAdmin(msg.sender), "Access is denied.");

    _;

  }



  ///@notice Adds the specified address to the list of administrators.

  ///@param _address The address to add to the administrator list.

  function addAdmin(address _address) external onlyAdmin returns(bool) {

    require(_address != address(0), "Invalid address.");

    require(!admins[_address], "This address is already an administrator.");



    require(_address != owner(), "The owner cannot be added or removed to or from the administrator list.");



    admins[_address] = true;



    emit AdminAdded(_address);

    return true;

  }



  ///@notice Adds multiple addresses to the administrator list.

  ///@param _accounts The wallet addresses to add to the administrator list.

  function addManyAdmins(address[] _accounts) external onlyAdmin returns(bool) {

    for(uint8 i = 0; i < _accounts.length; i++) {

      address account = _accounts[i];



      ///Zero address cannot be an admin.

      ///The owner is already an admin and cannot be assigned.

      ///The address cannot be an existing admin.

      if(account != address(0) && !admins[account] && account != owner()) {

        admins[account] = true;



        emit AdminAdded(_accounts[i]);

      }

    }



    return true;

  }



  ///@notice Removes the specified address from the list of administrators.

  ///@param _address The address to remove from the administrator list.

  function removeAdmin(address _address) external onlyAdmin returns(bool) {

    require(_address != address(0), "Invalid address.");

    require(admins[_address], "This address isn't an administrator.");



    //The owner cannot be removed as admin.

    require(_address != owner(), "The owner cannot be added or removed to or from the administrator list.");



    admins[_address] = false;

    emit AdminRemoved(_address);

    return true;

  }



  ///@notice Removes multiple addresses to the administrator list.

  ///@param _accounts The wallet addresses to add to the administrator list.

  function removeManyAdmins(address[] _accounts) external onlyAdmin returns(bool) {

    for(uint8 i = 0; i < _accounts.length; i++) {

      address account = _accounts[i];



      ///Zero address can neither be added or removed from this list.

      ///The owner is the super admin and cannot be removed.

      ///The address must be an existing admin in order for it to be removed.

      if(account != address(0) && admins[account] && account != owner()) {

        admins[account] = false;



        emit AdminRemoved(_accounts[i]);

      }

    }



    return true;

  }



  ///@notice Checks if an address is an administrator.

  function isAdmin(address _address) public view returns(bool) {

    if(_address == owner()) {

      return true;

    }



    return admins[_address];

  }

}







///@title This contract enables you to create pausable mechanism to stop in case of emergency.

contract CustomPausable is CustomAdmin {

  event Paused();

  event Unpaused();



  bool public paused = false;



  ///@notice Verifies whether the contract is not paused.

  modifier whenNotPaused() {

    require(!paused, "Sorry but the contract isn't paused.");

    _;

  }



  ///@notice Verifies whether the contract is paused.

  modifier whenPaused() {

    require(paused, "Sorry but the contract is paused.");

    _;

  }



  ///@notice Pauses the contract.

  function pause() external onlyAdmin whenNotPaused {

    paused = true;

    emit Paused();

  }



  ///@notice Unpauses the contract and returns to normal state.

  function unpause() external onlyAdmin whenPaused {

    paused = false;

    emit Unpaused();

  }

}





///@title This contract enables to maintain a list of whitelisted wallets.

contract CustomWhitelist is CustomPausable {

  mapping(address => bool) public whitelist;



  event WhitelistAdded(address indexed _account);

  event WhitelistRemoved(address indexed _account);



  ///@notice Verifies if the account is whitelisted.

  modifier ifWhitelisted(address _account) {

    require(_account != address(0), "Account cannot be zero address");

    require(isWhitelisted(_account), "Account is not whitelisted");



    _;

  }



  ///@notice Adds an account to the whitelist.

  ///@param _account The wallet address to add to the whitelist.

  function addWhitelist(address _account) external whenNotPaused onlyAdmin returns(bool) {

    require(_account != address(0), "Account cannot be zero address");



    if(!whitelist[_account]) {

      whitelist[_account] = true;



      emit WhitelistAdded(_account);

    }



    return true;

  }



  ///@notice Adds multiple accounts to the whitelist.

  ///@param _accounts The wallet addresses to add to the whitelist.

  function addManyWhitelist(address[] _accounts) external whenNotPaused onlyAdmin returns(bool) {

    for(uint8 i = 0;i < _accounts.length;i++) {

      if(_accounts[i] != address(0) && !whitelist[_accounts[i]]) {

        whitelist[_accounts[i]] = true;



        emit WhitelistAdded(_accounts[i]);

      }

    }



    return true;

  }



  ///@notice Removes an account from the whitelist.

  ///@param _account The wallet address to remove from the whitelist.

  function removeWhitelist(address _account) external whenNotPaused onlyAdmin returns(bool) {

    require(_account != address(0), "Account cannot be zero address");

    if(whitelist[_account]) {

      whitelist[_account] = false;

      emit WhitelistRemoved(_account);

    }



    return true;

  }



  ///@notice Removes multiple accounts from the whitelist.

  ///@param _accounts The wallet addresses to remove from the whitelist.

  function removeManyWhitelist(address[] _accounts) external whenNotPaused onlyAdmin returns(bool) {

    for(uint8 i = 0;i < _accounts.length;i++) {

      if(_accounts[i] != address(0) && whitelist[_accounts[i]]) {

        whitelist[_accounts[i]] = false;



        emit WhitelistRemoved(_accounts[i]);

      }

    }

    

    return true;

  }



  ///@notice Checks if an address is whitelisted.

  function isWhitelisted(address _address) public view returns(bool) {

    return whitelist[_address];

  }

}







/**

 * @title TokenSale

 * @dev Crowdsale contract for KubitX

 */

contract TokenSale is CappedCrowdsale, FinalizableCrowdsale, CustomWhitelist {

  event FundsWithdrawn(address indexed _wallet, uint256 _amount);

  event BonusChanged(uint256 _newBonus, uint256 _oldBonus);

  event RateChanged(uint256 _rate, uint256 _oldRate);



  uint256 public bonus;

  uint256 public rate;



  constructor(uint256 _openingTime,

    uint256 _closingTime,

    uint256 _rate,

    address _wallet,

    IERC20 _token,

    uint256 _bonus,

    uint256 _cap)

  public 

  TimedCrowdsale(_openingTime, _closingTime) 

  CappedCrowdsale(_cap) 

  Crowdsale(_rate, _wallet, _token) {

    require(_bonus > 0, "Bonus must be greater than 0");

    bonus = _bonus;

    rate = _rate;

  }



  ///@notice This feature enables the admins to withdraw Ethers held in this contract.

  ///@param _amount Amount of Ethers in wei to withdraw.

  function withdrawFunds(uint256 _amount) external whenNotPaused onlyAdmin {

    require(_amount <= address(this).balance, "The amount should be less than the balance/");

    msg.sender.transfer(_amount);

    emit FundsWithdrawn(msg.sender, _amount);

  }



  ///@notice Withdraw the tokens remaining tokens from the contract.

  function withdrawTokens() external whenNotPaused onlyAdmin {

    IERC20 t = super.token();

    t.safeTransfer(msg.sender, t.balanceOf(this));

  }



  ///@notice Enables admins to withdraw accidentally sent ERC20 token to the contract.

  function withdrawERC20(address _token) external whenNotPaused onlyAdmin {

    IERC20 erc20 = IERC20(_token);

    uint256 balance = erc20.balanceOf(this);



    erc20.safeTransfer(msg.sender, balance);

  }



  ///@notice Changes the bonus.

  ///@param _bonus The new bonus to set.

  function changeBonus(uint256 _bonus) external whenNotPaused onlyAdmin {

    require(_bonus > 0, "Bonus must be greater than 0");

    emit BonusChanged(_bonus, bonus);

    bonus = _bonus;

  }



  ///@notice Changes the rate.

  ///@param _rate The new rate to set.

  function changeRate(uint256 _rate) external whenNotPaused onlyAdmin {

    require(_rate > 0, "Rate must be greater than 0");

    emit RateChanged(_rate, rate);

    rate = _rate;

  }



  ///@notice Checks if the crowdsale has closed.

  function hasClosed() public view returns (bool) {

    return super.hasClosed() || super.capReached();

  }



  ///@notice This is called before determining the token amount.

  ///@param _beneficiary Contributing address of ETH

  ///@param _weiAmount ETH contribution

  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) 

  internal view whenNotPaused ifWhitelisted(_beneficiary) {

    super._preValidatePurchase(_beneficiary, _weiAmount);

  }



  ///@notice Returns the number of tokens for ETH

  ///@param _weiAmount ETH contribution

  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {

    uint256 tokenAmount = _weiAmount.mul(rate);

    uint256 bonusTokens = tokenAmount.mul(bonus).div(100);

    return tokenAmount.add(bonusTokens);

  }



  ///@notice overrided to store the funds in the contract itself

  //solhint-disable-next-line

  function _forwardFunds() internal {

    //nothing to do here

  }

}