pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0

contract CreateRee2 {
    mapping(address => uint) public counters;

    uint public entered;

    constructor() payable {}

    function deploy_and_win(
        bytes memory initCode,
        address payable winner
    ) public payable returns (address) {
        // to perform a deploy, 1 ether is required
        require(msg.value == 1 ether);

        // every 10 deploys, a prize of 2 ether is sent to the second argument
        if ((counters[msg.sender] + 1) % 10 == 0) {
            // cannot reenter from here due to low gas
            winner.transfer(2 ether);
        }

        address addr;
        assembly {
            // can reenter only from here, i.e. from the constructor code
            addr := create(0, add(initCode, 0x20), mload(initCode))
            if iszero(addr) {
                revert(0, 0)
            }
        }

        // side effect after constructor call makes this vulnerable
        counters[msg.sender] += 1;
        return addr;
    }

    function getCounter(address addr) public view returns (uint) {
        return counters[addr];
    }
}
