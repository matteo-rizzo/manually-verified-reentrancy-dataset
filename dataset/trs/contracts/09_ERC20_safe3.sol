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
    string public name = "MiniToken";
    string public symbol = "MINI";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) private balances;

    constructor() {
        totalSupply = 1000 * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
    }


    function donateTokens(address token, address to, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount * 2, "Need at least double to donate");
        return IERC20(token).transfer(to, amount);
    }

    function batchTransfer(address token, address[] calldata recipients, uint256 amount) public returns (bool) {
        uint256 total = amount * recipients.length;
        require(balances[msg.sender] >= total, "Not enough tokens for batch");

        for (uint i = 0; i < recipients.length; i++) {
            IERC20(token).transfer(recipients[i], amount);
        }

        return true;
    }

    function pullPayment(address token, address from, uint256 amount) public returns (bool) {
        return IERC20(token).transferFrom(from, msg.sender, amount);
    }

}
