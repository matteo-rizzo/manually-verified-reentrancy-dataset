/**
 *Submitted for verification at Etherscan.io on 2020-11-02
*/

// SPDX-License-Identifier: MIT

/**
 * https://kp3.network
 * 
 */


pragma solidity ^0.6.12;

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








contract Keep3Helper {
    using SafeMath for uint;
    
    IChainLinkFeed public constant FASTGAS = IChainLinkFeed(0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C);
    IKeep3 public constant KP3R = IKeep3(0xE218F275475a1Eb5DDE119Bcb2ec5f9bFd3Ac513);
    
    uint constant public BOOST = 25;
    uint constant public BASE = 10;
    uint constant public TARGETBOND = 100e18;
    
    function getFastGas() external view returns (uint) {
        return uint(FASTGAS.latestAnswer());
    }
    
    function bonds(address keeper) public view returns (uint) {
        return KP3R.bonds(keeper, address(KP3R)).add(KP3R.votes(keeper));
    }
    
    function getQuoteLimitFor(address origin, uint gasUsed) public view returns (uint) {
        uint _min = gasUsed.mul(uint(FASTGAS.latestAnswer()));
        uint _boost = _min.mul(BOOST).div(BASE); // increase by 2.5
        uint _bond = Math.min(bonds(origin), TARGETBOND);
        return Math.max(_min, _boost.mul(_bond).div(TARGETBOND));
    }
    
    function getQuoteLimit(uint gasUsed) external view returns (uint) {
        return getQuoteLimitFor(tx.origin, gasUsed);
    }
}