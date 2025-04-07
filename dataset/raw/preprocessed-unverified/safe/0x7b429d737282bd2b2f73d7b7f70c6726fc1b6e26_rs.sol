/**
 *Submitted for verification at Etherscan.io on 2021-06-15
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;


contract IndexedStakingLens {
  struct StakingPool {
    uint256 pid;
    address stakingToken;
    bool isPairToken;
    address token0;
    address token1;
    uint256 amountStaked;
    uint256 ndxPerDay;
    string symbol;
  }

  // Assume 13.5 sec per block
  uint256 internal constant BLOCKS_PER_DAY = 864000 / 135;
  IMultiTokenStaking public constant stakingContract = IMultiTokenStaking(0xC46E0E7eCb3EfCC417f6F89b940FFAFf72556382);

  function getPool(
    uint256 i,
    uint256 totalAllocPoint,
    uint256 totalNdxPerDay
  ) internal view returns (StakingPool memory pool) {
    pool.pid = i;
    pool.stakingToken = stakingContract.lpToken(i);
    IUniswapV2Pair poolAsPair = IUniswapV2Pair(pool.stakingToken);
    try poolAsPair.getReserves() returns (uint112, uint112, uint32) {
      pool.isPairToken = true;
      pool.token0 = poolAsPair.token0();
      pool.token1 = poolAsPair.token1();
      pool.symbol = string(abi.encodePacked(
        SymbolHelper.getSymbol(pool.token0),
        "/",
        SymbolHelper.getSymbol(pool.token1)
      ));
    } catch {
      pool.symbol = SymbolHelper.getSymbol(pool.stakingToken);
    }
    pool.amountStaked = IERC20(pool.stakingToken).balanceOf(address(stakingContract));
    pool.ndxPerDay = (stakingContract.poolInfo(i).allocPoint * totalNdxPerDay) / totalAllocPoint;
  }

  function getPools() external view returns (StakingPool[] memory arr) {
    uint256 len = stakingContract.poolLength();
    arr = new StakingPool[](len);
    uint256 totalAllocPoint = stakingContract.totalAllocPoint();
    uint256 totalNdxPerDay = stakingContract.rewardsSchedule().getRewardsForBlockRange(block.number, block.number + BLOCKS_PER_DAY);
    for (uint256 i; i < len; i++) {
      arr[i] = getPool(i, totalAllocPoint, totalNdxPerDay);
    }
  }
}











