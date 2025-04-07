/**

 *Submitted for verification at Etherscan.io on 2019-04-15

*/



/**

 * Copyright (c) 2019 blockimmo AG [emailÂ protected]

 * No license

 */



pragma solidity 0.5.4;







contract PauserRole {

    using Roles for Roles.Role;



    event PauserAdded(address indexed account);

    event PauserRemoved(address indexed account);



    Roles.Role private _pausers;



    constructor () internal {

        _addPauser(msg.sender);

    }



    modifier onlyPauser() {

        require(isPauser(msg.sender));

        _;

    }



    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);

    }



    function addPauser(address account) public onlyPauser {

        _addPauser(account);

    }



    function renouncePauser() public {

        _removePauser(msg.sender);

    }



    function _addPauser(address account) internal {

        _pausers.add(account);

        emit PauserAdded(account);

    }



    function _removePauser(address account) internal {

        _pausers.remove(account);

        emit PauserRemoved(account);

    }

}



contract Pausable is PauserRole {

    event Paused(address account);

    event Unpaused(address account);



    bool private _paused;



    constructor () internal {

        _paused = false;

    }



    /**

     * @return true if the contract is paused, false otherwise.

     */

    function paused() public view returns (bool) {

        return _paused;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is not paused.

     */

    modifier whenNotPaused() {

        require(!_paused);

        _;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is paused.

     */

    modifier whenPaused() {

        require(_paused);

        _;

    }



    /**

     * @dev called by the owner to pause, triggers stopped state

     */

    function pause() public onlyPauser whenNotPaused {

        _paused = true;

        emit Paused(msg.sender);

    }



    /**

     * @dev called by the owner to unpause, returns to normal state

     */

    function unpause() public onlyPauser whenPaused {

        _paused = false;

        emit Unpaused(msg.sender);

    }

}



















contract ReentrancyGuard {

    /// @dev counter to allow mutex lock with only one SSTORE operation

    uint256 private _guardCounter;



    constructor () internal {

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

    using SafeERC20 for IERC20;



    // The token being sold

    IERC20 private _token;



    // Address where funds are collected

    address payable private _wallet;



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

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);



    /**

     * @param rate Number of token units a buyer gets per wei

     * @dev The rate is the conversion between wei and the smallest and indivisible

     * token unit. So, if you are using a rate of 1 with a ERC20Detailed token

     * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.

     * @param wallet Address where collected funds will be forwarded to

     * @param token Address of the token being sold

     */

    constructor (uint256 rate, address payable wallet, IERC20 token) public {

        require(rate > 0);

        require(wallet != address(0));

        require(address(token) != address(0));



        _rate = rate;

        _wallet = wallet;

        _token = token;

    }



    /**

     * @dev fallback function ***DO NOT OVERRIDE***

     * Note that other contracts will transfer funds with a base gas stipend

     * of 2300, which is not enough to call buyTokens. Consider calling

     * buyTokens directly when purchasing tokens from a contract.

     */

    function () external payable {

        buyTokens(msg.sender);

    }



    /**

     * @return the token being sold.

     */

    function token() public view returns (IERC20) {

        return _token;

    }



    /**

     * @return the address where funds are collected.

     */

    function wallet() public view returns (address payable) {

        return _wallet;

    }



    /**

     * @return the number of token units a buyer gets per wei.

     */

    function rate() public view returns (uint256) {

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

        uint256 weiAmount = _weiAmount();

        _preValidatePurchase(beneficiary, weiAmount);



        // calculate token amount to be created

        uint256 tokens = _getTokenAmount(weiAmount);



        // update state

        _weiRaised = _weiRaised.add(weiAmount);



        _processPurchase(beneficiary, tokens);

        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);



        _updatePurchasingState(beneficiary, weiAmount);



        _forwardFunds();

        _postValidatePurchase(beneficiary, weiAmount);

    }



    /**

     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.

     * Use `super` in contracts that inherit from Crowdsale to extend their validations.

     * Example from CappedCrowdsale.sol's _preValidatePurchase method:

     *     super._preValidatePurchase(beneficiary, weiAmount);

     *     require(weiRaised().add(weiAmount) <= cap);

     * @param beneficiary Address performing the token purchase

     * @param weiAmount Value in wei involved in the purchase

     */

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        require(beneficiary != address(0));

        require(weiAmount != 0);

    }



    /**

     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid

     * conditions are not met.

     * @param beneficiary Address performing the token purchase

     * @param weiAmount Value in wei involved in the purchase

     */

    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        // solhint-disable-previous-line no-empty-blocks

    }



    /**

     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends

     * its tokens.

     * @param beneficiary Address performing the token purchase

     * @param tokenAmount Number of tokens to be emitted

     */

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {

        _token.safeTransfer(beneficiary, tokenAmount);

    }



    /**

     * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send

     * tokens.

     * @param beneficiary Address receiving the tokens

     * @param tokenAmount Number of tokens to be purchased

     */

    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {

        _deliverTokens(beneficiary, tokenAmount);

    }



    /**

     * @dev Override for extensions that require an internal state to check for validity (current user contributions,

     * etc.)

     * @param beneficiary Address receiving the tokens

     * @param weiAmount Value in wei involved in the purchase

     */

    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {

        // solhint-disable-previous-line no-empty-blocks

    }



    /**

     * @dev Override to extend the way in which ether is converted to tokens.

     * @param weiAmount Value in wei to be converted into tokens

     * @return Number of tokens that can be purchased with the specified _weiAmount

     */

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {

        return weiAmount.mul(_rate);

    }



    /**

     * @dev Determines how ETH is stored/forwarded on purchases.

     */

    function _forwardFunds() internal {

        _wallet.transfer(msg.value);

    }



    /**

     * @dev Determines the value (in Wei) included with a purchase.

     */

    function _weiAmount() internal view returns (uint256) {

      return msg.value;

    }

}



