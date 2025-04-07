/**
 *Submitted for verification at Etherscan.io on 2020-10-01
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.8;


// 
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


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
/**
 * @dev Collection of functions related to the address type
 */


// 
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// 
/**
 * @notice Interface for Curve.fi's REN pool.
 * Note that we are using array of 2 as Curve's REN pool contains only WBTC and renBTC.
 */


// 
/**
 * @notice Interface for Curve.fi's liquidity guage.
 */


// 
/**
 * @notice Interface for Curve.fi's CRV minter.
 */


// 
/**
 * @notice Interface for Uniswap's router.
 */


// 
/**
 * @notice Interface for Strategies.
 */


// 
/**
 * @dev Earning strategy that accepts renCRV, earns CRV and converts CRV back to renCRV as yield.
 */
contract StrategyCurveRenBTC is IStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event Harvested(address indexed token, uint256 amount);

    address public constant override want = address(0x49849C98ae39Fff122806C06791Fa73784FB3675); // renCrv token
    address public constant pool = address(0xB1F2cdeC61db658F091671F5f199635aEF202CAC); // renCrv guage
    address public constant mintr = address(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0); // Token minter
    address public constant crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);  // CRV token
    address public constant uni = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);  // UniswapV2Router02
    address public constant weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // WETH token. Used for crv <> weth <> wbtc route
    address public constant wbtc = address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599); // WBTC token
    address public constant curve = address(0x93054188d876f558f4a66B2EF1d97d16eDf0895B); // REN swap

    address public vault;

    constructor(address _vault) public {
        require(_vault != address(0x0), "vault not set");
        vault = _vault;
    }

    /**
     * @dev Deposits all renCRV into Curve liquidity gauge to earn CRV.
     */
    function deposit() public override {
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            IERC20(want).safeApprove(pool, 0);
            IERC20(want).safeApprove(pool, _want);
            ICurveGauge(pool).deposit(_want);
        }
    }

    /**
     * @dev Withdraw partial funds, normally used with a vault withdrawal
     */
    function withdraw(uint256 _amount) public override {
        require(msg.sender == vault, "not vault");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }

        IERC20(want).safeTransfer(vault, _amount);
    }

    /**
     * @dev Withdraw all funds, normally used when migrating strategies
     */
    function withdrawAll() public override returns (uint256 balance) {
        require(msg.sender == vault, "not vault");
        ICurveGauge(pool).withdraw(ICurveGauge(pool).balanceOf(address(this)));

        balance = IERC20(want).balanceOf(address(this));
        IERC20(want).safeTransfer(vault, balance);
    }

    /**
     * @dev Claims CRV from Curve and convert it back to renCRV. Only vault can harvest.
     */
    function harvest() public override {
        require(msg.sender == vault, "not vault");
        // Claims CRV from Curve
        ICurveMinter(mintr).mint(pool);
        uint256 _crv = IERC20(crv).balanceOf(address(this));

        // Uniswap: CRV --> WETH --> WBTC
        if (_crv > 0) {
            IERC20(crv).safeApprove(uni, 0);
            IERC20(crv).safeApprove(uni, _crv);

            address[] memory path = new address[](3);
            path[0] = crv;
            path[1] = weth;
            path[2] = wbtc;

            IUniswapRouter(uni).swapExactTokensForTokens(_crv, uint256(0), path, address(this), now.add(1800));
        }
        // Curve: WBTC --> renCRV
        uint256 _wbtc = IERC20(wbtc).balanceOf(address(this));
        if (_wbtc > 0) {
            IERC20(wbtc).safeApprove(curve, 0);
            IERC20(wbtc).safeApprove(curve, _wbtc);
            ICurveFi(curve).add_liquidity([0, _wbtc], 0);
        }
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            deposit();
        }

        emit Harvested(want, _want);
    }

    /**
     * @dev Withdraw some tokens from the gauge.
     */
    function _withdrawSome(uint256 _amount) internal returns (uint256) {
        ICurveGauge(pool).withdraw(_amount);
        return _amount;
    }

    /**
     * @dev Returns the amount of tokens deposited in the strategy.
     */
    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    /**
     * @dev Returns the amount of tokens deposited in the gauge.
     */
    function balanceOfPool() public view returns (uint256) {
        return ICurveGauge(pool).balanceOf(address(this));
    }

    /**
     * @dev Returns the amount of tokens deposited in strategy + gauge.
     */
    function balanceOf() public view override returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }
}