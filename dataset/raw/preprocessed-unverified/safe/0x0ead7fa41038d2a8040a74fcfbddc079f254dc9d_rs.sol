pragma solidity ^0.4.15;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * Fragment of EtherDelta smart contract with balanceOf stub
 */
contract EtherDelta {
  function balanceOf(address token, address user) public constant returns (uint256);
}


/**
 * Simple token stub for returning balanceOf owner
 */
contract Token {
  function balanceOf(address user) public constant returns (uint256);
}


contract JustBalance is Ownable {
  EtherDelta public etherdelta;

  function JustBalance(address _etherdelta) public {
    etherdelta = EtherDelta(_etherdelta);
  }

  /**
   * in case etherdelta decides to deploy new smartcontract
   */
  function newEtherdelta(address _etherdelta) public onlyOwner returns (bool) {
    etherdelta = EtherDelta(_etherdelta);
    return true;
  }

  function balanceOfEther(address user) public constant returns (uint256, uint256) {
    uint256 edBalance = etherdelta.balanceOf(address(0), user);
    return (user.balance, edBalance);
  }

  function balanceOfToken(address token, address user) public constant returns (uint256, uint256) {
    uint256 walletTokenBalance = Token(token).balanceOf(user);
    uint256 etherdeltaTokenBalance = etherdelta.balanceOf(token, user);
    return (walletTokenBalance, etherdeltaTokenBalance);
  }
}