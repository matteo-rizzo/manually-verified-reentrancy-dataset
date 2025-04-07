/*

    /     |  __    / ____|
   /      | |__) | | |
  / /    |  _  /  | |
 / ____   | |    | |____
/_/    _ |_|  _  _____|

* ARC: impl/ChainLinkOracle.sol
*
* Latest source (may be newer): https://github.com/arcxgame/contracts/blob/master/contracts/impl/ChainLinkOracle.sol
*
* Contract Dependencies: 
*	- IOracle
* Libraries: 
*	- Decimal
*	- Math
*	- SafeMath
*
* MIT License
* ===========
*
* Copyright (c) 2020 ARC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

pragma experimental ABIEncoderV2;

/* ===============================================
* Flattened with Solidifier by Coinage
* 
* https://solidifier.coina.ge
* ===============================================
*/


pragma solidity ^0.5.0;

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



// SPDX-License-Identifier: MIT


/**
 * @title Math
 *
 * Library for non-standard Math functions
 */


// SPDX-License-Identifier: MIT


/**
 * @title Decimal
 *
 * Library that defines a fixed-point number with 18 decimal places.
 */



// SPDX-License-Identifier: MIT





// SPDX-License-Identifier: MIT





// SPDX-License-Identifier: MIT


contract ChainLinkOracle is IOracle {

    using SafeMath for uint256;

    IChainLinkAggregator public chainLinkAggregator;

    uint256 constant public CHAIN_LINK_DECIMALS = 10**8;

    constructor(address _chainLinkAggregator) public {
        chainLinkAggregator = IChainLinkAggregator(_chainLinkAggregator);
    }

    function fetchCurrentPrice()
        external
        view
        returns (Decimal.D256 memory)
    {
        return Decimal.D256({
            value: uint256(chainLinkAggregator.latestAnswer()).mul(uint256(10**10))
        });
    }

}