contract CappedCrowdsale is Crowdsale {

    using SafeMath for uint256;



    uint256 private _cap;



    /**

     * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.

     * @param cap Max amount of wei to be contributed

     */

    constructor (uint256 cap) public {

        require(cap > 0);

        _cap = cap;

    }



    /**

     * @return the cap of the crowdsale.

     */

    function cap() public view returns (uint256) {

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

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        super._preValidatePurchase(beneficiary, weiAmount);

        require(weiRaised().add(weiAmount) <= _cap);

    }

}



contract TimedCrowdsale is Crowdsale {

    using SafeMath for uint256;



    uint256 private _openingTime;

    uint256 private _closingTime;



    /**

     * Event for crowdsale extending

     * @param newClosingTime new closing time

     * @param prevClosingTime old closing time

     */

    event TimedCrowdsaleExtended(uint256 prevClosingTime, uint256 newClosingTime);



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

    constructor (uint256 openingTime, uint256 closingTime) public {

        // solhint-disable-next-line not-rely-on-time

        require(openingTime >= block.timestamp);

        require(closingTime > openingTime);



        _openingTime = openingTime;

        _closingTime = closingTime;

    }



    /**

     * @return the crowdsale opening time.

     */

    function openingTime() public view returns (uint256) {

        return _openingTime;

    }



    /**

     * @return the crowdsale closing time.

     */

    function closingTime() public view returns (uint256) {

        return _closingTime;

    }



    /**

     * @return true if the crowdsale is open, false otherwise.

     */

    function isOpen() public view returns (bool) {

        // solhint-disable-next-line not-rely-on-time

        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;

    }



    /**

     * @dev Checks whether the period in which the crowdsale is open has already elapsed.

     * @return Whether crowdsale period has elapsed

     */

    function hasClosed() public view returns (bool) {

        // solhint-disable-next-line not-rely-on-time

        return block.timestamp > _closingTime;

    }



    /**

     * @dev Extend parent behavior requiring to be within contributing period

     * @param beneficiary Token purchaser

     * @param weiAmount Amount of wei contributed

     */

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal onlyWhileOpen view {

        super._preValidatePurchase(beneficiary, weiAmount);

    }



    /**

     * @dev Extend crowdsale

     * @param newClosingTime Crowdsale closing time

     */

    function _extendTime(uint256 newClosingTime) internal {

        require(!hasClosed());

        require(newClosingTime > _closingTime);



        emit TimedCrowdsaleExtended(_closingTime, newClosingTime);

        _closingTime = newClosingTime;

    }

}



