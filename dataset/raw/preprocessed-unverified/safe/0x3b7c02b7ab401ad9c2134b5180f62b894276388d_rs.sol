/**
 *Submitted for verification at Etherscan.io on 2020-07-17
*/

// SPDX-License-Identifier: Leafan.Chan

pragma solidity ^0.6.0;


/**
 * @author  Leafan.Chan <leafan@qq.com>
 *
 * @dev     Contract for imtoken dapp test
 *
 * @notice  Use it for your own risk
 */


/**
 * @title EIP20NonStandardInterface
 * @dev Version of ERC20 with no return values for `transfer` and `transferFrom`
 *  See https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
 */



contract MLFundTest {
    uint256 public constant etherUnit = 1e18;

    // commonly a pair should be base/quote
    // so ett is the base currency, usdt is the quote currency in our game.
    address public constant baseAddr    = 0x65eb823B91B0e17741Ef224dE3Da1ba4e439dfa7;   // ett token addr
    address public constant quoteAddr   = 0xdAC17F958D2ee523a2206206994597C13D831ec7;   // usdt token addr

    // convert token address to contract object
    EIP20NonStandardInterface public constant baseToken     = EIP20NonStandardInterface(baseAddr);
    EIP20NonStandardInterface public constant quoteToken    = EIP20NonStandardInterface(quoteAddr);

    address private _luckyPoolOwner;

    // constructor
    constructor() public {
        _luckyPoolOwner = msg.sender;
    }
    
    
    /**
     * @dev main mlfund function, deposit quote token, and return base token
     */
    function mlfund(uint256 amount) public returns(bool) {
        require(amount > 0, "amount should be greater than 0");
        uint256 testFunds = 10*etherUnit;

        require(baseToken.balanceOf(address(this)) > 0, "contract has no base token now, please retry.");

        quoteToken.transferFrom(msg.sender, _luckyPoolOwner, amount);

        // then do base token transfer
        baseToken.transfer(msg.sender, testFunds);
    }

}