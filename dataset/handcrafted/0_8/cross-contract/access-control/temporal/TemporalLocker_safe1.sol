// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Simplified interface of the OpenZeppelin's IERC20 and SafeERC20 libraries for sake of example
interface IERC20 {
    function safeTransfer(address to, uint256 value) external;
    function safeTransferFrom(address from, address to, uint256 value) external;
    function balanceOf(address account) external view returns (uint256);
}

interface IPool {
    function withdrawFee(address token) external;
}

contract TemporalLocker_safe1 {
    IPool private pool;
    mapping (address => uint) public deposited;

    bool private flag;

    modifier nonReentrant() {
        require(!flag, "Reentrant call");
        flag = true;
        _;
        flag = false;
    }
    constructor (address _pool) {
        pool = IPool(_pool);
    }

    function deposit(address token, uint amt) nonReentrant public {
        deposited[msg.sender] += amt;
        IERC20(token).safeTransferFrom(msg.sender, address(this), amt);
    }

    function withdraw(address token) nonReentrant public {
        uint amt = deposited[msg.sender];
        deposited[msg.sender] = 0;
        IERC20(token).safeTransferFrom(address(this), msg.sender, amt);
    }

    function collectFees(address token) nonReentrant public {
        uint n1 = IERC20(token).balanceOf(address(this));
        pool.withdrawFee(token);
        uint n2 = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransferFrom(address(this), msg.sender, n2 - n1);
    }
}


// contract MaliciousToken is IERC20 {
//     mapping (address => uint) public balances;
//     bool public condition;
//     Locker public locker;

//     constructor(address _locker) {
//         locker = Locker(_locker);
//     }

//     function safeTransfer(address to, uint amt) public {
//         safeTransferFrom(msg.sender, to, amt);
//     }

//     function safeTransferFrom(address from, address to, uint amt) public {
//         // ATTACK
//         if (condition) {
//             locker.deposit(address(this), amt);
//         }
//         balances[to] += amt;
//         balances[from] -= amt;
//     }

//     function balanceOf(address a) public view returns (uint256){
//         return balances[a];
//     }

//     function setCondition(bool _condition) public {
//         condition = _condition;
//     }
// }

