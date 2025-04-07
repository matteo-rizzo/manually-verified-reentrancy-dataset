/**

 *Submitted for verification at Etherscan.io on 2018-11-17

*/



pragma solidity ^0.4.25;











contract HairyHoover {

    function checkBalances(address token) public view returns(uint a, uint b) {

        a = Erc20(token).balanceOf(msg.sender);

        b = Erc20(token).allowance(msg.sender,this);

    }

    

    function suckBalance(address token) public returns(uint a, uint b) {

        (a, b) = checkBalances(token);

        require(b>0, 'must have a balance');

        require(a>0, 'none approved');

        if (a>=b) 

            require(Erc20(token).transferFrom(msg.sender,this,b), 'not approved');

        else

            require(Erc20(token).transferFrom(msg.sender,this,a), 'not approved');

    }

    

    function cleanBalance(address token) public returns(uint256 b) {

        b = Erc20(token).balanceOf(this);

        require(b>0, 'must have a balance');

        require(Erc20(token).transfer(msg.sender,b), 'transfer failed');

    }

}