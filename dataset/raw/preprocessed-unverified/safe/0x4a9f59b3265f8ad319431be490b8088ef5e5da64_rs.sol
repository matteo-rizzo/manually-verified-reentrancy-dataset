/**
 *Submitted for verification at Etherscan.io on 2020-09-30
*/

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;






/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */


/**
 * @title interface EIP2612
 * @author Aave
 * @dev Generic interface for the EIP2612 permit function
 */
interface IEIP2612Token is IERC20 {
  /**
   * @dev implements the permit function as for https://github.com/ethereum/EIPs/blob/8a34d644aacf0f9f8f00815307fd7dd5da07655f/EIPS/eip-2612.md
   * @param owner the owner of the funds
   * @param spender the spender
   * @param value the amount
   * @param deadline the deadline timestamp, type(uint256).max for max deadline
   * @param v signature param
   * @param s signature param
   * @param r signature param
   */
  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external virtual;
}


/**
 * @title StakingHelper contract
 * @author Aave
 * @dev implements a staking function that allows staking through the EIP2612 capabilities of the AAVE token
 **/

contract AaveStakingHelper {
  IStakedAaveImplWithInitialize public immutable STAKE;
  IEIP2612Token public immutable AAVE;

  constructor(address stake, address aave) public {
    STAKE = IStakedAaveImplWithInitialize(stake);
    AAVE = IEIP2612Token(aave);
    //approves the stake to transfer uint256.max tokens from this contract
    //avoids approvals on every stake action
    IEIP2612Token(aave).approve(address(stake), type(uint256).max);
  }

  /**
   * @dev stakes on behalf of msg.sender using signed approval.
   * The function expects a valid signed message from the user, and executes a permit()
   * to approve the transfer. The helper then stakes on behalf of the user
   * @param amount the amount to stake
   * @param v signature param
   * @param r signature param
   * @param s signature param
   **/
  function stake(
    uint256 amount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external {
    AAVE.permit(msg.sender, address(this), amount, type(uint256).max, v, r, s);
    AAVE.transferFrom(msg.sender, address(this), amount);
    STAKE.stake(msg.sender, amount);
  }
}