/**
 *Submitted for verification at Etherscan.io on 2020-12-04
*/

// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;


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
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
interface ISTABLEX is IERC20 {
  function a() external view returns (IAddressProvider);

  function mint(address account, uint256 amount) external;

  function burn(address account, uint256 amount) external;
}

// 


// 


// 


// 


// 


// 


// 


// 
/******************
@title WadRayMath library
@author Aave
@dev Provides mul and div function for wads (decimal numbers with 18 digits precision) and rays (decimals with 27 digits)
 */


// 
contract PriceFeedEUR is IPriceFeed {
  using SafeMath for uint256;
  using WadRayMath for uint256;

  event OracleUpdated(address indexed asset, address oracle, address sender);
  event EurOracleUpdated(address oracle, address sender);

  IAddressProvider public override a;

  mapping(address => AggregatorV3Interface) public override assetOracles;

  AggregatorV3Interface public eurOracle;

  constructor(IAddressProvider _addresses) public {
    a = _addresses;
  }

  modifier onlyManager() {
    require(a.controller().hasRole(a.controller().MANAGER_ROLE(), msg.sender), "Caller is not a Manager");
    _;
  }

  /**
   * Gets the asset price in EUR
   * @param _asset address to the collateral asset e.g. WETH
   */
  function getAssetPrice(address _asset) public override view returns (uint256 price) {
    AggregatorV3Interface eurAggregator = eurOracle;
    (, int256 eurAnswer, , , ) = eurAggregator.latestRoundData();

    require(eurAnswer > 0, "EUR price data not valid");

    AggregatorV3Interface aggregator = assetOracles[_asset];
    (, int256 answer, , , ) = aggregator.latestRoundData();

    require(answer > 0, "Price data not valid");

    uint256 price_accuracy = MathPow.pow(10, eurOracle.decimals());

    if (eurAnswer < 0 || answer < 0) {
      return 0; // This is where we may need a fallback oracle
    }

    return uint256(answer).mul(price_accuracy).div(uint256(eurAnswer));
  }

  /**
   * @notice Sets the oracle for the given asset, 
   * @param _asset address to the collateral asset e.g. WETH
   * @param _oracle address to the oracel, this oracle should implement the AggregatorV3Interface
   */
  function setAssetOracle(address _asset, address _oracle) public override onlyManager {
    require(_asset != address(0));
    require(_oracle != address(0));
    _setAssetOracle(_asset, _oracle);
  }

  function _setAssetOracle(address _asset, address _oracle) internal {
    assetOracles[_asset] = AggregatorV3Interface(_oracle);
    emit OracleUpdated(_asset, _oracle, msg.sender);
  }

  /**
   * @notice Sets the oracle for EUR, this oracle should provide EUR-USD prices
   * @param _oracle address to the oracle, this oracle should implement the AggregatorV3Interface
   */
  function setEurOracle(address _oracle) public onlyManager {
    _setEurOracle(_oracle);
  }

  function _setEurOracle(address _oracle) internal {
    require(_oracle != address(0));
    eurOracle = AggregatorV3Interface(_oracle);
    emit EurOracleUpdated(_oracle, msg.sender);
  }

  /**
   * @notice Converts asset balance into stablecoin balance at current price
   * @param _asset address to the collateral asset e.g. WETH
   * @param _balance amount of collateral
   */
  function convertFrom(address _asset, uint256 _balance) public override view returns (uint256) {
    uint256 price = getAssetPrice(_asset);
    uint256 price_accuracy = MathPow.pow(10, eurOracle.decimals());
    return _balance.mul(price).div(price_accuracy);
  }

  /**
   * @notice Converts stablecoin balance into collateral balance at current price
   * @param _asset address to the collateral asset e.g. WETH
   * @param _balance amount of stablecoin
   */
  function convertTo(address _asset, uint256 _balance) public override view returns (uint256) {
    uint256 price = getAssetPrice(_asset);
    uint256 price_accuracy = MathPow.pow(10, eurOracle.decimals());
    return _balance.mul(price_accuracy).div(price);
  }
}