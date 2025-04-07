/**
 *Submitted for verification at Etherscan.io on 2021-05-07
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.1;

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


// File: @openzeppelin/contracts/token/ERC20/IERC20.sol





/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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


// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol





/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
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
    constructor () {
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

// File: @openzeppelin/contracts/math/SignedSafeMath.sol





/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
 */


// File: @openzeppelin/contracts/utils/SafeCast.sol






/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */


// File: contracts/Interfaces/StakingInterface.sol






// File: contracts/Staking/Staking.sol










contract Staking is ReentrancyGuard, StakingInterface {
  using SafeMath for uint256;
  using SafeMath for uint128;
  using SignedSafeMath for int256;
  using SignedSafeMath for int128;
  using SafeCast for uint256;
  using SafeCast for uint128;
  using SafeCast for int256;
  using SafeCast for int128;
  using SafeERC20 for IERC20;

  /* ========== CONSTANT VARIABLES ========== */

  uint256 internal constant MAX_TERM = 100;

  IERC20 internal immutable _stakingToken;
  uint256 internal immutable _startTimestamp; // timestamp of the term 0
  uint256 internal immutable _termInterval; // time interval between terms in second

  /* ========== STATE VARIABLES ========== */

  uint256 internal _currentTerm; // the current term (all the info prior to this term is fixed)
  uint256 internal _totalRemaining; // total unsettled amount of rewards and withdrawal
  uint256 internal _totalRewardAdded; // total unsettled amount of rewards

  struct AccountInfo {
    int128 added; // the added amount of stake which will be merged to stakeAmount at the term+1.
    uint128 stakeAmount; // active stake amount of the user at userTerm
    uint256 remaining; // the total amount of rewards and withdrawal until userTerm
    uint256 userTerm; // the term when the user executed any function last time (all the terms before the term has been already settled)
  }

  /**
   * @dev account => data
   */
  mapping(address => AccountInfo) internal _accountInfoList;

  struct TermInfo {
    uint128 stakeAdd; // the total added amount of stake which will be merged to stakeSum at the term+1
    uint128 stakeRemove;
    uint128 stakeSum; // the total staking amount at the term
    uint256 rewardSum; // the total amount of rewards at the term
  }

  /**
   * @dev term => data
   */
  mapping(uint256 => TermInfo) internal _termInfoList;

  /* ========== EVENTS ========== */

  event Staked(address indexed account, uint128 amount);
  event Withdrawn(address indexed account, uint128 amount);
  event RewardPaid(address indexed account, uint256 amount);
  event TermUpdated(uint256 currentTerm);
  event RewardUpdated(address indexed account, uint256 currentTerm);
  event RewardAdded(address indexed account, uint256 indexed term, uint256 amount);

  /* ========== CONSTRUCTOR ========== */

  constructor(
    IERC20 stakingToken,
    uint256 startTimestamp,
    uint256 termInterval
  ) {
    require(startTimestamp <= block.timestamp, "startTimestamp should be past time");
    _startTimestamp = startTimestamp;
    _stakingToken = stakingToken;
    _termInterval = termInterval;
  }

  /* ========== MODIFIERS ========== */

  /**
   * @dev Update the info up to the current term.
   */
  modifier updateTerm() {
    uint256 latestTerm = _getLatestTerm();
    if (_currentTerm < latestTerm) {
      uint128 sendBackLater = _termInfoList[_currentTerm].stakeRemove;
      uint128 nextStakeSum = _getNextStakeSum();
      uint256 nextTerm = nextStakeSum == 0 ? latestTerm : _currentTerm + 1; // if next stakeSum is 0, skip to latest term
      uint256 nextTermReward = _getNextTermReward();
      _termInfoList[nextTerm] = TermInfo({
        stakeAdd: 0,
        stakeRemove: 0,
        stakeSum: nextStakeSum,
        rewardSum: nextTermReward
      });

      // write total stake amount since (nextTerm + 1) until latestTerm
      if (nextTerm < latestTerm) {
        // assert(_termInfoList[nextTerm].stakeSum != 0 && _termInfoList[nextTerm].stakeAdd == 0);
        _termInfoList[latestTerm] = TermInfo({
          stakeAdd: 0,
          stakeRemove: 0,
          stakeSum: nextStakeSum,
          rewardSum: 0
        });
      }

      _totalRemaining = _totalRemaining.add(_totalRewardAdded).add(sendBackLater);
      _totalRewardAdded = 0;
      _currentTerm = latestTerm;
    }

    emit TermUpdated(_currentTerm);
    _;
  }

  /**
   * @dev Calculate total rewards of the account until the current term.
   */
  modifier updateReward(address account) {
    AccountInfo memory accountInfo = _accountInfoList[account];
    uint256 startTerm = accountInfo.userTerm;
    for (uint256 term = startTerm; term < _currentTerm && term < startTerm + MAX_TERM; term++) {
      TermInfo memory termInfo = _termInfoList[term];

      if (termInfo.stakeSum != 0) {
        require(
          accountInfo.stakeAmount <= termInfo.stakeSum,
          "system error: stakeAmount is not more than stakeSum"
        );

        // `(total rewards) * (your stake amount) / (total stake amount)` in each term
        uint256 rewardsAdded = termInfo.rewardSum.mul(accountInfo.stakeAmount) / termInfo.stakeSum;
        accountInfo.remaining = accountInfo.remaining.add(rewardsAdded);
        emit RewardAdded(account, term, rewardsAdded);
      }

      accountInfo.stakeAmount = addDiff(accountInfo.stakeAmount, accountInfo.added).toUint128();
      if (accountInfo.added < 0) {
        accountInfo.remaining = addDiff(accountInfo.remaining, -accountInfo.added);
      }
      accountInfo.added = 0;

      if (accountInfo.stakeAmount == 0) {
        accountInfo.userTerm = _currentTerm;
        break; // skip unnecessary term
      }

      accountInfo.userTerm = term + 1; // calculated until this term
    }

    _accountInfoList[account] = accountInfo;

    // do not execute main function if `userTerm` is not the same with `_currentTerm`.
    if (accountInfo.userTerm < _currentTerm) {
      return;
    }

    emit RewardUpdated(account, _currentTerm);
    _;
  }

  /* ========== MUTATIVE FUNCTIONS ========== */

  /**
   * @notice Stake the staking token for the token to be paid as reward.
   */
  // function stake(uint128 amount)
  //   external
  //   override
  //   nonReentrant
  //   updateTerm()
  //   updateReward(msg.sender)
  // {
  //   require(amount != 0, "staking amount should be positive number");

  //   _stake(msg.sender, amount);
  //   _stakingToken.safeTransferFrom(msg.sender, address(this), amount);
  // }

  /**
   * @notice Withdraw the staking token for the token to be paid as reward.
   */
  // function withdraw(uint128 amount)
  //   external
  //   override
  //   nonReentrant
  //   updateTerm()
  //   updateReward(msg.sender)
  // {
  //   require(amount != 0, "withdrawing amount should be positive number");

  //   _withdraw(msg.sender, amount);
  //   // _stakingToken.safeTransfer(msg.sender, amount);
  // }

  /**
   * @notice Receive the reward and withdrawal from this contract.
   */
  // function receiveReward()
  //   external
  //   override
  //   nonReentrant
  //   updateTerm()
  //   updateReward(msg.sender)
  //   returns (uint256 remaining)
  // {
  //   remaining = _receiveReward(msg.sender);
  //   if (remaining != 0) {
  //     _stakingToken.safeTransfer(msg.sender, remaining);
  //   }
  //   return remaining;
  // }

  /**
   * @notice Add the reward to this contract.
   */
  function addReward(uint128 amount) external nonReentrant updateTerm() {
    _stakingToken.safeTransferFrom(msg.sender, address(this), amount);
    return _addReward(msg.sender, amount);
  }

  /* ========== INTERNAL FUNCTIONS ========== */

  /**
   * @dev The stake amount of `account` increaases by `amount`.
   * This function is staking if `amount` is positive, otherwise unstaking.
   */
  // function _stakeOrUnstake(address account, int128 amount) internal {
  //   uint256 term = _currentTerm;
  //   AccountInfo memory accountInfo = _accountInfoList[account];
  //   require(
  //     addDiff(accountInfo.stakeAmount, accountInfo.added) < type(uint128).max,
  //     "stake amount is out of range"
  //   );

  //   _accountInfoList[account].added = _accountInfoList[account].added.add(amount).toInt128(); // added when the term is shifted (the user)
  //   if (amount >= 0) {
  //     _termInfoList[term].stakeAdd = _termInfoList[term].stakeAdd.add(amount.toUint256()).toUint128(); // added when the term is shifted (global)
  //   } else {
  //     _termInfoList[term].stakeRemove = _termInfoList[term].stakeRemove.sub(-amount.toUint256()).toUint128(); // added when the term is shifted (global)
  //   }
  // }

  function _stake(address account, uint128 amount) internal returns (uint128 sendBack) {
    sendBack = 0;
    if (_accountInfoList[account].added < 0) {
      uint128 added = uint128(-_accountInfoList[account].added);
      sendBack = added < amount ? added : amount; // min(added, amount)
    }

    uint256 term = _currentTerm;
    AccountInfo memory accountInfo = _accountInfoList[account];
    require(
      addDiff(accountInfo.stakeAmount, accountInfo.added) < type(uint128).max,
      "stake amount is out of range"
    );

    _accountInfoList[account].added = _accountInfoList[account]
      .added
      .add(int256(amount))
      .toInt128(); // added when the term is shifted (the user)
    // assert(sendBack <= amount);
    TermInfo memory termInfo = _termInfoList[term];
    termInfo.stakeAdd = termInfo.stakeAdd.add(amount - sendBack).toUint128(); // added when the term is shifted (global)
    termInfo.stakeRemove = termInfo.stakeRemove.sub(sendBack).toUint128(); // added when the term is shifted (global)
    _termInfoList[term] = termInfo;
    emit Staked(account, amount);
  }

  /**
   * @dev Callee must send back staking token to sender instantly until `added` becomes zero.
   *  One can use the return value `sendBack` for it.
   */
  function _withdraw(address account, uint128 amount) internal returns (uint128 sendBack) {
    sendBack = 0;
    if (_accountInfoList[account].added > 0) {
      uint128 added = uint128(_accountInfoList[account].added);
      sendBack = added < amount ? added : amount; // min(added, amount)
    }

    uint256 term = _currentTerm;
    AccountInfo memory accountInfo = _accountInfoList[account];
    require(
      addDiff(accountInfo.stakeAmount, accountInfo.added) < type(uint128).max,
      "stake amount is out of range"
    );

    _accountInfoList[account].added = _accountInfoList[account].added.sub(amount).toInt128(); // added when the term is shifted (the user)
    // assert(sendBack <= amount);
    TermInfo memory termInfo = _termInfoList[term];
    termInfo.stakeAdd = termInfo.stakeAdd.sub(sendBack).toUint128(); // added when the term is shifted (global)
    termInfo.stakeRemove = termInfo.stakeRemove.add(amount - sendBack).toUint128(); // added when the term is shifted (global)
    _termInfoList[term] = termInfo;

    emit Withdrawn(account, amount);
  }

  function _receiveReward(address account) internal returns (uint256 remaining) {
    remaining = _accountInfoList[account].remaining;
    if (remaining != 0) {
      _totalRemaining = _totalRemaining.sub(remaining, "system error: _totalRemaining is invalid");
      _accountInfoList[account].remaining = 0;
      emit RewardPaid(account, remaining);
    }
  }

  function _addReward(address, uint128 amount) internal {
    _totalRewardAdded = _totalRewardAdded.add(amount);
  }

  function _getNextStakeSum() internal view returns (uint128 nextStakeSum) {
    TermInfo memory currentTermInfo = _termInfoList[_currentTerm];
    return
      currentTermInfo
        .stakeSum
        .add(currentTermInfo.stakeAdd)
        .sub(currentTermInfo.stakeRemove)
        .toUint128();
  }

  function _getCarriedReward() internal view returns (uint256 carriedReward) {
    TermInfo memory currentTermInfo = _termInfoList[_currentTerm];
    return currentTermInfo.stakeSum == 0 ? currentTermInfo.rewardSum : 0; // if stakeSum is 0, carried forward until someone stakes
  }

  function _getNextTermReward() internal view returns (uint256 rewards) {
    uint256 carriedReward = _getCarriedReward();
    return _totalRewardAdded.add(carriedReward);
  }

  function _getLatestTerm() internal view returns (uint256) {
    return (block.timestamp - _startTimestamp) / _termInterval;
  }

  /* ========== CALL FUNCTIONS ========== */

  /**
   * @return stakingTokenAddress is the token locked for staking
   */
  function getStakingTokenAddress() external view override returns (address stakingTokenAddress) {
    return address(_stakingToken);
  }

  /**
   * @return startTimestamp is the time when this contract was deployed
   * @return termInterval is the duration of a term
   */
  function getConfigs()
    external
    view
    override
    returns (uint256 startTimestamp, uint256 termInterval)
  {
    startTimestamp = _startTimestamp;
    termInterval = _termInterval;
  }

  function getTotalRewardAdded() external view returns (uint256 totalRewardAdded) {
    return _totalRewardAdded;
  }

  /**
   * @return currentTerm is the current latest term
   * @return latestTerm is the potential latest term
   * @return totalRemainingRewards is the as-of remaining rewards and withdrawal
   * @return currentTermRewards is the total rewards at the current term
   * @return nextTermRewards is the as-of total rewards to be paid at the next term
   * @return currentStaking is the total active staking amount
   * @return nextTermStaking is the total staking amount
   */
  function getTokenInfo()
    external
    view
    override
    returns (
      uint256 currentTerm,
      uint256 latestTerm,
      uint256 totalRemainingRewards,
      uint256 currentTermRewards,
      uint256 nextTermRewards,
      uint128 currentStaking,
      uint128 nextTermStaking
    )
  {
    currentTerm = _currentTerm;
    latestTerm = _getLatestTerm();
    totalRemainingRewards = _totalRemaining;
    TermInfo memory termInfo = _termInfoList[_currentTerm];
    currentTermRewards = termInfo.rewardSum;
    nextTermRewards = _getNextTermReward();
    currentStaking = termInfo.stakeSum;
    nextTermStaking = termInfo
      .stakeSum
      .add(termInfo.stakeAdd)
      .sub(termInfo.stakeRemove)
      .toUint128();
  }

  /**
   * @notice Returns _termInfoList[term].
   */
  function getTermInfo(uint256 term)
    external
    view
    override
    returns (
      int128 stakeAdd,
      uint128 stakeSum,
      uint256 rewardSum
    )
  {
    TermInfo memory termInfo = _termInfoList[term];
    stakeAdd = int256(termInfo.stakeAdd).sub(termInfo.stakeRemove).toInt128();
    stakeSum = termInfo.stakeSum;
    if (term == _currentTerm.add(1)) {
      rewardSum = _getNextTermReward();
    } else {
      rewardSum = termInfo.rewardSum;
    }
  }

  /**
   * @return userTerm is the latest term the user has updated to
   * @return stakeAmount is the latest amount of staking from the user has updated to
   * @return nextAddedStakeAmount is the next amount of adding to stake from the user has updated to
   * @return remaining is the reward and withdrawal getting by the user has updated to
   * @return currentTermUserRewards is the as-of user rewards to be paid at `_currentTerm`
   * @return nextTermUserRewards is the as-of user rewards to be paid at the next term of `_currentTerm`
   * @return depositAmount is the staking amount
   * @return withdrawableStakingAmount is the withdrawable staking amount
   */
  function getAccountInfo(address account)
    external
    view
    override
    returns (
      uint256 userTerm,
      uint256 stakeAmount,
      int128 nextAddedStakeAmount,
      uint256 remaining,
      uint256 currentTermUserRewards,
      uint256 nextTermUserRewards,
      uint128 depositAmount,
      uint128 withdrawableStakingAmount
    )
  {
    AccountInfo memory accountInfo = _accountInfoList[account];
    userTerm = accountInfo.userTerm;
    stakeAmount = accountInfo.stakeAmount;
    nextAddedStakeAmount = accountInfo.added;
    depositAmount = addDiff(stakeAmount, nextAddedStakeAmount).toUint128();
    withdrawableStakingAmount = depositAmount;
    remaining = accountInfo.remaining;

    TermInfo memory termInfo = _termInfoList[_currentTerm];
    uint256 currentTermRewards = termInfo.rewardSum;
    uint256 currentStakeSum = termInfo.stakeSum;
    currentTermUserRewards = currentStakeSum == 0
      ? 0
      : currentTermRewards.mul(userTerm < _currentTerm ? depositAmount : stakeAmount) /
        currentStakeSum;
    uint256 nextTermRewards = _getNextTermReward();
    uint256 nextStakeSum = currentStakeSum.add(termInfo.stakeAdd).sub(termInfo.stakeRemove);
    nextTermUserRewards = nextStakeSum == 0 ? 0 : nextTermRewards.mul(depositAmount) / nextStakeSum;
    // uint256 latestTermUserRewards = _getLatestTerm() > _currentTerm
    //   ? nextTermUserRewards
    //   : currentTermUserRewards;
  }

  /**
   * @dev Returns `base` added to `diff` which may be nagative number.
   */
  function addDiff(uint256 base, int256 diff) internal pure returns (uint256) {
    if (diff >= 0) {
      return base.add(uint256(diff));
    } else {
      return base.sub(uint256(-diff));
    }
  }
}

