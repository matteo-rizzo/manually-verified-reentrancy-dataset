/**
 *Submitted for verification at Etherscan.io on 2021-05-14
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.6.11;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @openzeppelin/contracts/math/SafeMath.sol

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


// File: @openzeppelin/contracts/utils/Address.sol

/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/protocol/IStrategyERC20_V3.sol

/*
version 1.3.0

Changes listed here do not affect interaction with other contracts (Vault and Controller)
- remove functions that are not called by other contracts (vaults and controller)
*/



// File: contracts/protocol/IController.sol



// File: contracts/StrategyERC20_V3.sol

/*
Changes
- remove functions related to slippage and delta
- add keeper
- remove _increaseDebt
- remove _decreaseDebt
*/

// used inside harvest

abstract contract StrategyERC20_V3 is IStrategyERC20_V3 {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    address public override admin;
    address public nextAdmin;
    address public override controller;
    address public immutable override vault;
    address public immutable override underlying;
    // some functions specific to strategy cannot be called by controller
    // so we introduce a new role
    address public keeper;

    // total amount of underlying transferred from vault
    uint public override totalDebt;

    // performance fee sent to treasury when harvest() generates profit
    uint public performanceFee = 500;
    uint private constant PERFORMANCE_FEE_CAP = 2000; // upper limit to performance fee
    uint internal constant PERFORMANCE_FEE_MAX = 10000;

    // Force exit, in case normal exit fails
    bool public forceExit;

    constructor(
        address _controller,
        address _vault,
        address _underlying,
        address _keeper
    ) public {
        require(_controller != address(0), "controller = zero address");
        require(_vault != address(0), "vault = zero address");
        require(_underlying != address(0), "underlying = zero address");
        require(_keeper != address(0), "keeper = zero address");

        admin = msg.sender;
        controller = _controller;
        vault = _vault;
        underlying = _underlying;
        keeper = _keeper;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "!admin");
        _;
    }

    modifier onlyAuthorized() {
        require(
            msg.sender == admin ||
                msg.sender == controller ||
                msg.sender == vault ||
                msg.sender == keeper,
            "!authorized"
        );
        _;
    }

    function setNextAdmin(address _nextAdmin) external onlyAdmin {
        require(_nextAdmin != admin, "next admin = current");
        // allow next admin = zero address (cancel next admin)
        nextAdmin = _nextAdmin;
    }

    function acceptAdmin() external {
        require(msg.sender == nextAdmin, "!next admin");
        admin = msg.sender;
        nextAdmin = address(0);
    }

    function setController(address _controller) external onlyAdmin {
        require(_controller != address(0), "controller = zero address");
        controller = _controller;
    }

    function setKeeper(address _keeper) external onlyAdmin {
        require(_keeper != address(0), "keeper = zero address");
        keeper = _keeper;
    }

    function setPerformanceFee(uint _fee) external onlyAdmin {
        require(_fee <= PERFORMANCE_FEE_CAP, "performance fee > cap");
        performanceFee = _fee;
    }

    function setForceExit(bool _forceExit) external onlyAdmin {
        forceExit = _forceExit;
    }

    function totalAssets() external view virtual override returns (uint);

    function deposit(uint) external virtual override;

    function withdraw(uint) external virtual override;

    function withdrawAll() external virtual override;

    function harvest() external virtual override;

    function skim() external virtual override;

    function exit() external virtual override;

    function sweep(address) external virtual override;
}

// File: contracts/interfaces/uniswap/Uniswap.sol



// File: contracts/interfaces/curve/LiquidityGaugeV2.sol



// File: contracts/interfaces/curve/Minter.sol

// https://github.com/curvefi/curve-dao-contracts/blob/master/contracts/Minter.vy


// File: contracts/interfaces/curve/StableSwapUsdp.sol



// File: contracts/interfaces/curve/StableSwap3Pool.sol



// File: contracts/interfaces/curve/DepositUsdp.sol



// File: contracts/strategies/StrategyCurveUsdp.sol

