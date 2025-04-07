/**
 *Submitted for verification at Etherscan.io on 2021-10-04
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// File: @openzeppelin/contracts/math/SafeMath.sol

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Simple payment splitter
 */
contract royaltySplitter{
    using SafeMath for uint256;

    address payable wallet1=payable(0x38201568A7fEce8Da2248461810a9D42FACcf313); //dev wallet
    address payable wallet2=payable(0x596bB29D8a47EB3a41b68E3664750a60d3A500cB);

    uint256 devFee=5; //5%

    constructor () {
    }

    /**
    * Standard fallback function to allow contract to receive payments
    */
    fallback() external payable {}

    /**
     * @dev Withdraw all ether from this contract and send to prespecified 
     * wallets (Callable by anyone)
    */
    function withdraw() external {
        uint256 balance = address(this).balance;
        uint256 walletBalance = balance.mul(devFee).div(100);
        payable(wallet1).transfer(walletBalance);
        payable(wallet2).transfer(balance.sub(walletBalance));
    }

}