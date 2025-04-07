/**

 *Submitted for verification at Etherscan.io on 2018-11-13

*/



pragma solidity ^0.4.23;



/**

* @title Ownable

* @dev The Ownable contract has an owner address, and provides basic authorization control

* functions, this simplifies the implementation of "user permissions".

*/





contract Hub is Ownable{

    address public tokenAddress;

    address public profileAddress;

    address public holdingAddress;

    address public readingAddress;

    address public approvalAddress;



    address public profileStorageAddress;

    address public holdingStorageAddress;

    address public readingStorageAddress;



    event ContractsChanged();



    function setTokenAddress(address newTokenAddress)

    public onlyOwner {

        tokenAddress = newTokenAddress;

        emit ContractsChanged();

    }



    function setProfileAddress(address newProfileAddress)

    public onlyOwner {

        profileAddress = newProfileAddress;

        emit ContractsChanged();

    }



    function setHoldingAddress(address newHoldingAddress)

    public onlyOwner {

        holdingAddress = newHoldingAddress;

        emit ContractsChanged();

    }



    function setReadingAddress(address newReadingAddress)

    public onlyOwner {

        readingAddress = newReadingAddress;

        emit ContractsChanged();

    }



    function setApprovalAddress(address newApprovalAddress)

    public onlyOwner {

        approvalAddress = newApprovalAddress;

        emit ContractsChanged();

    }





    function setProfileStorageAddress(address newpPofileStorageAddress)

    public onlyOwner {

        profileStorageAddress = newpPofileStorageAddress;

        emit ContractsChanged();

    }



    function setHoldingStorageAddress(address newHoldingStorageAddress)

    public onlyOwner {

        holdingStorageAddress = newHoldingStorageAddress;

        emit ContractsChanged();

    }

    

    function setReadingStorageAddress(address newReadingStorageAddress)

    public onlyOwner {

        readingStorageAddress = newReadingStorageAddress;

        emit ContractsChanged();

    }



    function isContract(address sender) 

    public view returns (bool) {

        if(sender == owner ||

           sender == tokenAddress ||

           sender == profileAddress ||

           sender == holdingAddress ||

           sender == readingAddress ||

           sender == approvalAddress ||

           sender == profileStorageAddress ||

           sender == holdingStorageAddress ||

           sender == readingStorageAddress) {

            return true;

        }

        return false;

    }

}