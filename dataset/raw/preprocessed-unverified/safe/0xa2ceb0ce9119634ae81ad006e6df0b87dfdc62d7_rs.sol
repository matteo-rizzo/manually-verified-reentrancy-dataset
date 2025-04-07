pragma solidity ^0.6.0;


// This contract merely calculates the cycle
contract Cycle {
  using SafeMath for uint256;
  function calculate(uint256 deployedTime,uint256 currentTime,uint256 duration) public view returns(uint256) {
    uint256 cycles = (currentTime.sub(deployedTime)).div(duration);
    return cycles;
  }
}