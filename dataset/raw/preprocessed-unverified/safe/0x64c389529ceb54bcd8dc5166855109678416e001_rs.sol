/**
 *Submitted for verification at Etherscan.io on 2021-05-07
*/

/*
https://powerpool.finance/

          wrrrw r wrr
         ppwr rrr wppr0       prwwwrp                                 prwwwrp                   wr0
        rr 0rrrwrrprpwp0      pp   pr  prrrr0 pp   0r  prrrr0  0rwrrr pp   pr  prrrr0  prrrr0    r0
        rrp pr   wr00rrp      prwww0  pp   wr pp w00r prwwwpr  0rw    prwww0  pp   wr pp   wr    r0
        r0rprprwrrrp pr0      pp      wr   pr pp rwwr wr       0r     pp      wr   pr wr   pr    r0
         prwr wrr0wpwr        00        www0   0w0ww    www0   0w     00        www0    www0   0www0
          wrr ww0rrrr

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// File: contracts/interfaces/sushi/ISushiBar.sol



// File: @powerpool/poweroracle/contracts/interfaces/IPowerPoke.sol

pragma experimental ABIEncoderV2;



// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @openzeppelin/contracts/math/SafeMath.sol

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


// File: @openzeppelin/contracts/utils/Address.sol

/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/interfaces/WrappedPiErc20Interface.sol

interface WrappedPiErc20Interface is IERC20 {
  function deposit(uint256 _amount) external payable returns (uint256);

  function withdraw(uint256 _amount) external payable returns (uint256);

  function changeRouter(address _newRouter) external;

  function setEthFee(uint256 _newEthFee) external;

  function withdrawEthFee(address payable receiver) external;

  function approveUnderlying(address _to, uint256 _amount) external;

  function callExternal(
    address voting,
    bytes4 signature,
    bytes calldata args,
    uint256 value
  ) external;

  struct ExternalCallData {
    address destination;
    bytes4 signature;
    bytes args;
    uint256 value;
  }

  function callExternalMultiple(ExternalCallData[] calldata calls) external;

  function getUnderlyingBalance() external view returns (uint256);
}

// File: contracts/interfaces/IPoolRestrictions.sol



// File: contracts/interfaces/PowerIndexBasicRouterInterface.sol




// File: contracts/interfaces/BMathInterface.sol



// File: contracts/interfaces/BPoolInterface.sol

interface BPoolInterface is IERC20, BMathInterface {
  function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;

  function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;

  function swapExactAmountIn(
    address,
    uint256,
    address,
    uint256,
    uint256
  ) external returns (uint256, uint256);

  function swapExactAmountOut(
    address,
    uint256,
    address,
    uint256,
    uint256
  ) external returns (uint256, uint256);

  function joinswapExternAmountIn(
    address,
    uint256,
    uint256
  ) external returns (uint256);

  function joinswapPoolAmountOut(
    address,
    uint256,
    uint256
  ) external returns (uint256);

  function exitswapPoolAmountIn(
    address,
    uint256,
    uint256
  ) external returns (uint256);

  function exitswapExternAmountOut(
    address,
    uint256,
    uint256
  ) external returns (uint256);

  function getDenormalizedWeight(address) external view returns (uint256);

  function getBalance(address) external view returns (uint256);

  function getSwapFee() external view returns (uint256);

  function getTotalDenormalizedWeight() external view returns (uint256);

  function getCommunityFee()
  external
  view
  returns (
    uint256,
    uint256,
    uint256,
    address
  );

  function calcAmountWithCommunityFee(
    uint256,
    uint256,
    address
  ) external view returns (uint256, uint256);

  function getRestrictions() external view returns (address);

  function isPublicSwap() external view returns (bool);

  function isFinalized() external view returns (bool);

  function isBound(address t) external view returns (bool);

  function getCurrentTokens() external view returns (address[] memory tokens);

  function getFinalTokens() external view returns (address[] memory tokens);

  function setSwapFee(uint256) external;

  function setCommunityFeeAndReceiver(
    uint256,
    uint256,
    uint256,
    address
  ) external;

  function setController(address) external;

  function setPublicSwap(bool) external;

  function finalize() external;

  function bind(
    address,
    uint256,
    uint256
  ) external;

  function rebind(
    address,
    uint256,
    uint256
  ) external;

  function unbind(address) external;

  function gulp(address) external;

  function callVoting(
    address voting,
    bytes4 signature,
    bytes calldata args,
    uint256 value
  ) external;

  function getMinWeight() external view returns (uint256);

  function getMaxBoundTokens() external view returns (uint256);
}

// File: @openzeppelin/contracts/GSN/Context.sol

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

// File: @openzeppelin/contracts/access/Ownable.sol

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: contracts/interfaces/PowerIndexNaiveRouterInterface.sol



// File: contracts/powerindex-router/PowerIndexNaiveRouter.sol

contract PowerIndexNaiveRouter is PowerIndexNaiveRouterInterface, Ownable {
  using SafeMath for uint256;

  function migrateToNewRouter(
    address _piToken,
    address payable _newRouter,
    address[] memory _tokens
  ) public virtual override onlyOwner {
    WrappedPiErc20Interface(_piToken).changeRouter(_newRouter);
  }

  function piTokenCallback(address sender, uint256 _withdrawAmount) external payable virtual override {
    // DO NOTHING
  }
}

// File: contracts/powerindex-router/PowerIndexBasicRouter.sol

contract PowerIndexBasicRouter is PowerIndexBasicRouterInterface, PowerIndexNaiveRouter {
  using SafeERC20 for IERC20;

  uint256 public constant HUNDRED_PCT = 1 ether;

  event SetVotingAndStaking(address indexed voting, address indexed staking);
  event SetReserveConfig(uint256 ratio, uint256 claimRewardsInterval);
  event SetRebalancingInterval(uint256 rebalancingInterval);
  event IgnoreRebalancing(uint256 blockTimestamp, uint256 lastRebalancedAt, uint256 rebalancingInterval);
  event RewardPool(address indexed pool, uint256 amount);
  event SetRewardPools(uint256 len, address[] rewardPools);
  event SetPvpFee(uint256 pvpFee);

  enum ReserveStatus { EQUILIBRIUM, SHORTAGE, EXCESS }

  struct BasicConfig {
    address poolRestrictions;
    address powerPoke;
    address voting;
    address staking;
    uint256 reserveRatio;
    uint256 reserveRatioToForceRebalance;
    uint256 claimRewardsInterval;
    address pvp;
    uint256 pvpFee;
    address[] rewardPools;
  }

  WrappedPiErc20Interface public immutable piToken;
  address public immutable pvp;

  IPoolRestrictions public poolRestrictions;
  IPowerPoke public powerPoke;
  address public voting;
  address public staking;
  uint256 public reserveRatio;
  uint256 public claimRewardsInterval;
  uint256 public lastClaimRewardsAt;
  uint256 public lastRebalancedAt;
  uint256 public reserveRatioToForceRebalance;
  // 1 ether == 100%
  uint256 public pvpFee;

  address[] internal rewardPools;

  uint256 internal constant COMPENSATION_PLAN_1_ID = 1;

  modifier onlyPiToken() {
    require(msg.sender == address(piToken), "ONLY_PI_TOKEN_ALLOWED");
    _;
  }

  modifier onlyEOA() {
    require(tx.origin == msg.sender, "ONLY_EOA");
    _;
  }

  modifier onlyReporter(uint256 _reporterId, bytes calldata _rewardOpts) {
    uint256 gasStart = gasleft();
    powerPoke.authorizeReporter(_reporterId, msg.sender);
    _;
    _reward(_reporterId, gasStart, COMPENSATION_PLAN_1_ID, _rewardOpts);
  }

  modifier onlyNonReporter(uint256 _reporterId, bytes calldata _rewardOpts) {
    uint256 gasStart = gasleft();
    powerPoke.authorizeNonReporter(_reporterId, msg.sender);
    _;
    _reward(_reporterId, gasStart, COMPENSATION_PLAN_1_ID, _rewardOpts);
  }

  constructor(address _piToken, BasicConfig memory _basicConfig) public PowerIndexNaiveRouter() Ownable() {
    require(_piToken != address(0), "INVALID_PI_TOKEN");
    require(_basicConfig.reserveRatio <= HUNDRED_PCT, "RR_GT_HUNDRED_PCT");
    require(_basicConfig.pvpFee < HUNDRED_PCT, "PVP_FEE_GTE_HUNDRED_PCT");
    require(_basicConfig.pvp != address(0), "INVALID_PVP_ADDR");
    require(_basicConfig.poolRestrictions != address(0), "INVALID_POOL_RESTRICTIONS_ADDR");

    piToken = WrappedPiErc20Interface(_piToken);
    poolRestrictions = IPoolRestrictions(_basicConfig.poolRestrictions);
    powerPoke = IPowerPoke(_basicConfig.powerPoke);
    voting = _basicConfig.voting;
    staking = _basicConfig.staking;
    reserveRatio = _basicConfig.reserveRatio;
    reserveRatioToForceRebalance = _basicConfig.reserveRatioToForceRebalance;
    claimRewardsInterval = _basicConfig.claimRewardsInterval;
    pvp = _basicConfig.pvp;
    pvpFee = _basicConfig.pvpFee;
    rewardPools = _basicConfig.rewardPools;
  }

  receive() external payable {}

  /*** OWNER METHODS ***/

  /**
   * @dev Changing the staking address with a positive underlying stake will break `getPiEquivalentForUnderlying`
   *      formula. Consider moving all the reserves to the piToken contract before doing this.
   */
  function setVotingAndStaking(address _voting, address _staking) external override onlyOwner {
    voting = _voting;
    staking = _staking;
    emit SetVotingAndStaking(_voting, _staking);
  }

  function setReserveConfig(uint256 _reserveRatio, uint256 _claimRewardsInterval) public virtual override onlyOwner {
    require(_reserveRatio <= HUNDRED_PCT, "RR_GREATER_THAN_100_PCT");
    reserveRatio = _reserveRatio;
    claimRewardsInterval = _claimRewardsInterval;
    emit SetReserveConfig(_reserveRatio, _claimRewardsInterval);
  }

  function setRewardPools(address[] calldata _rewardPools) external onlyOwner {
    require(_rewardPools.length > 0, "AT_LEAST_ONE_EXPECTED");
    rewardPools = _rewardPools;
    emit SetRewardPools(_rewardPools.length, _rewardPools);
  }

  function setPvpFee(uint256 _pvpFee) external onlyOwner {
    require(_pvpFee < HUNDRED_PCT, "PVP_FEE_OVER_THE_LIMIT");
    pvpFee = _pvpFee;
    emit SetPvpFee(_pvpFee);
  }

  function setPiTokenEthFee(uint256 _ethFee) external onlyOwner {
    require(_ethFee <= 0.1 ether, "ETH_FEE_OVER_THE_LIMIT");
    piToken.setEthFee(_ethFee);
  }

  function withdrawEthFee(address payable _receiver) external onlyOwner {
    piToken.withdrawEthFee(_receiver);
  }

  function migrateToNewRouter(
    address _piToken,
    address payable _newRouter,
    address[] memory _tokens
  ) public override onlyOwner {
    super.migrateToNewRouter(_piToken, _newRouter, _tokens);

    _newRouter.transfer(address(this).balance);

    uint256 len = _tokens.length;
    for (uint256 i = 0; i < len; i++) {
      IERC20 t = IERC20(_tokens[i]);
      t.safeTransfer(_newRouter, t.balanceOf(address(this)));
    }
  }

  function pokeFromReporter(
    uint256 _reporterId,
    bool _claimAndDistributeRewards,
    bytes calldata _rewardOpts
  ) external onlyReporter(_reporterId, _rewardOpts) onlyEOA {
    (uint256 minInterval, ) = _getMinMaxReportInterval();
    (ReserveStatus status, uint256 diff, bool forceRebalance) = getReserveStatus(_getUnderlyingStaked(), 0);
    require(forceRebalance || lastRebalancedAt + minInterval < block.timestamp, "MIN_INTERVAL_NOT_REACHED");
    require(status != ReserveStatus.EQUILIBRIUM, "RESERVE_STATUS_EQUILIBRIUM");
    _rebalancePoke(status, diff);
    _postPoke(_claimAndDistributeRewards);
  }

  function pokeFromSlasher(
    uint256 _reporterId,
    bool _claimAndDistributeRewards,
    bytes calldata _rewardOpts
  ) external onlyNonReporter(_reporterId, _rewardOpts) onlyEOA {
    (, uint256 maxInterval) = _getMinMaxReportInterval();
    (ReserveStatus status, uint256 diff, bool forceRebalance) = getReserveStatus(_getUnderlyingStaked(), 0);
    require(forceRebalance || lastRebalancedAt + maxInterval < block.timestamp, "MAX_INTERVAL_NOT_REACHED");
    require(status != ReserveStatus.EQUILIBRIUM, "RESERVE_STATUS_EQUILIBRIUM");
    _rebalancePoke(status, diff);
    _postPoke(_claimAndDistributeRewards);
  }

  function poke(bool _claimAndDistributeRewards) external onlyEOA {
    (ReserveStatus status, uint256 diff, ) = getReserveStatus(_getUnderlyingStaked(), 0);
    _rebalancePoke(status, diff);
    _postPoke(_claimAndDistributeRewards);
  }

  function _postPoke(bool _claimAndDistributeRewards) internal {
    lastRebalancedAt = block.timestamp;

    if (_claimAndDistributeRewards && lastClaimRewardsAt + claimRewardsInterval < block.timestamp) {
      _claimRewards();
      _distributeRewards();
      lastClaimRewardsAt = block.timestamp;
    }
  }

  function _rebalancePoke(ReserveStatus reserveStatus, uint256 sushiDiff) internal virtual {
    // need to redefine in implementation
  }

  function _claimRewards() internal virtual {
    // need to redefine in implementation
  }

  function _distributeRewards() internal virtual {
    // need to redefine in implementation
  }

  function _callVoting(bytes4 _sig, bytes memory _data) internal {
    piToken.callExternal(voting, _sig, _data, 0);
  }

  function _callStaking(bytes4 _sig, bytes memory _data) internal {
    piToken.callExternal(staking, _sig, _data, 0);
  }

  function _checkVotingSenderAllowed() internal view {
    require(poolRestrictions.isVotingSenderAllowed(voting, msg.sender), "SENDER_NOT_ALLOWED");
  }

  function _distributeRewardToPvp(uint256 _totalReward, IERC20 _underlying)
  internal
  returns (uint256 pvpReward, uint256 remainder)
  {
    pvpReward = 0;
    remainder = 0;

    if (pvpFee > 0) {
      pvpReward = _totalReward.mul(pvpFee).div(HUNDRED_PCT);
      remainder = _totalReward.sub(pvpReward);
      _underlying.safeTransfer(pvp, pvpReward);
    } else {
      remainder = _totalReward;
    }
  }

  function _distributePiRemainderToPools(IERC20 _piToken)
  internal
  returns (uint256 piBalanceToDistribute, address[] memory pools)
  {
    pools = rewardPools;
    uint256 poolsLen = pools.length;
    require(poolsLen > 0, "MISSING_REWARD_POOLS");

    piBalanceToDistribute = piToken.balanceOf(address(this));
    require(piBalanceToDistribute > 0, "NO_POOL_REWARDS_PI");

    uint256 totalPiOnPools = 0;
    for (uint256 i = 0; i < poolsLen; i++) {
      totalPiOnPools = totalPiOnPools.add(_piToken.balanceOf(pools[i]));
    }
    require(totalPiOnPools > 0, "TOTAL_PI_IS_0");

    for (uint256 i = 0; i < poolsLen; i++) {
      address pool = pools[i];
      uint256 poolPiBalance = piToken.balanceOf(pool);
      if (poolPiBalance == 0) {
        continue;
      }

      uint256 poolReward = piBalanceToDistribute.mul(poolPiBalance) / totalPiOnPools;

      piToken.transfer(pool, poolReward);

      BPoolInterface(pool).gulp(address(piToken));
      emit RewardPool(pool, poolReward);
    }
  }

  /*
   * @dev Getting status and diff of actual staked balance and target reserve balance.
   */
  function getReserveStatusForStakedBalance()
  public
  view
  returns (
    ReserveStatus status,
    uint256 diff,
    bool forceRebalance
  )
  {
    return getReserveStatus(_getUnderlyingStaked(), 0);
  }

  /*
   * @dev Getting status and diff of provided staked balance and target reserve balance.
   */
  function getReserveStatus(uint256 _stakedBalance, uint256 _withdrawAmount)
  public
  view
  returns (
    ReserveStatus status,
    uint256 diff,
    bool forceRebalance
  )
  {
    uint256 expectedReserveAmount;
    (status, diff, expectedReserveAmount) = getReserveStatusPure(
      reserveRatio,
      piToken.getUnderlyingBalance(),
      _stakedBalance,
      _withdrawAmount
    );

    if (status == ReserveStatus.SHORTAGE) {
      uint256 currentRatio = expectedReserveAmount.sub(diff).mul(HUNDRED_PCT).div(expectedReserveAmount);
      forceRebalance = reserveRatioToForceRebalance >= currentRatio;
    }
  }

  // NOTICE: could/should be changed depending on implementation
  function _getUnderlyingStaked() internal view virtual returns (uint256) {
    if (staking == address(0)) {
      return 0;
    }
    return IERC20(staking).balanceOf(address(piToken));
  }

  function getUnderlyingStaked() external view returns (uint256) {
    return _getUnderlyingStaked();
  }

  function getRewardPools() external view returns (address[] memory) {
    return rewardPools;
  }

  function getPiEquivalentForUnderlying(
    uint256 _underlyingAmount,
    IERC20 _underlyingToken,
    uint256 _piTotalSupply
  ) public view virtual override returns (uint256) {
    uint256 underlyingOnPiToken = _underlyingToken.balanceOf(address(piToken));
    return
    getPiEquivalentForUnderlyingPure(
      _underlyingAmount,
    // underlyingOnPiToken + underlyingOnStaking,
      underlyingOnPiToken.add(_getUnderlyingStaked()),
      _piTotalSupply
    );
  }

  function getPiEquivalentForUnderlyingPure(
    uint256 _underlyingAmount,
    uint256 _totalUnderlyingWrapped,
    uint256 _piTotalSupply
  ) public pure virtual override returns (uint256) {
    if (_piTotalSupply == 0) {
      return _underlyingAmount;
    }
    // return _piTotalSupply * _underlyingAmount / _totalUnderlyingWrapped;
    return _piTotalSupply.mul(_underlyingAmount).div(_totalUnderlyingWrapped);
  }

  function getUnderlyingEquivalentForPi(
    uint256 _piAmount,
    IERC20 _underlyingToken,
    uint256 _piTotalSupply
  ) public view virtual override returns (uint256) {
    uint256 underlyingOnPiToken = _underlyingToken.balanceOf(address(piToken));
    return
    getUnderlyingEquivalentForPiPure(
      _piAmount,
    // underlyingOnPiToken + underlyingOnStaking,
      underlyingOnPiToken.add(_getUnderlyingStaked()),
      _piTotalSupply
    );
  }

  function getUnderlyingEquivalentForPiPure(
    uint256 _piAmount,
    uint256 _totalUnderlyingWrapped,
    uint256 _piTotalSupply
  ) public pure virtual override returns (uint256) {
    if (_piTotalSupply == 0) {
      return _piAmount;
    }
    // _piAmount * _totalUnderlyingWrapped / _piTotalSupply;
    return _totalUnderlyingWrapped.mul(_piAmount).div(_piTotalSupply);
  }

  /**
   * @notice Calculates the desired reserve status
   * @param _reserveRatioPct The reserve ratio in %, 1 ether == 100 ether
   * @param _leftOnPiToken The amount of origin tokens left on the piToken (WrappedPiErc20) contract
   * @param _stakedBalance The amount of original tokens staked on the staking contract
   * @param _withdrawAmount The amount to be withdrawn within the current transaction
   *                        (could be negative in a case of deposit)
   * @return status The reserve status:
   * * SHORTAGE - There is not enough underlying funds on the wrapper contract to satisfy the reserve ratio,
   *           the diff amount should be redeemed from the staking contract
   * * EXCESS - there are some extra funds over reserve ratio on the wrapper contract,
   *           the diff amount should be sent to the staking contract
   * * EQUILIBRIUM - the reserve ratio hasn't changed,
   *           the diff amount is 0 and there are no additional stake/redeem actions expected
   * @return diff The difference between `adjustedReserveAmount` and `_leftOnWrapper`
   * @return expectedReserveAmount The calculated expected reserve amount
   */
  function getReserveStatusPure(
    uint256 _reserveRatioPct,
    uint256 _leftOnPiToken,
    uint256 _stakedBalance,
    uint256 _withdrawAmount
  )
  public
  pure
  returns (
    ReserveStatus status,
    uint256 diff,
    uint256 expectedReserveAmount
  )
  {
    require(_reserveRatioPct <= HUNDRED_PCT, "RR_GREATER_THAN_100_PCT");
    expectedReserveAmount = getExpectedReserveAmount(_reserveRatioPct, _leftOnPiToken, _stakedBalance, _withdrawAmount);

    if (expectedReserveAmount > _leftOnPiToken) {
      status = ReserveStatus.SHORTAGE;
      diff = expectedReserveAmount.sub(_leftOnPiToken);
    } else if (expectedReserveAmount < _leftOnPiToken) {
      status = ReserveStatus.EXCESS;
      diff = _leftOnPiToken.sub(expectedReserveAmount);
    } else {
      status = ReserveStatus.EQUILIBRIUM;
      diff = 0;
    }
  }

  /**
   * @notice Calculates an expected reserve amount after the transaction taking into an account the withdrawAmount
   * @param _reserveRatioPct % of a reserve ratio, 1 ether == 100%
   * @param _leftOnPiToken The amount of origin tokens left on the piToken (WrappedPiErc20) contract
   * @param _stakedBalance The amount of original tokens staked on the staking contract
   * @param _withdrawAmount The amount to be withdrawn within the current transaction
   *                        (could be negative in a case of deposit)
   * @return expectedReserveAmount The expected reserve amount
   *
   *                           / %reserveRatio * (staked + _leftOnPiToken - withdrawAmount) \
   * expectedReserveAmount =  | ------------------------------------------------------------| + withdrawAmount
   *                           \                         100%                              /
   */
  function getExpectedReserveAmount(
    uint256 _reserveRatioPct,
    uint256 _leftOnPiToken,
    uint256 _stakedBalance,
    uint256 _withdrawAmount
  ) public pure returns (uint256) {
    return
    _reserveRatioPct.mul(_stakedBalance.add(_leftOnPiToken).sub(_withdrawAmount)).div(HUNDRED_PCT).add(
      _withdrawAmount
    );
  }

  function _reward(
    uint256 _reporterId,
    uint256 _gasStart,
    uint256 _compensationPlan,
    bytes calldata _rewardOpts
  ) internal {
    powerPoke.reward(_reporterId, _gasStart.sub(gasleft()), _compensationPlan, _rewardOpts);
  }

  function _getMinMaxReportInterval() internal view returns (uint256 min, uint256 max) {
    return powerPoke.getMinMaxReportIntervals(address(this));
  }
}

