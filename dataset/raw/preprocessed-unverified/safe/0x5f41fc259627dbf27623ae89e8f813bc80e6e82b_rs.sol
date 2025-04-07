/**
 *Submitted for verification at Etherscan.io on 2020-10-09
*/

// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity ^0.7.1;


// 
/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
/******************************************************************************/


// 
/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
*
* Implementation of internal diamondCut function.
/******************************************************************************/


// 


// 
contract ReentryProtectionFacet {
  modifier noReentry {
    // Use counter to only write to storage once


      LibReentryProtectionStorage.RPStorage storage s
     = LibReentryProtectionStorage.rpStorage();
    s.lockCounter++;
    uint256 lockValue = s.lockCounter;
    _;
    require(
      lockValue == s.lockCounter,
      "ReentryProtectionFacet.noReentry: reentry detected"
    );
  }
}

// 
contract CallFacet is ReentryProtectionFacet {
  function call(
    address[] memory _targets,
    bytes[] memory _calldata,
    uint256[] memory _values
  ) external noReentry {
    // ONLY THE OWNER CAN DO ARBITRARY CALLS
    require(msg.sender == LibDiamond.diamondStorage().contractOwner);
    require(
      _targets.length == _calldata.length && _values.length == _calldata.length,
      "ARRAY_LENGTH_MISMATCH"
    );

    for (uint256 i = 0; i < _targets.length; i++) {
      // address(test).call{value: 1}(abi.encodeWithSignature("nonExistingFunction()"))
      (bool success, ) = _targets[i].call{ value: _values[i] }(_calldata[i]);
      require(success, "CALL_FAILED");
    }
  }
}