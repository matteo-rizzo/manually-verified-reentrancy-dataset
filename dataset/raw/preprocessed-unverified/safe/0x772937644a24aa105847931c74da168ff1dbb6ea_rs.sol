/**
 *Submitted for verification at Etherscan.io on 2021-04-28
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: IBaseOracle



// Part: ICurvePool



// Part: ICurveRegistry



// Part: IERC20Decimal



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


// Part: UsingBaseOracle

contract UsingBaseOracle {
  IBaseOracle public immutable base; // Base oracle source

  constructor(IBaseOracle _base) public {
    base = _base;
  }
}

// File: CurveOracle.sol

contract CurveOracle is UsingBaseOracle, IBaseOracle {
  using SafeMath for uint;

  ICurveRegistry public immutable registry; // Curve registry

  struct UnderlyingToken {
    uint8 decimals; // token decimals
    address token; // token address
  }

  mapping(address => UnderlyingToken[]) public ulTokens; // Mapping from LP token to underlying tokens
  mapping(address => address) public poolOf; // Mapping from LP token to pool

  constructor(IBaseOracle _base, ICurveRegistry _registry) public UsingBaseOracle(_base) {
    registry = _registry;
  }

  /// @dev Register the pool given LP token address and set the pool info.
  /// @param lp LP token to find the corresponding pool.
  function registerPool(address lp) external {
    address pool = poolOf[lp];
    require(pool == address(0), 'lp is already registered');
    pool = registry.get_pool_from_lp_token(lp);
    require(pool != address(0), 'no corresponding pool for lp token');
    poolOf[lp] = pool;
    (uint n, ) = registry.get_n_coins(pool);
    address[8] memory tokens = registry.get_coins(pool);
    for (uint i = 0; i < n; i++) {
      ulTokens[lp].push(
        UnderlyingToken({token: tokens[i], decimals: IERC20Decimal(tokens[i]).decimals()})
      );
    }
  }

  /// @dev Return the value of the given input as ETH per unit, multiplied by 2**112.
  /// @param lp The ERC-20 LP token to check the value.
  function getETHPx(address lp) external view override returns (uint) {
    address pool = poolOf[lp];
    require(pool != address(0), 'lp is not registered');
    UnderlyingToken[] memory tokens = ulTokens[lp];
    uint minPx = uint(-1);
    uint n = tokens.length;
    for (uint idx = 0; idx < n; idx++) {
      UnderlyingToken memory ulToken = tokens[idx];
      uint tokenPx = base.getETHPx(ulToken.token);
      if (ulToken.decimals < 18) tokenPx = tokenPx.div(10**(18 - uint(ulToken.decimals)));
      if (ulToken.decimals > 18) tokenPx = tokenPx.mul(10**(uint(ulToken.decimals) - 18));
      if (tokenPx < minPx) minPx = tokenPx;
    }
    require(minPx != uint(-1), 'no min px');
    // use min underlying token prices
    return minPx.mul(ICurvePool(pool).get_virtual_price()).div(1e18);
  }
}