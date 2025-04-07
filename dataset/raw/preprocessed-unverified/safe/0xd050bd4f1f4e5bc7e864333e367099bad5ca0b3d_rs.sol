/**
 *Submitted for verification at Etherscan.io on 2020-11-30
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.6.11;





// https://github.com/curvefi/curve-contract/blob/master/contracts/gauges/LiquidityGauge.vy


// https://github.com/curvefi/curve-dao-contracts/blob/master/contracts/Minter.vy


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






abstract contract StrategyBase is IStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    address public override admin;
    address public override controller;
    address public override vault;
    address public override underlying;

    // total amount of underlying transferred from vault
    uint public override totalDebt;

    // performance fee sent to treasury when harvest() generates profit
    uint public override performanceFee = 100;
    uint internal constant PERFORMANCE_FEE_MAX = 10000;

    // valuable tokens that cannot be swept
    mapping(address => bool) public override assets;

    constructor(
        address _controller,
        address _vault,
        address _underlying
    ) public {
        require(_controller != address(0), "controller = zero address");
        require(_vault != address(0), "vault = zero address");
        require(_underlying != address(0), "underlying = zero address");

        admin = msg.sender;
        controller = _controller;
        vault = _vault;
        underlying = _underlying;

        assets[underlying] = true;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "!admin");
        _;
    }

    modifier onlyAuthorized() {
        require(
            msg.sender == admin || msg.sender == controller || msg.sender == vault,
            "!authorized"
        );
        _;
    }

    function setAdmin(address _admin) external override onlyAdmin {
        require(_admin != address(0), "admin = zero address");
        admin = _admin;
    }

    function setController(address _controller) external override onlyAdmin {
        require(_controller != address(0), "controller = zero address");
        controller = _controller;
    }

    function setPerformanceFee(uint _fee) external override onlyAdmin {
        require(_fee <= PERFORMANCE_FEE_MAX, "performance fee > max");
        performanceFee = _fee;
    }

    function _increaseDebt(uint _underlyingAmount) private {
        uint balBefore = IERC20(underlying).balanceOf(address(this));
        IERC20(underlying).safeTransferFrom(vault, address(this), _underlyingAmount);
        uint balAfter = IERC20(underlying).balanceOf(address(this));

        totalDebt = totalDebt.add(balAfter.sub(balBefore));
    }

    function _decreaseDebt(uint _underlyingAmount) private {
        uint balBefore = IERC20(underlying).balanceOf(address(this));
        IERC20(underlying).safeTransfer(vault, _underlyingAmount);
        uint balAfter = IERC20(underlying).balanceOf(address(this));

        uint diff = balBefore.sub(balAfter);
        if (diff > totalDebt) {
            totalDebt = 0;
        } else {
            totalDebt = totalDebt - diff;
        }
    }

    function _totalAssets() internal view virtual returns (uint);

    /*
    @notice Returns amount of underlying tokens locked in this contract
    */
    function totalAssets() external view override returns (uint) {
        return _totalAssets();
    }

    function _depositUnderlying() internal virtual;

    /*
    @notice Deposit underlying token into this strategy
    @param _underlyingAmount Amount of underlying token to deposit
    */
    function deposit(uint _underlyingAmount) external override onlyAuthorized {
        require(_underlyingAmount > 0, "underlying = 0");

        _increaseDebt(_underlyingAmount);
        _depositUnderlying();
    }

    /*
    @notice Returns total shares owned by this contract for depositing underlying
            into external Defi
    */
    function _getTotalShares() internal view virtual returns (uint);

    function _getShares(uint _underlyingAmount, uint _totalUnderlying)
        internal
        view
        returns (uint)
    {
        /*
        calculate shares to withdraw

        w = amount of underlying to withdraw
        U = total redeemable underlying
        s = shares to withdraw
        P = total shares deposited into external liquidity pool

        w / U = s / P
        s = w / U * P
        */
        if (_totalUnderlying > 0) {
            uint totalShares = _getTotalShares();
            return _underlyingAmount.mul(totalShares) / _totalUnderlying;
        }
        return 0;
    }

    function _withdrawUnderlying(uint _shares) internal virtual;

    /*
    @notice Withdraw undelying token to vault
    @param _underlyingAmount Amount of underlying token to withdraw
    @dev Caller should implement guard agains slippage
    */
    function withdraw(uint _underlyingAmount) external override onlyAuthorized {
        require(_underlyingAmount > 0, "underlying = 0");
        uint totalUnderlying = _totalAssets();
        require(_underlyingAmount <= totalUnderlying, "underlying > total");

        uint shares = _getShares(_underlyingAmount, totalUnderlying);
        if (shares > 0) {
            _withdrawUnderlying(shares);
        }

        // transfer underlying token to vault
        uint underlyingBal = IERC20(underlying).balanceOf(address(this));
        if (underlyingBal > 0) {
            _decreaseDebt(underlyingBal);
        }
    }

    function _withdrawAll() internal {
        uint totalShares = _getTotalShares();
        if (totalShares > 0) {
            _withdrawUnderlying(totalShares);
        }

        uint underlyingBal = IERC20(underlying).balanceOf(address(this));
        if (underlyingBal > 0) {
            _decreaseDebt(underlyingBal);
            totalDebt = 0;
        }
    }

    /*
    @notice Withdraw all underlying to vault
    @dev Caller should implement guard agains slippage
    */
    function withdrawAll() external override onlyAuthorized {
        _withdrawAll();
    }

    /*
    @notice Sell any staking rewards for underlying, deposit or transfer undelying
            depending on total debt
    */
    function harvest() external virtual override;

    /*
    @notice Transfer profit over total debt to vault
    */
    function skim() external override onlyAuthorized {
        uint totalUnderlying = _totalAssets();

        if (totalUnderlying > totalDebt) {
            uint profit = totalUnderlying - totalDebt;
            uint shares = _getShares(profit, totalUnderlying);
            if (shares > 0) {
                uint balBefore = IERC20(underlying).balanceOf(address(this));
                _withdrawUnderlying(shares);
                uint balAfter = IERC20(underlying).balanceOf(address(this));

                uint diff = balAfter.sub(balBefore);
                if (diff > 0) {
                    IERC20(underlying).safeTransfer(vault, diff);
                }
            }
        }
    }

    function exit() external virtual override;

    function sweep(address _token) external override onlyAdmin {
        require(!assets[_token], "asset");

        IERC20(_token).safeTransfer(admin, IERC20(_token).balanceOf(address(this)));
    }
}



