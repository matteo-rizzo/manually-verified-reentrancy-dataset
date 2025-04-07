pragma solidity ^0.4.13;

/**
 * Math operations with safety checks
 */


/**
 * Interface for defining crowdsale pricing.
 */
contract PricingStrategy {

  /** Interface declaration. */
  function isPricingStrategy() public constant returns (bool) {
    return true;
  }

  /**
   * When somebody tries to buy tokens for X eth, calculate how many tokens they get.
   *
   *
   * @param value - What is the value of the transaction sent in as wei
   * @param weiRaised - how much money has been raised this far
   * @param tokensSold - how many tokens have been sold this far
   * @param msgSender - who is the investor of this transaction
   * @param decimals - how many decimal units the token has
   * @return Amount of tokens the investor receives
   */
  function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) public constant returns (uint tokenAmount);
}

/**
 * Fixed crowdsale pricing - everybody gets the same price.
 */
contract FlatPricing is PricingStrategy {

  using SafeMath for uint;

  /* How many weis one token costs */
  uint public oneTokenInWei;

  function FlatPricing(uint _oneTokenInWei) {
    oneTokenInWei = _oneTokenInWei;
  }

  /**
   * Calculate the current price for buy in amount.
   *
   * @ param  {uint value} Buy-in value in wei.
   * @ param
   * @ param
   * @ param
   * @ param  {uint decimals} The decimals used by the token representation (e.g. given by FractionalERC20).
   */
  function calculatePrice(uint value, uint, uint, address, uint decimals) public constant returns (uint) {
    uint multiplier = 10 ** decimals;
    return value.mul(multiplier).div(oneTokenInWei);
  }

}