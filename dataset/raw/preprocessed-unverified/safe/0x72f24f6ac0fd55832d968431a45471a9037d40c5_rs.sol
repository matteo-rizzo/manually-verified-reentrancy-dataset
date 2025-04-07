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

contract Sac3D is  Owned {

    using SafeMath for uint;

    Snip3DInterface constant Snip3Dcontract_ = Snip3DInterface(0x4fac33dAbFd83d160717dFee4175d9cAaA249CA5);

    function harvestableBalance()

        view

        public

        returns(uint256)

    {

        return ( address(this).balance)  ;

    }

    function unfetchedVault()

        view

        public

        returns(uint256)

    {

        return ( Snip3Dcontract_.myEarnings())  ;

    }

    function sacUp () onlyOwner public payable {

       

        Snip3Dcontract_.offerAsSacrifice.value(0.1 ether)(msg.sender);

    }/*

    function validate () onlyOwner public {

       

        Snip3Dcontract_.tryFinalizeStage();

    }*/

    function fetchvault () onlyOwner public {

      

        Snip3Dcontract_.withdraw();

    }

    function fetchBalance () onlyOwner public {

      

        msg.sender.transfer(address(this).balance);

    }

}