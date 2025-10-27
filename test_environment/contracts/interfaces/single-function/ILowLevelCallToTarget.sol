// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ILowLevelCallToTarget {
    function deposit() external payable;
    function pay() external;
}

interface ILowLevelCallToTarget2 {
    function deposit() external payable;
    function pay(address) external; // receiver via parameter
}