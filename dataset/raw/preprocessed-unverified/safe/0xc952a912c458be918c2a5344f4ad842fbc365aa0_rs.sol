/**
 *Submitted for verification at Etherscan.io on 2020-10-29
*/

// SPDX-License-Identifier: MIT
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






contract Keep3rV1Helper {
    using SafeMath for uint;
    
    IChainLinkFeed public constant FASTGAS = IChainLinkFeed(0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C);
    IUniswapV2Oracle public constant UNIQUOTE = IUniswapV2Oracle(0x127a2975c4E1c75f1ed4757a861bbd42523DB035);
    
    address constant WETH = address(0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44);
    address constant KP3R = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    
    function quote(uint spent) public view returns (uint) {
        return UNIQUOTE.consult(WETH, spent, KP3R);
    }
    
    function quoteGas(uint gasUsed) external view returns (uint) {
        return gasUsed.mul(uint(FASTGAS.latestAnswer()));
    }
    
    function getQuoteLimit(uint gasUsed) external view returns (uint) {
        return quote(gasUsed.mul(uint(FASTGAS.latestAnswer())));
    }
}