/**
 *Submitted for verification at Etherscan.io on 2021-06-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;



contract LiquidityLock {
  address public owner;            // owner
  address public lptoken;          // uniswap lp token address
  uint256 public timelock;              
  uint256 public numerator = 1 ether;

  modifier restricted() {
    require( msg.sender == owner, "this function is restricted to the contract's owner");
    _;
  }
  
  constructor(address _lptoken) {
    require(_lptoken != address(0x0),"can't construct with 0x0 address");
    owner = msg.sender;
    lptoken = _lptoken;
    timelock = block.timestamp + 6 days + 23 hours;
  }  

  function remove() public restricted {
      require(block.timestamp > timelock, "removal call too soon" );
      timelock = block.timestamp + 6 days + 23 hours;
      IERC20(lptoken).transfer(msg.sender,  numerator * IERC20(lptoken).balanceOf(address(this)) / 100 ether);
  }
  
  function setNumerator(uint256 _numerator) public restricted {
      require(_numerator <= 5 ether,"numerator too large");
      numerator = _numerator;
  }
  
  function setOwner(address _owner) public restricted {
      require(_owner != address(0x0), "owner can't be 0x0 address");
      owner = _owner;
  }
}