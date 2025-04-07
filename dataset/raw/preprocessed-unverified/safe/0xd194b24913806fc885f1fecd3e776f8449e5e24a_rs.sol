/**
 *Submitted for verification at Etherscan.io on 2020-12-11
*/

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;













/**
 * @title GovernanceV2ProposalPayload
 * @notice Proposal payload to be executed by the Aave Governance contract via DELEGATECALL
 * - Upgrade implementations of AAVE and stkAAVE, to include proposition/voting delegation
 * - Transfer all permissions from the Aave governance v1 to the Aave governance v2, with
 *   granularity per Executor contracts (short and long)
 * @author Aave
 **/
contract GovernanceV2ProposalPayload is IProposalExecutor {
  event ProposalExecuted();

  address public immutable AAVE_TOKEN_PROXY;
  address public immutable AAVE_TOKEN_NEW_IMPL;
  address public immutable STKAAVE_PROXY;
  address public immutable STKAAVE_NEW_IMPL;
  address public immutable RESERVE_ECOSYSTEM_PROXY;
  address public immutable ADDRESSES_PROVIDER_V1_PROTO;
  address public immutable ADDRESSES_PROVIDER_V1_UNISWAP;
  address public immutable TOKEN_DISTRIBUTOR_PROXY;
  address public immutable FEES_COLLECTOR;
  address public immutable SHORT_EXECUTOR_V2;
  address public immutable LONG_EXECUTOR_V2;

  constructor(
    address aaveTokenProxy,
    address aaveTokenNewImpl,
    address stkAaveProxy,
    address stkAaveNewImpl,
    address reserveEcosystemProxy,
    address addressesProviderV1Proto,
    address addressesProviderV1Uniswap,
    address tokenDistributorProxy,
    address feesCollector,
    address shortExecutor,
    address longExecutor
  ) public {
    AAVE_TOKEN_PROXY = aaveTokenProxy;
    AAVE_TOKEN_NEW_IMPL = aaveTokenNewImpl;
    STKAAVE_PROXY = stkAaveProxy;
    STKAAVE_NEW_IMPL = stkAaveNewImpl;
    RESERVE_ECOSYSTEM_PROXY = reserveEcosystemProxy;
    ADDRESSES_PROVIDER_V1_PROTO = addressesProviderV1Proto;
    ADDRESSES_PROVIDER_V1_UNISWAP = addressesProviderV1Uniswap;
    TOKEN_DISTRIBUTOR_PROXY = tokenDistributorProxy;
    FEES_COLLECTOR = feesCollector;
    SHORT_EXECUTOR_V2 = shortExecutor;
    LONG_EXECUTOR_V2 = longExecutor;
  }

  /**
   * @dev Payload execution function, called once a proposal passed in the Aave governance
   */
  function execute() external override {
    bytes memory aaveTokenParams =
      abi.encodeWithSelector(IAaveTokenV2(AAVE_TOKEN_NEW_IMPL).initialize.selector);

    IProxyWithAdminActions(AAVE_TOKEN_PROXY).upgradeToAndCall(AAVE_TOKEN_NEW_IMPL, aaveTokenParams);

    IProxyWithAdminActions(AAVE_TOKEN_PROXY).changeAdmin(LONG_EXECUTOR_V2);

    bytes memory stkAaveParams =
      abi.encodeWithSelector(IStkAaveV2(STKAAVE_NEW_IMPL).initialize.selector);

    IProxyWithAdminActions(STKAAVE_PROXY).upgradeToAndCall(STKAAVE_NEW_IMPL, stkAaveParams);

    IProxyWithAdminActions(STKAAVE_PROXY).changeAdmin(LONG_EXECUTOR_V2);

    ILendingPoolAddressesProvider(ADDRESSES_PROVIDER_V1_PROTO).setLendingPoolManager(
      SHORT_EXECUTOR_V2
    );
    IOwnable(ADDRESSES_PROVIDER_V1_PROTO).transferOwnership(SHORT_EXECUTOR_V2);

    ILendingPoolAddressesProvider(ADDRESSES_PROVIDER_V1_UNISWAP).setLendingPoolManager(
      SHORT_EXECUTOR_V2
    );
    IOwnable(ADDRESSES_PROVIDER_V1_UNISWAP).transferOwnership(SHORT_EXECUTOR_V2);

    IProxyWithAdminActions(TOKEN_DISTRIBUTOR_PROXY).changeAdmin(SHORT_EXECUTOR_V2);

    IProxyWithAdminActions(FEES_COLLECTOR).changeAdmin(SHORT_EXECUTOR_V2);

    IProxyWithAdminActions(RESERVE_ECOSYSTEM_PROXY).changeAdmin(SHORT_EXECUTOR_V2);

    emit ProposalExecuted();
  }
}