// File: contracts/Staking/StakingWithAggregator.sol







contract StakingWithAggregator is Ownable, Staking {
  using SafeERC20 for IERC20;

  event Recovered(address tokenAddress, uint256 tokenAmount);

  constructor(
    IERC20 stakingToken,
    uint256 startTimestamp,
    uint256 termInterval
  ) Staking(stakingToken, startTimestamp, termInterval) {}

  /* ========== MUTATIVE FUNCTIONS ========== */

  /**
   * @notice Stake the staking token for the token to be paid as reward.
   */
  function stakeViaAggregator(address account, uint128 amount)
    external
    onlyOwner
    nonReentrant
    updateTerm()
    updateReward(account)
    returns (uint128 sendBack)
  {
    require(amount != 0, "staking amount should be positive number");

    sendBack = _stake(account, amount);
    // _stakingToken.safeTransferFrom(msg.sender, address(this), amount - sendBack);
  }

  /**
   * @notice Withdraw the staking token for the token to be paid as reward.
   */
  function withdrawViaAggregator(address account, uint128 amount)
    external
    onlyOwner
    nonReentrant
    updateTerm()
    updateReward(account)
    returns (uint128 sendBack)
  {
    require(amount != 0, "withdrawing amount should be positive number");

    return _withdraw(account, amount);
  }

  /**
   * @notice Receive the reward for your staking in the token.
   */
  function receiveRewardViaAggregator(address account)
    external
    onlyOwner
    nonReentrant
    updateTerm()
    updateReward(account)
    returns (uint256 remaining)
  {
    return _receiveReward(account);
  }

  function addRewardViaAggregator(address account, uint128 amount)
    external
    onlyOwner
    nonReentrant
    updateTerm()
  {
    // _stakingToken.safeTransferFrom(msg.sender, address(this), amount);
    return _addReward(account, amount);
  }

  /**
   * @notice If you have accidentally transferred token which is not `_stakingToken`,
   * you can use this function to get it back.
   */
  function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
    require(tokenAddress != address(_stakingToken), "Cannot recover the staking token");
    IERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);
    emit Recovered(tokenAddress, tokenAmount);
  }
}

