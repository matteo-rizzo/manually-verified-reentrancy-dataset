/**

 *Submitted for verification at Etherscan.io on 2018-11-26

*/



pragma solidity ^0.4.25;







// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------



// Snip3dbridge contract

contract Snip3D is  Owned {

    using SafeMath for uint;

    Snip3DInterface constant Snip3Dcontract_ = Snip3DInterface(0x6D534b48835701312ebc904d4b37e54D4f7D039f);

    

    function soldierUp () onlyOwner public payable {

       

        Snip3Dcontract_.sendInSoldier.value(0.1 ether)(msg.sender);

    }

    function shoot () onlyOwner public {

       

        Snip3Dcontract_.shootSemiRandom();

    }

    function fetchdivs () onlyOwner public {

      

        Snip3Dcontract_.fetchdivs(address(this));

    }

    function fetchBalance () onlyOwner public {

      

        msg.sender.transfer(address(this).balance);

    }

}