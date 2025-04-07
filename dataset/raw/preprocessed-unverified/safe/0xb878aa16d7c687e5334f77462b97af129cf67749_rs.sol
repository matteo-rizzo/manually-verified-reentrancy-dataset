pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


contract ERC20Interface {
    function balanceOf(address _owner) public constant returns (uint balance) {}
    function transfer(address _to, uint _value) public returns (bool success) {}
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {}
}

contract Exchanger {
    using SafeMath for uint;
  // Decimals 18
  ERC20Interface dai = ERC20Interface(0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359);
  // Decimals 6
  ERC20Interface usdt = ERC20Interface(0xdac17f958d2ee523a2206206994597c13d831ec7);

  function getDAI(uint _amountInDollars) public returns (bool) {
    // Must first call approve for the usdt contract
    usdt.transferFrom(msg.sender, this, _amountInDollars * (10 ** 6));
    dai.transfer(msg.sender, _amountInDollars.mul(((10 ** 18))));
    return true;
  }

  function getUSDT(uint _amountInDollars) public returns (bool) {
    // Must first call approve for the dai contract
    dai.transferFrom(msg.sender, this, _amountInDollars * (10 ** 18));
    usdt.transfer(msg.sender, _amountInDollars.mul(((10 ** 6))));
    return true;
  }
}