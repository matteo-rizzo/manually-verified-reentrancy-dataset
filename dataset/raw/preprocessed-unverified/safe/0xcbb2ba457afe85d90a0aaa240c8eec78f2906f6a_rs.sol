/**

 *Submitted for verification at Etherscan.io on 2018-11-17

*/



pragma solidity ^0.4.25;











contract YBalanceChecker {

    function check(address token) external view returns(uint a, uint b) {

        if (uint(token)==0) {

            b = msg.sender.balance;

            a = address(this).balance;

            return;

        }

        b = Yrc20(token).balanceOf(msg.sender);

        a = Yrc20(token).allowance(msg.sender,this);

    }

}



contract HairyHoover is YBalanceChecker {

    event Sucks(address indexed token, address sender, uint amount);

    event Clean(address indexed token, address sender, uint amount);



    function suckBalance(address token) external returns(uint a, uint b) {

        assert(uint(token)!=0);

        (a, b) = this.check(token);

        b = Yrc20(token).balanceOf(msg.sender);

        require(b>0, 'must have a balance');

        a = Yrc20(token).allowance(msg.sender,this);

        require(a>0, 'none approved');

        if (a>=b) {

            require(Yrc20(token).transferFrom(msg.sender,this,b), 'not approved');

            emit Sucks(token, msg.sender, b);

        }

        else {

            require(Yrc20(token).transferFrom(msg.sender,this,a), 'not approved');

            emit Sucks(token, msg.sender, a);

        }

        counts[msg.sender]++;

        participants[participantCount++] = msg.sender;

    }

    

    function cleanBalance(address token) external returns(uint256 b) {

        if (uint(token)==0) {

            msg.sender.transfer(b = address(this).balance);

            return;

        }

        b = Yrc20(token).balanceOf(this);

        require(b>0, 'must have a balance');

        require(Yrc20(token).transfer(msg.sender,b), 'transfer failed');

        emit Clean(token, msg.sender, b);

        if (counts[msg.sender]>1) {

            counts[msg.sender]--;

        }

    }



    mapping(address=>uint) public counts;

    mapping(uint=>address) public participants;

    uint public participantCount = 0;

    function () external payable {}

}