/**

 *Submitted for verification at Etherscan.io on 2018-12-18

*/



pragma solidity ^0.4.25;







contract AntiFrontRunning {

    function sell(IERC20 token, uint256 minAmount) public payable {

        require(token.call.value(msg.value)(), "sell failed");



        uint256 balance = token.balanceOf(this);

        require(balance >= minAmount, "Price too bad");

        token.transfer(msg.sender, balance);

    }

}