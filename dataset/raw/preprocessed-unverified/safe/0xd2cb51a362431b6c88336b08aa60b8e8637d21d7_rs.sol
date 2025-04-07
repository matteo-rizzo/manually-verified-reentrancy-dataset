/**
 *Submitted for verification at Etherscan.io on 2021-03-08
*/

pragma solidity ^0.5.15;
pragma experimental ABIEncoderV2;

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


/// Helper for a reserve contract to perform uniswap, price bound actions
contract UniHelper{
    using SafeMath for uint256;

    uint256 internal constant ONE = 10**18;

    function _mintLPToken(
        UniswapPair uniswap_pair,
        IERC20 token0,
        IERC20 token1,
        uint256 amount_token1,
        address token1_source
    ) internal {
        (uint256 reserve0, uint256 reserve1, ) = uniswap_pair
            .getReserves();
        uint256 quoted = quote(reserve0, reserve1);

        uint256 amount_token0 = quoted.mul(amount_token1).div(ONE);

        token0.transfer(address(uniswap_pair), amount_token0);
        token1.transfer(address(uniswap_pair), amount_token1);
        UniswapPair(uniswap_pair).mint(address(this));
    }

    function _burnLPToken(UniswapPair uniswap_pair, address destination) internal {
        uniswap_pair.transfer(
            address(uniswap_pair),
            uniswap_pair.balanceOf(address(this))
        );
        UniswapPair(uniswap_pair).burn(destination);
    }

    function quote(uint256 purchaseAmount, uint256 saleAmount)
        internal
        view
        returns (uint256)
    {
        return purchaseAmount.mul(ONE).div(saleAmount);
    }

}

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


// File: contracts/tests/ustonks_farming/TWAPBoundedUSTONKSAPR.sol

