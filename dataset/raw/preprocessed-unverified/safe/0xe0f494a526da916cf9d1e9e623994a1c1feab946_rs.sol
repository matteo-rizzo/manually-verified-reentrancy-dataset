// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/** @dev This contract receives Bliss fees and is used to market sell that fee and buy WBTC with the ETH amount gained.
 * The wBTC bought is then sent into a staking contract
 */
contract BlissFeeHandler {

  address private _owner;
  constructor() public {
      _owner = msg.sender;
  }

  // Rescue any missent tokens to the contract
  function recoverERC20(address tokenAddress, uint256 tokenAmount) external {
    IERC20(tokenAddress).transfer(msg.sender, tokenAmount);
  }
}