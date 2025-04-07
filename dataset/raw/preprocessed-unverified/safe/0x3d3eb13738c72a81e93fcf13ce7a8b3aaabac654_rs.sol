pragma solidity ^0.5.17;

// This contract merely calculates the cycle
contract CalculateCyle {
  using SafeMath for uint256;
  function calculate(uint256 deployedTime,uint256 currentTime,uint256 duration) public view returns(uint256) {
    uint256 cycles = (currentTime.sub(deployedTime)).div(duration);
    return cycles;
  }
}