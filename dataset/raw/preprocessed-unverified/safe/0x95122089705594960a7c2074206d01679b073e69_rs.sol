/**
 *Submitted for verification at Etherscan.io on 2021-03-18
*/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.5.15;

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




contract PriceOracleCL {
    using SafeMath for uint256;

    uint256 private constant BASE = 10**18;

    EACAggregatorProxy private _aggregator;

    constructor(EACAggregatorProxy aggregator) public {
        _aggregator = aggregator;
    }

    /**
     * @notice Reads the current answer from aggregator delegated to,
     *          and converted to a decimal point of 18
     * @return The price of the asset aggregator (scaled by 18), zero under unexpected case.
     */
    function getPrice(address asset) external view returns (uint256) {
        asset;
        int256 aggregatorAnswer = _aggregator.latestAnswer();
        if (aggregatorAnswer > 0)
            return BASE.mul(10 ** uint256(_aggregator.decimals())).div(uint256(aggregatorAnswer));

        return 0;
    }

    /**
     * @notice represents the number of decimals the aggregator responses represent.
     * @return The decimal point of the aggregator.
     */
    function decimals() external view returns (uint8) {
        return _aggregator.decimals();
    }

    /**
     * @dev Used to query the source address of the aggregator.
     * @return aggregator address.
     */
    function aggregators() external view returns (address) {
        return address(_aggregator);
    }
}