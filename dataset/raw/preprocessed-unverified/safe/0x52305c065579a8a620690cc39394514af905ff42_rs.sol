/*

    Copyright 2019 dYdX Trading Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */


// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


// File: contracts/protocol/interfaces/IErc20.sol

/**
 * @title IErc20
 * @author dYdX
 *
 * Interface for using ERC20 Tokens. We have to use a special interface to call ERC20 functions so
 * that we don't automatically revert when calling non-compliant tokens that have no return value for
 * transfer(), transferFrom(), or approve().
 */


// File: contracts/protocol/lib/Monetary.sol

/**
 * @title Monetary
 * @author dYdX
 *
 * Library for types involving money
 */


// File: contracts/protocol/interfaces/IPriceOracle.sol

/**
 * @title IPriceOracle
 * @author dYdX
 *
 * Interface that Price Oracles for Solo must implement in order to report prices.
 */
contract IPriceOracle {

    // ============ Constants ============

    uint256 public constant ONE_DOLLAR = 10 ** 36;

    // ============ Public Functions ============

    /**
     * Get the price of a token
     *
     * @param  token  The ERC20 token address of the market
     * @return        The USD price of a base unit of the token, then multiplied by 10^36.
     *                So a USD-stable coin with 18 decimal places would return 10^18.
     *                This is the price of the base unit rather than the price of a "human-readable"
     *                token amount. Every ERC20 may have a different number of decimals.
     */
    function getPrice(
        address token
    )
        public
        view
        returns (Monetary.Price memory);
}

// File: contracts/protocol/lib/Require.sol

/**
 * @title Require
 * @author dYdX
 *
 * Stringifies parameters to pretty-print revert messages. Costs more gas than regular require()
 */


// File: contracts/protocol/lib/Math.sol

/**
 * @title Math
 * @author dYdX
 *
 * Library for non-standard Math functions
 */


// File: contracts/protocol/lib/Time.sol

/**
 * @title Time
 * @author dYdX
 *
 * Library for dealing with time, assuming timestamps fit within 32 bits (valid until year 2106)
 */


// File: contracts/external/interfaces/ICurve.sol

/*

    Copyright 2020 dYdX Trading Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

/**
 * @title ICurve
 * @author dYdX
 *
 * Partial interface for a Curve contract.
 */


// File: contracts/external/interfaces/IUniswapV2Pair.sol

/*

    Copyright 2020 dYdX Trading Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

/**
 * @title IUniswapV2Pair
 * @author dYdX
 *
 * Partial interface for a Uniswap V2 pair.
 */


// File: contracts/external/oracles/DaiPriceOracle.sol

/**
 * @title DaiPriceOracle
 * @author dYdX
 *
 * PriceOracle that gives the price of Dai in USDC.
 */
