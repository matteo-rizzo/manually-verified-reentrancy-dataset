/**
 *Submitted for verification at Etherscan.io on 2020-11-13
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
    IKeep3rV1 public constant KP3R = IKeep3rV1(0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44);
    IUniswapV2SlidingOracle public constant UV2SO = IUniswapV2SlidingOracle(0x73353801921417F465377c8d898c6f4C0270282C);
    address public constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    uint constant public MIN = 11;
    uint constant public MAX = 12;
    uint constant public BASE = 10;
    uint constant public SWAP = 300000;
    uint constant public TARGETBOND = 200e18;
    
    function quote(uint eth) public view returns (uint) {
        return UV2SO.current(address(WETH), eth, address(KP3R));
    }

    function getFastGas() external view returns (uint) {
        return uint(FASTGAS.latestAnswer());
    }

    function bonds(address keeper) public view returns (uint) {
        return KP3R.bonds(keeper, address(KP3R)).add(KP3R.votes(keeper));
    }

    function getQuoteLimitFor(address origin, uint gasUsed) public view returns (uint) {
        uint _quote = quote((gasUsed.add(SWAP)).mul(uint(FASTGAS.latestAnswer())));
        uint _min = _quote.mul(MIN).div(BASE);
        uint _boost = _quote.mul(MAX).div(BASE);
        uint _bond = Math.min(bonds(origin), TARGETBOND);
        return Math.max(_min, _boost.mul(_bond).div(TARGETBOND));
    }

    function getQuoteLimit(uint gasUsed) external view returns (uint) {
        return getQuoteLimitFor(tx.origin, gasUsed);
    }
}