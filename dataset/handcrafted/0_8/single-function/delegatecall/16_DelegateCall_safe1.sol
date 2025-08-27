// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract C {
    address public logic;
    mapping(address => uint256) public balances;
    bool private flag;

    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    constructor(address _logic) {
        logic = _logic;
    }

    function deposit() nonReentrant external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() nonReentrant external {
        (bool success, ) = logic.delegatecall(abi.encodeWithSignature("f(address)", msg.sender));
        require(success, "delegatecall failed");
    }

}

contract Logic {
    address public logic;

    function f(address a) public {
        logic = a;
    }
}

contract CallerHarmless {
    function main(address logic) public {
        C c = new C(address(logic));
    }
}