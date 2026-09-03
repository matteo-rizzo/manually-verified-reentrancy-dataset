// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract This_safe1 {
    mapping(address => uint256) public balances;

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "No funds");

        // this.authorize is externally dispatched, but its target is the
        // current contract and therefore does not transfer control to
        // attacker-controlled code in this MWE.
        bool ok = this.authorize(msg.sender, amt);
        require(ok, "Unauthorized");

        balances[msg.sender] = 0;

        // The actual attacker-controlled interaction occurs only after the
        // recorded balance has been cleared.
        (bool success, ) = payable(msg.sender).call{value: amt}("");
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
