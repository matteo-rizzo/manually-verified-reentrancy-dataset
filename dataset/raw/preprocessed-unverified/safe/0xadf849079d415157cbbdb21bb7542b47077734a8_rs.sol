/**
 *Submitted for verification at Etherscan.io on 2021-09-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Claimable is Context {
  address private _owner;
  address public pendingOwner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event NewPendingOwner(address indexed owner);

  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_msgSender() == owner(), "Ownable: caller is not the owner");
    _;
  }

  modifier onlyPendingOwner() {
    require(_msgSender() == pendingOwner);
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(owner(), address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(pendingOwner == address(0));
    pendingOwner = newOwner;
    emit NewPendingOwner(newOwner);
  }

  function cancelTransferOwnership() public onlyOwner {
    require(pendingOwner != address(0));
    delete pendingOwner;
    emit NewPendingOwner(address(0));
  }

  function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(owner(), pendingOwner);
    _owner = pendingOwner;
    delete pendingOwner;
  }
}





/**
 * @title Errors library
 * @author Fuji
 * @notice Defines the error messages emitted by the different contracts of the Aave protocol
 * @dev Error messages prefix glossary:
 *  - VL = Validation Logic 100 series
 *  - MATH = Math libraries 200 series
 *  - RF = Refinancing 300 series
 *  - VLT = vault 400 series
 *  - SP = Special 900 series
 */



contract FujiOracle is IFujiOracle, Claimable {
  // mapping from asset address to its price feed oracle in USD - decimals: 8
  mapping(address => address) public usdPriceFeeds;

  constructor(address[] memory _assets, address[] memory _priceFeeds) Claimable() {
    require(_assets.length == _priceFeeds.length, Errors.ORACLE_INVALID_LENGTH);
    for (uint256 i = 0; i < _assets.length; i++) {
      usdPriceFeeds[_assets[i]] = _priceFeeds[i];
    }
  }

  function setPriceFeed(address _asset, address _priceFeed) public onlyOwner {
    usdPriceFeeds[_asset] = _priceFeed;
  }

  /// @dev Calculates the exchange rate n given decimals (_borrowAsset / _collateralAsset Exchange Rate)
  /// @param _collateralAsset the collateral asset, zero-address for USD
  /// @param _borrowAsset the borrow asset, zero-address for USD
  /// @param _decimals the decimals of the price output
  /// @return price The exchange rate of the given assets pair
  function getPriceOf(
    address _collateralAsset,
    address _borrowAsset,
    uint8 _decimals
  ) external view override returns (uint256 price) {
    price = 10**uint256(_decimals);

    if (_borrowAsset != address(0)) {
      price = price * _getUSDPrice(_borrowAsset);
    } else {
      price = price * (10**8);
    }

    if (_collateralAsset != address(0)) {
      price = price / _getUSDPrice(_collateralAsset);
    } else {
      price = price / (10**8);
    }
  }

  /// @dev Calculates the USD price of asset
  /// @param _asset the asset address
  /// @return price USD price of the give asset
  function _getUSDPrice(address _asset) internal view returns (uint256 price) {
    require(usdPriceFeeds[_asset] != address(0), Errors.ORACLE_NONE_PRICE_FEED);

    (, int256 latestPrice, , , ) = AggregatorV3Interface(usdPriceFeeds[_asset]).latestRoundData();

    price = uint256(latestPrice);
  }
}