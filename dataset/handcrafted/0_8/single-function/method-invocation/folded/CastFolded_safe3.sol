// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


interface I {
    function transfer(uint256 amt) external returns (bool);
}

contract CastFolded_safe3 {
    mapping (address => uint256) public balances;

    function pay(address addr, uint256 amt) internal {
        bool success = I(addr).transfer(amt);   // the implementation is unknown and could be malicious, though the position of the side effect in the function below makes this safe
        require(success, "Call failed");
    }

    function withdraw(address addr) public {
        uint256 amt = balances[msg.sender];
        require(check(amt), "Insufficient funds");
        update();
        pay(addr, amt);
    }

    function update() internal {
        balances[msg.sender] = 0;    // side effect is folded and before the folded call, making this safe
    }

    function check(uint256 amt) internal view returns (bool) {
        return balances[msg.sender] >= amt;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}