// File: contracts/Interfaces/StakingAggregatorInterface.sol







// File: contracts/Staking/StakingAggregator.sol









contract StakingAggregator is StakingAggregatorInterface {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  /* ========== CONSTANT VARIABLES ========== */

  uint256 internal immutable _termInterval;
  IERC20 internal immutable _stakingToken;
  StakingWithAggregator[] internal _stakingContracts; // immutable
  uint256[] internal _startTimestampList; // immutable

  /* ========== STATE VARIABLES ========== */

  /**
   * @dev if this contract is initialized
   */
  bool internal _enabled = false;

  /* ========== CONSTRUCTOR ========== */

  constructor(
    IERC20 stakingToken,
    uint256 termInterval,
    StakingWithAggregator[] memory stakingContracts
  ) {
    require(stakingContracts.length != 0, "staking contracts should not be empty");
    _stakingToken = stakingToken;
    _termInterval = termInterval;
    uint256 oldStartTimestamp = 0;
    for (uint256 i = 0; i < stakingContracts.length; i++) {
      require(
        stakingContracts[i].getStakingTokenAddress() == address(stakingToken),
        "staking token address differ from expected"
      );
      (uint256 ithStartTimestamp, uint256 ithTermInterval) = stakingContracts[i].getConfigs();
      require(ithTermInterval == termInterval, "term interval differ from expected");
      require(ithStartTimestamp > oldStartTimestamp, "startTimestamp should be sorted");
      oldStartTimestamp = ithStartTimestamp;
      _startTimestampList.push(ithStartTimestamp);
      _stakingContracts.push(stakingContracts[i]);
      // stakingToken.safeApprove(address(stakingContracts[i]), type(uint256).max);
    }
  }

  modifier isEnabled() {
    require(_enabled, "aggregator is not initialized");
    _;
  }

  /* ========== MUTATIVE FUNCTIONS ========== */

  function init() external {
    require(!_enabled, "already initialized");

    for (uint256 i = 0; i < _stakingContracts.length; i++) {
      require(_stakingContracts[i].owner() == address(this), "not owner");
    }

    _enabled = true;
  }

  /**
   * @notice Stake the staking token for the token to be paid as reward.
   */
  function stake(uint128 amount) external override isEnabled returns (uint128 totalSendBack) {
    uint256 maxUntilNextTerm;
    uint256 nextStakingContractIndex;
    for (uint256 i = 0; i < _startTimestampList.length; i++) {
      // assert(_startTimestampList[i] <= block.timestamp);
      uint256 untilNextTerm = (block.timestamp - _startTimestampList[i]) % _termInterval;
      if (untilNextTerm > maxUntilNextTerm) {
        maxUntilNextTerm = untilNextTerm;
        nextStakingContractIndex = i;
      }
    }

    totalSendBack = _stakingContracts[nextStakingContractIndex].stakeViaAggregator(
      msg.sender,
      amount
    );

    if (amount - totalSendBack != 0) {
      _stakingToken.safeTransferFrom(msg.sender, address(this), amount - totalSendBack);
    }
  }

  /**
   * @notice Withdraw the staking token for the token to be paid as reward.
   * @return totalSendBack is the amount returned instantly.
   */
  function withdraw(uint128 amount) external override isEnabled returns (uint256 totalSendBack) {
    require(amount != 0, "withdrawing amount should be positive number");

    uint256 maxUntilNextTerm;
    uint256 nextStakingContractIndex;
    for (uint256 i = 0; i < _startTimestampList.length; i++) {
      // assert(_startTimestampList[i] <= block.timestamp);
      uint256 untilNextTerm = (block.timestamp - _startTimestampList[i]) % _termInterval;
      if (untilNextTerm > maxUntilNextTerm) {
        maxUntilNextTerm = untilNextTerm;
        nextStakingContractIndex = i;
      }
    }

    for (
      uint256 i = nextStakingContractIndex;
      i < nextStakingContractIndex + _startTimestampList.length && amount != 0;
      i++
    ) {
      StakingWithAggregator ithStakingContract = _stakingContracts[i % _startTimestampList.length];
      (, , , , , , uint128 withdrawableAmount, ) = ithStakingContract.getAccountInfo(msg.sender);
      uint128 ithAmount = (amount < withdrawableAmount) ? amount : withdrawableAmount;
      // assert(amount >= ithAmount);
      amount -= ithAmount;

      if (ithAmount != 0) {
        uint128 sendBack = ithStakingContract.withdrawViaAggregator(msg.sender, ithAmount);
        totalSendBack = totalSendBack.add(sendBack);
      }
    }

    require(amount == 0, "exceed withdrawable amount");

    if (totalSendBack != 0) {
      _stakingToken.safeTransfer(msg.sender, totalSendBack);
    }
  }

  /**
   * @notice Receive the reward for your staking in the token.
   */
  function receiveReward() external override isEnabled returns (uint256 remaining) {
    for (uint256 i = 0; i < _stakingContracts.length; i++) {
      remaining = remaining.add(_stakingContracts[i].receiveRewardViaAggregator(msg.sender));
    }

    if (remaining != 0) {
      _stakingToken.safeTransfer(msg.sender, remaining);
    }
  }

  /**
   * @notice Add the reward to this contract.
   */
  function addReward(uint256 stakingContractIndex, uint128 amount) external override isEnabled {
    require(
      stakingContractIndex < _stakingContracts.length,
      "stakingContractIndex is out of index"
    );
    _stakingToken.safeTransferFrom(msg.sender, address(this), amount);
    return _stakingContracts[stakingContractIndex].addRewardViaAggregator(msg.sender, amount);
  }

  function getStakingTokenAddress() external view override returns (address) {
    return address(_stakingToken);
  }

  function getStakingContracts()
    external
    view
    override
    returns (StakingWithAggregator[] memory stakingContracts)
  {
    return _stakingContracts;
  }

  function getConfigs()
    external
    view
    override
    returns (uint256[] memory startTimestampList, uint256 termInterval)
  {
    startTimestampList = _startTimestampList;
    termInterval = _termInterval;
  }

  function getTokenInfo()
    external
    view
    override
    returns (
      uint256[] memory latestTermList,
      uint256[] memory totalRemainingRewardsList,
      uint256[] memory currentTermRewardsList,
      uint256[] memory nextTermRewardsList,
      uint128[] memory currentStakingList,
      uint128[] memory nextTermStakingList
    )
  {
    uint256 numOfStakingContracts = _stakingContracts.length;
    latestTermList = new uint256[](numOfStakingContracts);
    totalRemainingRewardsList = new uint256[](numOfStakingContracts);
    currentTermRewardsList = new uint256[](numOfStakingContracts);
    nextTermRewardsList = new uint256[](numOfStakingContracts);
    currentStakingList = new uint128[](numOfStakingContracts);
    nextTermStakingList = new uint128[](numOfStakingContracts);
    for (uint256 i = 0; i < numOfStakingContracts; i++) {
      (
        ,
        uint256 latestTerm,
        uint256 totalRemainingRewards,
        uint256 currentTermRewards,
        uint256 nextTermRewards,
        uint128 currentStaking,
        uint128 nextTermStaking
      ) = _stakingContracts[i].getTokenInfo();
      latestTermList[i] = latestTerm;
      totalRemainingRewardsList[i] = totalRemainingRewards;
      currentTermRewardsList[i] = currentTermRewards;
      nextTermRewardsList[i] = nextTermRewards;
      currentStakingList[i] = currentStaking;
      nextTermStakingList[i] = nextTermStaking;
    }
  }

  function getTermInfo(uint256 term)
    external
    view
    override
    returns (
      int128[] memory stakeAddList,
      uint128[] memory stakeSumList,
      uint256[] memory rewardSumList
    )
  {
    uint256 numOfStakingContracts = _stakingContracts.length;
    stakeAddList = new int128[](numOfStakingContracts);
    stakeSumList = new uint128[](numOfStakingContracts);
    rewardSumList = new uint256[](numOfStakingContracts);
    for (uint256 i = 0; i < numOfStakingContracts; i++) {
      (int128 stakeAdd, uint128 stakeSum, uint256 rewardSum) = _stakingContracts[i].getTermInfo(
        term
      );
      stakeAddList[i] = stakeAdd;
      stakeSumList[i] = stakeSum;
      rewardSumList[i] = rewardSum;
    }
  }

  function getAccountInfo(address account)
    external
    view
    override
    returns (
      uint256[] memory userTermList,
      uint256[] memory stakeAmountList,
      int128[] memory nextAddedStakeAmountList,
      uint256[] memory currentTermUserRewardsList,
      uint256[] memory nextTermUserRewardsList,
      uint128[] memory withdrawableStakingAmountList
    )
  {
    uint256 numOfStakingContracts = _stakingContracts.length;
    userTermList = new uint256[](numOfStakingContracts);
    stakeAmountList = new uint256[](numOfStakingContracts);
    nextAddedStakeAmountList = new int128[](numOfStakingContracts);
    currentTermUserRewardsList = new uint256[](numOfStakingContracts);
    nextTermUserRewardsList = new uint256[](numOfStakingContracts);
    withdrawableStakingAmountList = new uint128[](numOfStakingContracts);
    for (uint256 i = 0; i < numOfStakingContracts; i++) {
      address accountTmp = account;
      (
        uint256 userTerm,
        uint256 stakeAmount,
        int128 nextAddedStakeAmount,
        ,
        uint256 currentTermUserRewards,
        uint256 nextTermUserRewards,
        ,
        uint128 withdrawableStakingAmount
      ) = _stakingContracts[i].getAccountInfo(accountTmp);
      userTermList[i] = userTerm;
      stakeAmountList[i] = stakeAmount;
      nextAddedStakeAmountList[i] = nextAddedStakeAmount;
      currentTermUserRewardsList[i] = currentTermUserRewards;
      nextTermUserRewardsList[i] = nextTermUserRewards;
      withdrawableStakingAmountList[i] = withdrawableStakingAmount;
    }
  }
}