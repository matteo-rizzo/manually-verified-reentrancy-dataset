/**
 *Submitted for verification at Etherscan.io on 2020-10-13
*/

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */





/**
 * @title SwapToAaveAndReturnHelper
 * @notice Swaps LEND to AAVE and sends the AAVE balance to the configured `RECEIVER`
 * @author Aave
 **/
contract SwapToAaveAndReturnHelper {
  address public immutable RECEIVER;
  ILendToAaveMigrator public immutable MIGRATOR;

  constructor(ILendToAaveMigrator migrator, address receiver) public {
    RECEIVER = receiver;
    MIGRATOR = migrator;
  }

  /**
   * @dev Swap the whole LEND balance of this contract, migrates to AAVE and sends to `RECEIVER`
   **/
  function swapAndReturn() public {
    IERC20 lend = MIGRATOR.LEND();
    IERC20 aave = MIGRATOR.AAVE();
    uint256 lendBalance = lend.balanceOf(address(this));

    lend.approve(address(MIGRATOR), lendBalance);
    MIGRATOR.migrateFromLEND(lendBalance);
    aave.transfer(RECEIVER, aave.balanceOf(address(this)));
  }

  /**
   * @dev Rescue any token sent to this contract, only callable by `RECEIVER`
   **/
  function rescueToken(IERC20 token) public {
    require(msg.sender == RECEIVER, 'ONLY_BY_RECEIVER');

    token.transfer(RECEIVER, token.balanceOf(address(this)));
  }
}