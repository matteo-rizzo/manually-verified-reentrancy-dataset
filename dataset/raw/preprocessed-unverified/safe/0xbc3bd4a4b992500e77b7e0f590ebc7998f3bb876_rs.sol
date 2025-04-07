/**

 *Submitted for verification at Etherscan.io on 2018-12-15

*/



pragma solidity ^0.4.25;







contract Forwarder {

    address owner;



    constructor() public {

        owner = msg.sender;

    }



    function flush(ERC20Interface _token) public {

        require(msg.sender == owner, "Unauthorized caller");

        _token.transfer(owner, _token.balanceOf(address(this)));

    }

}