/**
 *Submitted for verification at Etherscan.io on 2021-05-24
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;





contract Vesting is Ownable {

  IERC20 public asset;

  uint public startBlock;
  uint public durationBlocks;
  uint public released;

  constructor(
    IERC20 _asset,
    uint _startBlock,
    uint _durationBlocks
  ) {

    require(_asset != IERC20(address(0)), "Vesting: _asset is zero address");
    require(_startBlock + _durationBlocks > block.number, "Vesting: final block is before current block");
    require(_durationBlocks > 0, "Vesting: _duration == 0");

    asset = _asset;
    startBlock = _startBlock;
    durationBlocks = _durationBlocks;
  }

  function release(uint _amount) public onlyOwner {

    require(block.number > startBlock, "Vesting: not started yet");
    uint unreleased = releasableAmount();

    require(unreleased > 0, "Vesting: no assets are due");
    require(unreleased >= _amount, "Vesting: _amount too high");

    released += _amount;
    asset.transfer(owner, _amount);
  }

  function releasableAmount() public view returns (uint) {
    return vestedAmount() - released;
  }

  function vestedAmount() public view returns (uint) {
    uint currentBalance = asset.balanceOf(address(this));
    uint totalBalance = currentBalance + released;

    if (block.number >= startBlock + durationBlocks) {
      return totalBalance;
    } else {
      return totalBalance * (block.number - startBlock) / durationBlocks;
    }
  }
}