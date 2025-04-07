/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;







/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */


/**
 * @title AIP2ProposalPayload
 * @notice Proposal payload to be executed by the Aave Governance contract via DELEGATECALL
 * - Updates the TokenDistributor contract as defined by the AIP-2
 * @author Aave
 **/
contract AIP2ProposalPayload is IProposalExecutor {
  event ProposalExecuted();

  address public constant DISTRIBUTOR_IMPL = 0x62C936a16905AfC49B589a41d033eE222A2325Ad;
  address public constant DISTRIBUTOR_PROXY = 0xE3d9988F676457123C5fD01297605efdD0Cba1ae;
  address public constant AAVE_COLLECTOR = 0x464C71f6c2F760DdA6093dCB91C24c39e5d6e18c;
  address public constant REFERRAL_WALLET = 0x2fbB0c60a41cB7Ea5323071624dCEAD3d213D0Fa;

  /**
   * @dev Payload execution function, called once a proposal passed in the Aave governance
   */
  function execute() external override {
    address[] memory receivers = new address[](2);
    receivers[0] = AAVE_COLLECTOR;
    receivers[1] = REFERRAL_WALLET;

    uint256[] memory percentages = new uint256[](2);
    percentages[0] = uint256(8000);
    percentages[1] = uint256(2000);

    bytes memory params =
      abi.encodeWithSelector(
        ITokenDistributor(DISTRIBUTOR_IMPL).initialize.selector,
        receivers,
        percentages
      );

    IProxyWithAdminActions(DISTRIBUTOR_PROXY).upgradeToAndCall(DISTRIBUTOR_IMPL, params);

    emit ProposalExecuted();
  }
}