contract UseUniswap {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    // Uniswap //
    address private constant UNISWAP = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function _swap(
        address _from,
        address _to,
        uint _amount
    ) internal {
        require(_to != address(0), "to = zero address");

        // Swap with uniswap
        IERC20(_from).safeApprove(UNISWAP, 0);
        IERC20(_from).safeApprove(UNISWAP, _amount);

        address[] memory path;

        if (_from == WETH || _to == WETH) {
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = WETH;
            path[2] = _to;
        }

        Uniswap(UNISWAP).swapExactTokensForTokens(
            _amount,
            0,
            path,
            address(this),
            now.add(60)
        );
    }
}

abstract contract StrategyCurve is StrategyBase, UseUniswap {
    // DAI = 0 | USDC = 1 | USDT = 2
    uint internal underlyingIndex;
    // precision to convert 10 ** 18  to underlying decimals
    uint internal precisionDiv = 1;

    // Curve //
    // liquidity provider token (cDAI/cUSDC or 3Crv)
    address internal lp;
    // ICurveFi2 or ICurveFi3
    address internal pool;
    // Gauge
    address internal gauge;
    // Minter
    address internal minter;
    // DAO
    address internal crv;

    constructor(
        address _controller,
        address _vault,
        address _underlying
    ) public StrategyBase(_controller, _vault, _underlying) {}

    function _getVirtualPrice() internal view virtual returns (uint);

    function _totalAssets() internal view override returns (uint) {
        uint lpBal = Gauge(gauge).balanceOf(address(this));
        uint pricePerShare = _getVirtualPrice();

        return lpBal.mul(pricePerShare).div(precisionDiv) / 1e18;
    }

    function _addLiquidity(uint _amount, uint _index) internal virtual;

    /*
    @notice deposit token into curve
    */
    function _deposit(address _token, uint _index) private {
        // token to lp
        uint bal = IERC20(_token).balanceOf(address(this));
        if (bal > 0) {
            IERC20(_token).safeApprove(pool, 0);
            IERC20(_token).safeApprove(pool, bal);
            // mint lp
            _addLiquidity(bal, _index);
        }

        // stake into Gauge
        uint lpBal = IERC20(lp).balanceOf(address(this));
        if (lpBal > 0) {
            IERC20(lp).safeApprove(gauge, 0);
            IERC20(lp).safeApprove(gauge, lpBal);
            Gauge(gauge).deposit(lpBal);
        }
    }

    /*
    @notice Deposits underlying to Gauge
    */
    function _depositUnderlying() internal override {
        _deposit(underlying, underlyingIndex);
    }

    function _removeLiquidityOneCoin(uint _lpAmount) internal virtual;

    function _getTotalShares() internal view override returns (uint) {
        return Gauge(gauge).balanceOf(address(this));
    }

    function _withdrawUnderlying(uint _lpAmount) internal override {
        // withdraw lp from  Gauge
        Gauge(gauge).withdraw(_lpAmount);
        // withdraw underlying
        uint lpBal = IERC20(lp).balanceOf(address(this));
        // creates lp dust
        _removeLiquidityOneCoin(lpBal);
        // Now we have underlying
    }

    /*
    @notice Returns address and index of token with lowest balance in Curve pool
    */
    function _getMostPremiumToken() internal view virtual returns (address, uint);

    function _swapCrvFor(address _token) private {
        Minter(minter).mint(gauge);

        uint crvBal = IERC20(crv).balanceOf(address(this));
        if (crvBal > 0) {
            _swap(crv, _token, crvBal);
            // Now this contract has token
        }
    }

    /*
    @notice Claim CRV and deposit most premium token into Curve
    */
    function harvest() external override onlyAuthorized {
        (address token, uint index) = _getMostPremiumToken();

        _swapCrvFor(token);

        uint bal = IERC20(token).balanceOf(address(this));
        if (bal > 0) {
            // transfer fee to treasury
            uint fee = bal.mul(performanceFee) / PERFORMANCE_FEE_MAX;
            if (fee > 0) {
                address treasury = IController(controller).treasury();
                require(treasury != address(0), "treasury = zero address");

                IERC20(token).safeTransfer(treasury, fee);
            }

            _deposit(token, index);
        }
    }

    /*
    @notice Exit strategy by harvesting CRV to underlying token and then
            withdrawing all underlying to vault
    @dev Must return all underlying token to vault
    @dev Caller should implement guard agains slippage
    */
    function exit() external override onlyAuthorized {
        _swapCrvFor(underlying);
        _withdrawAll();
    }
}

