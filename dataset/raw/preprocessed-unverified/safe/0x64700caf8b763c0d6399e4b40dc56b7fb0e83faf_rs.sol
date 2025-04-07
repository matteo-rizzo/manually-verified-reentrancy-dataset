/**

 *Submitted for verification at Etherscan.io on 2018-09-14

*/



pragma solidity ^0.4.23;



// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------





contract FundsTransfer is Owned{

    address public wallet;

    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    constructor (address _wallet, address _owner) public{

        wallet = _wallet;

        owner = _owner;

    }



    function () external payable{

        _forwardFunds(msg.value);   

    }

  

    function _forwardFunds(uint256 _amount) internal {

        wallet.transfer(_amount);

    }

    

    function changeWallet(address newWallet) public onlyOwner {

        wallet = newWallet;

    }

}