// File: contracts/powerindex-router/implementations/SushiPowerIndexRouter.sol

contract SushiPowerIndexRouter is PowerIndexBasicRouter {
  event Stake(address indexed sender, uint256 amount);
  event Redeem(address indexed sender, uint256 amount);
  event IgnoreDueMissingStaking();
  event ClaimRewards(
    address indexed sender,
    uint256 xSushiBurned,
    uint256 expectedSushiReward,
    uint256 releasedSushiReward
  );
  event DistributeRewards(
    address indexed sender,
    uint256 sushiReward,
    uint256 pvpReward,
    uint256 poolRewardsUnderlying,
    uint256 poolRewardsPi,
    address[] pools
  );

  struct SushiConfig {
    address SUSHI;
  }

  IERC20 internal immutable SUSHI;

  constructor(
    address _piToken,
    BasicConfig memory _basicConfig,
    SushiConfig memory _sushiConfig
  ) public PowerIndexBasicRouter(_piToken, _basicConfig) {
    SUSHI = IERC20(_sushiConfig.SUSHI);
  }

  /*** PERMISSIONLESS REWARD CLAIMING AND DISTRIBUTION ***/

  /**
   * @notice Withdraws the extra staked SUSHI as a reward and transfers it to the router
   */
  function _claimRewards() internal override {
    uint256 rewardsPending = getPendingRewards();
    require(rewardsPending > 0, "NOTHING_TO_CLAIM");

    uint256 sushiBefore = SUSHI.balanceOf(address(piToken));
    uint256 xSushiToBurn = getXSushiForSushi(rewardsPending);

    // Step #1. Claim the excess of SUSHI from SushiBar
    _callStaking(ISushiBar.leave.selector, abi.encode(xSushiToBurn));
    uint256 released = SUSHI.balanceOf(address(piToken)).sub(sushiBefore);
    require(released > 0, "NOTHING_RELEASED");

    // Step #2. Transfer the claimed SUSHI to the router
    piToken.callExternal(address(SUSHI), SUSHI.transfer.selector, abi.encode(address(this), released), 0);

    emit ClaimRewards(msg.sender, xSushiToBurn, rewardsPending, released);
  }

  /**
   * @notice Wraps the router's SUSHIs into piTokens and transfers it to the pools proportionally their SUSHI balances
   */
  function _distributeRewards() internal override {
    uint256 pendingReward = SUSHI.balanceOf(address(this));
    require(pendingReward > 0, "NO_PENDING_REWARD");

    // Step #1. Distribute pvpReward
    (uint256 pvpReward, uint256 poolRewardsUnderlying) = _distributeRewardToPvp(pendingReward, SUSHI);
    require(poolRewardsUnderlying > 0, "NO_POOL_REWARDS_UNDERLYING");

    // Step #2. Wrap SUSHI into piSUSHI
    SUSHI.approve(address(piToken), poolRewardsUnderlying);
    piToken.deposit(poolRewardsUnderlying);

    // Step #3. Distribute piSUSHI over the pools
    (uint256 poolRewardsPi, address[] memory pools) = _distributePiRemainderToPools(piToken);

    emit DistributeRewards(msg.sender, pendingReward, pvpReward, poolRewardsUnderlying, poolRewardsPi, pools);
  }

  /*** VIEWERS ***/

  /**
   * @notice Get the amount of xSUSHI tokens SushiBar will mint in exchange of the given SUSHI tokens
   * @param _sushi The input amount of SUSHI tokens
   * @return The corresponding amount of xSUSHI tokens
   */
  function getXSushiForSushi(uint256 _sushi) public view returns (uint256) {
    return _sushi.mul(IERC20(staking).totalSupply()) / SUSHI.balanceOf(staking);
  }

  /**
   * @notice Get the amount of SUSHI tokens SushiBar will release in exchange of the given xSUSHI tokens
   * @param _xSushi The input amount of xSUSHI tokens
   * @return The corresponding amount of SUSHI tokens
   */
  function getSushiForXSushi(uint256 _xSushi) public view returns (uint256) {
    return _xSushi.mul(SUSHI.balanceOf(staking)) / IERC20(staking).totalSupply();
  }

  /**
   * @notice Get the total amount of SUSHI tokens could be released in exchange of the piToken's xSUSHI balance.
   *         Is comprised of the underlyingStaked and the pendingRewards.
   * @return The SUSHI amount
   */
  function getUnderlyingBackedByXSushi() public view returns (uint256) {
    if (staking == address(0)) {
      return 0;
    }

    uint256 xSushiAtPiToken = IERC20(staking).balanceOf(address(piToken));
    if (xSushiAtPiToken == 0) {
      return 0;
    }

    return getSushiForXSushi(xSushiAtPiToken);
  }

  /**
   * @notice Get the amount of current pending rewards available at SushiBar
   * @return amount of pending rewards
   */
  function getPendingRewards() public view returns (uint256 amount) {
    // return sushiAtPiToken + sushiBackedByXSushi - piToken.totalSupply()
    amount = SUSHI.balanceOf(address(piToken)).add(getUnderlyingBackedByXSushi()).add(1).sub(piToken.totalSupply());
    return amount == 1 ? 0 : amount;
  }

  /*** EQUIVALENT METHODS OVERRIDES ***/

  function getPiEquivalentForUnderlying(
    uint256 _underlyingAmount,
    IERC20, /* _underlyingToken */
    uint256 /* _piTotalSupply */
  ) public view override returns (uint256) {
    return _underlyingAmount;
  }

  function getPiEquivalentForUnderlyingPure(
    uint256 _underlyingAmount,
    uint256, /* _totalUnderlyingWrapped */
    uint256 /* _piTotalSupply */
  ) public pure override returns (uint256) {
    return _underlyingAmount;
  }

  function getUnderlyingEquivalentForPi(
    uint256 _piAmount,
    IERC20, /* _underlyingToken */
    uint256 /* _piTotalSupply */
  ) public view override returns (uint256) {
    return _piAmount;
  }

  function getUnderlyingEquivalentForPiPure(
    uint256 _piAmount,
    uint256, /* _totalUnderlyingWrapped */
    uint256 /* _piTotalSupply */
  ) public pure override returns (uint256) {
    return _piAmount;
  }

  /*** OWNER METHODS ***/

  /**
   * @notice The contract owner manually stakes the given amount of SUSHI
   * @param _sushi The amount SUSHI to stake
   */
  function stake(uint256 _sushi) external onlyOwner {
    _stake(_sushi);
  }

  /**
   * @notice The contract owner manually burns the given amount of xSUSHI in exchange of SUSHI tokens
   * @param _xSushi The amount xSUSHI to burn
   */
  function redeem(uint256 _xSushi) external onlyOwner {
    _redeem(_xSushi);
  }

  /*** POKE FUNCTION ***/

  function _rebalancePoke(ReserveStatus reserveStatus, uint256 sushiDiff) internal override {
    require(staking != address(0), "STACKING_IS_NULL");

    if (reserveStatus == ReserveStatus.SHORTAGE) {
      _redeem(getXSushiForSushi(sushiDiff));
    } else if (reserveStatus == ReserveStatus.EXCESS) {
      _stake(sushiDiff);
    }
  }

  /*** INTERNALS ***/

  /**
   * @notice Get the opposite to the reserve ratio amount of SUSHI staked at SushiBar
   * @return The SUSHI amount
   */
  function _getUnderlyingStaked() internal view override returns (uint256) {
    // return piTokenTotalSupply - sushiAtPiToken
    return piToken.totalSupply().sub(SUSHI.balanceOf(address(piToken)));
  }

  function _stake(uint256 _sushi) internal {
    require(_sushi > 0, "CANT_STAKE_0");

    piToken.approveUnderlying(staking, _sushi);
    _callStaking(ISushiBar(0).enter.selector, abi.encode(_sushi));

    emit Stake(msg.sender, _sushi);
  }

  function _redeem(uint256 _xSushi) internal {
    require(_xSushi > 0, "CANT_REDEEM_0");

    _callStaking(ISushiBar(0).leave.selector, abi.encode(_xSushi));

    emit Redeem(msg.sender, _xSushi);
  }
}

// File: contracts/powerindex-router/implementations/factories/SushiPowerIndexRouterFactory.sol

contract SushiPowerIndexRouterFactory is IPiRouterFactory {
  event BuildSushiRouter(address indexed builder, address indexed piToken, address indexed router);

  function buildRouter(address _piToken, bytes calldata _args) external override returns (address) {
    (PowerIndexBasicRouter.BasicConfig memory _basicConfig, SushiPowerIndexRouter.SushiConfig memory _sushiConfig) =
    abi.decode(_args, (PowerIndexBasicRouter.BasicConfig, SushiPowerIndexRouter.SushiConfig));

    address router = address(new SushiPowerIndexRouter(_piToken, _basicConfig, _sushiConfig));

    emit BuildSushiRouter(msg.sender, _piToken, router);

    Ownable(router).transferOwnership(msg.sender);

    return router;
  }
}