/**

 *Submitted for verification at Etherscan.io on 2019-06-14

*/



pragma solidity 0.5.9;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract Distripto is Ownable {



    using SafeMath for uint256;



    uint public minDeposit = 10000000000000000; // 0.01 eth

    uint public maxDeposit = 1000000000000000000; // 1 eth

    uint public minDistribute = 2 ether;

    uint public currentPaymentIndex;

    uint public amountForDistribution;

    uint public percent = 120;



    uint public lastWinnerPeriod = 12 hours;



    uint public amountRaised;

    uint public depositorsCount;



    address payable promoWallet;



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

        promoWallet = msg.sender;

    }





    function () external payable {

        if (msg.value > 0) {

            makeDeposit();

        } else {

            distributeLast();

            distribute(0);

        }

    }





    function makeDeposit() internal {

        require (msg.value >= minDeposit && msg.value <= maxDeposit);



        if (deposits.length > 0 && deposits[deposits.length - 1].depositTime + lastWinnerPeriod < now) {

            distributeLast();

        }



        Deposit memory newDeposit = Deposit(msg.sender, msg.value, msg.value.mul(percent).div(100), now, 0);

        deposits.push(newDeposit);



        if (depositors[msg.sender].length == 0) depositorsCount += 1;



        depositors[msg.sender].push(deposits.length - 1);

        amountForDistribution = amountForDistribution.add(msg.value);



        amountRaised = amountRaised.add(msg.value);



        emit OnDepositReceived(msg.sender, msg.value);

    }





    function distributeLast() public  {

        if(deposits.length > 0 && deposits[deposits.length - 1].depositTime + lastWinnerPeriod < now) {

            uint val = deposits[deposits.length - 1].amount.mul(10).div(100);

            if (address(this).balance >= deposits[deposits.length - 1].payout + val) {

                if (deposits[deposits.length - 1].paymentTime == 0) {

                    deposits[deposits.length - 1].paymentTime = now;

                    promoWallet.transfer(val);

                    deposits[deposits.length - 1].depositor.send(deposits[deposits.length - 1].payout);

                    emit OnPaymentSent(deposits[deposits.length - 1].depositor, deposits[deposits.length - 1].payout);

                }

            }

        }

    }





    function distribute(uint _iterations) public  {

        if (address(this).balance >= minDistribute) {

            promoWallet.transfer(amountForDistribution.mul(10).div(100));



            _iterations = _iterations == 0 ? deposits.length : _iterations;



            for (uint i = currentPaymentIndex; i < _iterations && address(this).balance >= deposits[i].payout; i++) {

                if (deposits[i].paymentTime == 0) {

                    deposits[i].paymentTime = now;

                    deposits[i].depositor.send(deposits[i].payout);

                    emit OnPaymentSent(deposits[i].depositor, deposits[i].payout);

                }



                currentPaymentIndex += 1;

            }



            amountForDistribution = 0;

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





    function setNewMinDeposit(uint newMinDeposit) public onlyOwner {

        minDeposit = newMinDeposit;

    }



    function setNewMaxDeposit(uint newMaxDeposit) public onlyOwner {

        maxDeposit = newMaxDeposit;

    }



    function setPromoWallet(address payable newPromoWallet) public onlyOwner {

        require (newPromoWallet != address(0));

        promoWallet = newPromoWallet;

    }

}