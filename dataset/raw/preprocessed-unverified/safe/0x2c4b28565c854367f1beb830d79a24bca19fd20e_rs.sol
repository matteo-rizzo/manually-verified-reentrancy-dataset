/**
 *Submitted for verification at Etherscan.io on 2021-04-08
*/

// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
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


// 


// 


// 


// 


// 
contract EmployeePriceFeed is IEmployeePriceFeed {
  using SafeMath for uint256;

  uint256 public constant PRICE_ORACLE_STALE_THRESHOLD = 1 days;

  IERC20 public mimo;
  AggregatorV3Interface public eurOracle;
  IPriceFeed public priceFeed;
  mapping(uint256 => uint256) public override priceReachedTimes;

  constructor(
    IERC20 _mimo,
    AggregatorV3Interface _eurOracle,
    IPriceFeed _priceFeed
  ) public {
    require(address(_mimo) != address(0));
    require(address(_eurOracle) != address(0));
    require(address(_priceFeed) != address(0));

    mimo = _mimo;
    eurOracle = _eurOracle;
    priceFeed = _priceFeed;
  }

  function assetPriceReached(uint256 price) public override {
    require(assetPrice() >= price, "price has not been reached");
    priceReachedTimes[price] = block.timestamp;
  }

  function assetPrice() public override view returns (uint256) {
    (, int256 eurAnswer, , uint256 eurUpdatedAt, ) = eurOracle.latestRoundData();
    require(eurAnswer > 0, "EUR price data not valid");
    require(block.timestamp - eurUpdatedAt < PRICE_ORACLE_STALE_THRESHOLD, "EUR price data is stale");

    uint8 eurDecimals = eurOracle.decimals();
    uint256 eurAccuracy = MathPow.pow(10, eurDecimals);

    return priceFeed.getAssetPrice(address(mimo)).mul(uint256(eurAnswer)).div(eurAccuracy);
  }
}