contract FinalizableCrowdsale is TimedCrowdsale {

    using SafeMath for uint256;



    bool private _finalized;



    event CrowdsaleFinalized();



    constructor () internal {

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

        // solhint-disable-previous-line no-empty-blocks

    }

}



contract PostDeliveryCrowdsale is TimedCrowdsale {

    using SafeMath for uint256;



    mapping(address => uint256) private _balances;



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

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];

    }



    /**

     * @dev Overrides parent by storing balances instead of issuing tokens right away.

     * @param beneficiary Token purchaser

     * @param tokenAmount Amount of tokens purchased

     */

    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {

        _balances[beneficiary] = _balances[beneficiary].add(tokenAmount);

    }



}



contract MoneyMarketInterface {

  function getSupplyBalance(address account, address asset) public view returns (uint);

  function supply(address asset, uint amount) public returns (uint);

  function withdraw(address asset, uint requestedAmount) public returns (uint);

}



contract LoanEscrow is Pausable {

  using SafeERC20 for IERC20;

  using SafeMath for uint256;



  // configurable to any ERC20 (i.e. xCHF)

  IERC20 public dai = IERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);  // 0x9Ad61E35f8309aF944136283157FABCc5AD371E5  // 0xB4272071eCAdd69d933AdcD19cA99fe80664fc08

  MoneyMarketInterface public moneyMarket = MoneyMarketInterface(0x3FDA67f7583380E67ef93072294a7fAc882FD7E7);  // 0x6732c278C58FC90542cce498981844A073D693d7



  event Deposited(address indexed from, uint256 daiAmount);

  event InterestWithdrawn(address indexed to, uint256 daiAmount);

  event Pulled(address indexed to, uint256 daiAmount);



  mapping(address => uint256) public deposits;

  mapping(address => uint256) public pulls;

  uint256 public deposited;

  uint256 public pulled;



  modifier onlyBlockimmo() {

    require(msg.sender == blockimmo(), "onlyBlockimmo");

    _;

  }



  function blockimmo() public view returns (address);



  function withdrawInterest() public onlyBlockimmo {

    uint256 amountInterest = moneyMarket.getSupplyBalance(address(this), address(dai)).add(dai.balanceOf(address(this))).add(pulled).sub(deposited);

    require(amountInterest > 0, "no interest");



    uint256 errorCode = (amountInterest > dai.balanceOf(address(this))) ? moneyMarket.withdraw(address(dai), amountInterest.sub(dai.balanceOf(address(this)))) : 0;

    require(errorCode == 0, "withdraw failed");



    dai.safeTransfer(msg.sender, amountInterest);

    emit InterestWithdrawn(msg.sender, amountInterest);

  }



  function withdrawMoneyMarket(uint256 _amountDai) public onlyBlockimmo {

    uint256 errorCode = moneyMarket.withdraw(address(dai), _amountDai);

    require(errorCode == 0, "withdraw failed");

  }



  function deposit(address _from, uint256 _amountDai) internal {

    require(_from != address(0) && _amountDai > 0, "invalid parameter(s)");



    dai.safeTransferFrom(msg.sender, address(this), _amountDai);



    if (!paused()) {

      dai.safeApprove(address(moneyMarket), _amountDai);



      uint256 errorCode = moneyMarket.supply(address(dai), _amountDai);

      require(errorCode == 0, "supply failed");

      require(dai.allowance(address(this), address(moneyMarket)) == 0, "allowance not fully consumed by moneyMarket");

    }



    deposits[_from] = deposits[_from].add(_amountDai);

    deposited = deposited.add(_amountDai);

    emit Deposited(_from, _amountDai);

  }



  function pull(address _to, uint256 _amountDai, bool _refund) internal {

    require(_to != address(0) && _amountDai > 0, "invalid parameter(s)");



    uint256 errorCode = (_amountDai > dai.balanceOf(address(this))) ? moneyMarket.withdraw(address(dai), _amountDai.sub(dai.balanceOf(address(this)))) : 0;

    require(errorCode == 0, "withdraw failed");



    if (_refund) {

      deposits[_to] = deposits[_to].sub(_amountDai);

      deposited = deposited.sub(_amountDai);

    } else {

      pulls[_to] = pulls[_to].add(_amountDai);

      pulled = pulled.add(_amountDai);

    }



    dai.safeTransfer(_to, _amountDai);

    emit Pulled(_to, _amountDai);

  }

}



