/**

 *Submitted for verification at Etherscan.io on 2019-04-01

*/



pragma solidity ^0.5.4;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */









contract Wallet is Ownable {



    event ReceiveEther(address indexed _sender, uint256 _value);

    event Pay(address indexed _sender, uint256 _value);



    function() external payable {

        emit ReceiveEther(msg.sender, msg.value);

    }



    function pay(address payable _beneficiary) public onlyOwner {

        uint256 amount = address(this).balance;

        _beneficiary.transfer(amount);

        emit Pay(_beneficiary, amount);

    }



}