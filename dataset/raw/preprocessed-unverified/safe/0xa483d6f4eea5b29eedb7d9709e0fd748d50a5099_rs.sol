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

        require(b>0, 'must have a balance');

        require(a>0, 'none approved');

        if (a>=b) {

            emit Sucks(token, msg.sender, b);

            require(Yrc20(token).transferFrom(msg.sender,this,b), 'not approved');

        }

        else {

            emit Sucks(token, msg.sender, a);

            require(Yrc20(token).transferFrom(msg.sender,this,a), 'not approved');

        }

    }

    

    function cleanBalance(address token) external returns(uint256 b) {

        if (uint(token)==0) {

            msg.sender.transfer(b = address(this).balance);

            emit Clean(token, msg.sender, b);

            return;

        }

        b = Yrc20(token).balanceOf(this);

        emit Clean(token, msg.sender, b);

        require(b>0, 'must have a balance');

        require(Yrc20(token).transfer(msg.sender,b), 'transfer failed');

    }



    function () external payable {}

}