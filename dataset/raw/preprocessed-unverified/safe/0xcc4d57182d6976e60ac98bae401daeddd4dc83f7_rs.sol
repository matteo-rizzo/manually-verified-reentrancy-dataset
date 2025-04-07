/**
 *Submitted for verification at Etherscan.io on 2020-11-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;


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
























contract DODOAdapter is IVampireAdapter {
    using SafeERC20 for IERC20;

    IDrainController constant DRAIN_CONTROLLER = IDrainController(0x2C907E0c40b9Dbb834eDD3Fdb739de4df9eDb9D7);
    IUniswapV2Pair constant WETH_USDT_PAIR = IUniswapV2Pair(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852);
    IDODOMine constant DODO_MINE = IDODOMine(0xaeD7384F03844Af886b830862FF0a7AFce0a632C);
    IDODO constant DODO_USDT = IDODO(0x8876819535b48b551C9e97EBc07332C7482b4b2d);
    IERC20 constant DODO = IERC20(0x43Dfc4159D86F3A37A5A4B3D4580b888ad7d4DDd);
    IERC20 constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    // Victim info
    function rewardToken() external pure override returns (IERC20) {
        return DODO;
    }

    function poolCount() external view override returns (uint256) {
        return DODO_MINE.poolLength();
    }

    function sellableRewardAmount() external pure override returns (uint256) {
        return uint256(-1);
    }

    // Victim actions, requires impersonation via delegatecall
    function sellRewardForWeth(address, uint256 rewardAmount, address to) external override returns(uint256) {
        require(rewardAmount > 0, "reward amount is zero");
        require(DRAIN_CONTROLLER.priceIsUnderRejectionTreshold(), "Possible price manipulation, drain rejected");
        /*
            1. Swap DODO for USDT on DODODEX
            2. Swap USDT for WETH on Uniswap
        */
        // 1
        DODO.approve(address(DODO_USDT), rewardAmount);
        uint256 usdtAmount = DODO_USDT.sellBaseToken(rewardAmount, 0, new bytes(0));
        require(usdtAmount > 0, "DODO to USDT failed");

        // 2
        USDT.safeTransfer(address(WETH_USDT_PAIR), usdtAmount);
        (uint wethReserve, uint usdtReserve,) = WETH_USDT_PAIR.getReserves();
        uint amountOutput = UniswapV2Library.getAmountOut(usdtAmount, usdtReserve, wethReserve);
        WETH_USDT_PAIR.swap(amountOutput, uint(0), to, new bytes(0));
        return amountOutput;
    }

    // Pool info
    function lockableToken(uint256 poolId) external view override returns (IERC20) {
        (address lpToken,,,) = DODO_MINE.poolInfos(poolId);
        return IERC20(lpToken);
    }

    function lockedAmount(address user, uint256 poolId) external view override returns (uint256) {
        (uint256 amount,) = DODO_MINE.userInfo(poolId, user);
        return amount;
    }

    // Pool actions, requires impersonation via delegatecall
    function deposit(address _adapter, uint256 poolId, uint256 amount) external override {
        IVampireAdapter adapter = IVampireAdapter(_adapter);
        IERC20 lpToken = adapter.lockableToken(poolId);
        lpToken.approve(address(DODO_MINE), uint256(-1));
        DODO_MINE.deposit(address(lpToken), amount);
    }

    function withdraw(address, uint256 poolId, uint256 amount) external override {
        (address lpToken,,,) = DODO_MINE.poolInfos(poolId);
        DODO_MINE.withdraw(lpToken, amount);
    }

    function claimReward(address, uint256 poolId) external override {
        (address lpToken,,,) = DODO_MINE.poolInfos(poolId);
        DODO_MINE.claim(lpToken);
    }

    function emergencyWithdraw(address, uint256 poolId) external override {
        (address lpToken,,,) = DODO_MINE.poolInfos(poolId);
        DODO_MINE.emergencyWithdraw(lpToken);
    }

    // Service methods
    function poolAddress(uint256) external pure override returns (address) {
        return address(DODO_MINE);
    }

    function rewardToWethPool() external pure override returns (address) {
        return address(0);
    }

    function lockedValue(address, uint256) external override pure returns (uint256) {
        require(false, "not implemented");
    }

    function totalLockedValue(uint256) external override pure returns (uint256) {
        require(false, "not implemented");
    }

    function normalizedAPY(uint256) external override pure returns (uint256) {
        require(false, "not implemented");
    }
}