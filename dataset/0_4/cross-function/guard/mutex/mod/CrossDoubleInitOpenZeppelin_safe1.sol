// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.24;

contract CrossDoubleInitOpenZeppelin_safe1 {

    mapping (address => uint256) public balances;

    //OpenZeppelin-style flags make more sense here cause they need to be initialized
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status; // 0 if not intialized

    uint256 public currentVersion;
    bool private initializedV2;

    constructor () public{
        _status = _NOT_ENTERED;
        currentVersion = 2;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
    
    // using the nonReentrant modifier on initializePoolV2() protects the whole contract from reentrancy attacks
    function initializePoolV2() external nonReentrant {
        if (initializedV2) {
            revert("Already IntializedV2");
        }
        initializedV2 = true;
        currentVersion = 2;
        _status = _NOT_ENTERED;
    }


    function withdraw() nonReentrant public {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        bool success = msg.sender.call.value(amt)("");
        require(success, "Call failed");
        balances[msg.sender] = 0;
    }

    function deposit() nonReentrant public payable {
        balances[msg.sender] += msg.value;       
    }

}