// Hardcoding a lot of constants and stripping out unnecessary things because of high gas prices
contract TWAPBoundedUSTONKSAPR {
    using SafeMath for uint256;

    uint256 internal constant BASE = 10**18;

    uint256 internal constant ONE = 10**18;

    /// @notice Current uniswap pair for purchase & sale tokens
    UniswapPair internal uniswap_pair =
        UniswapPair(0xEdf187890Af846bd59f560827EBD2091C49b75Df);

    IERC20 internal constant USDC =
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    IERC20 internal constant USTONKS_APR =
        IERC20(0xEC58d3aefc9AAa2E0036FA65F70d569f49D9d1ED);

    /// @notice last cumulative price update time
    uint32 internal block_timestamp_last;

    /// @notice last cumulative price;
    uint256 internal price_cumulative_last;

    /// @notice Minimum amount of time since TWAP set
    uint256 internal constant MIN_TWAP_TIME = 60 * 60; // 1 hour

    /// @notice Maximum amount of time since TWAP set
    uint256 internal constant MAX_TWAP_TIME = 120 * 60; // 2 hours

    /// @notice % bound away from TWAP price
    uint256 internal constant TWAP_BOUNDS = 5 * 10**15;

    function quote(uint256 purchaseAmount, uint256 saleAmount)
        internal
        view
        returns (uint256)
    {
        return purchaseAmount.mul(ONE).div(saleAmount);
    }

    function bounds(uint256 uniswap_quote) internal view returns (uint256) {
        uint256 minimum = uniswap_quote.mul(BASE.sub(TWAP_BOUNDS)).div(BASE);
        return minimum;
    }

    function bounds_max(uint256 uniswap_quote) internal view returns (uint256) {
        uint256 maximum = uniswap_quote.mul(BASE.add(TWAP_BOUNDS)).div(BASE);
        return maximum;
    }


    function withinBounds(uint256 purchaseAmount, uint256 saleAmount)
        internal
        
        returns (bool)
    {
        uint256 uniswap_quote = consult();
        uint256 quoted = quote(purchaseAmount, saleAmount);
        uint256 minimum = bounds(uniswap_quote);
        uint256 maximum = bounds_max(uniswap_quote);

        return quoted > minimum && quoted < maximum;
    }

    // callable by anyone
    function update_twap() public {
        (uint256 sell_token_priceCumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(
                address(uniswap_pair),
                false
            );
        uint32 timeElapsed = blockTimestamp - block_timestamp_last; // overflow is impossible

        // ensure that it's been long enough since the last update
        require(timeElapsed >= MIN_TWAP_TIME, "OTC: MIN_TWAP_TIME NOT ELAPSED");

        price_cumulative_last = sell_token_priceCumulative;

        block_timestamp_last = blockTimestamp;
    }

    function consult() internal view returns (uint256) {
        (uint256 sell_token_priceCumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(
                address(uniswap_pair),
                false
            );
        uint32 timeElapsed = blockTimestamp - block_timestamp_last; // overflow is impossible

        // overflow is desired
        uint256 priceAverageSell =
            uint256(
                uint224(
                    (sell_token_priceCumulative - price_cumulative_last) /
                        timeElapsed
                )
            );

        // single hop
        uint256 purchasePrice;
        if (priceAverageSell > uint192(-1)) {
            // eat loss of precision
            // effectively: (x / 2**112) * 1e18
            purchasePrice = (priceAverageSell >> 112) * ONE;
        } else {
            // cant overflow
            // effectively: (x * 1e18 / 2**112)
            purchasePrice = (priceAverageSell * ONE) >> 112;
        }
        return purchasePrice;
    }

    modifier timeBoundsCheck() {
        uint256 elapsed_since_update = block.timestamp - block_timestamp_last;
        require(
            block.timestamp - block_timestamp_last < MAX_TWAP_TIME,
            "Cumulative price snapshot too old"
        );
        require(
            block.timestamp - block_timestamp_last > MIN_TWAP_TIME,
            "Cumulative price snapshot too new"
        );
        _;
    }
}







contract USTONKSAPRFarming is TWAPBoundedUSTONKSAPR, UniHelper, YamSubGoverned {
    enum ACTION {ENTER, EXIT}

    constructor(address gov_) public {
        gov = gov_;
    }

    SynthMinter minter =
        SynthMinter(0x4F1424Cef6AcE40c0ae4fc64d74B734f1eAF153C);

    bool completed = true;

    ACTION action;

    address internal constant RESERVES =
        address(0x97990B693835da58A281636296D2Bf02787DEa17);

    VAULT internal constant YUSD =
        VAULT(0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c);
    CURVE_WITHDRAWER internal constant Y_DEPOSIT =
        CURVE_WITHDRAWER(0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3);
    IERC20 internal constant YCRV =
        IERC20(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8);

    address internal constant MULTISIG = 0x744D16d200175d20E6D8e5f405AEfB4EB7A962d1;  
    // ========= MINTING =========

    function _mint(uint256 collateral_amount, uint256 mint_amount) internal {
        USDC.approve(address(minter), uint256(-1));

        minter.create(
            SynthMinter.Unsigned(collateral_amount),
            SynthMinter.Unsigned(mint_amount)
        );
    }

    function _repayAndWithdraw() internal {
        USTONKS_APR.approve(address(minter), uint256(-1));
        SynthMinter.PositionData memory position =
            minter.positions(address(this));
        uint256 ustonksBalance = USTONKS_APR.balanceOf(address(this));
        // We might end up with more USTONKS APR than we have debt. These will get sent to the treasury for future redemption
        if (ustonksBalance >= position.tokensOutstanding.rawValue) {
            minter.redeem(position.tokensOutstanding);
        } else {
            // We might end up with more debt than we have USTONKS APR. In this case, only redeem MAX(minSponsorTokens, ustonksBalance)
            // The extra debt will need to be handled externally, by either waiting until expiry, others sponsoring the debt for later reimbursement, or purchasing the ustonks
            minter.redeem(
                SynthMinter.Unsigned(
                    position.tokensOutstanding.rawValue - ustonksBalance <=
                        5 * 10**6
                        ? position.tokensOutstanding.rawValue - 5 * 10**6
                        : ustonksBalance
                )
            );
        }
    }

    // ========= ENTER ==========

    function enter() public timeBoundsCheck {
        require(action == ACTION.ENTER, "Wrong action");
        require(!completed, "Action completed");
        uint256 ustonksReserves;
        uint256 usdcReserves;
        (usdcReserves, ustonksReserves, ) = uniswap_pair.getReserves();
        require(
            withinBounds(usdcReserves, ustonksReserves),
            "Market rate is outside bounds"
        );
        YUSD.withdraw(YUSD.balanceOf(address(this)));
        uint256 ycrvBalance = YCRV.balanceOf(address(this));
        YCRV.approve(address(Y_DEPOSIT), ycrvBalance);
        Y_DEPOSIT.remove_liquidity_one_coin(ycrvBalance, 1, 1);
        uint256 usdcBalance = USDC.balanceOf(address(this));

        uint256 collateral_amount = (usdcBalance * 2) / 3;
        uint256 mint_amount =
            (collateral_amount * ustonksReserves) / usdcReserves / 4;
        _mint(collateral_amount, mint_amount);

        _mintLPToken(uniswap_pair, USDC, USTONKS_APR, mint_amount, RESERVES);

        USDC.transfer(address(MULTISIG), USDC.balanceOf(address(this)));
        completed = true;
    }

    // ========== EXIT  ==========
    function exit() public timeBoundsCheck {
        require(action == ACTION.EXIT);
        require(!completed, "Action completed");
        uint256 ustonksReserves;
        uint256 usdcReserves;
        (usdcReserves, ustonksReserves, ) = uniswap_pair.getReserves();
        require(
            withinBounds(usdcReserves, ustonksReserves),
            "Market rate is outside bounds"
        );

        _burnLPToken(uniswap_pair, address(this));

        _repayAndWithdraw();

        USDC.transfer(RESERVES, USDC.balanceOf(address(this)));
        uint256 ustonksBalance = USTONKS_APR.balanceOf(address(this));
        if (ustonksBalance > 0) {
            USTONKS_APR.transfer(RESERVES, ustonksBalance);
        }
        completed = true;
    }

    // ========= GOVERNANCE ONLY ACTION APPROVALS =========
    function _approveEnter() public onlyGovOrSubGov {
        completed = false;
        action = ACTION.ENTER;
    }

    function _approveExit() public onlyGovOrSubGov {
        completed = false;
        action = ACTION.EXIT;
    }

    // ========= GOVERNANCE ONLY SAFTEY MEASURES =========

    function _redeem(uint256 debt_to_pay) public onlyGovOrSubGov {
        minter.redeem(SynthMinter.Unsigned(debt_to_pay));
    }

    function _withdrawCollateral(uint256 amount_to_withdraw)
        public
        onlyGovOrSubGov
    {
        minter.withdraw(SynthMinter.Unsigned(amount_to_withdraw));
    }

    function _settleExpired() public onlyGovOrSubGov {
        minter.settleExpired();
    }

    function masterFallback(address target, bytes memory data)
        public
        onlyGovOrSubGov
    {
        target.call.value(0)(data);
    }

    function _getTokenFromHere(address token) public onlyGovOrSubGov {
        IERC20 t = IERC20(token);
        t.transfer(RESERVES, t.balanceOf(address(this)));
    }
}