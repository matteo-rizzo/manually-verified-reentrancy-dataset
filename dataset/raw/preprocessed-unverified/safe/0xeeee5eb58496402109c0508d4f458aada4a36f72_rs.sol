/**
 *Submitted for verification at Etherscan.io on 2020-11-14
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.7.4;



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



/**
 * @dev Interface of UniswapV2Router02, two functions only.
 */


/**
 * @dev Ether2DAI, provide only `ether2usd` function to get the ether price in USD.
 */
contract Ether2DAI {
    using SafeMath for uint256;

    IUniswapV2Router02 private immutable UniswapV2Router02 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    address private _token = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);  // DAI mainnet
    uint8 private _decimals = 18;

    function ether2usd()
        public
        view
        returns (uint256)
    {
        return UniswapV2Router02.getAmountsOut(1 ether, _path4ether2usd())[1].mul(1_000_000).div(10 ** _decimals);
    }

    function _path4ether2usd()
        private
        view
        returns (address[] memory)
    {
        address[] memory path = new address[](2);
        path[0] = UniswapV2Router02.WETH();
        path[1] = _token;

        return path;
    }
}