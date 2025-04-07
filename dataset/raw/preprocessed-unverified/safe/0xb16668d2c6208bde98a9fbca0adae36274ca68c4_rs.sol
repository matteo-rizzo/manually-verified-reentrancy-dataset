/**
 *Submitted for verification at Etherscan.io on 2021-09-30
*/

pragma solidity 0.6.3;


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
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
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
 * @title ERC20 Airdrop dapp smart contract
 */
contract Airdrop {
  using SafeERC20 for IERC20;

  /**
   * @dev doAirdrop is the main method for distribution
   * @param token airdropped token address
   * @param addresses address[] addresses to airdrop
   * @param values address[] values for each address
   */
  function doAirdrop(IERC20 token, address[] calldata addresses, uint256 [] calldata values) external returns (uint256) {
    uint256 i = 0;

    while (i < addresses.length) {
      token.safeTransferFrom(msg.sender, addresses[i], values[i]);
      i += 1;
    }

    return i;
  }
}