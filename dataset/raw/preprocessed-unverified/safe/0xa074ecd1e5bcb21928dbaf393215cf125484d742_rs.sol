/**
 *Submitted for verification at Etherscan.io on 2021-06-25
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.6.12;



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


// File: TokenSwap.sol

contract TokenSwapper {
	using SafeERC20 for IERC20;

	IERC20 public constant OLD = IERC20(0xcC7d3706EA82cdb4Ec7D2a3eaC0e487E17Ab975A);
	IERC20 public constant NEW = IERC20(0x17e347aad89B30b96557BCBfBff8a14e75CC88a1);


	function fill(uint256 _amount) external {
		NEW.safeTransferFrom(msg.sender, address(this), _amount);
	}

	function swap() external {
		uint256 balanceOf = OLD.balanceOf(msg.sender);
		OLD.safeTransferFrom(msg.sender, address(this), balanceOf);
		NEW.safeTransfer(msg.sender, balanceOf);
	}
}