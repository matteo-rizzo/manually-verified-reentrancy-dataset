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

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => uint256) public stakedAmounts;
    
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);


    function stake(address token, uint256 amount) external {
        require(amount > 0, "Amount must be > 0");

        emit Staked(msg.sender, amount);
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, "transferFrom failed");

        stakedAmounts[msg.sender] += amount;
    }

    function unstake(address token, uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        require(stakedAmounts[msg.sender] >= amount, "Not enough staked");

        emit Unstaked(msg.sender, amount);
        bool success = IERC20(token).transfer(msg.sender, amount);
        require(success, "transfer failed");

        stakedAmounts[msg.sender] -= amount;

    }
}
