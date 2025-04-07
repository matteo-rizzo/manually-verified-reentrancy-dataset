/**

 *Submitted for verification at Etherscan.io on 2019-01-19

*/



pragma solidity ^0.4.25;







// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------



// Snip3dbridge contract

contract Slaughter3D is  Owned {

    using SafeMath for uint;

    Snip3DInterface constant Snip3Dcontract_ = Snip3DInterface(0xb172BB8BAae74F27Ade3211E0c145388d3b4f8d8);// change to real address

    uint256 public toSlaughter;

    function harvestableBalance()

        view

        public

        returns(uint256)

    {

        uint256 toReturn = address(this).balance.sub(toSlaughter);

        return ( toReturn)  ;

    }

    function unfetchedVault()

        view

        public

        returns(uint256)

    {

        return ( Snip3Dcontract_.myEarnings())  ;

    }

    function sacUp ()  public payable {

       

        toSlaughter = toSlaughter.add(msg.value);

    }

    function sacUpto (address masternode)  public {

        require(toSlaughter> 0.1 ether);

        toSlaughter = toSlaughter.sub(0.1 ether);

        Snip3Dcontract_.offerAsSacrifice.value(0.1 ether)(masternode);

    }

    function validate ()  public {

       

        Snip3Dcontract_.tryFinalizeStage();

    }

    function fetchvault () public {

      

        Snip3Dcontract_.withdraw();

    }

    function fetchBalance () onlyOwner public {

      uint256 tosend = address(this).balance.sub(toSlaughter);

        msg.sender.transfer(tosend);

    }

    function () external payable{} // needs for divs

}