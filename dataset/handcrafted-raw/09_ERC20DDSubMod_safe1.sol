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

contract MyERC20 is IERC20 {
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    uint256 public totalSupply;

    constructor() {
        totalSupply = 1000 * 10 ** uint256(10);
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "Not enough tokens");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(balances[from] >= amount, "Not enough tokens");
        require(allowances[from][msg.sender] >= amount, "Allowance exceeded");
        allowances[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }


    function donateTokens(address to, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount * 2, "Need at least double to donate");
        return transfer(to, amount);
    }

    function batchTransfer(address[] calldata recipients, uint256 amount) public returns (bool) {
        uint256 total = amount * recipients.length;
        require(balances[msg.sender] >= total, "Not enough tokens for batch");

        for (uint i = 0; i < recipients.length; i++) {
            transfer(recipients[i], amount);
        }

        return true;
    }

    function pullPayment(address from, uint256 amount) public returns (bool) {
        return transferFrom(from, msg.sender, amount);
    }
}

contract C {

    uint constant public MAX_AMOUNT = 10**3;
    bool private flag;
    mapping (address => uint) private received;

    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    function donate(address token, address to, uint256 amount) nonReentrant public {
        require(received[to] < MAX_AMOUNT, "Already received maximum amount");
        bool success = MyERC20(token).transfer(to, amount);
        received[to] += amount;
        require(success, "Transfer failed");
    }
}
