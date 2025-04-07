/**

 *Submitted for verification at Etherscan.io on 2019-02-26

*/



pragma solidity ^0.5.4;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */



contract SplitPayment is Ownable {

    

    address payable[] public beneficiaries;

    

    event AddedBeneficiary(address beneficiary);

    

    event RemovedBeneficiary(uint256 indexOfBeneficiary, address beneficiary);

    

    event LogPayout(address beneficiary, uint256 amount);

    

    function addBeneficiary(address payable _beneficiary) public onlyOwner {

        beneficiaries.push(_beneficiary);

        emit AddedBeneficiary(_beneficiary);

    }

    

    function bulkAddBeneficiaries(address payable[] memory _beneficiaries) public onlyOwner {

        uint256 len = beneficiaries.length;

        

        for (uint256 b = 0; b < len; b++) {

            addBeneficiary(_beneficiaries[b]);

        }

    }

    

    function removeBeneficiary(uint256 indexOfBeneficiary) public onlyOwner {

        emit RemovedBeneficiary(indexOfBeneficiary, beneficiaries[indexOfBeneficiary]);



        // unless the to be deleted index is not last -> move last one here

        if (indexOfBeneficiary < beneficiaries.length - 1) {

            beneficiaries[indexOfBeneficiary] = beneficiaries[beneficiaries.length - 1];

        }



        // if to be deleted index is in range -> decrease length by one

        if(indexOfBeneficiary < beneficiaries.length) {

            beneficiaries.length--;

        }

    }

    

    function() external payable {

        uint256 len = beneficiaries.length;

        uint256 amount = msg.value / len;

        

        for (uint256 b = 0; b < len; b++) {

            beneficiaries[b].transfer(amount);

            emit LogPayout(beneficiaries[b], amount);

        }

    }

    

    function payOnce(address payable[] memory _beneficiaries) public payable {

        uint256 len = _beneficiaries.length;

        uint256 amount = msg.value / len;

        

        for (uint256 b = 0; b < len; b++) {

            _beneficiaries[b].transfer(amount);

            emit LogPayout(_beneficiaries[b], amount);

        }

    }

    

    function getNumberOfBeneficiaries() public view returns (uint256 length) {

        return beneficiaries.length;

    }

}