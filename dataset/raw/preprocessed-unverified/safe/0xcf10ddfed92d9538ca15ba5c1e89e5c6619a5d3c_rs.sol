/**
 *Submitted for verification at Etherscan.io on 2021-03-11
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
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


// File: contracts/protocol/IStrategy.sol

/*
version 1.2.0

Changes

Changes listed here do not affect interaction with other contracts (Vault and Controller)
- removed function assets(address _token) external view returns (bool);
- remove function deposit(uint), declared in IStrategyERC20
- add function setSlippage(uint _slippage);
- add function setDelta(uint _delta);
*/



// File: contracts/protocol/IStrategyETH.sol

interface IStrategyETH is IStrategy {
    /*
    @notice Deposit ETH
    */
    function deposit() external payable;
}

// File: contracts/protocol/IController.sol



// File: contracts/StrategyETH.sol

/*
version 1.2.0
*/

// used inside harvest

abstract contract StrategyETH is IStrategyETH {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    address public override admin;
    address public override controller;
    address public immutable override vault;
    // Placeholder address to indicate that this is ETH strategy
    address public constant override underlying =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // total amount of ETH transferred from vault
    uint public override totalDebt;

    // performance fee sent to treasury when harvest() generates profit
    uint public override performanceFee = 500;
    uint private constant PERFORMANCE_FEE_CAP = 2000; // upper limit to performance fee
    uint internal constant PERFORMANCE_FEE_MAX = 10000;

    // prevent slippage from deposit / withdraw
    uint public override slippage = 100;
    uint internal constant SLIPPAGE_MAX = 10000;

    /* 
    Multiplier used to check totalAssets() is <= total debt * delta / DELTA_MIN
    */
    uint public override delta = 10050;
    uint private constant DELTA_MIN = 10000;

    // Force exit, in case normal exit fails
    bool public override forceExit;

    constructor(address _controller, address _vault) public {
        require(_controller != address(0), "controller = zero address");
        require(_vault != address(0), "vault = zero address");

        admin = msg.sender;
        controller = _controller;
        vault = _vault;
    }

    /*
    @dev implement receive() external payable in child contract
    @dev receive() should restrict msg.sender to prevent accidental ETH transfer
    @dev vault and controller will never call receive()
    */

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
        require(_fee <= PERFORMANCE_FEE_CAP, "performance fee > cap");
        performanceFee = _fee;
    }

    function setSlippage(uint _slippage) external override onlyAdmin {
        require(_slippage <= SLIPPAGE_MAX, "slippage > max");
        slippage = _slippage;
    }

    function setDelta(uint _delta) external override onlyAdmin {
        require(_delta >= DELTA_MIN, "delta < min");
        delta = _delta;
    }

    function setForceExit(bool _forceExit) external override onlyAdmin {
        forceExit = _forceExit;
    }

    function _sendEthToVault(uint _amount) internal {
        require(address(this).balance >= _amount, "ETH balance < amount");

        (bool sent, ) = vault.call{value: _amount}("");
        require(sent, "Send ETH failed");
    }

    function _increaseDebt(uint _ethAmount) private {
        totalDebt = totalDebt.add(_ethAmount);
    }

    function _decreaseDebt(uint _ethAmount) private {
        _sendEthToVault(_ethAmount);

        if (_ethAmount >= totalDebt) {
            totalDebt = 0;
        } else {
            totalDebt -= _ethAmount;
        }
    }

    function _totalAssets() internal view virtual returns (uint);

    /*
    @notice Returns amount of ETH locked in this contract
    */
    function totalAssets() external view override returns (uint) {
        return _totalAssets();
    }

    function _deposit() internal virtual;

    /*
    @notice Deposit ETH into this strategy
    */
    function deposit() external payable override onlyAuthorized {
        require(msg.value > 0, "deposit = 0");

        _increaseDebt(msg.value);
        _deposit();
    }

    /*
    @notice Returns total shares owned by this contract for depositing ETH
            into external Defi
    */
    function _getTotalShares() internal view virtual returns (uint);

    function _getShares(uint _ethAmount, uint _totalEth) internal view returns (uint) {
        /*
        calculate shares to withdraw

        w = amount of ETH to withdraw
        E = total redeemable ETH
        s = shares to withdraw
        P = total shares deposited into external liquidity pool

        w / E = s / P
        s = w / E * P
        */
        if (_totalEth > 0) {
            uint totalShares = _getTotalShares();
            return _ethAmount.mul(totalShares) / _totalEth;
        }
        return 0;
    }

    function _withdraw(uint _shares) internal virtual;

    /*
    @notice Withdraw ETH to vault
    @param _ethAmount Amount of ETH to withdraw
    @dev Caller should implement guard against slippage
    */
    function withdraw(uint _ethAmount) external override onlyAuthorized {
        require(_ethAmount > 0, "withdraw = 0");
        uint totalEth = _totalAssets();
        require(_ethAmount <= totalEth, "withdraw > total");

        uint shares = _getShares(_ethAmount, totalEth);
        if (shares > 0) {
            _withdraw(shares);
        }

        // transfer ETH to vault
        /*
        WARNING: Here we are transferring all funds in this contract.
                 This operation is safe under 2 conditions:
        1. This contract does not hold any funds at rest.
        2. Vault does not allow user to withdraw excess > _underlyingAmount
        */
        uint ethBal = address(this).balance;
        if (ethBal > 0) {
            _decreaseDebt(ethBal);
        }
    }

    function _withdrawAll() internal {
        uint totalShares = _getTotalShares();
        if (totalShares > 0) {
            _withdraw(totalShares);
        }

        // transfer ETH to vault
        uint ethBal = address(this).balance;
        if (ethBal > 0) {
            _sendEthToVault(ethBal);
            totalDebt = 0;
        }
    }

    /*
    @notice Withdraw all ETH to vault
    @dev Caller should implement guard agains slippage
    */
    function withdrawAll() external override onlyAuthorized {
        _withdrawAll();
    }

    /*
    @notice Sell any staking rewards for ETH and then deposit ETH
    */
    function harvest() external virtual override;

    /*
    @notice Increase total debt if profit > 0 and total assets <= max,
            otherwise transfers profit to vault.
    @dev Guard against manipulation of external price feed by checking that
         total assets is below factor of total debt
    */
    function skim() external override onlyAuthorized {
        uint totalEth = _totalAssets();
        require(totalEth > totalDebt, "total ETH < debt");

        uint profit = totalEth - totalDebt;

        // protect against price manipulation
        uint max = totalDebt.mul(delta) / DELTA_MIN;
        if (totalEth <= max) {
            /*
            total ETH is within reasonable bounds, probaly no price
            manipulation occured.
            */

            /*
            If we were to withdraw profit followed by deposit, this would
            increase the total debt roughly by the profit.

            Withdrawing consumes high gas, so here we omit it and
            directly increase debt, as if withdraw and deposit were called.
            */
            totalDebt = totalDebt.add(profit);
        } else {
            /*
            Possible reasons for total ETH > max
            1. total debt = 0
            2. total ETH really did increase over max
            3. price was manipulated
            */
            uint shares = _getShares(profit, totalEth);
            if (shares > 0) {
                uint balBefore = address(this).balance;
                _withdraw(shares);
                uint balAfter = address(this).balance;

                uint diff = balAfter.sub(balBefore);
                if (diff > 0) {
                    _sendEthToVault(diff);
                }
            }
        }
    }

    function exit() external virtual override;

    function sweep(address) external virtual override;
}

