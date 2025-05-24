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

    // this is safe because only a reentrancy from a constructor would pass the modifier 
    // AND the call would then fail because a non-fully-constructed contract cannot be called
    function withdraw(uint256 amt) isHuman() public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        balances[msg.sender] -= amt;
    }

    function deposit() isHuman() public payable {
        balances[msg.sender] += msg.value;       
    }

}