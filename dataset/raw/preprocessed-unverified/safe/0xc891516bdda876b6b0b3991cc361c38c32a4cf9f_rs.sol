/**
 *Submitted for verification at Etherscan.io on 2021-05-17
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;













contract FeeRecipient is Ownable {

  IFeeConverter public feeConverter;

  constructor(IFeeConverter _feeConverter) {
    feeConverter = _feeConverter;
  }

  function convert(
    ILendingPair _pair,
    address[] memory _path
  ) public {
    IERC20 lpToken = IERC20(_pair.lpToken(_path[0]));
    uint supplyTokenAmount = lpToken.balanceOf(address(this));
    lpToken.transfer(address(feeConverter), supplyTokenAmount);
    feeConverter.convert(msg.sender, _pair, _path, supplyTokenAmount);
  }

  function setFeeConverter(IFeeConverter _value) onlyOwner public {
    feeConverter = _value;
  }
}