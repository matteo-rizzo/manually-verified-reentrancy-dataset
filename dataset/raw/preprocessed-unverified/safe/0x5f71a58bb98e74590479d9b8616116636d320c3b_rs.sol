/**
 *Submitted for verification at Etherscan.io on 2021-07-27
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.6;



















contract FeeRecipient is Ownable, IFeeRecipient {

  using BytesLib for bytes;

  IFeeConverter public feeConverter;

  constructor(IFeeConverter _feeConverter) {
    feeConverter = _feeConverter;
  }

  function convert(
    ILendingPair _pair,
    bytes memory _path,
    uint _minWildOutput
  ) external {

    IERC20 lpToken = IERC20(_pair.lpToken(_path.toAddress(0)));
    uint supplyTokenAmount = lpToken.balanceOf(address(this));
    lpToken.transfer(address(feeConverter), supplyTokenAmount);
    feeConverter.convert(msg.sender, _pair, _path, supplyTokenAmount, _minWildOutput);
  }

  function setFeeConverter(IFeeConverter _value) external override onlyOwner {
    feeConverter = _value;
  }
}