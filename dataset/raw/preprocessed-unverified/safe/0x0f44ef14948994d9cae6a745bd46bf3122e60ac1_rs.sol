/**

 *Submitted for verification at Etherscan.io on 2019-06-06

*/



pragma solidity 0.5.8;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







contract x2 is Ownable {

    using SafeMath for uint256;



    uint public depositAmount = 10000000000000000000; // 10 eth

    uint public currentPaymentIndex;

    uint public percent = 150;



    uint public amountRaised;

    uint public depositorsCount;





    struct Deposit {

        address payable depositor;

        uint amount;

        uint payout;

        uint depositTime;

        uint paymentTime;

    }



    // list of all deposites

    Deposit[] public deposits;

    // list of user deposits

    mapping (address => uint[]) public depositors;



    event OnDepositReceived(address investorAddress, uint value);

    event OnPaymentSent(address investorAddress, uint value);





    constructor () public {



    }





    function () external payable {

        makeDeposit();

    }



    function makeDeposit() internal {

        require(msg.value == depositAmount);



        Deposit memory newDeposit = Deposit(msg.sender, msg.value, msg.value.mul(percent).div(100), now, 0);

        deposits.push(newDeposit);



        if (depositors[msg.sender].length == 0) depositorsCount += 1;



        depositors[msg.sender].push(deposits.length - 1);



        amountRaised = amountRaised.add(msg.value);



        emit OnDepositReceived(msg.sender, msg.value);



        owner.transfer(msg.value.mul(10).div(100));



        if (address(this).balance >= deposits[currentPaymentIndex].payout && deposits[currentPaymentIndex].paymentTime == 0) {

            deposits[currentPaymentIndex].paymentTime = now;

            deposits[currentPaymentIndex].depositor.send(deposits[currentPaymentIndex].payout);

            emit OnPaymentSent(deposits[currentPaymentIndex].depositor, deposits[currentPaymentIndex].payout);

            currentPaymentIndex += 1;

        }

    }





    function getDepositsCount() public view returns (uint) {

        return deposits.length;

    }



    function lastDepositId() public view returns (uint) {

        return deposits.length - 1;

    }



    function getDeposit(uint _id) public view returns (address, uint, uint, uint, uint){

        return (deposits[_id].depositor, deposits[_id].amount, deposits[_id].payout,

        deposits[_id].depositTime, deposits[_id].paymentTime);

    }



    function getUserDepositsCount(address depositor) public view returns (uint) {

        return depositors[depositor].length;

    }



    // lastIndex from the end of payments lest (0 - last payment), returns: address of depositor, payment time, payment amount

    function getLastPayments(uint lastIndex) public view returns (address, uint, uint, uint, uint) {

        uint depositIndex = currentPaymentIndex.sub(lastIndex + 1);



        return (deposits[depositIndex].depositor,

        deposits[depositIndex].amount,

        deposits[depositIndex].payout,

        deposits[depositIndex].depositTime,

        deposits[depositIndex].paymentTime);

    }



    function getUserDeposit(address depositor, uint depositNumber) public view returns(uint, uint, uint, uint) {

        return (deposits[depositors[depositor][depositNumber]].amount,

        deposits[depositors[depositor][depositNumber]].payout,

        deposits[depositors[depositor][depositNumber]].depositTime,

        deposits[depositors[depositor][depositNumber]].paymentTime);

    }



}