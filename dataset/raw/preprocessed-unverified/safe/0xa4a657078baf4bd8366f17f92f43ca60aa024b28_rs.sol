/**
 *Submitted for verification at Etherscan.io on 2021-03-03
*/

/*
    .'''''''''''..     ..''''''''''''''''..       ..'''''''''''''''..
    .;;;;;;;;;;;'.   .';;;;;;;;;;;;;;;;;;,.     .,;;;;;;;;;;;;;;;;;,.
    .;;;;;;;;;;,.   .,;;;;;;;;;;;;;;;;;;;,.    .,;;;;;;;;;;;;;;;;;;,.
    .;;;;;;;;;,.   .,;;;;;;;;;;;;;;;;;;;;,.   .;;;;;;;;;;;;;;;;;;;;,.
    ';;;;;;;;'.  .';;;;;;;;;;;;;;;;;;;;;;,. .';;;;;;;;;;;;;;;;;;;;;,.
    ';;;;;,..   .';;;;;;;;;;;;;;;;;;;;;;;,..';;;;;;;;;;;;;;;;;;;;;;,.
    ......     .';;;;;;;;;;;;;,'''''''''''.,;;;;;;;;;;;;;,'''''''''..
              .,;;;;;;;;;;;;;.           .,;;;;;;;;;;;;;.
             .,;;;;;;;;;;;;,.           .,;;;;;;;;;;;;,.
            .,;;;;;;;;;;;;,.           .,;;;;;;;;;;;;,.
           .,;;;;;;;;;;;;,.           .;;;;;;;;;;;;;,.     .....
          .;;;;;;;;;;;;;'.         ..';;;;;;;;;;;;;'.    .',;;;;,'.
        .';;;;;;;;;;;;;'.         .';;;;;;;;;;;;;;'.   .';;;;;;;;;;.
       .';;;;;;;;;;;;;'.         .';;;;;;;;;;;;;;'.    .;;;;;;;;;;;,.
      .,;;;;;;;;;;;;;'...........,;;;;;;;;;;;;;;.      .;;;;;;;;;;;,.
     .,;;;;;;;;;;;;,..,;;;;;;;;;;;;;;;;;;;;;;;,.       ..;;;;;;;;;,.
    .,;;;;;;;;;;;;,. .,;;;;;;;;;;;;;;;;;;;;;;,.          .',;;;,,..
   .,;;;;;;;;;;;;,.  .,;;;;;;;;;;;;;;;;;;;;;,.              ....
    ..',;;;;;;;;,.   .,;;;;;;;;;;;;;;;;;;;;,.
       ..',;;;;'.    .,;;;;;;;;;;;;;;;;;;;'.
          ...'..     .';;;;;;;;;;;;;;,,,'.
                       ...............
*/

// https://github.com/trusttoken/smart-contracts
// Dependency file: @openzeppelin/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

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



// Dependency file: contracts/truefi/interface/ICrvPriceOracle.sol

// pragma solidity 0.6.10;




// Dependency file: @chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol

// pragma solidity >=0.6.0;




// Root file: contracts/truefi/CrvPriceOracle.sol

pragma solidity 0.6.10;

// import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
// import {ICrvPriceOracle} from "contracts/truefi/interface/ICrvPriceOracle.sol";
// import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract CrvPriceOracle is ICrvPriceOracle {
    AggregatorV3Interface internal crvPriceFeed;
    // AggregatorV3Interface internal ethPriceFeed;
    using SafeMath for uint256;

    /**
     * Network: Mainnet
     * Aggregator: CRV/ETH
     * Address: 0x8a12Be339B0cD1829b91Adc01977caa5E9ac121e
     * Network: Mainnet
     * Aggregator: ETH/USD
     * Address: 0x9326BFA02ADD2366b30bacB125260Af641031331
     */
    constructor() public {
        crvPriceFeed = AggregatorV3Interface(0x8a12Be339B0cD1829b91Adc01977caa5E9ac121e);
        // ethPriceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
    }

    /**
     * @dev return the lastest price for CRV/USD with 18 decimals places
     * @return CRV/USD price
     */
    function getLatestPrice() public view returns (uint256) {
        (, int256 crvEthPrice, , , ) = crvPriceFeed.latestRoundData();
        // (, int256 ethPrice, , , ) = ethPriceFeed.latestRoundData();
        uint256 crvPrice = (safeUint(crvEthPrice));
        return crvPrice;
    }

    /**
     * @dev converts from USD with 18 decimals to CRV with 18 decimals
     * @param amount Amount in USD
     * @return CRV value of USD input
     */
    function usdToCrv(uint256 amount) external override view returns (uint256) {
        return amount.div(getLatestPrice());
    }

    /**
     * @dev converts from CRV with 18 decimals to USD with 18 decimals
     * @param amount Amount in CRV
     * @return USD value of CRV input
     */
    function crvToUsd(uint256 amount) external override view returns (uint256) {
        return amount.mul(getLatestPrice());
    }

    /**
     * @dev convert int256 to uint256
     * @param value to convert to uint
     * @return the converted uint256 value
     */
    function safeUint(int256 value) internal pure returns (uint256) {
        require(value >= 0, "CrvPriceChainLinkOracle: uint underflow");
        return uint256(value);
    }
}