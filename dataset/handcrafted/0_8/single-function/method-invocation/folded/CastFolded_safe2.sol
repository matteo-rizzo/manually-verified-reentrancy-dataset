// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../../interfaces/single-function/IMethodInvocation.sol";

contract CastFolded_safe2 {
    mapping(address => uint256) public balances;

    function pay(address addr, uint256 amt) internal {
        bool success = IMethodCallee(addr).transfer{value: amt}(); // the implementation is unknown and could be malicious, though the position of the side effect in the function below makes this safe
        require(success, "Call failed");
    }

    function withdraw(address addr) public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        update();
        pay(addr, amt);
    }

    function update() internal {
        balances[msg.sender] = 0; // side effect is folded and before the folded call, making this safe
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
}
