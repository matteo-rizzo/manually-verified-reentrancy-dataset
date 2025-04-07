/**
 *Submitted for verification at Etherscan.io on 2020-07-17
*/

// SPDX-License-Identifier: GPLv3

pragma solidity 0.6.11;

// This is the funding contract for use within TRIATICS with the TRIATICS Native Token (TRA).
// All licensing issues are covered in the standard GPLv3 licensing terms
// Proper attribution has to be provided when using this code for other projects other than TRIATICS

// 2020 Triatics All Rights Reserved.

/**
  @dev This contract holds all locked tokens that will be used for funding the triatics project
  @dev Locked tokens can only be released after a certain amount of time
  @dev The emissions schedule is as follows the uniswap listing
  1) 3rd Month after uniswap listing : 100,000 TRA for marketing and 200,000 for payment to audit firms
  2) Every month: 50,000 TRA for developer salaries.
 */


 // Interface defines the TRA token




contract Funding {
  // This is the funding contract that stores all locked funds for the TRIATICS project
  // Do not use this code without proper attribution
  // 2020 All Rights Reserved.
  using SafeMath for uint256;
  
  uint256 public _oneMonthBlock;
  uint256 public _threeMonthBlock;
  uint256 public _deployedBlock;
  address public _owner;
  address public _TRAAddress;

  bool public _threeMonthWithdrawn;
  TRA public _TRAContract;

  // Constructor sets the address of the token
  constructor() public {
    _owner = msg.sender;
    _TRAAddress = address(0);
    _TRAContract = TRA(_TRAAddress);
    _oneMonthBlock = uint256(5760).mul(30);
    _threeMonthBlock = uint256(5760).mul(30).mul(3);
    _deployedBlock = block.number;
    _threeMonthWithdrawn = false;
  }

  function SetTRAAddress(address TRAAddress) public {
    require(msg.sender == _owner,"Only owners can change the TRA address");
    _TRAAddress = TRAAddress;
    _TRAContract = TRA(_TRAAddress);
  }

  // Release 50,000 every month.
  function ReleaseMonthly() public {
    // Check if one months worth of block has passed by
    require(block.number >= _deployedBlock.add(_oneMonthBlock),"One month hasn't passed since the last transaction");
    // Calculate 50,000. Make this to 18 decimal places.
    uint256 amount = 50000 * uint256(10) ** 18;
    // Set the next block to be another 5760 blocks ahead
    _oneMonthBlock = _oneMonthBlock.add(_oneMonthBlock);
    _TRAContract.transfer(msg.sender,amount);
  }

  // Release 300,000 after three months
  function ReleaseThreeMonths() public {
  // Check if one months worth of block has passed by
    require(block.number >= _deployedBlock.add(_threeMonthBlock),"Three month hasn't passed since the last transaction");
    require(_threeMonthWithdrawn == false,"Cannot withdraw more than once");
    // Calculate 300,000. Make this to 18 decimal places.
    uint256 amount = 300000 * uint256(10) ** 18;
    // Set the flag to false so that we cannot withdraw 300,000 more than once
    _threeMonthWithdrawn = true;
    _TRAContract.transfer(msg.sender,amount);
  }
}