/**

 *Submitted for verification at Etherscan.io on 2018-11-16

*/



pragma solidity ^0.4.24;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract Donation is Ownable {

    

    event Donated(address donator, uint amount);

    

    function () public payable {

        emit Donated(msg.sender, msg.value);

    }

    

    function claim() public onlyOwner {

        msg.sender.transfer(getBalance());

    }

    

    function getBalance() public view returns (uint) {

        return address(this).balance;

    }

}