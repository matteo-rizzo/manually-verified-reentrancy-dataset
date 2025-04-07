/**
 *Submitted for verification at Etherscan.io on 2021-03-01
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



// Dependency file: contracts/truefi/interface/ITruPriceOracle.sol

// pragma solidity 0.6.10;




// Dependency file: @chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol

// pragma solidity >=0.6.0;




// Root file: contracts/truefi/TruPriceOracle.sol

pragma solidity 0.6.10;

// import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
// import {ITruPriceOracle} from "contracts/truefi/interface/ITruPriceOracle.sol";
// import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract TruPriceOracle is ITruPriceOracle {
    AggregatorV3Interface internal priceFeed;
    using SafeMath for uint256;

    /**
     * Network: Mainnet
     * Aggregator: TRU/USD
     * Address: 0x26929b85fE284EeAB939831002e1928183a10fb1
     */
    constructor() public {
        priceFeed = AggregatorV3Interface(0x26929b85fE284EeAB939831002e1928183a10fb1);
    }

    /**
     * @dev return the lastest price for TRU/USD with 8 decimals places
     * @return TRU/USD price
     */
    function getLatestPrice() public view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    /**
     * @dev converts from USD with 18 decimals to TRU with 8 decimals
     * Divide by 100 since Chainlink returns 10 decimals and TRU is 8 decimals
     * @param amount Amount in USD
     * @return TRU value of USD input
     */
    function usdToTru(uint256 amount) external override view returns (uint256) {
        return amount.div(safeUint(getLatestPrice())).div(100);
    }

    /**
     * @dev converts from TRU with 8 decimals to USD with 18 decimals
     * Multiply by 100 since Chainlink returns 10 decimals and TRU is 8 decimals
     * @param amount Amount in TRU
     * @return USD value of TRU input
     */
    function truToUsd(uint256 amount) external override view returns (uint256) {
        return amount.mul(safeUint(getLatestPrice())).mul(100);
    }

    /**
     * @dev convert int256 to uint256
     * @param value to convert to uint
     * @return the converted uint256 value
     */
    function safeUint(int256 value) internal pure returns (uint256) {
        require(value >= 0, "TruPriceChainLinkOracle: uint underflow");
        return uint256(value);
    }
}