// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IMethodInvocation {
    function deposit() external payable;
    function withdraw(address) external;
}

interface IMethodCallee {
    function transfer() payable external returns (bool);
}