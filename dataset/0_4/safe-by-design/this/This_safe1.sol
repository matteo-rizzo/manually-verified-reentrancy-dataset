// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.24;

contract This_safe1 {
    mapping(address => uint256) public balances;

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "No funds");

        bool ok = this.authorize(msg.sender, amt);
        require(ok, "Unauthorized");

        balances[msg.sender] = 0;

        bool success = msg.sender.call.value(amt)("");
        require(success, "Call failed");
    }

    function authorize(address a, uint256 amt) external returns (bool) {
        require(msg.sender == address(this));
        return balances[a] >= amt;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
}
