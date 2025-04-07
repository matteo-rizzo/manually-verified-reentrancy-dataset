pragma solidity ^0.4.18;



contract test {
  using SafeMath for uint256;
  uint256 public num;
  function test() {
    num = 10;
  }
  function add(uint256 _num) {
    num = num.add(_num);
  }
}