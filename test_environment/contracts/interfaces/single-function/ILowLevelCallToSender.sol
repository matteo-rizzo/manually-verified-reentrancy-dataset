// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ILowLevelCallToSender {
    function deposit() external payable;
    function withdraw() external;
}