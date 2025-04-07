/**
 *Submitted for verification at Etherscan.io on 2020-11-18
*/

pragma solidity ^0.6.2;

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


/**
 * @title Timelock
 * @dev A PEAKDEFI holder contract that should release its token balance immediately after the certain date.
 */
contract Timelock {
    using SafeERC20 for IERC20;

    // PEAKDEFI token interface
    IERC20 private constant _token = IERC20(0x630d98424eFe0Ea27fB1b3Ab7741907DFFEaAd78);

    // beneficiary of tokens after they are released
    address private _beneficiary;

    // timestamp when token release is enabled
    uint256 private _releaseTime;

	// -----------------------------------------------------------------------
	// CONSTRUCTOR
	// -----------------------------------------------------------------------

    /**
     * @dev Creates a timelock contract that holds its balance of any ERC20 token to the
     * beneficiary, and release immediately after finish of the certain date.
     * @param beneficiary address to whom locked tokens are transferred
     * @param releaseTime the time (as Unix time) when tokens should be unlocked
     */
    constructor (address beneficiary, uint256 releaseTime) public {
        // solhint-disable-next-line not-rely-on-time
        require(releaseTime > block.timestamp, "Timelock: release time is before current time");

        _beneficiary = beneficiary;
        _releaseTime = releaseTime;
    }

    fallback () external payable {}
    receive () external payable {}

	// -----------------------------------------------------------------------
	// SETTERS
	// -----------------------------------------------------------------------

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() external {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= _releaseTime, "Timelock: current time is before release time");

        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0, "Timelock: no tokens to release");

        _token.safeTransfer(_beneficiary, amount);
    }

	// -----------------------------------------------------------------------
	// GETTERS
	// -----------------------------------------------------------------------

    /**
     * @return the token being held.
     */
    function token() external pure returns (IERC20) {
        return _token;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() external view returns (address) {
        return _beneficiary;
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() external view returns (uint256) {
        return _releaseTime;
    }
}