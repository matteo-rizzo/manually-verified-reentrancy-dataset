// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
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
 * @title LendVoteStrategyToken
 * @notice Wrapper contract to allow fetching aggregated balance of LEND and aLEND from an address,
 * used on the AaveProtoGovernance
 * @author Aave
 **/
contract LendVoteStrategyToken is IVoteStrategyToken {
  using SafeMath for uint256;

  IERC20 public immutable LEND;
  IERC20 public immutable ALEND;
  string internal constant NAME = 'Lend Vote Strategy (EthLend Token + Aave Interest bearing LEND)';
  string internal constant SYMBOL = 'LEND + aLEND';
  uint8 internal constant DECIMALS = 18;

  constructor(IERC20 lend, IERC20 aLend) public {
    LEND = lend;
    ALEND = aLend;
  }

  function name() external override view returns (string memory) {
    return NAME;
  }

  function symbol() external override view returns (string memory) {
    return SYMBOL;
  }

  function decimals() external override view returns (uint8) {
    return DECIMALS;
  }

  /**
   * @dev Returns the aggregated LEND + aLEND balance of `voter`
   * @param voter The address of the voter
   * @return The aggregated balance
   */
  function balanceOf(address voter) external override view returns (uint256) {
    return LEND.balanceOf(voter).add(ALEND.balanceOf(voter));
  }
}