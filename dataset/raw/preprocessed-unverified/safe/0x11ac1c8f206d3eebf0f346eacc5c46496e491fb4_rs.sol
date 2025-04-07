/**

 *Submitted for verification at Etherscan.io on 2019-02-20

*/



/*! payment_processor.sol | (c) 2018 Develop by BelovITLab LLC (smartcontract.ru), author @stupidlovejoy | License: MIT */



pragma solidity 0.4.25;











contract PaymentProcessor is Ownable {

    using SafeMath for uint;



    uint public commission = 10;

    address public recepient = 0x0000000000000000000000000000000000000000;      // §á§â§Ú §Õ§Ö§á§Ý§à§Ö §ß§Ñ§Õ§à §å§Ü§Ñ§Ù§Ñ§ä§î §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ñ

    uint public min_payment = 0.001 ether;



    mapping(address => uint) public buyers;



    event NewCommission(uint previousCommission, uint newCommission);

    event NewRecepient(address previousRecepient, address newRecepient);

    event NewMinPayment(uint previousMinPayment, uint newMinPayment);

    event Payment(address indexed submiter, address indexed recepient, address indexed middleman, uint amount, uint commission);



    function() payable public {

        require(msg.value >= min_payment, "Too small amount");



        address middleman = bytesToAddress(msg.data);



        require(middleman != address(0), "Zero address middleman");

        require(middleman == recepient || buyers[middleman] > 0, "The mediator did not make purchases");



        uint com = msg.value.mul(commission).div(100);

        uint value = msg.value.sub(com);



        recepient.transfer(value);

        middleman.transfer(com);



        buyers[msg.sender] = buyers[msg.sender].add(msg.value);



        emit Payment(msg.sender, recepient, middleman, value, com);

    }



    function bytesToAddress(bytes bys) pure private returns(address addr) {

        assembly {

            addr := mload(add(bys, 20))

        }

    }



    function setCommission(uint new_commission) onlyOwner public {

        emit NewCommission(commission, new_commission);



        commission = new_commission;

    }



    function setRecepient(address new_recepient) onlyOwner public {

        require(new_recepient != address(0), "Zero address");



        emit NewRecepient(recepient, new_recepient);



        recepient = new_recepient;

    }



    function setMinPayment(uint new_min_payment) onlyOwner public {

        emit NewMinPayment(min_payment, new_min_payment);



        min_payment = new_min_payment;

    }

}