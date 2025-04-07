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
 * @title AIP3ProposalPayload
 * @notice Proposal payload to be executed by the Aave Governance contract via DELEGATECALL
 * - Updates the LendingPool contract as defined by the AIP-3 
 * @author Aave
 **/
contract AIP3ProposalPayload is IProposalExecutor {
  event ProposalExecuted();

  ILendingPoolAddressesProvider public constant ADDRESSES_PROVIDER = ILendingPoolAddressesProvider(
    0x24a42fD28C976A61Df5D00D0599C34c4f90748c8
  );

  address public constant POOL_IMPL =  0x017788DDEd30FDd859d295b90D4e41a19393F423;

  /**
   * @dev Payload execution function, called once a proposal passed in the Aave governance
   */
  function execute() external override {

    ADDRESSES_PROVIDER.setLendingPoolImpl(POOL_IMPL);

    emit ProposalExecuted();
  }
}