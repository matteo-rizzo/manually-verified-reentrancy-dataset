/**

 *Submitted for verification at Etherscan.io on 2019-02-04

*/



pragma solidity ^0.5.2;



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/mocks/Wallet.sol



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