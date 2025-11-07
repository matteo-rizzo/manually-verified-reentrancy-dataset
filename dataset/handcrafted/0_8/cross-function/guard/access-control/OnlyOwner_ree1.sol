// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


// TODO try now
contract ControlledPayout {
    mapping (address => mapping (address => uint256)) private allowances;
    mapping (address => uint256) public balances;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }
    
    function setAllowance(address to, uint256 amt) public onlyOwner() {
        allowances[msg.sender][to] = amt;
    }

    function transfer(address target, uint256 amount) public {
        require(allowances[msg.sender][target] >= amount);
        require(balances[msg.sender] >= amount);
        uint256 amt = allowances[msg.sender][target];
        (bool success, ) = target.call{value:amt}("");    
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect after call
        allowances[msg.sender][target] = 0;
    }

  
}