// File: contracts/interfaces/uniswap/Uniswap.sol



// File: contracts/interfaces/curve/LiquidityGaugeV2.sol



// File: contracts/interfaces/curve/Minter.sol

// https://github.com/curvefi/curve-dao-contracts/blob/master/contracts/Minter.vy


// File: contracts/interfaces/curve/StableSwapSTETH.sol



// File: contracts/interfaces/lido/StETH.sol



// File: contracts/strategies/StrategyStEth.sol

contract StrategyStEth is StrategyETH {
    // Uniswap //
    address private constant UNISWAP = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // Curve //
    // liquidity provider token (Curve ETH/STETH)
    address private constant LP = 0x06325440D014e39736583c165C2963BA99fAf14E;
    // StableSwapSTETH
    address private constant POOL = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
    // LiquidityGaugeV2
    address private constant GAUGE = 0x182B723a58739a9c974cFDB385ceaDb237453c28;
    // Minter
    address private constant MINTER = 0xd061D61a4d941c39E5453435B6345Dc261C2fcE0;
    // CRV
    address private constant CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;

    // LIDO //
    address private constant ST_ETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address private constant LDO = 0x5A98FcBEA516Cf06857215779Fd812CA3beF1B32;

    constructor(address _controller, address _vault)
        public
        StrategyETH(_controller, _vault)
    {
        // These tokens are never held by this contract
        // so the risk of them getting stolen is minimal
        IERC20(CRV).safeApprove(UNISWAP, uint(-1));
        // Minted on Gauge deposit, withdraw and claim_rewards
        // only this contract can spend on UNISWAP
        IERC20(LDO).safeApprove(UNISWAP, uint(-1));
    }

    receive() external payable {
        // Don't allow vault to accidentally send ETH
        require(msg.sender != vault, "msg.sender = vault");
    }

    function _totalAssets() internal view override returns (uint) {
        uint shares = LiquidityGaugeV2(GAUGE).balanceOf(address(this));
        uint pricePerShare = StableSwapSTETH(POOL).get_virtual_price();

        return shares.mul(pricePerShare) / 1e18;
    }

    function _getStEthDepositAmount(uint _ethBal) private view returns (uint) {
        /*
        Goal is to find a0 and a1 such that b0 + a0 is close to b1 + a1 

        E = amount of ETH
        b0 = balance of ETH in Curve
        b1 = balance of stETH in Curve
        a0 = amount of ETH to deposit into Curve
        a1 = amount of stETH to deposit into Curve

        d = |b0 - b1|

        if d >= E
            if b0 >= b1
                a0 = 0
                a1 = E
            else
                a0 = E
                a1 = 0
        else
            if b0 >= b1
                # add d to balance Curve pool, plus half of remaining
                a1 = d + (E - d) / 2 = (E + d) / 2
                a0 = E - a1
            else
                a0 = (E + d) / 2
                a1 = E - a0
        */
        uint[2] memory balances;
        balances[0] = StableSwapSTETH(POOL).balances(0);
        balances[1] = StableSwapSTETH(POOL).balances(1);

        uint diff;
        if (balances[0] >= balances[1]) {
            diff = balances[0] - balances[1];
        } else {
            diff = balances[1] - balances[0];
        }

        // a0 = ETH amount is ignored, recomputed after stEth is bought
        // a1 = stETH amount
        uint a1;
        if (diff >= _ethBal) {
            if (balances[0] >= balances[1]) {
                a1 = _ethBal;
            }
        } else {
            if (balances[0] >= balances[1]) {
                a1 = (_ethBal.add(diff)) / 2;
            } else {
                a1 = _ethBal.sub((_ethBal.add(diff)) / 2);
            }
        }

        // a0 is ignored, recomputed after stEth is bought
        return a1;
    }

    /*
    @notice Deposits ETH to LiquidityGaugeV2
    */
    function _deposit() internal override {
        uint bal = address(this).balance;
        if (bal > 0) {
            uint stEthAmount = _getStEthDepositAmount(bal);
            if (stEthAmount > 0) {
                StETH(ST_ETH).submit{value: stEthAmount}(address(this));
            }

            uint ethBal = address(this).balance;
            uint stEthBal = IERC20(ST_ETH).balanceOf(address(this));

            if (stEthBal > 0) {
                // ST_ETH is proxy so don't allow infinite approval
                IERC20(ST_ETH).safeApprove(POOL, stEthBal);
            }

            /*
            shares = eth amount * 1e18 / price per share
            */
            uint pricePerShare = StableSwapSTETH(POOL).get_virtual_price();
            uint shares = bal.mul(1e18).div(pricePerShare);
            uint min = shares.mul(SLIPPAGE_MAX - slippage) / SLIPPAGE_MAX;

            StableSwapSTETH(POOL).add_liquidity{value: ethBal}([ethBal, stEthBal], min);
        }

        // stake into LiquidityGaugeV2
        uint lpBal = IERC20(LP).balanceOf(address(this));
        if (lpBal > 0) {
            IERC20(LP).safeApprove(GAUGE, lpBal);
            LiquidityGaugeV2(GAUGE).deposit(lpBal);
        }
    }

    function _getTotalShares() internal view override returns (uint) {
        return LiquidityGaugeV2(GAUGE).balanceOf(address(this));
    }

    function _withdraw(uint _lpAmount) internal override {
        // withdraw LP from  LiquidityGaugeV2
        LiquidityGaugeV2(GAUGE).withdraw(_lpAmount);

        uint lpBal = IERC20(LP).balanceOf(address(this));
        /*
        eth amount = (shares * price per shares) / 1e18
        */
        uint pricePerShare = StableSwapSTETH(POOL).get_virtual_price();
        uint ethAmount = lpBal.mul(pricePerShare) / 1e18;
        uint min = ethAmount.mul(SLIPPAGE_MAX - slippage) / SLIPPAGE_MAX;

        StableSwapSTETH(POOL).remove_liquidity_one_coin(lpBal, 0, min);
        // Now we have ETH
    }

    /*
    @dev Uniswap fails with zero address so no check is necessary here
    */
    function _swapToEth(address _from, uint _amount) private {
        // create dynamic array with 2 elements
        address[] memory path = new address[](2);
        path[0] = _from;
        path[1] = WETH;

        Uniswap(UNISWAP).swapExactTokensForETH(
            _amount,
            1,
            path,
            address(this),
            block.timestamp
        );
    }

    function _claimRewards() private {
        // claim LDO
        LiquidityGaugeV2(GAUGE).claim_rewards();
        // claim CRV
        Minter(MINTER).mint(GAUGE);

        // Infinity approval for Uniswap set inside constructor
        uint ldoBal = IERC20(LDO).balanceOf(address(this));
        if (ldoBal > 0) {
            _swapToEth(LDO, ldoBal);
        }

        uint crvBal = IERC20(CRV).balanceOf(address(this));
        if (crvBal > 0) {
            _swapToEth(CRV, crvBal);
        }
    }

    /*
    @notice Claim CRV and deposit most premium token into Curve
    */
    function harvest() external override onlyAuthorized {
        _claimRewards();

        uint bal = address(this).balance;
        if (bal > 0) {
            // transfer fee to treasury
            uint fee = bal.mul(performanceFee) / PERFORMANCE_FEE_MAX;
            if (fee > 0) {
                address treasury = IController(controller).treasury();
                require(treasury != address(0), "treasury = zero address");
                // treasury must be able to receive ETH
                (bool sent, ) = treasury.call{value: fee}("");
                require(sent, "Send ETH failed");
            }
            _deposit();
        }
    }

    /*
    @notice Exit strategy by harvesting CRV to underlying token and then
            withdrawing all underlying to vault
    @dev Must return all underlying token to vault
    @dev Caller should implement guard agains slippage
    */
    function exit() external override onlyAuthorized {
        if (forceExit) {
            return;
        }
        _claimRewards();
        _withdrawAll();
    }

    function sweep(address _token) external override onlyAdmin {
        require(_token != GAUGE, "protected token");
        require(_token != LDO, "protected token");
        IERC20(_token).safeTransfer(admin, IERC20(_token).balanceOf(address(this)));
    }
}