contract StrategyCurveUsdp is StrategyERC20_V3 {
    event Deposit(uint amount);
    event Withdraw(uint amount);
    event Harvest(uint profit);
    event Skim(uint profit);

    // Uniswap //
    address private constant UNISWAP = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address internal constant USDP = 0x1456688345527bE1f37E9e627DA0837D6f08C925;
    address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    // USDP = 0 | DAI = 1 | USDC = 2 | USDT = 3
    uint private immutable UNDERLYING_INDEX;
    // precision to convert 10 ** 18  to underlying decimals
    uint[4] private PRECISION_DIV = [1, 1, 1e12, 1e12];
    // precision div of underlying token (used to save gas)
    uint private immutable PRECISION_DIV_UNDERLYING;

    // Curve //
    // StableSwap3Pool
    address private constant BASE_POOL = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
    // StableSwap
    address private constant SWAP = 0x42d7025938bEc20B69cBae5A77421082407f053A;
    // liquidity provider token (USDP / 3CRV)
    address private constant LP = 0x7Eb40E450b9655f4B3cC4259BCC731c63ff55ae6;
    // Deposit
    address private constant DEPOSIT = 0x3c8cAee4E09296800f8D29A68Fa3837e2dae4940;
    // LiquidityGaugeV2
    address private constant GAUGE = 0x055be5DDB7A925BfEF3417FC157f53CA77cA7222;
    // Minter
    address private constant MINTER = 0xd061D61a4d941c39E5453435B6345Dc261C2fcE0;
    // CRV
    address private constant CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;

    // prevent slippage from deposit / withdraw
    uint public slippage = 100;
    uint private constant SLIPPAGE_MAX = 10000;

    /*
    Numerator used to update totalDebt if
    totalAssets() is <= totalDebt * delta / DELTA_MIN
    */
    uint public delta = 10050;
    uint private constant DELTA_MIN = 10000;

    // enable to claim LiquidityGaugeV2 rewards
    bool public shouldClaimRewards;

    constructor(
        address _controller,
        address _vault,
        address _underlying,
        uint _underlyingIndex,
        address _keeper
    ) public StrategyERC20_V3(_controller, _vault, _underlying, _keeper) {
        UNDERLYING_INDEX = _underlyingIndex;
        PRECISION_DIV_UNDERLYING = PRECISION_DIV[_underlyingIndex];

        // Infinite approvals should be safe as long as only small amount
        // of underlying is stored in this contract.

        // Approve DepositUsdp.add_liquidity
        IERC20(USDP).safeApprove(DEPOSIT, type(uint).max);
        IERC20(DAI).safeApprove(DEPOSIT, type(uint).max);
        IERC20(USDC).safeApprove(DEPOSIT, type(uint).max);
        IERC20(USDT).safeApprove(DEPOSIT, type(uint).max);
        // Approve LiquidityGaugeV2.deposit
        IERC20(LP).safeApprove(GAUGE, type(uint).max);
        // approve DepositUsdp.remove_liquidity
        IERC20(LP).safeApprove(DEPOSIT, type(uint).max);

        // These tokens are never held by this contract
        // so the risk of them getting stolen is minimal
        IERC20(CRV).safeApprove(UNISWAP, type(uint).max);
    }

    /*
    @notice Set max slippage for deposit and withdraw from Curve pool
    @param _slippage Max amount of slippage allowed
    */
    function setSlippage(uint _slippage) external onlyAdmin {
        require(_slippage <= SLIPPAGE_MAX, "slippage > max");
        slippage = _slippage;
    }

    /*
    @notice Set delta, used to calculate difference between totalAsset and totalDebt
    @param _delta Numerator of delta / DELTA_MIN
    */
    function setDelta(uint _delta) external onlyAdmin {
        require(_delta >= DELTA_MIN, "delta < min");
        delta = _delta;
    }

    /*
    @notice Activate or decactivate LiquidityGaugeV2.claim_rewards()
    */
    function setShouldClaimRewards(bool _shouldClaimRewards) external onlyAdmin {
        shouldClaimRewards = _shouldClaimRewards;
    }

    function _totalAssets() private view returns (uint) {
        uint lpBal = LiquidityGaugeV2(GAUGE).balanceOf(address(this));
        uint pricePerShare = StableSwapUsdp(SWAP).get_virtual_price();

        return lpBal.mul(pricePerShare) / (PRECISION_DIV_UNDERLYING * 1e18);
    }

    function totalAssets() external view override returns (uint) {
        return _totalAssets();
    }

    function _increaseDebt(uint _amount) private returns (uint) {
        // USDT has transfer fee so we need to check balance after transfer
        uint balBefore = IERC20(underlying).balanceOf(address(this));
        IERC20(underlying).safeTransferFrom(vault, address(this), _amount);
        uint balAfter = IERC20(underlying).balanceOf(address(this));

        uint diff = balAfter.sub(balBefore);
        totalDebt = totalDebt.add(diff);

        return diff;
    }

    function _decreaseDebt(uint _amount) private returns (uint) {
        // USDT has transfer fee so we need to check balance after transfer
        uint balBefore = IERC20(underlying).balanceOf(address(this));
        IERC20(underlying).safeTransfer(vault, _amount);
        uint balAfter = IERC20(underlying).balanceOf(address(this));

        uint diff = balBefore.sub(balAfter);
        if (diff >= totalDebt) {
            totalDebt = 0;
        } else {
            totalDebt -= diff;
        }

        return diff;
    }

    /*
    @notice Deposit underlying token into Curve
    @param _token Address of underlying token
    @param _index Index of underlying token
    */
    function _deposit(address _token, uint _index) private {
        // deposit underlying token, get LP
        uint bal = IERC20(_token).balanceOf(address(this));
        if (bal > 0) {
            // mint LP
            uint[4] memory amounts;
            amounts[_index] = bal;

            /*
            shares = underlying amount * precision div * 1e18 / price per share
            */
            uint pricePerShare = StableSwapUsdp(SWAP).get_virtual_price();
            uint shares = bal.mul(PRECISION_DIV[_index]).mul(1e18).div(pricePerShare);
            uint min = shares.mul(SLIPPAGE_MAX - slippage) / SLIPPAGE_MAX;

            uint lpAmount = DepositUsdp(DEPOSIT).add_liquidity(amounts, min);

            // stake into LiquidityGaugeV2
            if (lpAmount > 0) {
                LiquidityGaugeV2(GAUGE).deposit(lpAmount);
            }
        }
    }

    function deposit(uint _amount) external override onlyAuthorized {
        require(_amount > 0, "deposit = 0");

        uint diff = _increaseDebt(_amount);
        _deposit(underlying, UNDERLYING_INDEX);

        emit Deposit(diff);
    }

    function _getTotalShares() private view returns (uint) {
        return LiquidityGaugeV2(GAUGE).balanceOf(address(this));
    }

    function _getShares(
        uint _amount,
        uint _total,
        uint _totalShares
    ) private pure returns (uint) {
        /*
        calculate shares to withdraw

        w = amount of underlying to withdraw
        U = total redeemable underlying
        s = shares to withdraw
        P = total shares deposited into external liquidity pool

        w / U = s / P
        s = w / U * P
        */
        if (_total > 0) {
            // avoid rounding errors and cap shares to be <= total shares
            if (_amount >= _total) {
                return _totalShares;
            }
            return _amount.mul(_totalShares) / _total;
        }
        return 0;
    }

    /*
    @notice Withdraw underlying token from Curve
    @param _amount Amount of underlying token to withdraw
    @return Actual amount of underlying token that was withdrawn
    */
    function _withdraw(uint _amount) private returns (uint) {
        require(_amount > 0, "withdraw = 0");

        uint total = _totalAssets();

        if (_amount >= total) {
            _amount = total;
        }

        uint totalShares = _getTotalShares();
        uint shares = _getShares(_amount, total, totalShares);

        if (shares > 0) {
            // withdraw LP from LiquidityGaugeV2
            LiquidityGaugeV2(GAUGE).withdraw(shares);

            uint min = _amount.mul(SLIPPAGE_MAX - slippage) / SLIPPAGE_MAX;
            // withdraw creates LP dust
            return
                DepositUsdp(DEPOSIT).remove_liquidity_one_coin(
                    shares,
                    int128(UNDERLYING_INDEX),
                    min
                );
            // Now we have underlying
        }
        return 0;
    }

    function withdraw(uint _amount) external override onlyAuthorized {
        uint withdrawn = _withdraw(_amount);

        if (withdrawn < _amount) {
            _amount = withdrawn;
        }
        // if withdrawn > _amount, excess will be deposited when deposit() is called

        uint diff;
        if (_amount > 0) {
            diff = _decreaseDebt(_amount);
        }

        emit Withdraw(diff);
    }

    function _withdrawAll() private {
        _withdraw(type(uint).max);

        // There may be dust so re-calculate balance
        uint bal = IERC20(underlying).balanceOf(address(this));
        if (bal > 0) {
            IERC20(underlying).safeTransfer(vault, bal);
            totalDebt = 0;
        }

        emit Withdraw(bal);
    }

    function withdrawAll() external override onlyAuthorized {
        _withdrawAll();
    }

    /*
    @notice Returns address and index of token with lowest balance in Curve pool
    */
    function _getMostPremiumToken() private view returns (address, uint) {
        // meta pool balances
        uint[2] memory balances;
        balances[0] = StableSwapUsdp(SWAP).balances(0); // USDP
        balances[1] = StableSwapUsdp(SWAP).balances(1); // 3CRV

        if (balances[0] <= balances[1]) {
            return (USDP, 0);
        } else {
            // base pool balances
            uint[3] memory baseBalances;
            baseBalances[0] = StableSwap3Pool(BASE_POOL).balances(0); // DAI
            baseBalances[1] = StableSwap3Pool(BASE_POOL).balances(1).mul(1e12); // USDC
            baseBalances[2] = StableSwap3Pool(BASE_POOL).balances(2).mul(1e12); // USDT

            /*
            DAI  1
            USDC 2
            USDT 3
            */

            // DAI
            if (
                baseBalances[0] <= baseBalances[1] && baseBalances[0] <= baseBalances[2]
            ) {
                return (DAI, 1);
            }

            // USDC
            if (
                baseBalances[1] <= baseBalances[0] && baseBalances[1] <= baseBalances[2]
            ) {
                return (USDC, 2);
            }

            return (USDT, 3);
        }
    }

    /*
    @dev Uniswap fails with zero address so no check is necessary here
    */
    function _swap(
        address _from,
        address _to,
        uint _amount
    ) private {
        // create dynamic array with 3 elements
        address[] memory path = new address[](3);
        path[0] = _from;
        path[1] = WETH;
        path[2] = _to;

        Uniswap(UNISWAP).swapExactTokensForTokens(
            _amount,
            1,
            path,
            address(this),
            block.timestamp
        );
    }

    function _claimRewards(address _token) private {
        if (shouldClaimRewards) {
            LiquidityGaugeV2(GAUGE).claim_rewards();
            // Rewarded tokens will be managed by admin via calling sweep()
        }

        // claim CRV
        Minter(MINTER).mint(GAUGE);

        uint crvBal = IERC20(CRV).balanceOf(address(this));
        // Swap only if CRV >= 1, otherwise swap may fail
        if (crvBal >= 1e18) {
            _swap(CRV, _token, crvBal);
            // Now this contract has token
        }
    }

    /*
    @notice Claim CRV and deposit most premium token into Curve
    */
    function harvest() external override onlyAuthorized {
        (address token, uint index) = _getMostPremiumToken();

        _claimRewards(token);

        uint bal = IERC20(token).balanceOf(address(this));
        if (bal > 0) {
            // transfer fee to treasury
            uint fee = bal.mul(performanceFee) / PERFORMANCE_FEE_MAX;
            if (fee > 0) {
                address treasury = IController(controller).treasury();
                require(treasury != address(0), "treasury = 0 address");

                IERC20(token).safeTransfer(treasury, fee);
            }

            _deposit(token, index);

            emit Harvest(bal.sub(fee));
        }
    }

    function skim() external override onlyAuthorized {
        uint total = _totalAssets();
        require(total > totalDebt, "total underlying < debt");

        uint profit = total - totalDebt;

        // protect against price manipulation
        uint max = totalDebt.mul(delta) / DELTA_MIN;
        if (total <= max) {
            /*
            total underlying is within reasonable bounds, probaly no price
            manipulation occured.
            */

            /*
            If we were to withdraw profit followed by deposit, this would
            increase the total debt roughly by the profit.

            Withdrawing consumes high gas, so here we omit it and
            directly increase debt, as if withdraw and deposit were called.
            */
            // total debt = total debt + profit = total
            totalDebt = total;
        } else {
            /*
            Possible reasons for total underlying > max
            1. total debt = 0
            2. total underlying really did increase over max
            3. price was manipulated
            */
            uint withdrawn = _withdraw(profit);
            if (withdrawn > 0) {
                IERC20(underlying).safeTransfer(vault, withdrawn);
            }
        }

        emit Skim(profit);
    }

    function exit() external override onlyAuthorized {
        if (forceExit) {
            return;
        }
        _claimRewards(underlying);
        _withdrawAll();
    }

    function sweep(address _token) external override onlyAdmin {
        require(_token != underlying, "protected token");
        require(_token != GAUGE, "protected token");
        IERC20(_token).safeTransfer(admin, IERC20(_token).balanceOf(address(this)));
    }
}

// File: contracts/strategies/StrategyCurveUsdpUsdt.sol

contract StrategyCurveUsdpUsdt is StrategyCurveUsdp {
    constructor(
        address _controller,
        address _vault,
        address _keeper
    ) public StrategyCurveUsdp(_controller, _vault, USDT, 3, _keeper) {}
}