contract LandRegistryProxyInterface {

  function owner() public view returns (address);

}



contract WhitelistInterface {

  function checkRole(address _operator, string memory _role) public view;

  function hasRole(address _operator, string memory _role) public view returns (bool);

}



contract WhitelistProxyInterface {

  function whitelist() public view returns (WhitelistInterface);

}



contract TokenSale is CappedCrowdsale, FinalizableCrowdsale, LoanEscrow, PostDeliveryCrowdsale {

  LandRegistryProxyInterface public registryProxy = LandRegistryProxyInterface(0x0f5Ea0A652E851678Ebf77B69484bFcD31F9459B);  // 0xe72AD2A335AE18e6C7cdb6dAEB64b0330883CD56;

  WhitelistProxyInterface public whitelistProxy = WhitelistProxyInterface(0xEC8bE1A5630364292E56D01129E8ee8A9578d7D8);  // 0x7223b032180CDb06Be7a3D634B1E10032111F367;



  mapping(address => bool) public claimedRefund;

  uint256 public goal;

  mapping(address => bool) public reversed;

  uint256 public totalTokens;



  constructor (

    uint256 _cap,

    uint256 _closingTime,

    uint256 _goal,

    uint256 _openingTime,

    uint256 _rate,

    IERC20 _token,

    address payable _wallet

  )

  public

    Crowdsale(_rate, _wallet, _token)

    CappedCrowdsale(_cap)

    FinalizableCrowdsale()

    TimedCrowdsale(_openingTime, _closingTime)

    PostDeliveryCrowdsale()

  {

    goal = _goal;

  }



  function blockimmo() public view returns (address) {

    return registryProxy.owner();

  }



  function claimRefund(address _refundee) public {

    require(finalized() && !goalReached());

    require(!claimedRefund[_refundee]);



    claimedRefund[_refundee] = true;

    pull(_refundee, deposits[_refundee], true);

  }



  function goalReached() public view returns (bool) {

    return weiRaised() >= goal;

  }



  function hasClosed() public view returns (bool) {

    return capReached() || super.hasClosed();

  }



  function reverse(address _account) public {

    require(!finalized());

    require(!reversed[_account]);

    WhitelistInterface whitelist = whitelistProxy.whitelist();

    require(!whitelist.hasRole(_account, "authorized"));



    reversed[_account] = true;

    pull(_account, deposits[_account], true);

  }



  function totalTokensSold() public view returns (uint256) {

    return _getTokenAmount(weiRaised());

  }



  function withdrawTokens(address beneficiary) public {  // airdrop remaining tokens to investors proportionally

    require(finalized() && goalReached(), "withdrawTokens requires the TokenSale to be successfully finalized");

    require(!reversed[beneficiary]);



    uint256 extra = totalTokens.sub(totalTokensSold()).mul(balanceOf(beneficiary)).div(totalTokensSold());

    _deliverTokens(beneficiary, extra);



    super.withdrawTokens(beneficiary);

  }



  function weiRaised() public view returns (uint256) {

    return deposited;

  }



  function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {

    return weiAmount.div(rate());

  }



  function _finalization() internal {

    require(msg.sender == blockimmo() || msg.sender == wallet());

    super._finalization();



    totalTokens = token().balanceOf(address(this));



    if (goalReached()) {

      uint256 fee = weiRaised().div(100);



      pull(blockimmo(), fee, false);

      pull(wallet(), weiRaised().sub(fee), false);

    } else {

      token().safeTransfer(wallet(), totalTokens);

    }

  }



  function _processPurchase(address beneficiary, uint256 tokenAmount) internal {

    super._processPurchase(beneficiary, tokenAmount);

    deposit(beneficiary, tokenAmount.mul(rate()));

  }



  function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

    require(msg.value == 0, "ether loss");

    require(!reversed[beneficiary]);



    super._preValidatePurchase(beneficiary, weiAmount);



    WhitelistInterface whitelist = whitelistProxy.whitelist();

    whitelist.checkRole(beneficiary, "authorized");

    require(deposits[beneficiary].add(weiAmount) <= 100000e18 || whitelist.hasRole(beneficiary, "uncapped"));

  }



  function _weiAmount() internal view returns (uint256) {

    return dai.allowance(msg.sender, address(this));

  }

}