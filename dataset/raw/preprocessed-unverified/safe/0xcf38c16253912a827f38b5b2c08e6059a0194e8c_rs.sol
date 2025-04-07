/**
 *Submitted for verification at Etherscan.io on 2021-08-13
*/

//SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.3;




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */








contract DSMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x >= y ? x : y;
    }

    function imin(int256 x, int256 y) internal pure returns (int256 z) {
        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) internal pure returns (int256 z) {
        return x >= y ? x : y;
    }

    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;

    //rounds to zero if x*WAD < y/2
    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    //rounds to zero if x*RAY < y/2
    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    //rounds to zero if x*y < WAD / 2
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    //rounds to zero if x*y < RAY / 2
    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}



interface IERC20Detailed is IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string calldata);
}





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


contract OptionsPremiumPricer is DSMath {
    using SafeMath for uint256;

    /**
     * Immutables
     */
    address public immutable pool;
    IVolatilityOracle public immutable volatilityOracle;
    IPriceOracle public immutable priceOracle;
    IPriceOracle public immutable stablesOracle;
    uint256 private immutable priceOracleDecimals;
    uint256 private immutable stablesOracleDecimals;

    // For reference - IKEEP3rVolatility: 0xCCdfCB72753CfD55C5afF5d98eA5f9C43be9659d

    /**
     * @notice Constructor for pricer, deploy one for every pool
     * @param _pool is the Uniswap v3 pool
     * @param _volatilityOracle is the oracle for historical volatility
     * @param _priceOracle is the Chainlink price oracle for the underlying asset
     * @param _stablesOracle is the Chainlink price oracle for the strike asset (e.g. USDC)
     */
    constructor(
        address _pool,
        address _volatilityOracle,
        address _priceOracle,
        address _stablesOracle
    ) {
        require(_pool != address(0), "!_pool");
        require(_volatilityOracle != address(0), "!_volatilityOracle");
        require(_priceOracle != address(0), "!_priceOracle");
        require(_stablesOracle != address(0), "!_stablesOracle");

        pool = _pool;
        volatilityOracle = IVolatilityOracle(_volatilityOracle);
        priceOracle = IPriceOracle(_priceOracle);
        stablesOracle = IPriceOracle(_stablesOracle);
        priceOracleDecimals = IPriceOracle(_priceOracle).decimals();
        stablesOracleDecimals = IPriceOracle(_stablesOracle).decimals();
    }

    /**
     * @notice Calculates the premium of the provided option using Black-Scholes
     * References for Black-Scholes:
       https://www.macroption.com/black-scholes-formula/
       https://www.investopedia.com/terms/b/blackscholes.asp
       https://www.erieri.com/blackscholes
       https://goodcalculators.com/black-scholes-calculator/
       https://www.calkoo.com/en/black-scholes-option-pricing-model
     * @param st is the strike price of the option
     * @param expiryTimestamp is the unix timestamp of expiry
     * @param isPut is whether the option is a put option
     * @return premium for 100 contracts with 18 decimals i.e.
     * 500*10**18 = 500 USDC for 100 contracts for puts,
     * 5*10**18 = 5 of underlying asset (ETH, WBTC, etc.) for 100 contracts for calls,
     */
    function getPremium(
        uint256 st,
        uint256 expiryTimestamp,
        bool isPut
    ) external view returns (uint256 premium) {
        require(
            expiryTimestamp > block.timestamp,
            "Expiry must be in the future!"
        );

        uint256 spotPrice = priceOracle.latestAnswer();

        (uint256 sp, uint256 v, uint256 t) =
            blackScholesParams(spotPrice, expiryTimestamp);

        (uint256 call, uint256 put) = quoteAll(t, v, sp, st);

        // Multiplier to convert oracle latestAnswer to 18 decimals
        uint256 assetOracleMultiplier =
            10 **
                (
                    uint256(18).sub(
                        isPut ? stablesOracleDecimals : priceOracleDecimals
                    )
                );
        // Make option premium denominated in the underlying
        // asset for call vaults and USDC for put vaults
        premium = isPut
            ? wdiv(put, stablesOracle.latestAnswer().mul(assetOracleMultiplier))
            : wdiv(call, spotPrice.mul(assetOracleMultiplier));

        // Convert to 18 decimals
        premium = premium.mul(assetOracleMultiplier);
    }

    /**
     * @notice Calculates the option's delta
     * Formula reference: `d_1` in https://www.investopedia.com/terms/b/blackscholes.asp
     * http://www.optiontradingpedia.com/options_delta.htm
     * https://www.macroption.com/black-scholes-formula/
     * @param st is the strike price of the option
     * @param expiryTimestamp is the unix timestamp of expiry
     * @return delta for given option. 4 decimals (ex: 8100 = 0.81 delta) as this is what strike selection
     * module recognizes
     */
    function getOptionDelta(uint256 st, uint256 expiryTimestamp)
        external
        view
        returns (uint256 delta)
    {
        require(
            expiryTimestamp > block.timestamp,
            "Expiry must be in the future!"
        );

        uint256 spotPrice = priceOracle.latestAnswer();
        (uint256 sp, uint256 v, uint256 t) =
            blackScholesParams(spotPrice, expiryTimestamp);

        uint256 d1;
        uint256 d2;

        // Divide delta by 10 ** 10 to bring it to 4 decimals for strike selection
        if (sp >= st) {
            (d1, d2) = derivatives(t, v, sp, st);
            delta = Math.ncdf((Math.FIXED_1 * d1) / 1e18).div(10**10);
        } else {
            // If underlying < strike price notice we switch st <-> sp passed into d
            (d1, d2) = derivatives(t, v, st, sp);
            delta = uint256(10)
                .mul(10**13)
                .sub(Math.ncdf((Math.FIXED_1 * d2) / 1e18))
                .div(10**10);
        }
    }

    /**
     * @notice Calculates the option's delta
     * Formula reference: `d_1` in https://www.investopedia.com/terms/b/blackscholes.asp
     * http://www.optiontradingpedia.com/options_delta.htm
     * https://www.macroption.com/black-scholes-formula/
     * @param sp is the spot price of the option
     * @param st is the strike price of the option
     * @param v is the annualized volatility of the underlying asset
     * @param expiryTimestamp is the unix timestamp of expiry
     * @return delta for given option. 4 decimals (ex: 8100 = 0.81 delta) as this is what strike selection
     * module recognizes
     */
    function getOptionDelta(
        uint256 sp,
        uint256 st,
        uint256 v,
        uint256 expiryTimestamp
    ) external view returns (uint256 delta) {
        require(
            expiryTimestamp > block.timestamp,
            "Expiry must be in the future!"
        );

        // days until expiry
        uint256 t = expiryTimestamp.sub(block.timestamp).div(1 days);

        uint256 d1;
        uint256 d2;

        // Divide delta by 10 ** 10 to bring it to 4 decimals for strike selection
        if (sp >= st) {
            (d1, d2) = derivatives(t, v, sp, st);
            delta = Math.ncdf((Math.FIXED_1 * d1) / 1e18).div(10**10);
        } else {
            // If underlying < strike price notice we switch st <-> sp passed into d
            (d1, d2) = derivatives(t, v, st, sp);
            delta = uint256(10)
                .mul(10**13)
                .sub(Math.ncdf((Math.FIXED_1 * d2) / 1e18))
                .div(10**10);
        }
    }

    /**
     * @notice Calculates black scholes for both put and call
     * @param t is the days until expiry
     * @param v is the annualized volatility
     * @param sp is the underlying price
     * @param st is the strike price
     * @return call is the premium of the call option given parameters
     * @return put is the premium of the put option given parameters
     */
    function quoteAll(
        uint256 t,
        uint256 v,
        uint256 sp,
        uint256 st
    ) private pure returns (uint256 call, uint256 put) {
        uint256 _c;
        uint256 _p;

        if (sp > st) {
            _c = blackScholes(t, v, sp, st);
            _p = max(_c.add(st), sp) == sp ? 0 : _c.add(st).sub(sp);
        } else {
            _p = blackScholes(t, v, st, sp);
            _c = max(_p.add(sp), st) == st ? 0 : _p.add(sp).sub(st);
        }

        return (_c, _p);
    }

    /**
     * @notice Calculates black scholes for the ITM option at mint given strike
     * price and underlying given the parameters (if underling >= strike price this is
     * premium of call, and put otherwise)
     * @param t is the days until expiry
     * @param v is the annualized volatility
     * @param sp is the underlying price
     * @param st is the strike price
     * @return premium is the premium of option
     */
    function blackScholes(
        uint256 t,
        uint256 v,
        uint256 sp,
        uint256 st
    ) private pure returns (uint256 premium) {
        (uint256 d1, uint256 d2) = derivatives(t, v, sp, st);

        uint256 cdfD1 = Math.ncdf((Math.FIXED_1 * d1) / 1e18);
        uint256 cdfD2 = Math.cdf((int256(Math.FIXED_1) * int256(d2)) / 1e18);

        premium = (sp * cdfD1) / 1e14 - (st * cdfD2) / 1e14;
    }

    /**
     * @notice Calculates d1 and d2 used in black scholes calculation
     * as parameters to black scholes calculations
     * @param t is the days until expiry
     * @param v is the annualized volatility
     * @param sp is the underlying price
     * @param st is the strike price
     * @return d1 and d2
     */
    function derivatives(
        uint256 t,
        uint256 v,
        uint256 sp,
        uint256 st
    ) internal pure returns (uint256 d1, uint256 d2) {
        require(sp > 0, "!sp");
        require(st > 0, "!st");

        uint256 sigma = ((v**2) / 2);
        uint256 sigmaB = 1e36;

        uint256 sig = (((1e18 * sigma) / sigmaB) * t) / 365;

        uint256 sSQRT = (v * Math.sqrt2((1e18 * t) / 365)) / 1e9;
        require(sSQRT > 0, "!sSQRT");

        d1 = (1e18 * Math.ln((Math.FIXED_1 * sp) / st)) / Math.FIXED_1;
        d1 = ((d1 + sig) * 1e18) / sSQRT;
        d2 = d1 - sSQRT;
    }

    /**
     * @notice Calculates the current underlying price, annualized volatility, and days until expiry
     * as parameters to black scholes calculations
     * @param expiryTimestamp is the unix timestamp of expiry
     * @return sp is the underlying
     * @return v is the volatility
     * @return t is the days until expiry
     */
    function blackScholesParams(uint256 spotPrice, uint256 expiryTimestamp)
        private
        view
        returns (
            uint256 sp,
            uint256 v,
            uint256 t
        )
    {
        // chainlink oracle returns crypto / usd pairs with 8 decimals, like otoken strike price
        sp = spotPrice.mul(10**8).div(10**priceOracleDecimals);
        // annualized vol * 10 ** 8 because delta expects 18 decimals
        // and annualizedVol is 8 decimals
        v = volatilityOracle.annualizedVol(pool).mul(10**10);
        t = expiryTimestamp.sub(block.timestamp).div(1 days);
    }

    /**
     * @notice Calculates the underlying assets price
     */
    function getUnderlyingPrice() external view returns (uint256 price) {
        price = priceOracle.latestAnswer();
    }
}