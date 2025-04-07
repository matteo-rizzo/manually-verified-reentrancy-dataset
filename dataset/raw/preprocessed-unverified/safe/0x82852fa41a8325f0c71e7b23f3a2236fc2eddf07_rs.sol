/**

 *Submitted for verification at Etherscan.io on 2018-09-21

*/



pragma solidity ^0.4.24;





///@title Dremabridge Payment contract

///@author Arq

///@notice Simple payment contract that checks an address for an "Operating Threshold" which is a set balance of ether, the remaining balance to another Address called Cold Storage.



contract paymentContract {



    using SafeMath for uint256;



    address operatingAddress;

    address coldStorage;



    uint public opThreshold;

    

///@author Arq

///@notice Constructor function determines the payment parties and threshold.

///@param _operatingAddress - The Address that will be refilled by payments to this contract.

///@param _coldStorage - The Address of the Cold Storage wallet, where overflow funds are sent.

///@param _threshold - The level to which this contract will replenish the funds in the operatingAddress wallet.

    constructor(address _operatingAddress, address _coldStorage, uint _threshold) public {

        operatingAddress = _operatingAddress;

        coldStorage = _coldStorage;

        opThreshold = _threshold * 1 ether;

    }

///@author Arq

///@notice The Fallback Function that accepts payments.

///@dev Contract can be used as a payment source.

    function () public payable {

        distribute();

    }



    ///@author Arq

    ///@notice Function that sends funds to either Cold Storage, Operating Address, or both based on the Operating Threshold.

    ///@dev opThreshold determines what the balance in the operatingAddress should be, at a minimum.

        function distribute() internal {

            if(operatingAddress.balance < opThreshold) {

                if(address(this).balance < (opThreshold - operatingAddress.balance)){

                    operatingAddress.transfer(address(this).balance);

                } else {

                    operatingAddress.transfer(opThreshold - operatingAddress.balance);

                    coldStorage.transfer(address(this).balance);

                }

            } else {

                coldStorage.transfer(address(this).balance);

            }

        }

}