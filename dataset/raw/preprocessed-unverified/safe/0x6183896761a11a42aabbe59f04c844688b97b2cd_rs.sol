pragma solidity ^0.4.13;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    
  event Pause();
  
  event Unpause();

  bool public paused = false;

  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused {
    paused = false;
    Unpause();
  }
  
}


/**
 * @title PreSale
 * @dev The PreSale contract stores balances investors of pre sale stage.
 */
contract PreSale is Pausable {
    
  event Invest(address, uint);

  using SafeMath for uint;
    
  address public wallet;

  uint public start;

  uint public min;

  uint public hardcap;
  
  uint public invested;
  
  uint public period;

  mapping (address => uint) public balances;

  address[] public investors;

  modifier saleIsOn() {
    require(now > start && now < start + period * 1 days);
    _;
  }

  modifier isUnderHardcap() {
    require(invested < hardcap);
    _;
  }

  function setMin(uint newMin) onlyOwner {
    min = newMin;
  }

  function setHardcap(uint newHardcap) onlyOwner {
    hardcap = newHardcap;
  }
  
  function totalInvestors() constant returns (uint) {
    return investors.length;
  }
  
  function balanceOf(address investor) constant returns (uint) {
    return balances[investor];
  }
  
  function setStart(uint newStart) onlyOwner {
    start = newStart;
  }
  
  function setPeriod(uint16 newPeriod) onlyOwner {
    period = newPeriod;
  }
  
  function setWallet(address newWallet) onlyOwner {
    require(newWallet != address(0));
    wallet = newWallet;
  }

  function invest() saleIsOn isUnderHardcap whenNotPaused payable {
    require(msg.value >= min);
    wallet.transfer(msg.value);
    if(balances[msg.sender] == 0) {
      investors.push(msg.sender);    
    }
    balances[msg.sender] = balances[msg.sender].add(msg.value);
    invested = invested.add(msg.value);
    Invest(msg.sender, msg.value);
  }

  function() external payable {
    invest();
  }

}