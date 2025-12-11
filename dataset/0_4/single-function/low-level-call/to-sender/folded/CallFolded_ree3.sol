// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.24;

contract CallFolded_ree3 {
    mapping (address => uint256) public balances;


    function pay(uint256 amt) internal {        
        require(call(amt), "Call failed");
    }

    function call(uint256 amt) internal returns (bool) {
        bool success = msg.sender.call.value(amt)("");
        return success;
    }

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(check(amt), "Insufficient funds");
        pay(amt);
        update();
    }

    function check(uint256 amt) internal pure returns (bool) {
        return amt > 0;
    }

    function update() internal {
        balances[msg.sender] = 0;    // side effect is folded and AFTER the folded call, making this vulnerable
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}