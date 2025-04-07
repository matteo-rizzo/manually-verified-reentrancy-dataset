/**
 *Submitted for verification at Etherscan.io on 2020-11-09
*/

// Keep4r.Network ğŸš€


// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

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








/*contract FASTGASPlaceholder is IChainLinkFeed {
    function latestAnswer() override external view returns (int256) {
        return 21120000000;
    }
}*/

contract Keep4rV1Helper {
    using SafeMath for uint;

    IChainLinkFeed public FASTGAS; //= IChainLinkFeed(0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C);
    IKeep4rV1 public KP4R; //= IKeep4rV1(0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44);


    uint constant public BOOST = 50;
    uint constant public BASE = 10;
    uint constant public TARGETBOND = 200e18;

    uint constant public PRICE = 10;
    
    constructor (address _fastGas, address _kp4r) public {
        FASTGAS = IChainLinkFeed(_fastGas);
        KP4R = IKeep4rV1(_kp4r);
    }

    function getFastGas() external view returns (uint) {
        return uint(FASTGAS.latestAnswer());
    }

    function bonds(address keeper) public view returns (uint) {
        return KP4R.bonds(keeper, address(KP4R)).add(KP4R.votes(keeper));
    }

    function getQuoteLimitFor(address origin, uint gasUsed) public view returns (uint) {
        uint _min = gasUsed.mul(PRICE).mul(uint(FASTGAS.latestAnswer()));
        uint _boost = _min.mul(BOOST).div(BASE); // increase by 2.5
        uint _bond = Math.min(bonds(origin), TARGETBOND);
        return Math.max(_min, _boost.mul(_bond).div(TARGETBOND));
    }

    function getQuoteLimit(uint gasUsed) external view returns (uint) {
        // solhint-disable avoid-tx-origin
        return getQuoteLimitFor(tx.origin, gasUsed);
    }
    
}