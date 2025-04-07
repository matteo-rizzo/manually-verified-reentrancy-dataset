/**
 *Submitted for verification at Etherscan.io on 2020-11-16
*/

pragma solidity 0.5.15;

// YAM ecosystem contract to facilitate staking DPI/ETH into INDEX farm


contract YamGoverned {
    event NewGov(address oldGov, address newGov);
    event NewPendingGov(address oldPendingGov, address newPendingGov);

    address public gov;
    address public pendingGov;

    modifier onlyGov {
        require(msg.sender == gov, "!gov");
        _;
    }

    function _setPendingGov(address who)
        public
        onlyGov
    {
        address old = pendingGov;
        pendingGov = who;
        emit NewPendingGov(old, who);
    }

    function _acceptGov()
        public
    {
        require(msg.sender == pendingGov, "!pendingGov");
        address oldgov = gov;
        gov = pendingGov;
        pendingGov = address(0);
        emit NewGov(oldgov, gov);
    }
}

contract YamSubGoverned is YamGoverned {
    /**
     * @notice Event emitted when a sub gov is enabled/disabled
     */
    event SubGovModified(
        address account,
        bool isSubGov
    );
    /// @notice sub governors
    mapping(address => bool) public isSubGov;

    modifier onlyGovOrSubGov() {
        require(msg.sender == gov || isSubGov[msg.sender]);
        _;
    }

    function setIsSubGov(address subGov, bool _isSubGov)
        public
        onlyGov
    {
        isSubGov[subGov] = _isSubGov;
        emit SubGovModified(subGov, _isSubGov);
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

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


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */




// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method


// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))


// library with helper methods for oracles that are concerned with computing average prices




contract TWAPBound is YamSubGoverned {
    using SafeMath for uint256;

    uint256 public constant BASE = 10**18;

    /// @notice For a sale of a specific amount
    uint256 public sell_amount;

    /// @notice For a purchase of a specific amount
    uint256 public purchase_amount;

    /// @notice Token to be sold
    address public sell_token;

    /// @notice Token to be puchased
    address public purchase_token;

    /// @notice Current uniswap pair for purchase & sale tokens
    address public uniswap_pair1;

    /// @notice Second uniswap pair for if TWAP uses two markets to determine price (for liquidity purposes)
    address public uniswap_pair2;

    /// @notice Flag for if purchase token is toke 0 in uniswap pair 2
    bool public purchaseTokenIs0;

    /// @notice Flag for if sale token is token 0 in uniswap pair
    bool public saleTokenIs0;

    /// @notice TWAP for first hop
    uint256 public priceAverageSell;

    /// @notice TWAP for second hop
    uint256 public priceAverageBuy;

    /// @notice last TWAP update time
    uint32 public blockTimestampLast;

    /// @notice last TWAP cumulative price;
    uint256 public priceCumulativeLastSell;

    /// @notice last TWAP cumulative price for two hop pairs;
    uint256 public priceCumulativeLastBuy;

    /// @notice Time between TWAP updates
    uint256 public period;

    /// @notice counts number of twaps
    uint256 public twap_counter;

    /// @notice Grace period after last twap update for a trade to occur
    uint256 public grace = 60 * 60; // 1 hour

    uint256 public constant MAX_BOUND = 10**17;

    /// @notice % bound away from TWAP price
    uint256 public twap_bounds;

    /// @notice denotes a trade as complete
    bool public complete;

    bool public isSale;

    function setup_twap_bound (
        address sell_token_,
        address purchase_token_,
        uint256 amount_,
        bool is_sale,
        uint256 twap_period,
        uint256 twap_bounds_,
        address uniswap1,
        address uniswap2, // if two hop
        uint256 grace_ // length after twap update that it can occur
    )
        public
        onlyGovOrSubGov
    {
        require(twap_bounds_ <= MAX_BOUND, "slippage too high");
        sell_token = sell_token_;
        purchase_token = purchase_token_;
        period = twap_period;
        twap_bounds = twap_bounds_;
        isSale = is_sale;
        if (is_sale) {
            sell_amount = amount_;
            purchase_amount = 0;
        } else {
            purchase_amount = amount_;
            sell_amount = 0;
        }

        complete = false;
        grace = grace_;
        reset_twap(uniswap1, uniswap2, sell_token, purchase_token);
    }

    function reset_twap(
        address uniswap1,
        address uniswap2,
        address sell_token_,
        address purchase_token_
    )
        internal
    {
        uniswap_pair1 = uniswap1;
        uniswap_pair2 = uniswap2;

        blockTimestampLast = 0;
        priceCumulativeLastSell = 0;
        priceCumulativeLastBuy = 0;
        priceAverageBuy = 0;

        if (UniswapPair(uniswap1).token0() == sell_token_) {
            saleTokenIs0 = true;
        } else {
            saleTokenIs0 = false;
        }

        if (uniswap2 != address(0)) {
            if (UniswapPair(uniswap2).token0() == purchase_token_) {
                purchaseTokenIs0 = true;
            } else {
                purchaseTokenIs0 = false;
            }
        }

        update_twap();
        twap_counter = 0;
    }

    function quote(
      uint256 purchaseAmount,
      uint256 saleAmount
    )
      public
      view
      returns (uint256)
    {
      uint256 decs = uint256(ExpandedERC20(sell_token).decimals());
      uint256 one = 10**decs;
      return purchaseAmount.mul(one).div(saleAmount);
    }

    function bounds()
        public
        view
        returns (uint256)
    {
        uint256 uniswap_quote = consult();
        uint256 minimum = uniswap_quote.mul(BASE.sub(twap_bounds)).div(BASE);
        return minimum;
    }

    function bounds_max()
        public
        view
        returns (uint256)
    {
        uint256 uniswap_quote = consult();
        uint256 maximum = uniswap_quote.mul(BASE.add(twap_bounds)).div(BASE);
        return maximum;
    }


    function withinBounds (
        uint256 purchaseAmount,
        uint256 saleAmount
    )
        internal
        view
        returns (bool)
    {
        uint256 quoted = quote(purchaseAmount, saleAmount);
        uint256 minimum = bounds();
        uint256 maximum = bounds_max();
        return quoted > minimum && quoted < maximum;
    }

    function withinBoundsWithQuote (
        uint256 quoted
    )
        internal
        view
        returns (bool)
    {
        uint256 minimum = bounds();
        uint256 maximum = bounds_max();
        return quoted > minimum && quoted < maximum;
    }

    // callable by anyone
    function update_twap()
        public
    {
        (uint256 sell_token_priceCumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(uniswap_pair1, saleTokenIs0);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        // ensure that at least one full period has passed since the last update
        require(timeElapsed >= period, 'OTC: PERIOD_NOT_ELAPSED');

        // overflow is desired
        priceAverageSell = uint256(uint224((sell_token_priceCumulative - priceCumulativeLastSell) / timeElapsed));
        priceCumulativeLastSell = sell_token_priceCumulative;


        if (uniswap_pair2 != address(0)) {
            // two hop
            (uint256 buy_token_priceCumulative, ) =
                UniswapV2OracleLibrary.currentCumulativePrices(uniswap_pair2, !purchaseTokenIs0);
            priceAverageBuy = uint256(uint224((buy_token_priceCumulative - priceCumulativeLastBuy) / timeElapsed));

            priceCumulativeLastBuy = buy_token_priceCumulative;
        }

        twap_counter = twap_counter.add(1);

        blockTimestampLast = blockTimestamp;
    }

    function consult()
        public
        view
        returns (uint256)
    {
        if (uniswap_pair2 != address(0)) {
            // two hop
            uint256 purchasePrice;
            uint256 salePrice;
            uint256 one;
            if (saleTokenIs0) {
                uint8 decs = ExpandedERC20(sell_token).decimals();
                require(decs <= 18, "too many decimals");
                one = 10**uint256(decs);
            } else {
                uint8 decs = ExpandedERC20(sell_token).decimals();
                require(decs <= 18, "too many decimals");
                one = 10**uint256(decs);
            }

            if (priceAverageSell > uint192(-1)) {
               // eat loss of precision
               // effectively: (x / 2**112) * 1e18
               purchasePrice = (priceAverageSell >> 112) * one;
            } else {
              // cant overflow
              // effectively: (x * 1e18 / 2**112)
              purchasePrice = (priceAverageSell * one) >> 112;
            }

            if (purchaseTokenIs0) {
                uint8 decs = ExpandedERC20(UniswapPair(uniswap_pair2).token1()).decimals();
                require(decs <= 18, "too many decimals");
                one = 10**uint256(decs);
            } else {
                uint8 decs = ExpandedERC20(UniswapPair(uniswap_pair2).token0()).decimals();
                require(decs <= 18, "too many decimals");
                one = 10**uint256(decs);
            }

            if (priceAverageBuy > uint192(-1)) {
                salePrice = (priceAverageBuy >> 112) * one;
            } else {
                salePrice = (priceAverageBuy * one) >> 112;
            }

            return purchasePrice.mul(salePrice).div(one);

        } else {
            uint256 one;
            if (saleTokenIs0) {
                uint8 decs = ExpandedERC20(sell_token).decimals();
                require(decs <= 18, "too many decimals");
                one = 10**uint256(decs);
            } else {
                uint8 decs = ExpandedERC20(sell_token).decimals();
                require(decs <= 18, "too many decimals");
                one = 10**uint256(decs);
            }
            // single hop
            uint256 purchasePrice;
            if (priceAverageSell > uint192(-1)) {
               // eat loss of precision
               // effectively: (x / 2**112) * 1e18
               purchasePrice = (priceAverageSell >> 112) * one;
            } else {
                // cant overflow
                // effectively: (x * 1e18 / 2**112)
                purchasePrice = (priceAverageSell * one) >> 112;
            }
            return purchasePrice;
        }
    }

    function recencyCheck()
        internal
        returns (bool)
    {
        return (block.timestamp - blockTimestampLast < grace) && (twap_counter > 0);
    }
}
/// Helper for a reserve contract to perform uniswap, price bound actions
contract ReserveUniHelper is TWAPBound {

    event NewReserves(address oldReserves, address NewReserves);

    address public reserves;

    function _getLPToken()
        internal
    {
        require(!complete, "Action complete");

        uint256 amount_;
        if (isSale) {
          amount_ = sell_amount;
        } else {
          amount_ = purchase_amount;
        }
        // early return
        if (amount_ == 0) {
          complete = true;
          return;
        }

        require(recencyCheck(), "TWAP needs updating");

        uint256 bal_of_a = IERC20(sell_token).balanceOf(reserves);
        
        if (amount_ > bal_of_a) {
            // cap to bal
            amount_ = bal_of_a;
        }

        (uint256 reserve0, uint256 reserve1, ) = UniswapPair(uniswap_pair1).getReserves();
        uint256 quoted;
        if (saleTokenIs0) {
            quoted = quote(reserve1, reserve0);
            require(withinBoundsWithQuote(quoted), "!in_bounds, uni reserve manipulation");
        } else {
            quoted = quote(reserve0, reserve1);
            require(withinBoundsWithQuote(quoted), "!in_bounds, uni reserve manipulation");
        }

        uint256 amount_b;
        {
          uint256 decs = uint256(ExpandedERC20(sell_token).decimals());
          uint256 one = 10**decs;
          amount_b = quoted.mul(amount_).div(one);
        }


        uint256 bal_of_b = IERC20(purchase_token).balanceOf(reserves);
        if (amount_b > bal_of_b) {
            // we set the limit token as the sale token, but that could change
            // between proposal and execution.
            // limit amount_ and amount_b
            amount_b = bal_of_b;

            // reverse quote
            if (!saleTokenIs0) {
                quoted = quote(reserve1, reserve0);
            } else {
                quoted = quote(reserve0, reserve1);
            }
            // recalculate a
            uint256 decs = uint256(ExpandedERC20(purchase_token).decimals());
            uint256 one = 10**decs;
            amount_ = quoted.mul(amount_b).div(one);
        }

        IERC20(sell_token).transferFrom(reserves, uniswap_pair1, amount_);
        IERC20(purchase_token).transferFrom(reserves, uniswap_pair1, amount_b);
        UniswapPair(uniswap_pair1).mint(address(this));
        complete = true;
    }

    function _getUnderlyingToken(
        bool skip_this
    )
        internal
    {
        require(!complete, "Action complete");
        require(recencyCheck(), "TWAP needs updating");

        (uint256 reserve0, uint256 reserve1, ) = UniswapPair(uniswap_pair1).getReserves();
        uint256 quoted;
        if (saleTokenIs0) {
            quoted = quote(reserve1, reserve0);
            require(withinBoundsWithQuote(quoted), "!in_bounds, uni reserve manipulation");
        } else {
            quoted = quote(reserve0, reserve1);
            require(withinBoundsWithQuote(quoted), "!in_bounds, uni reserve manipulation");
        }

        // transfer lp tokens back, burn
        if (skip_this) {
          IERC20(uniswap_pair1).transfer(uniswap_pair1, IERC20(uniswap_pair1).balanceOf(address(this)));
          UniswapPair(uniswap_pair1).burn(reserves);
        } else {
          IERC20(uniswap_pair1).transfer(uniswap_pair1, IERC20(uniswap_pair1).balanceOf(address(this)));
          UniswapPair(uniswap_pair1).burn(address(this));
        }
        complete = true;
    }

    function _setReserves(address new_reserves)
        public
        onlyGovOrSubGov
    {
        address old_res = reserves;
        reserves = new_reserves;
        emit NewReserves(old_res, reserves);
    }
}



contract IndexStaking is ReserveUniHelper {

    constructor(address pendingGov_, address reserves_) public {
        gov = msg.sender;
        pendingGov = pendingGov_;
        reserves = reserves_;
        IERC20(lp).approve(address(staking), uint256(-1));
    }

    IndexStaker public staking = IndexStaker(0x8f06FBA4684B5E0988F215a47775Bb611Af0F986);

    address public lp = address(0x4d5ef58aAc27d99935E5b6B4A6778ff292059991);

    function currentStake()
        public
        view
        returns (uint256)
    {
        return staking.balanceOf(address(this));
    }

    // callable by anyone assuming twap bounds checks
    function stake()
        public
    {
        _getLPToken();
        uint256 amount = IERC20(lp).balanceOf(address(this));
        staking.stake(amount);
    }

    // callable by anyone assuming twap bounds checks
    function getUnderlying()
        public
    {
        _getUnderlyingToken(true);
    }

    // ========= STAKING ========
    function _stakeCurrentLPBalance()
        public
        onlyGovOrSubGov
    {
        uint256 amount = IERC20(lp).balanceOf(address(this));
        staking.stake(amount);
    }

    function _approveStakingFromReserves(
        bool isToken0Limited,
        uint256 amount
    )
        public
        onlyGovOrSubGov
    {
        if (isToken0Limited) {
          setup_twap_bound(
              UniswapPair(lp).token0(), // The limiting asset
              UniswapPair(lp).token1(),
              amount, // amount of token0
              true, // is sale
              60 * 60, // 1 hour
              5 * 10**15, // .5%
              lp,
              address(0), // if two hop
              60 * 60 // length after twap update that it can occur
          );
        } else {
          setup_twap_bound(
              UniswapPair(lp).token1(), // The limiting asset
              UniswapPair(lp).token0(),
              amount, // amount of token1
              true, // is sale
              60 * 60, // 1 hour
              5 * 10**15, // .5%
              lp,
              address(0), // if two hop
              60 * 60 // length after twap update that it can occur
          );
        }
    }
    // ============================

    // ========= EXITING ==========
    function _exitStaking()
        public
        onlyGovOrSubGov
    {
        staking.exit();
    }

    function _exitAndApproveGetUnderlying()
        public
        onlyGovOrSubGov
    {
        staking.exit();
        setup_twap_bound(
            UniswapPair(lp).token0(), // doesnt really matter
            UniswapPair(lp).token1(), // doesnt really matter
            staking.balanceOf(address(this)), // amount of LP tokens
            true, // is sale
            60 * 60, // 1 hour
            5 * 10**15, // .5%
            lp,
            address(0), // if two hop
            60 * 60 // length after twap update that it can occur
        );
    }

    function _exitStakingEmergency()
        public
        onlyGovOrSubGov
    {
        staking.withdraw(staking.balanceOf(address(this)));
    }

    function _exitStakingEmergencyAndApproveGetUnderlying()
        public
        onlyGovOrSubGov
    {
        staking.withdraw(staking.balanceOf(address(this)));
        setup_twap_bound(
            UniswapPair(lp).token0(), // doesnt really matter
            UniswapPair(lp).token1(), // doesnt really matter
            staking.balanceOf(address(this)), // amount of LP tokens
            true, // is sale
            60 * 60, // 1 hour
            5 * 10**15, // .5%
            lp,
            address(0), // if two hop
            60 * 60 // length after twap update that it can occur
        );
    }
    // ============================


    function _getTokenFromHere(address token)
        public
        onlyGovOrSubGov
    {
        IERC20 t = IERC20(token);
        t.transfer(reserves, t.balanceOf(address(this)));
    }
}