contract StrategyCusd is StrategyCurve {
    address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    address private constant SWAP = 0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56;

    constructor(
        address _controller,
        address _vault,
        address _underlying
    ) public StrategyCurve(_controller, _vault, _underlying) {
        // Curve
        // cDAI/cUSDC
        lp = 0x845838DF265Dcd2c412A1Dc9e959c7d08537f8a2;
        // DepositCompound
        pool = 0xeB21209ae4C2c9FF2a86ACA31E123764A3B6Bc06;
        // Gauge
        gauge = 0x7ca5b0a2910B33e9759DC7dDB0413949071D7575;
        // Minter
        minter = 0xd061D61a4d941c39E5453435B6345Dc261C2fcE0;
        // DAO
        crv = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    }

    /*
    @dev Returns USD price of 1 Curve Compound LP token
    */
    function _getVirtualPrice() internal view override returns (uint) {
        return StableSwap2(SWAP).get_virtual_price();
    }

    function _addLiquidity(uint _amount, uint _index) internal override {
        uint[2] memory amounts;
        amounts[_index] = _amount;
        Deposit2(pool).add_liquidity(amounts, 0);
    }

    function _removeLiquidityOneCoin(uint _lpAmount) internal override {
        IERC20(lp).safeApprove(pool, 0);
        IERC20(lp).safeApprove(pool, _lpAmount);

        Deposit2(pool).remove_liquidity_one_coin(
            _lpAmount,
            int128(underlyingIndex),
            0,
            true
        );
    }

    function _getMostPremiumToken() internal view override returns (address, uint) {
        uint[] memory balances = new uint[](2);
        balances[0] = StableSwap2(SWAP).balances(0); // DAI
        balances[1] = StableSwap2(SWAP).balances(1).mul(1e12); // USDC

        // DAI
        if (balances[0] < balances[1]) {
            return (DAI, 0);
        }

        return (USDC, 1);
    }
}

contract StrategyCusdUsdc is StrategyCusd {
    constructor(address _controller, address _vault)
        public
        StrategyCusd(_controller, _vault, USDC)
    {
        // usdc
        underlyingIndex = 1;
        precisionDiv = 1e12;
    }
}