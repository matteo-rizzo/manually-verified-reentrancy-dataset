/**
 *Submitted for verification at Etherscan.io on 2021-08-09
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;



// Part: OpenZeppelin/[emailÂ protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: MultiSender.sol

contract MultiSender {
    function transferBatch(IERC20 token, uint256 amount, address[] calldata target) external {
        for (uint i = 0; i < target.length; i++) {
            token.transferFrom(msg.sender, target[i], amount);
        }
    }
}