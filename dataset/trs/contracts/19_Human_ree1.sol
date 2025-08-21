pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract Victim {
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

    // this is reentrant because the "to" parameter above could be a contract reentering into the deposit() and changing the state
    function deposit() isHuman() public payable {
        balances[msg.sender] += msg.value;       
    }

}
