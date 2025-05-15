// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StakableToken {
    uint256 public totalSupply;
    IERC20 private token;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => uint256) public stakedAmounts;
    mapping(address => uint256) public pendingWithdrawals;
    
    event Staked(address indexed user, uint256 amount);
    event RequestedUnstake(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address a) {
        token = IERC20(a);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");

        stakedAmounts[msg.sender] += amount;
        emit Staked(msg.sender, amount);
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "transferFrom failed");
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        require(stakedAmounts[msg.sender] >= amount, "Not enough staked");

        stakedAmounts[msg.sender] -= amount;
        pendingWithdrawals[msg.sender] += amount;

        emit RequestedUnstake(msg.sender, amount);
    }

    function withdraw() external {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        pendingWithdrawals[msg.sender] = 0;
        require(token.transfer(msg.sender, amount), "transfer failed");

        emit Withdrawn(msg.sender, amount);
    }
}
