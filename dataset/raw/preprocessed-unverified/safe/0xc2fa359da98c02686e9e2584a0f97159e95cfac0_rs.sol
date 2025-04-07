/**
 *Submitted for verification at Etherscan.io on 2021-04-24
*/

// SPDX-License-Identifier: UNLICENSED

// Copyright (c) 2021 0xdev0 - All rights reserved
// https://twitter.com/0xdev0

pragma solidity ^0.8.0;











contract Controller is Ownable {

  IInterestRateModel public interestRateModel;

  uint public priceDelay;
  uint public slowPricePeriod;
  uint public slowPriceRange; // 1e18 - 1% during first slowPricePeriod, 99% during remaining (priceDelay - slowPricePeriod)

  uint public liqMinHealth; // 15e17 = 1.5
  uint public liqFeePool;   // 45e17 = 4.5%
  uint public liqFeeSystem; // 45e17 = 4.5%
  uint public liqFeeCaller; // 1e18  = 1%

  mapping(address => mapping(address => uint)) public depositLimit;

  address public feeRecipient;

  constructor(
    IInterestRateModel _interestRateModel,
    uint _priceDelay,
    uint _slowPricePeriod,
    uint _slowPriceRange,
    uint _liqMinHealth,
    uint _liqFeePool,
    uint _liqFeeSystem,
    uint _liqFeeCaller
  ) {
    priceDelay = _priceDelay;
    slowPricePeriod = _slowPricePeriod;
    slowPriceRange = _slowPriceRange;
    feeRecipient = msg.sender;
    interestRateModel = _interestRateModel;

    setLiqParams(_liqMinHealth,  _liqFeePool, _liqFeeSystem, _liqFeeCaller);
  }

  function setFeeRecipient(address _feeRecipient) public onlyOwner {
    require(_feeRecipient != address(0), 'PairFactory: _feeRecipient != 0x0');
    feeRecipient = _feeRecipient;
  }

  function setLiqParams(
    uint _liqMinHealth,
    uint _liqFeePool,
    uint _liqFeeSystem,
    uint _liqFeeCaller
  ) public onlyOwner {
    // Never more than a total of 20%
    require(_liqFeePool + _liqFeeSystem + _liqFeeCaller <= 20e18, "PairFactory: fees too high");

    liqMinHealth = _liqMinHealth;
    liqFeePool = _liqFeePool;
    liqFeeSystem = _liqFeeSystem;
    liqFeeCaller = _liqFeeCaller;
  }

  function setPriceDelay(uint _value) onlyOwner public {
    priceDelay = _value;
  }

  function setSlowPricePeriod(uint _value) onlyOwner public {
    slowPricePeriod = _value;
  }

  function setSlowPriceRange(uint _value) onlyOwner public {
    slowPriceRange = _value;
  }

  function setInterestRateModel(IInterestRateModel _value) onlyOwner public {
    interestRateModel = _value;
  }

  function setDepositLimit(address _pair, address _token, uint _value) public onlyOwner {
    depositLimit[_pair][_token] = _value;
  }

  function liqFeesTotal() public view returns(uint) {
    return liqFeePool + liqFeeSystem + liqFeeCaller;
  }
}