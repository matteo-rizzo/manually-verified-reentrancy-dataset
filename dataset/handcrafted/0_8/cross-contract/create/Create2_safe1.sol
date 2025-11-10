// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Create2_safe1 {
    mapping(address => uint) public counters;

    function deploy_and_win(
        bytes memory initCode,
        address payable winner,
        uint salt
    ) public payable returns (address) {
        // to perform a deploy, 100 is required
        require(msg.value == 100);

        // every 10 deploys, a prize of 200 is sent to the second argument
        if ((counters[msg.sender] + 1) % 10 == 0) {
            winner.transfer(200); // cannot reenter from here due to low gas
        }

        counters[msg.sender] += 1; // side effect before constructor call makes this safe

        address addr;
        assembly {
            addr := create2(0, add(initCode, 0x20), mload(initCode), salt) // can reenter only from here, i.e. from the constructor code
            if iszero(addr) {
                revert(0, 0)
            }
        }

        return addr;
    }
}
