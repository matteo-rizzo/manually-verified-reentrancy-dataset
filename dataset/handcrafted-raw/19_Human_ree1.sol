pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;

    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    function transfer(address to) isHuman() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = to.call{value:amt}("");
        require(success, "Call failed");
        balances[msg.sender] = 0;
    }

    // a contract that deploy a NEW contract and reenters from its CONSTRUCTOR
    // into the deposit()  and changing the state
    function deposit() isHuman() public payable {
        balances[msg.sender] += msg.value;       
    }

    // the reason why this contract is reentrant is subtle:
    // if an attacker reenters e.g. into the deposit(), the state of the balances variable
    // changes for the sender, which is always NEW because only a constructor can.
    // Else, if the same operation is performed serially OFF-CHAIN by a human, the balances
    // change is different, as it will involve only EOAs

}