contract DaiPriceOracle is
    Ownable,
    IPriceOracle
{
    using SafeMath for uint256;

    // ============ Constants ============

    bytes32 constant FILE = "DaiPriceOracle";

    // DAI decimals and expected price.
    uint256 constant DECIMALS = 18;
    uint256 constant EXPECTED_PRICE = ONE_DOLLAR / (10 ** DECIMALS);

    // Parameters used when getting the DAI-USDC price from Curve.
    int128 constant CURVE_DAI_ID = 0;
    int128 constant CURVE_USDC_ID = 1;
    uint256 constant CURVE_FEE_DENOMINATOR = 10 ** 10;
    uint256 constant CURVE_DECIMALS_BASE = 10 ** 30;

    // Parameters used when getting the DAI-USDC price from Uniswap.
    uint256 constant UNISWAP_DECIMALS_BASE = 10 ** 30;

    // ============ Structs ============

    struct PriceInfo {
        uint128 price;
        uint32 lastUpdate;
    }

    struct DeviationParams {
        uint64 denominator;
        uint64 maximumPerSecond;
        uint64 maximumAbsolute;
    }

    // ============ Events ============

    event PriceSet(
        PriceInfo newPriceInfo
    );

    // ============ Storage ============

    PriceInfo public g_priceInfo;

    address public g_poker;

    DeviationParams public DEVIATION_PARAMS;

    IErc20 public WETH;

    IErc20 public DAI;

    ICurve public CURVE;

    IUniswapV2Pair public UNISWAP_DAI_ETH;

    IUniswapV2Pair public UNISWAP_USDC_ETH;

    // ============ Constructor =============

    constructor(
        address poker,
        address weth,
        address dai,
        address curve,
        address uniswapDaiEth,
        address uniswapUsdcEth,
        DeviationParams memory deviationParams
    )
        public
    {
        g_poker = poker;
        WETH = IErc20(weth);
        DAI = IErc20(dai);
        CURVE = ICurve(curve);
        UNISWAP_DAI_ETH = IUniswapV2Pair(uniswapDaiEth);
        UNISWAP_USDC_ETH = IUniswapV2Pair(uniswapUsdcEth);
        DEVIATION_PARAMS = deviationParams;
        g_priceInfo = PriceInfo({
            lastUpdate: uint32(block.timestamp),
            price: uint128(EXPECTED_PRICE)
        });
    }

    // ============ Admin Functions ============

    function ownerSetPokerAddress(
        address newPoker
    )
        external
        onlyOwner
    {
        g_poker = newPoker;
    }

    // ============ Public Functions ============

    function updatePrice(
        Monetary.Price memory minimum,
        Monetary.Price memory maximum
    )
        public
        returns (PriceInfo memory)
    {
        Require.that(
            msg.sender == g_poker,
            FILE,
            "Only poker can call updatePrice",
            msg.sender
        );

        Monetary.Price memory newPrice = getBoundedTargetPrice();

        Require.that(
            newPrice.value >= minimum.value,
            FILE,
            "newPrice below minimum",
            newPrice.value,
            minimum.value
        );

        Require.that(
            newPrice.value <= maximum.value,
            FILE,
            "newPrice above maximum",
            newPrice.value,
            maximum.value
        );

        g_priceInfo = PriceInfo({
            price: Math.to128(newPrice.value),
            lastUpdate: Time.currentTime()
        });

        emit PriceSet(g_priceInfo);
        return g_priceInfo;
    }

    // ============ IPriceOracle Functions ============

    function getPrice(
        address /* token */
    )
        public
        view
        returns (Monetary.Price memory)
    {
        return Monetary.Price({
            value: g_priceInfo.price
        });
    }

    // ============ Price-Query Functions ============

    /**
     * Get the new price that would be stored if updated right now.
     */
    function getBoundedTargetPrice()
        public
        view
        returns (Monetary.Price memory)
    {
        Monetary.Price memory targetPrice = getTargetPrice();

        PriceInfo memory oldInfo = g_priceInfo;
        uint256 timeDelta = uint256(Time.currentTime()).sub(oldInfo.lastUpdate);
        (uint256 minPrice, uint256 maxPrice) = getPriceBounds(oldInfo.price, timeDelta);
        uint256 boundedTargetPrice = boundValue(targetPrice.value, minPrice, maxPrice);

        return Monetary.Price({
            value: boundedTargetPrice
        });
    }

    /**
     * Get the DAI-USDC price that this contract will move towards when updated. This price is
     * not bounded by the variables governing the maximum deviation from the old price.
     */
    function getTargetPrice()
        public
        view
        returns (Monetary.Price memory)
    {
        uint256 targetPrice = getMidValue(
            EXPECTED_PRICE,
            getCurvePrice(),
            getUniswapPrice()
        );

        return Monetary.Price({
            value: targetPrice
        });
    }

    /**
     * Get the DAI-USDC price according to Curve.
     *
     * @return  The DAI-USDC price in natural units as a fixed-point number with 18 decimals.
     */
    function getCurvePrice()
        public
        view
        returns (uint256)
    {
        ICurve curve = CURVE;

        // Get dy when dx = 1, i.e. the number of DAI base units we can buy for 1 USDC base unit.
        //
        // After accounting for the fee, this is a very good estimate of the spot price.
        uint256 dyWithFee = curve.get_dy(CURVE_USDC_ID, CURVE_DAI_ID, 1);
        uint256 fee = curve.fee();
        uint256 dyWithoutFee = dyWithFee.mul(CURVE_FEE_DENOMINATOR).div(
            CURVE_FEE_DENOMINATOR.sub(fee)
        );

        // Note that dy is on the order of 10^12 due to the difference in DAI and USDC base units.
        // We divide 10^30 by dy to get the price of DAI in USDC with 18 decimals of precision.
        return CURVE_DECIMALS_BASE.div(dyWithoutFee);
    }

    /**
     * Get the DAI-USDC price according to Uniswap.
     *
     * @return  The DAI-USDC price in natural units as a fixed-point number with 18 decimals.
     */
    function getUniswapPrice()
        public
        view
        returns (uint256)
    {
        // Note: Depending on the pool used, ETH may be the first asset or the second asset.
        (uint256 daiAmt, uint256 poolOneEthAmt, ) = UNISWAP_DAI_ETH.getReserves();
        (uint256 usdcAmt, uint256 poolTwoEthAmt, ) = UNISWAP_USDC_ETH.getReserves();

        // Get the price of DAI in USDC. Multiply by 10^30 to account for the difference in decimals
        // between DAI and USDC, and get a result with 18 decimals of precision.
        //
        // Note: There is a risk for overflow depending on the assets used and size of the pools.
        return UNISWAP_DECIMALS_BASE
            .mul(usdcAmt)
            .mul(poolOneEthAmt)
            .div(poolTwoEthAmt)
            .div(daiAmt);
    }

    // ============ Helper Functions ============

    function getPriceBounds(
        uint256 oldPrice,
        uint256 timeDelta
    )
        private
        view
        returns (uint256, uint256)
    {
        DeviationParams memory deviation = DEVIATION_PARAMS;

        uint256 maxDeviation = Math.getPartial(
            oldPrice,
            Math.min(deviation.maximumAbsolute, timeDelta.mul(deviation.maximumPerSecond)),
            deviation.denominator
        );

        return (
            oldPrice.sub(maxDeviation),
            oldPrice.add(maxDeviation)
        );
    }

    function getMidValue(
        uint256 valueA,
        uint256 valueB,
        uint256 valueC
    )
        private
        pure
        returns (uint256)
    {
        uint256 maximum = Math.max(valueA, Math.max(valueB, valueC));
        if (maximum == valueA) {
            return Math.max(valueB, valueC);
        }
        if (maximum == valueB) {
            return Math.max(valueA, valueC);
        }
        return Math.max(valueA, valueB);
    }

    function boundValue(
        uint256 value,
        uint256 minimum,
        uint256 maximum
    )
        private
        pure
        returns (uint256)
    {
        assert(minimum <= maximum);
        return Math.max(minimum, Math.min(maximum, value));
    }
}