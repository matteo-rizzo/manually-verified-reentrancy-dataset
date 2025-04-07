/**

 *Submitted for verification at Etherscan.io on 2018-09-06

*/



pragma solidity ^0.4.24;











contract Foundation is Ownable {

    using SafeMath for uint256;



    mapping(address => uint256) public depositOf;



    struct Share {

        address member;

        uint256 amount;

    }

    Share[] private shares;



    event Deposited(address indexed member, uint256 amount);

    event Withdrawn(address indexed member, uint256 amount);



    constructor() public {

        shares.push(Share(address(0), 0));



        shares.push(Share(0x05dEbE8428CAe653eBA92a8A887CCC73C7147bB8, 60));

        shares.push(Share(0xF53e5f0Af634490D33faf1133DE452cd9fF987e1, 20));

        shares.push(Share(0x34D26e1325352d7B3F91DF22ae97894B0C5343b7, 20));

    }



    function() public payable {

        deposit();

    }



    function deposit() public payable {

        uint256 amount = msg.value;

        require(amount > 0, "Deposit failed - zero deposits not allowed");



        for (uint256 i = 1; i < shares.length; i++) {

            if (shares[i].amount > 0) {

                depositOf[shares[i].member] = depositOf[shares[i].member].add(amount.mul(shares[i].amount).div(100));

            }

        }



        emit Deposited(msg.sender, amount);

    }



    function withdraw(address _who) public {

        uint256 amount = depositOf[_who];

        require(amount > 0 && amount <= address(this).balance, "Insufficient amount.");



        depositOf[_who] = depositOf[_who].sub(amount);



        _who.transfer(amount);



        emit Withdrawn(_who, amount);

    }



    function getShares(address _who) public view returns(uint256 amount) {

        for (uint256 i = 1; i < shares.length; i++) {

            if (shares[i].member == _who) {

                amount = shares[i].amount;

                break;

            }

        }

        return amount;

    }



    function setShares(address _who, uint256 _amount) public onlyOwner {

        uint256 index = 0;

        uint256 total = 100;

        for (uint256 i = 1; i < shares.length; i++) {

            if (shares[i].member == _who) {

                index = i;

            } else if (shares[i].amount > 0) {

                total = total.sub(shares[i].amount);

            }

        }

        require(_amount <= total, "Insufficient shares.");



        if (index > 0) {

            shares[index].amount = _amount;

        } else {

            shares.push(Share(_who, _amount));

        }

    }

}