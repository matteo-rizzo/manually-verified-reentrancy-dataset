pragma solidity ^0.4.19;



// EasySend

// A service on top of the AHS for sending ETH to a handle















contract EasySend is Ownable {



    AHSInterface public ahs;



    function EasySend(AHSInterface _ahs) public {

        ahs = _ahs;

    }



    function sendETH(bytes32 _base, bytes32 _handle) public payable {

        require(ahs.isRegistered(_base));

        require(findAddress(_base, _handle) != address(0));

        require(msg.value > 0);

        address to = findAddress(_base, _handle);

        to.transfer(msg.value);

    }



    function findAddress(bytes32 _base, bytes32 _handle) public view returns(address) {

        address addr = ahs.findAddress(_base, _handle);

        assert(addr != address(0));

        return addr;

    }



}