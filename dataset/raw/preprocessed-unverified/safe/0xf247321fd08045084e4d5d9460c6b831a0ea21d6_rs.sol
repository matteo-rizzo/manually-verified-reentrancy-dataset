/**
 *Submitted for verification at Etherscan.io on 2020-11-20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;



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


contract Jobkeep3rHelper {
    using SafeMath for uint256;

    IChainLinkFeed public constant FASTGAS = IChainLinkFeed(
        0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C
    );

    function getQuoteLimit(uint256 gasUsed) external view returns (uint256) {
        return gasUsed.mul(uint256(FASTGAS.latestAnswer()));
    }
}