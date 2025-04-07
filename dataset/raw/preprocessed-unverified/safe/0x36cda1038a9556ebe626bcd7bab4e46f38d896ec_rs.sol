pragma solidity 0.4.11;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */

contract ControllerInterface {


  // State Variables
  bool public paused;

  // Nutz functions
  function babzBalanceOf(address _owner) constant returns (uint256);
  function activeSupply() constant returns (uint256);
  function burnPool() constant returns (uint256);
  function powerPool() constant returns (uint256);
  function totalSupply() constant returns (uint256);
  function allowance(address _owner, address _spender) constant returns (uint256);

  function approve(address _owner, address _spender, uint256 _amountBabz) public;
  function transfer(address _from, address _to, uint256 _amountBabz, bytes _data) public returns (bool);
  function transferFrom(address _sender, address _from, address _to, uint256 _amountBabz, bytes _data) public returns (bool);

  // Market functions
  function floor() constant returns (uint256);
  function ceiling() constant returns (uint256);

  function purchase(address _sender, uint256 _price) public payable returns (uint256, bool);
  function sell(address _from, uint256 _price, uint256 _amountBabz) public;

  // Power functions
  function powerBalanceOf(address _owner) constant returns (uint256);
  function outstandingPower() constant returns (uint256);
  function authorizedPower() constant returns (uint256);
  function powerTotalSupply() constant returns (uint256);

  function powerUp(address _sender, address _from, uint256 _amountBabz) public;
  function downTick(uint256 _pos, uint256 _now) public;
  function createDownRequest(address _owner, uint256 _amountPower) public;
}

/**
 * @title PullPayment
 * @dev Base contract supporting async send for pull payments.
 */
contract PullPayment is Ownable {
  using SafeMath for uint256;

  struct Payment {
    uint256 value;  // TODO: use compact storage
    uint256 date;   //
  }

  uint public dailyLimit = 1000000000000000000000;  // 1 ETH
  uint public lastDay;
  uint public spentToday;

  mapping(address => Payment) internal payments;

  modifier whenNotPaused () {
    require(!ControllerInterface(owner).paused());
     _;
  }
  function balanceOf(address _owner) constant returns (uint256 value) {
    return payments[_owner].value;
  }

  function paymentOf(address _owner) constant returns (uint256 value, uint256 date) {
    value = payments[_owner].value;
    date = payments[_owner].date;
    return;
  }

  /// @dev Allows to change the daily limit. Transaction has to be sent by wallet.
  /// @param _dailyLimit Amount in wei.
  function changeDailyLimit(uint _dailyLimit) public onlyOwner {
      dailyLimit = _dailyLimit;
  }

  function changeWithdrawalDate(address _owner, uint256 _newDate)  public onlyOwner {
    // allow to withdraw immediately
    // move witdrawal date more days into future
    payments[_owner].date = _newDate;
  }

  function asyncSend(address _dest) public payable onlyOwner {
    require(msg.value > 0);
    uint256 newValue = payments[_dest].value.add(msg.value);
    uint256 newDate;
    if (isUnderLimit(msg.value)) {
      newDate = (payments[_dest].date > now) ? payments[_dest].date : now;
    } else {
      newDate = now.add(3 days);
    }
    spentToday = spentToday.add(msg.value);
    payments[_dest] = Payment(newValue, newDate);
  }


  function withdraw() public whenNotPaused {
    address untrustedRecipient = msg.sender;
    uint256 amountWei = payments[untrustedRecipient].value;

    require(amountWei != 0);
    require(now >= payments[untrustedRecipient].date);
    require(this.balance >= amountWei);

    payments[untrustedRecipient].value = 0;

    untrustedRecipient.transfer(amountWei);
  }

  /*
   * Internal functions
   */
  /// @dev Returns if amount is within daily limit and resets spentToday after one day.
  /// @param amount Amount to withdraw.
  /// @return Returns if amount is under daily limit.
  function isUnderLimit(uint amount) internal returns (bool) {
    if (now > lastDay.add(24 hours)) {
      lastDay = now;
      spentToday = 0;
    }
    // not using safe math because we don&#39;t want to throw;
    if (spentToday + amount > dailyLimit || spentToday + amount < spentToday) {
      return false;
    }
    return true;
  }

}