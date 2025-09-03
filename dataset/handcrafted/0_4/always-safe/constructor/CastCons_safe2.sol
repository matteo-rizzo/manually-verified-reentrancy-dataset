pragma solidity ^0.4.24;

// SPDX-License-Identifier: GPL-3.0

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

// this contract implements a donation logic by using ERC20 token
contract C {
    mapping (address => uint256) private donated;
    address private token;
    
    constructor(address _token, address to, uint256 initial_amount)  public {
        require(IERC20(_token).balanceOf(msg.sender) >= initial_amount, "Need at least double to donate");
        bool success = IERC20(_token).transfer(to, initial_amount);       // this is an external call to unknown code that could possibly be reentrant, but the contract is safe anyway
        require(success, "Transfer failed");
        donated[msg.sender] += initial_amount;                     // the side effect before the external call makes this safe
        token = _token;
    }
}