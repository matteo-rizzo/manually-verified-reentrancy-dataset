/**
 *Submitted for verification at Etherscan.io on 2021-05-18
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;













contract Controller is Ownable {

  IInterestRateModel public interestRateModel;
  IPriceOracle public priceOracle;

  uint public liqMinHealth; // 15e17 = 1.5
  uint public liqFeeSystem; // 5e18  = 5%
  uint public liqFeeCaller; // 5e18  = 5%

  mapping(address => mapping(address => uint)) public depositLimit;

  address public feeRecipient;

  constructor(
    IInterestRateModel _interestRateModel,
    uint _liqMinHealth,
    uint _liqFeeSystem,
    uint _liqFeeCaller
  ) {
    feeRecipient = msg.sender;
    interestRateModel = _interestRateModel;

    setLiqParams(_liqMinHealth, _liqFeeSystem, _liqFeeCaller);
  }

  function setFeeRecipient(address _feeRecipient) public onlyOwner {
    require(_feeRecipient != address(0), 'PairFactory: _feeRecipient != 0x0');
    feeRecipient = _feeRecipient;
  }

  function setLiqParams(
    uint _liqMinHealth,
    uint _liqFeeSystem,
    uint _liqFeeCaller
  ) public onlyOwner {
    // Never more than a total of 20%
    require(_liqFeeSystem + _liqFeeCaller <= 20e18, "PairFactory: fees too high");

    liqMinHealth = _liqMinHealth;
    liqFeeSystem = _liqFeeSystem;
    liqFeeCaller = _liqFeeCaller;
  }

  function setInterestRateModel(IInterestRateModel _value) onlyOwner public {
    interestRateModel = _value;
  }

  function setPriceOracle(IPriceOracle _oracle) onlyOwner public {
    priceOracle = _oracle;
  }

  function setDepositLimit(address _pair, address _token, uint _value) public onlyOwner {
    depositLimit[_pair][_token] = _value;
  }

  function liqFeesTotal() public view returns(uint) {
    return liqFeeSystem + liqFeeCaller;
  }

  function tokenPrice(address _token) public view returns(uint) {
    return priceOracle.tokenPrice(_token);
  }

  function tokenSupported(address _token) public view returns(bool) {
    return priceOracle.tokenSupported(_token);
  }
}