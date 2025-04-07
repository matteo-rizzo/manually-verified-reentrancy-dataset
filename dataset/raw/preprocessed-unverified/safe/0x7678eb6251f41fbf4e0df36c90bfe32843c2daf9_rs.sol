/**
 *Submitted for verification at Etherscan.io on 2021-04-28
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: IBaseOracle



// Part: IUniswapV2Pair

// https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol



// Part: OpenZeppelin/[emailÂ protected]/SafeMath

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


// Part: HomoraMath



// Part: UsingBaseOracle

contract UsingBaseOracle {
  IBaseOracle public immutable base; // Base oracle source

  constructor(IBaseOracle _base) public {
    base = _base;
  }
}

// File: UniswapV2Oracle.sol

contract UniswapV2Oracle is UsingBaseOracle, IBaseOracle {
  using SafeMath for uint;
  using HomoraMath for uint;

  constructor(IBaseOracle _base) public UsingBaseOracle(_base) {}

  /// @dev Return the value of the given input as ETH per unit, multiplied by 2**112.
  /// @param pair The Uniswap pair to check the value.
  function getETHPx(address pair) external view override returns (uint) {
    address token0 = IUniswapV2Pair(pair).token0();
    address token1 = IUniswapV2Pair(pair).token1();
    uint totalSupply = IUniswapV2Pair(pair).totalSupply();
    (uint r0, uint r1, ) = IUniswapV2Pair(pair).getReserves();
    uint sqrtK = HomoraMath.sqrt(r0.mul(r1)).fdiv(totalSupply); // in 2**112
    uint px0 = base.getETHPx(token0); // in 2**112
    uint px1 = base.getETHPx(token1); // in 2**112
    // fair token0 amt: sqrtK * sqrt(px1/px0)
    // fair token1 amt: sqrtK * sqrt(px0/px1)
    // fair lp price = 2 * sqrt(px0 * px1)
    // split into 2 sqrts multiplication to prevent uint overflow (note the 2**112)
    return sqrtK.mul(2).mul(HomoraMath.sqrt(px0)).div(2**56).mul(HomoraMath.sqrt(px1)).div(2**56);
  }
}