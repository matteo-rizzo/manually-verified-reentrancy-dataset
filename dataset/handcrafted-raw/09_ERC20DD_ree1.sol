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

contract C {

    uint constant public MAX_AMOUNT = 10**3;

    mapping (address => uint) private received;

    function donate(address token, address to, uint256 amount) public {
        require(received[to] < MAX_AMOUNT, "Already received maximum amount");
        bool success = IERC20(token).transfer(to, amount);
        received[to] += amount;
        require(success, "Transfer failed");
    }
}
