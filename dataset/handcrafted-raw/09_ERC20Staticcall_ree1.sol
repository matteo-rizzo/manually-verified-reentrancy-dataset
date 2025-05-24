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

contract MiniToken {

    mapping (address => bool) private donated;

    function donateTokens(address token, address to, uint256 amount) public {
        require(!donated[msg.sender]);
        (bool success, bytes memory data) = token.staticcall(abi.encodeWithSignature("balanceOf(address)", msg.sender));
        require(success, "Balance query failed");
        uint256 bal = abi.decode(data, (uint256));
        require(bal >= amount * 2, "Need at least double to donate");
        success = IERC20(token).transfer(to, amount);       
        require(success, "Donation failed");
        donated[msg.sender] = true;
    }
}
