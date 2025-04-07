pragma solidity ^0.4.15;

contract ELTCoinToken {
  function transfer(address to, uint256 value) public returns (bool);
  function balanceOf(address who) public constant returns (uint256);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



contract ELTCOINLock is Ownable {
  ELTCoinToken public token;

  uint256 public endTime;

  function ELTCOINLock(address _contractAddress, uint256 _endTime) {
    token = ELTCoinToken(_contractAddress);
    endTime = _endTime;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }

  /**
  * @dev Transfer the unsold tokens to the owner main wallet
  * @dev Only for owner
  */
  function drainRemainingToken () public onlyOwner {
      require(hasEnded());
      token.transfer(owner, token.balanceOf(this));
  }
}