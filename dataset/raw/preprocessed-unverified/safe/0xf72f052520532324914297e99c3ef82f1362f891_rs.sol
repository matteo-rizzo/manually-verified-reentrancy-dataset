/**
 *Submitted for verification at Etherscan.io on 2020-03-28
*/

pragma solidity 0.5.16;



contract HandlerBase {
    address[] public tokens;

    function _updateToken(address token) internal {
        tokens.push(token);
    }
}

/**
 * @dev Collection of functions related to the address type
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
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


contract HCToken is HandlerBase {
    using SafeERC20 for IERC20;

    function _getToken(address token) internal view returns (address result) {
        return ICToken(token).underlying();
    }

    function mint(address cToken, uint256 amount) external payable {
        address token = _getToken(cToken);
        IERC20(token).safeApprove(cToken, amount);
        ICToken compound = ICToken(cToken);
        compound.mint(amount);
        IERC20(token).safeApprove(cToken, 0);

        // Update involved token
        _updateToken(cToken);
    }
}