/**
 *Submitted for verification at Etherscan.io on 2020-11-28
*/

pragma solidity 0.7.4;

/**
 * @dev Collection of functions related to the address type
 */


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



/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Hegic
 * Copyright (C) 2020 Hegic Protocol
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @author 0mllwntrmt3
 * @title Hegic Initial Offering
 * @notice some description
 */
contract MimirBondingCurveSale is Ownable {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    event SaleStarted( uint256 saleStatTime, uint256 saleEndTime );
    event Claimed(address indexed account, uint userShare, uint mimirAmount);
    event Received(address indexed account, uint amount);

    uint public START;
    uint public END;
    uint public TOTAL_DISTRIBUTE_AMOUNT;
    uint public MINIMAL_PROVIDE_AMOUNT = 600 ether;
    uint public totalProvided = 0;
    mapping(address => uint) public provided;
    IERC20 public MIMIRTOKEN;
    // ERC20 public immutable SAFEMIMIRTOKEN;

    constructor() {}

    function setTokenForSale( IERC20 mimirToken_ ) public onlyOwner() {
        MIMIRTOKEN = mimirToken_;
        TOTAL_DISTRIBUTE_AMOUNT = mimirToken_.balanceOf( address(this) );
    }

    function startSale() public onlyOwner() {
        START = block.timestamp;
        END = START + 3 days;
        emit SaleStarted( START, END );
    }

    receive() external payable {
        require(START <= block.timestamp, "The offering has not started yet");
        require(block.timestamp <= END, "The offering has already ended");
        totalProvided += msg.value;
        provided[Context._msgSender()] += msg.value;
        emit Received(Context._msgSender(), msg.value);
    }

    function claim() external {
        require(block.timestamp > END);
        require(provided[Context._msgSender()] > 0);

        uint userShare = provided[Context._msgSender()];
        provided[Context._msgSender()] = 0;

        if(totalProvided >= MINIMAL_PROVIDE_AMOUNT) {
            uint mimirAmount = TOTAL_DISTRIBUTE_AMOUNT
                .mul(userShare)
                .div(totalProvided);
            MIMIRTOKEN.safeTransfer(Context._msgSender(), mimirAmount);
            emit Claimed(Context._msgSender(), userShare, mimirAmount);
        } else {
            Context._msgSender().transfer(userShare);
            emit Claimed(Context._msgSender(), userShare, 0);
        }
    }

    function withdrawProvidedETH() external onlyOwner() {
        require(END < block.timestamp, "The offering must be completed");
        require(
            totalProvided >= MINIMAL_PROVIDE_AMOUNT,
            "The required amount has not been provided!"
        );
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawUnclaimedMimir() external onlyOwner() {
        require(END + 7 days < block.timestamp, "Withdrawal unavailable yet");
        MIMIRTOKEN.safeTransfer(owner(), MIMIRTOKEN.balanceOf(address(this)));
    }
}