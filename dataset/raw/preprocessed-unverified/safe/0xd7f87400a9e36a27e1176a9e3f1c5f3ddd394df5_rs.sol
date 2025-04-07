/**
 *Submitted for verification at Etherscan.io on 2021-08-10
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.6;





contract VaultController is Ownable {

  using Address for address;

  address public rebalancer;

  bool public depositsEnabled;

  mapping(address => uint) public depositLimit;

  event NewDepositLimit(address indexed vault, uint amount);
  event DepositsEnabled(bool value);
  event NewRebalancer(address indexed rebalancer);

  constructor() {
    depositsEnabled = true;
  }

  function setRebalancer(address _rebalancer) external onlyOwner {
    _requireContract(_rebalancer);
    rebalancer = _rebalancer;
    emit NewRebalancer(_rebalancer);
  }

  function setDepositsEnabled(bool _value) external onlyOwner {
    depositsEnabled = _value;
    emit DepositsEnabled(_value);
  }

  function setDepositLimit(address _vault, uint _amount) external onlyOwner {
    _requireContract(_vault);
    depositLimit[_vault] = _amount;
    emit NewDepositLimit(_vault, _amount);
  }

  function _requireContract(address _value) internal view {
    require(_value.isContract(), "VaultController: must be a contract");
  }
}