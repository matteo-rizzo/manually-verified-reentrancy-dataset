/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;





/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */


interface IERC20WithNonce is IERC20 {
  function _nonces(address user) external view returns (uint256);
}

contract StakeUIHelper is StakeUIHelperI {
  address immutable AAVE;
  IStakedToken immutable STAKED_AAVE;

  address immutable BPT;
  IStakedToken immutable STAKED_BPT;

  constructor(
    address aave,
    IStakedToken stkAave,
    address bpt,
    IStakedToken stkBpt
  ) public {
    AAVE = aave;
    STAKED_AAVE = stkAave;
    BPT = bpt;
    STAKED_BPT = stkBpt;
  }

  function _getStakedAssetData(
    IStakedToken stakeToken,
    address underlyingToken,
    address user,
    bool isNonceAvailable
  ) internal view returns (AssetUIData memory) {
    AssetUIData memory data;

    data.stakeTokenTotalSupply = stakeToken.totalSupply();
    data.stakeCooldownSeconds = stakeToken.COOLDOWN_SECONDS();
    data.stakeUnstakeWindow = stakeToken.UNSTAKE_WINDOW();
    data.distributionPerSecond = stakeToken.assets(address(STAKED_AAVE)).emissionPerSecond;

    if (user != address(0)) {
      data.underlyingTokenUserBalance = IERC20(underlyingToken).balanceOf(user);
      data.stakeTokenUserBalance = stakeToken.balanceOf(user);
      data.userIncentivesToClaim = stakeToken.getTotalRewardsBalance(user);
      data.userCooldown = stakeToken.stakersCooldowns(user);
      data.userPermitNonce = isNonceAvailable ? IERC20WithNonce(underlyingToken)._nonces(user) : 0;
    }
    return data;
  }

  function getStkAaveData(address user) public override view returns (AssetUIData memory) {
    return _getStakedAssetData(STAKED_AAVE, AAVE, user, true);
  }

  function getStkBptData(address user) public override view returns (AssetUIData memory) {
    return _getStakedAssetData(STAKED_BPT, BPT, user, false);
  }

  function getUserUIData(address user)
    external
    override
    view
    returns (AssetUIData memory, AssetUIData memory)
  {
    return (getStkAaveData(user), getStkBptData(user));
  }
}