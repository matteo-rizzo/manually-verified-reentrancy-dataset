/**
 *Submitted for verification at Etherscan.io on 2021-08-11
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Collection of functions related to the address type
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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



contract Swapper2 {
    using SafeERC20 for IERC20;
    
    IERC20 constant usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 constant usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 constant dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    Curve3Pool constant pool = Curve3Pool(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);
    
    address parent;
    address controller;
    
    constructor (address _parent, address _controller) public {
        parent = _parent;
        controller = _controller;
    }

    function swap_to_usdc(uint128 amount) external {
        require(msg.sender == controller);
        usdt.safeIncreaseAllowance(address(pool), amount);
        pool.exchange(0x2, 0x1, amount, (amount * 99)/100);
        usdc.safeTransfer(parent, usdc.balanceOf(address(this)));
    }

    function swap_to_dai(uint256 amount) external {
        require(msg.sender == controller);
        usdt.safeIncreaseAllowance(address(pool), amount);
        pool.exchange(0x2, 0x0, amount, amount * 99 * (10 ** 10));
        dai.safeTransfer(parent, dai.balanceOf(address(this)));
    }

    
    function return_usdt() external {
        // note: anyone can call this
        usdt.safeTransfer(parent, usdt.balanceOf(address(this)));
    }
    
}