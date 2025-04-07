/**
 *Submitted for verification at Etherscan.io on 2021-06-23
*/

pragma solidity 0.6.7;

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits


/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128


/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values


/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction


/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.




/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState
{

}

/// @title Optimized overflow and underflow safe math operations
/// @notice Contains methods for doing math operations that revert on overflow or underflow for minimal gas cost


/// @title Provides functions for deriving a pool address from the factory, tokens, and the fee


/// @title Oracle library
/// @notice Provides functions to integrate with V3 pool oracle


abstract contract TokenLike {
    function balanceOf(address) public view virtual returns (uint256);
}

contract UniswapV3Medianizer {
    // --- Auth ---
    mapping (address => uint) public authorizedAccounts;
    /**
     * @notice Add auth to an account
     * @param account Account to add auth to
     */
    function addAuthorization(address account) virtual external isAuthorized {
        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    /**
     * @notice Remove auth from an account
     * @param account Account to remove auth from
     */
    function removeAuthorization(address account) virtual external isAuthorized {
        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    /**
    * @notice Checks whether msg.sender can call an authed function
    **/
    modifier isAuthorized {
        require(authorizedAccounts[msg.sender] == 1, "UniswapV3Medianizer/account-not-authorized");
        _;
    }

    // --- Uniswap Vars ---
    // Default amount of targetToken used when calculating the denominationToken output
    uint128              public defaultAmountIn  = 1 ether;
    // Minimum liquidity of targetToken to consider a valid result
    uint256              public minimumLiquidity = 10000 ether; // note: increase this for prod
    // Token for which the contract calculates the medianPrice for
    address              public targetToken;
    // Pair token from the Uniswap pair
    address              public denominationToken;
    // The pool to read price data from
    address              public uniswapPool;

    // --- General Vars ---
    // The desired amount of time over which the moving average should be computed, e.g. 24 hours
    uint32  public windowSize;
    // Manual flag that can be set by governance and indicates if a result is valid or not
    uint256 public validityFlag;

    // --- Events ---
    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event ModifyParameters(
      bytes32 parameter,
      address addr
    );
    event ModifyParameters(
      bytes32 parameter,
      uint256 val
    );

    constructor(
      address uniswapPool_,
      address targetToken_,
      uint32  windowSize_
    ) public {
        require(uniswapPool_ != address(0), "UniswapV3Medianizer/null-uniswap-factory");
        require(windowSize_ > 0, 'UniswapV3Medianizer/null-window-size');

        authorizedAccounts[msg.sender] = 1;

        uniswapPool                    = uniswapPool_;
        windowSize                     = windowSize_;
        validityFlag                   = 1;
        targetToken                    = targetToken_;

        address token0 = IUniswapV3Pool(uniswapPool_).token0();
        address token1 = IUniswapV3Pool(uniswapPool_).token1();

        require(targetToken_ == token0 || targetToken_ == token1, "UniswapV3Medianizer/target-not-from-pool");

        denominationToken = targetToken_ == token0 ? token1 : token0;

        // Emit events
        emit AddAuthorization(msg.sender);
        emit ModifyParameters(bytes32("windowSize"), windowSize_);
    }

    // --- General Utils --
    function either(bool x, bool y) internal pure returns (bool z) {
        assembly{ z := or(x, y)}
    }
    function both(bool x, bool y) private pure returns (bool z) {
        assembly{ z := and(x, y)}
    }
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "UniswapV3Medianizer/toUint128_overflow");
        return uint128(value);
    }
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value < 2**32, "UniswapV3Medianizer/toUint32_overflow");
        return uint32(value);
    }

    // --- Administration ---
    /**
    * @notice Modify uint256 parameters
    * @param parameter Name of the parameter to modify
    * @param data New parameter value
    **/
    function modifyParameters(bytes32 parameter, uint256 data) external isAuthorized {
        if (parameter == "validityFlag") {
          require(either(data == 1, data == 0), "UniswapV3Medianizer/invalid-data");
          validityFlag = data;
        }
        else if (parameter == "defaultAmountIn") {
          require(data > 0, "UniswapV3Medianizer/invalid-default-amount-in");
          defaultAmountIn = toUint128(data);
        }
        else if (parameter == "windowSize") {
          require(data > 0, 'UniswapV3Medianizer/invalid-window-size');
          windowSize = toUint32(data);
        }
        else revert("UniswapV3Medianizer/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }

    // --- Getters ---
    /**
    * @notice Returns true if feed is valid
    **/
    function isValid() public view returns (bool) {
        return both(validityFlag == 1, TokenLike(targetToken).balanceOf(address(uniswapPool)) >= minimumLiquidity);
    }

    /**
    * @notice Returns medianPrice for windowSize
    **/
    function getMedianPrice() public view returns (uint256) {
        return getMedianPrice(windowSize);
    }

    /**
    * @notice Returns medianPrice for a given period
    * @param period Number of seconds in the past to start calculating time-weighted average
    * @return TWAP
    **/
    function getMedianPrice(uint32 period) public view returns (uint256) {
        int24 timeWeightedAverageTick = OracleLibrary.consult(address(uniswapPool), period);
        return OracleLibrary.getQuoteAtTick(
            timeWeightedAverageTick,
            defaultAmountIn,
            targetToken,
            denominationToken
        );
    }

    /**
    * @notice Fetch the latest medianPrice (for maxWindow) or revert if is is null
    **/
    function read() external view returns (uint256 value) {
        value = getMedianPrice();
        require(
          both(value > 0, isValid()),
          "UniswapV3Medianizer/invalid-price-feed"
        );
    }
    /**
    * @notice Fetch the latest medianPrice and whether it is null or not
    **/
    function getResultWithValidity() external view returns (uint256 value, bool valid) {
        value = getMedianPrice();
        valid = both(value > 0, isValid());
    }
}