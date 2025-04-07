/**
 *Submitted for verification at Etherscan.io on 2020-10-26
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

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


// Token pool of arbitrary ERC20 token.
// This is owned and used by a parent FaaSPool.
contract FaaSRewardFund {
    using SafeERC20 for IERC20;

    address public governance;
    address public faasPool;

    constructor(address _faasPool) public {
        faasPool = _faasPool;
        governance = msg.sender;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setFaasPool(address _faasPool) external {
        require(msg.sender == governance, "!governance");
        faasPool = _faasPool;
    }

    function balance(IERC20 _token) public view returns (uint256) {
        return _token.balanceOf(address(this));
    }

    function safeTransfer(IERC20 _token, address _to, uint256 _value) external {
        require(msg.sender == faasPool || msg.sender == governance, "!(faasPool||governance)");
        uint256 _tokenBal = balance(_token);
        _token.safeTransfer(_to, _tokenBal > _value ? _value : _tokenBal);
    }
}