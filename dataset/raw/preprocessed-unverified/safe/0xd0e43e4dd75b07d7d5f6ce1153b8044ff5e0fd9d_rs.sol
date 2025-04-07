/**

 *Submitted for verification at Etherscan.io on 2019-02-24

*/



pragma solidity ^0.4.25;







// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------



// Snip3dbridge contract

contract Snip3dbridgecontract is  Owned {

    using SafeMath for uint;

    Snip3DInterface constant Snip3Dcontract_ = Snip3DInterface(0x31cF8B6E8bB6cB16F23889F902be86775bB1d0B3);//0x31cF8B6E8bB6cB16F23889F902be86775bB1d0B3);

    uint256 public toSnipe;

    function harvestableBalance()

        view

        public

        returns(uint256)

    {

        uint256 tosend = address(this).balance.sub(toSnipe);

        return ( tosend)  ;

    }

    function unfetchedVault()

        view

        public

        returns(uint256)

    {

        return ( Snip3Dcontract_.myEarnings())  ;

    }

    function sacUp ()  public payable {

       

        toSnipe = toSnipe.add(msg.value);

    }

    function sacUpto (address masternode, uint256 amount)  public  {

       require(toSnipe>amount.mul(0.1 ether));

        toSnipe = toSnipe.sub(amount.mul(0.1 ether));

        Snip3Dcontract_.sendInSoldier.value(amount.mul(0.1 ether))(masternode , 1);

    }

    function fetchvault ()  public {

      

        Snip3Dcontract_.vaultToWallet(address(this));

    }

    function shoot ()  public {

      

        Snip3Dcontract_.shootSemiRandom();

    }

    function fetchBalance () onlyOwner public {

      uint256 tosend = address(this).balance.sub(toSnipe);

        msg.sender.transfer(tosend);

    }

    function () external payable{} // needs for divs

}