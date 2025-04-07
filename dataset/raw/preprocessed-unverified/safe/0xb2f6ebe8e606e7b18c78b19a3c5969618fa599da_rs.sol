pragma solidity ^0.4.15;

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
 * @title Token
 * @dev API interface for interacting with the WILD Token contract 
 */


contract Crowdsale is Ownable {

  using SafeMath for uint256;

  Token public token;

  uint256 public constant RATE = 2200; // Number of tokens per Ether
  uint256 public constant CAP = 15910; // Cap in Ether
  uint256 public constant START = 1504594800; // Sep 5, 2017 @ 08:00 GMT+1
  uint256 public constant DAYS = 7; // 7 Days

  uint256 public constant initialTokens = 35000000 * 10**18; // Initial number of tokens available
  bool public initialized = false;
  uint256 public raisedAmount = 0;

  event BoughtTokens(address indexed to, uint256 value);

  modifier whenSaleIsActive() {
    // Check if sale is active
    assert(isActive());

    _;
  }

  function Crowdsale(address _tokenAddr) {
      require(_tokenAddr != 0);
      token = Token(_tokenAddr);
  }
  
  function initialize() onlyOwner {
      require(initialized == false); // Can only be initialized once
      require(tokensAvailable() == initialTokens); // Must have some tokens allocated
      initialized = true;
  }

  function isActive() constant returns (bool) {
    return (
        initialized == true &&
        now >= START && // Must be after the START date
        now <= START.add(DAYS * 1 days) && // Must be before the end date
        goalReached() == false // Goal must not already be reached
    );
  }

  function goalReached() constant returns (bool) {
    return (raisedAmount >= CAP * 1 ether);
  }

  function () payable {
    buyTokens();
  }

  /**
  * @dev function that sells available tokens
  */
  function buyTokens() payable whenSaleIsActive {

    // Calculate tokens to sell
    uint256 weiAmount = msg.value;
    uint256 tokens = weiAmount.mul(RATE);

    BoughtTokens(msg.sender, tokens);

    // Increment raised amount
    raisedAmount = raisedAmount.add(msg.value);
    
    // Send tokens to buyer
    token.transfer(msg.sender, tokens);
    
    // Send money to owner
    owner.transfer(msg.value);
  }

  /**
   * @dev returns the number of tokens allocated to this contract
   */
  function tokensAvailable() constant returns (uint256) {
    return token.balanceOf(this);
  }

  /**
   * @notice Terminate contract and refund to owner
   */
  function destroy() onlyOwner {
    // Transfer tokens back to owner
    uint256 balance = token.balanceOf(this);
    assert(balance > 0);
    token.transfer(owner, balance);

    // There should be no ether in the contract but just in case
    selfdestruct(owner);
  }

}