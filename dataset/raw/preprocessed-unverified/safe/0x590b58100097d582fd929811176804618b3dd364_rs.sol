/**
 *Submitted for verification at Etherscan.io on 2021-04-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: ICurveFi



// Part: IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: SafeMath

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


// Part: IBridgeVault

interface IBridgeVault is IERC20 {
    function depositFor(address recipient, uint256 amount) external;

    function withdraw(uint256 shares) external;

    function token() external returns (IERC20);
}

// Part: SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: CurveTokenWrapper.sol

// Permissionless curve lp token wrapper contract.
// RenBTC must be transferred before calling wrap fns.
// Wrapped tokens will be transferred back to sender.
contract CurveTokenWrapper {
    /*
     * Currently only support curve lp pools that have renBTC as an asset.
     * We supply liquidity as renBTC to these pools.
     * Some lp pools require two deposits as they are a pool of other pool tokens (e.g. tbtc).
     *
     * Currently supported lp pools are:
     * - renbtc
     * - sbtc
     * - tbtc (requires depositng into sbtc lp pool first)
     *
     * We can consider implementing a generic curve token wrapper that accepts a wrap/unwrap path.
     */
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // NB: Addresses are hardcoded to ETH addresses.
    // Supported tokens.
    IERC20 renbtc = IERC20(0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D);
    IERC20 renbtcLpToken = IERC20(0x49849C98ae39Fff122806C06791Fa73784FB3675);
    IERC20 sbtcLpToken = IERC20(0x075b1bb99792c9E1041bA13afEf80C91a1e70fB3);
    IERC20 tbtcLpToken = IERC20(0x64eda51d3Ad40D56b9dFc5554E06F94e1Dd786Fd);

    // Supported pools.
    ICurveFi renbtcPool = ICurveFi(0x93054188d876f558f4a66B2EF1d97d16eDf0895B);
    ICurveFi sbtcPool = ICurveFi(0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714);
    ICurveFi tbtcPool = ICurveFi(0xC25099792E9349C7DD09759744ea681C7de2cb66);

    constructor() public {}

    function wrap(address _vault) external returns (uint256) {
        IERC20 vaultToken = IBridgeVault(_vault).token();

        uint256 toTransfer;

        if (vaultToken == renbtcLpToken) {
            toTransfer = _addLiquidity(renbtc, renbtcLpToken, renbtcPool, 0, 2);
        }

        if (vaultToken == sbtcLpToken) {
            toTransfer = _addLiquidity(renbtc, sbtcLpToken, sbtcPool, 0, 3);
        }

        // tbtcLpToken is doubly wrapped.
        if (vaultToken == tbtcLpToken) {
            _addLiquidity(renbtc, sbtcLpToken, sbtcPool, 0, 3);
            toTransfer = _addLiquidity(sbtcLpToken, tbtcLpToken, tbtcPool, 1, 2);
        }

        vaultToken.safeTransfer(msg.sender, toTransfer);
        return toTransfer;
    }

    function unwrap(address _vault) external {
        IERC20 vaultToken = IBridgeVault(_vault).token();

        uint256 toTransfer;

        if (vaultToken == renbtcLpToken) {
            toTransfer = _removeLiquidity(renbtcLpToken, renbtc, renbtcPool, 0);
        }

        if (vaultToken == sbtcLpToken) {
            toTransfer = _removeLiquidity(sbtcLpToken, renbtc, sbtcPool, 0);
        }

        // tbtcLpToken is doubly wrapped.
        if (vaultToken == tbtcLpToken) {
            _removeLiquidity(tbtcLpToken, sbtcLpToken, tbtcPool, 1);
            toTransfer = _removeLiquidity(sbtcLpToken, renbtc, sbtcPool, 0);
        }

        renbtc.safeTransfer(msg.sender, toTransfer);
        return;
    }

    // NB: Only supports 2/3 token pools.
    function _addLiquidity(
        IERC20 _token, // in token
        IERC20 _lpToken, // out token
        ICurveFi _pool,
        uint256 _i, // coins idx
        uint256 _numTokens // num of coins
    ) internal returns (uint256) {
        uint256 beforeBalance = _lpToken.balanceOf(address(this));
        uint256 amount = _token.balanceOf(address(this));

        _token.safeApprove(address(_pool), amount);

        if (_numTokens == 2) {
            uint256[2] memory amounts;
            amounts[_i] = amount;
            _pool.add_liquidity(amounts, 0);
        }

        if (_numTokens == 3) {
            uint256[3] memory amounts;
            amounts[_i] = amount;
            _pool.add_liquidity(amounts, 0);
        }

        return _lpToken.balanceOf(address(this)).sub(beforeBalance);
    }

    function _removeLiquidity(
        IERC20 _lpToken, // in token
        IERC20 _token, // out token
        ICurveFi _pool,
        int128 _i // coins idx
    ) internal returns (uint256) {
        uint256 beforeBalance = _token.balanceOf(address(this));
        uint256 amount = _lpToken.balanceOf(address(this));

        _lpToken.safeApprove(address(_pool), amount);

        _pool.remove_liquidity_one_coin(amount, _i, 0);

        return _token.balanceOf(address(this)).sub(beforeBalance);
    }
}