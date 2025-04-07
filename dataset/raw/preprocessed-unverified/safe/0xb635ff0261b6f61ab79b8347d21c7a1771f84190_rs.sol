/**
 *Submitted for verification at Etherscan.io on 2021-05-10
*/

/**
 *Submitted for verification at Etherscan.io on 2017-10-30
*/
pragma solidity ^0.4.11;
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */

contract SimpleWallet is Ownable {
    function () public payable {
    }
    function weiBalance() public constant returns(uint256) {
        return this.balance;
    }
    function claim(address destination) public onlyOwner {
        destination.transfer(this.balance);
    }
}