// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract C {
    address public logic;
    mapping(address => uint256) public balances;
    bool private flag;

    constructor(address _logic) {
        logic = _logic;
    }

    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }
    
    function deposit() nonReentrant external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() nonReentrant external {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect BEFORE external call is safe anyway, even with broken mutex
    }

    function doSomething() nonReentrant public {
        (bool success, ) = logic.delegatecall(abi.encodeWithSignature("doSomething()"));
    }

}