pragma solidity ^0.4.11;











/// @title Loopring Refund Program

/// @author Kongliang Zhong - <[emailÂ protected]>.

/// For more information, please visit https://loopring.org.

contract BatchTransferContract {

    using SafeMath for uint;

    using Math for uint;



    address public owner;



    function BatchTransferContract(address _owner) public {

        owner = _owner;

    }



    function () payable {

        // do nothing.

    }



    function batchRefund(address[] investors, uint[] ethAmounts) public payable {

        require(msg.sender == owner);

        require(investors.length > 0);

        require(investors.length == ethAmounts.length);



        uint total = 0;

        for (uint i = 0; i < investors.length; i++) {

            total += ethAmounts[i];

        }



        require(total <= this.balance);



        for (i = 0; i < investors.length; i++) {

            if (ethAmounts[i] > 0) {

                investors[i].transfer(ethAmounts[i]);

            }

        }

    }



    function batchRefundzFixed(address[] investors, uint ethAmount) public payable {

        require(msg.sender == owner);

        require(investors.length > 0);

        for (uint i = 0; i < investors.length; i++) {

            investors[i].transfer(ethAmount);

        }

    }



    function drain(uint ethAmount) public payable {

        require(msg.sender == owner);



        uint amount = ethAmount.min256(this.balance);

        if (amount > 0) {

          owner.transfer(amount);

        }

    }

}