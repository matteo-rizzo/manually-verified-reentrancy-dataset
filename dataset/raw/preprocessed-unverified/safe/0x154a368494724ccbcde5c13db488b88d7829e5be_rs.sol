/**
 *Submitted for verification at Etherscan.io on 2021-07-07
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.6.6;



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: GMC24Swap.sol

contract TokenSwapper {
	using SafeERC20 for IERC20;

	IERC20 public constant GMC24 = IERC20(0x06141F60eE56c8ECc869f46568E2cb1e66BAaf41);
	IERC20 public constant uGMC = IERC20(0xD4f2249dd6c26446F1413f6d97F14fcaa7792545);

	uint256 public constant SUPPLY = 9_950_000 ether;

	function fill() external {
		uGMC.safeTransferFrom(msg.sender, address(this), SUPPLY);
	}

	function swap() external {
		uint256 balanceOf = GMC24.balanceOf(msg.sender);
		GMC24.safeTransferFrom(msg.sender, address(this), balanceOf);
		uGMC.safeTransfer(msg.sender, balanceOf);
	}
}