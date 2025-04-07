/*
 * Robonomics DAO BigBag sale.
 * (c) Robonomics Team <research@robonomics.network>
 *
 * SPDX-License-Identifier: MIT
 */

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

contract BigBag {
    using SafeERC20 for IERC20;
    
    address payable dao_agent = 0xe40C0C4F8E2424c74e13a301C133ce8b80d90549;
    IERC20 public xrt = IERC20(0x7dE91B204C1C737bcEe6F000AAA6569Cf7061cb7);

    uint256 public amount_wei = 0.1 ether;
    uint256 public amount_wn = 1600000000;

    receive() payable external {
        require(msg.value == amount_wei, "transaction value does not match");
        xrt.safeTransferFrom(dao_agent, msg.sender, amount_wn);
        dao_agent.transfer(msg.value);
    }
}