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




contract Crowdsale is Ownable {

  using SafeMath for uint256;

  Token token;

  uint256 public constant RATE = 1000; // Number of tokens per Ether
  uint256 public constant CAP = 100000; // Cap in Ether
  uint256 public constant START = 1505138400; // Sep 11, 2017 @ 14:00 GMT
  uint256 public DAYS = 30; // 30 Days

  uint256 public raisedAmount = 0;

  event BoughtTokens(address indexed to, uint256 value);

  modifier whenSaleIsActive() {
    // Check how much Ether has been raised
    assert(!goalReached());

    // Check if sale is active
    assert(isActive());

    _;
  }

  function Crowdsale(address _tokenAddr) {
      require(_tokenAddr != 0);
      token = Token(_tokenAddr);
  }

  function isActive() constant returns (bool) {
    return (now >= START && now <= START.add(DAYS * 1 days));
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
    uint256 bonus = 0;

    // Calculate Bonus
    if (now <= START.add(7 days)) {
      bonus = tokens.mul(30).div(100);
    } else if (now <= START.add(14 days)) {
      bonus = tokens.mul(25).div(100);
    } else if (now <= START.add(21 days)) {
      bonus = tokens.mul(20).div(100);
    } else if (now <= START.add(30 days)) {
      bonus = tokens.mul(10).div(100);
    }

    tokens = tokens.add(bonus);

    // Send tokens to buyer
    token.transfer(msg.sender, tokens);

    BoughtTokens(msg.sender, tokens);

    // Send money to owner
    owner.transfer(msg.value);

    // Increment raised amount
    raisedAmount = raisedAmount.add(msg.value);
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
    token.transfer(owner, balance);

    // There should be no ether in the contract but just in case
    selfdestruct(owner);
  }

}