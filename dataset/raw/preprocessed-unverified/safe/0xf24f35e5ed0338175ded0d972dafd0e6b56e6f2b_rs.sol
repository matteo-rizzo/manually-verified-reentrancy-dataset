/**
 *Submitted for verification at Etherscan.io on 2021-07-26
*/

// SPDX-License-Identifier: UNLICENSED

// Copyright (c) 2021 0xdev0 - All rights reserved
// https://twitter.com/0xdev0

pragma solidity 0.8.6;











contract FeeHelper {

  uint private constant MAX_INT = 2**256 - 1;

  function accrueAccounts(ILendingPair _lendingPair, address[] memory _accounts) external {
    for (uint i = 0; i < _accounts.length; i++) {
      _lendingPair.accrueAccount(_accounts[i]);
    }
  }
}