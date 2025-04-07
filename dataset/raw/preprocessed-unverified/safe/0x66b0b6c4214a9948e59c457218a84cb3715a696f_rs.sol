/**
 *Submitted for verification at Etherscan.io on 2020-10-14
*/

/* yLAND Farming Contract - v3 */



// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

// File: @openzeppelin\contracts\math\Math.sol

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


// File: @openzeppelin\contracts\math\SafeMath.sol

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


// File: @openzeppelin\contracts\token\ERC20\IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts\interfaces\IStakedRewardsPool.sol



// File: contracts\interfaces\IStakedRewardsPoolTimedRate.sol

interface IStakedRewardsPoolTimedRate is IStakedRewardsPool {
	/* Views */

	function accruedRewardPerToken() external view returns (uint256);

	function hasEnded() external view returns (bool);

	function hasStarted() external view returns (bool);

	function lastTimeRewardApplicable() external view returns (uint256);

	function periodDuration() external view returns (uint256);

	function periodEndTime() external view returns (uint256);

	function periodStartTime() external view returns (uint256);

	function rewardRate() external view returns (uint256);

	function timeRemainingInPeriod() external view returns (uint256);

	/* Mutators */

	function addToRewardsAllocation(uint256 amount) external;

	function setNewPeriod(uint256 startTime, uint256 endTime) external;

	/* Events */

	event RewardAdded(uint256 amount);
	event NewPeriodSet(uint256 startTIme, uint256 endTime);
}

// File: node_modules\@openzeppelin\contracts\GSN\Context.sol

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

// File: @openzeppelin\contracts\access\Ownable.sol

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
contract Ownable is Context {
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

// File: @openzeppelin\contracts\utils\Pausable.sol

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context {
	/**
	 * @dev Emitted when the pause is triggered by `account`.
	 */
	event Paused(address account);

	/**
	 * @dev Emitted when the pause is lifted by `account`.
	 */
	event Unpaused(address account);

	bool private _paused;

	/**
	 * @dev Initializes the contract in unpaused state.
	 */
	constructor () {
		_paused = false;
	}

	/**
	 * @dev Returns true if the contract is paused, and false otherwise.
	 */
	function paused() public view returns (bool) {
		return _paused;
	}

	/**
	 * @dev Modifier to make a function callable only when the contract is not paused.
	 *
	 * Requirements:
	 *
	 * - The contract must not be paused.
	 */
	modifier whenNotPaused() {
		require(!_paused, "Pausable: paused");
		_;
	}

	/**
	 * @dev Modifier to make a function callable only when the contract is paused.
	 *
	 * Requirements:
	 *
	 * - The contract must be paused.
	 */
	modifier whenPaused() {
		require(_paused, "Pausable: not paused");
		_;
	}

	/**
	 * @dev Triggers stopped state.
	 *
	 * Requirements:
	 *
	 * - The contract must not be paused.
	 */
	function _pause() internal virtual whenNotPaused {
		_paused = true;
		emit Paused(_msgSender());
	}

	/**
	 * @dev Returns to normal state.
	 *
	 * Requirements:
	 *
	 * - The contract must be paused.
	 */
	function _unpause() internal virtual whenPaused {
		_paused = false;
		emit Unpaused(_msgSender());
	}
}

// File: @openzeppelin\contracts\utils\ReentrancyGuard.sol

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
contract ReentrancyGuard {
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

// File: node_modules\@openzeppelin\contracts\utils\Address.sol

/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin\contracts\token\ERC20\SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts\StakedRewardsPool.sol

abstract contract StakedRewardsPool is
	Context,
	ReentrancyGuard,
	Ownable,
	Pausable,
	IStakedRewardsPool
{
	using SafeERC20 for IERC20;
	using SafeMath for uint256;

	/* Mutable Internal State */

	mapping(address => uint256) internal _rewards;

	/* Immutable Private State */

	uint8 private _stakingTokenDecimals;
	IERC20 private _rewardsToken;
	IERC20 private _stakingToken;
	uint256 private _stakingTokenBase;

	/* Mutable Private State */

	mapping(address => uint256) private _balances;
	uint256 private _totalSupply;

	/* Constructor */

	constructor(
		IERC20 rewardsToken,
		IERC20 stakingToken,
		uint8 stakingTokenDecimals
	) Ownable() {
		// Prevent overflow, though 76 would create a safe but unusable contract
		require(
			stakingTokenDecimals < 77,
			"StakedRewardsPool: staking token has far too many decimals"
		);

		_rewardsToken = rewardsToken;

		_stakingToken = stakingToken;
		_stakingTokenDecimals = stakingTokenDecimals;
		_stakingTokenBase = 10**stakingTokenDecimals;
	}

	/* Public Views */

	function balanceOf(address account) public view override returns (uint256) {
		return _balances[account];
	}

	function earned(address account)
		public
		view
		virtual
		override
		returns (uint256);

	function rewardsToken() public view override returns (IERC20) {
		return _rewardsToken;
	}

	function stakingToken() public view override returns (IERC20) {
		return _stakingToken;
	}

	function stakingTokenDecimals() public view override returns (uint8) {
		return _stakingTokenDecimals;
	}

	function totalSupply() public view override returns (uint256) {
		return _totalSupply;
	}

	/* Public Mutators */

	function exit() public override nonReentrant {
		_exit();
	}

	function getReward() public override nonReentrant {
		_getReward();
	}

	function getRewardExact(uint256 amount) public override nonReentrant {
		_getRewardExact(amount);
	}

	function pause() public override onlyOwner {
		_pause();
	}

	// In the unlikely event that unsupported tokens are successfully sent to the
	// contract. This will also allow for removal of airdropped tokens.
	function recoverUnsupportedERC20(
		IERC20 token,
		address to,
		uint256 amount
	) public override onlyOwner {
		_recoverUnsupportedERC20(token, to, amount);
	}

	function stake(uint256 amount) public override nonReentrant whenNotPaused {
		_stakeFrom(_msgSender(), amount);
	}

	function unpause() public override onlyOwner {
		_unpause();
	}

	function updateReward() public override nonReentrant {
		_updateRewardFor(_msgSender());
	}

	function updateRewardFor(address account) public override nonReentrant {
		_updateRewardFor(account);
	}

	function withdraw(uint256 amount) public override nonReentrant {
		_withdraw(amount);
	}

	/* Internal Views */

	function _getStakingTokenBase() internal view returns (uint256) {
		return _stakingTokenBase;
	}

	/* Internal Mutators */

	function _exit() internal virtual {
		_withdraw(_balances[_msgSender()]);
		_getReward();
	}

	function _getReward() internal virtual {
		_updateRewardFor(_msgSender());
		uint256 reward = _rewards[_msgSender()];
		if (reward > 0) {
			_rewards[_msgSender()] = 0;
			_rewardsToken.safeTransfer(_msgSender(), reward);
			emit RewardPaid(_msgSender(), reward);
		}
	}

	function _getRewardExact(uint256 amount) internal virtual {
		_updateRewardFor(_msgSender());
		uint256 reward = _rewards[_msgSender()];
		require(
			amount <= reward,
			"StakedRewardsPool: can not redeem more rewards than you have earned"
		);
		_rewards[_msgSender()] = reward.sub(amount);
		_rewardsToken.safeTransfer(_msgSender(), amount);
		emit RewardPaid(_msgSender(), amount);
	}

	function _recoverUnsupportedERC20(
		IERC20 token,
		address to,
		uint256 amount
	) internal virtual {
		require(
			token != _stakingToken,
			"StakedRewardsPool: cannot withdraw the staking token"
		);
		require(
			token != _rewardsToken,
			"StakedRewardsPool: cannot withdraw the rewards token"
		);
		token.safeTransfer(to, amount);
		emit Recovered(token, to, amount);
	}

	function _stakeFrom(address account, uint256 amount) internal virtual {
		require(
			account != address(0),
			"StakedRewardsPool: cannot stake from the zero address"
		);
		require(amount > 0, "StakedRewardsPool: cannot stake zero");
		_updateRewardFor(account);
		_totalSupply = _totalSupply.add(amount);
		_balances[account] = _balances[account].add(amount);
		_stakingToken.safeTransferFrom(account, address(this), amount);
		emit Staked(account, amount);
	}

	function _updateRewardFor(address account) internal virtual;

	function _withdraw(uint256 amount) internal virtual {
		require(amount > 0, "StakedRewardsPool: cannot withdraw zero");
		_updateRewardFor(_msgSender());
		_totalSupply = _totalSupply.sub(amount);
		_balances[_msgSender()] = _balances[_msgSender()].sub(amount);
		_stakingToken.safeTransfer(_msgSender(), amount);
		emit Withdrawn(_msgSender(), amount);
	}
}

// File: contracts\StakedRewardsPoolTimedRate.sol

// Accuracy in block.timestamps is not needed.
// https://consensys.github.io/smart-contract-best-practices/recommendations/#the-15-second-rule
/* solhint-disable not-rely-on-time */

contract StakedRewardsPoolTimedRate is
	StakedRewardsPool,
	IStakedRewardsPoolTimedRate
{
	using SafeMath for uint256;

	/* Mutable Private State */

	uint256 private _accruedRewardPerToken;
	mapping(address => uint256) private _accruedRewardPerTokenPaid;
	uint256 private _lastUpdateTime;
	uint256 private _periodEndTime;
	uint256 private _periodStartTime;
	uint256 private _rewardRate;

	/* Modifiers */

	modifier whenStarted {
		require(
			hasStarted(),
			"StakedRewardsPoolTimedRate: current rewards distribution period has not yet begun"
		);
		_;
	}

	/* Constructor */

	constructor(
		IERC20 rewardsToken,
		IERC20 stakingToken,
		uint8 stakingTokenDecimals,
		uint256 periodStartTime,
		uint256 periodEndTime
	) StakedRewardsPool(rewardsToken, stakingToken, stakingTokenDecimals) {
		_periodStartTime = periodStartTime;
		_periodEndTime = periodEndTime;
	}

	/* Public Views */

	// Represents the ratio of reward token to staking token accrued thus far,
	// multiplied by 10**stakingTokenDecimal in case of a fraction.
	function accruedRewardPerToken() public view override returns (uint256) {
		uint256 totalSupply = totalSupply();
		if (totalSupply == 0) {
			return _accruedRewardPerToken;
		}

		uint256 lastUpdateTime = _lastUpdateTime;
		uint256 lastTimeApplicable = lastTimeRewardApplicable();

		// Allow staking at any time without earning undue rewards
		// The following is guaranteed if the next `if` is true:
		// lastUpdateTime == previous _periodEndTime || lastUpdateTime == 0
		if (_periodStartTime > lastUpdateTime) {
			// Prevent underflow
			if (_periodStartTime > lastTimeApplicable) {
				return _accruedRewardPerToken;
			}
			lastUpdateTime = _periodStartTime;
		}

		uint256 dt = lastTimeApplicable.sub(lastUpdateTime);
		if (dt == 0) {
			return _accruedRewardPerToken;
		}

		uint256 accruedReward = _rewardRate.mul(dt);

		return
			_accruedRewardPerToken.add(
				accruedReward.mul(_getStakingTokenBase()).div(totalSupply)
			);
	}

	function earned(address account)
		public
		view
		override(IStakedRewardsPool, StakedRewardsPool)
		returns (uint256)
	{
		// Divide by stakingTokenBase in accordance with accruedRewardPerToken()
		return
			balanceOf(account)
				.mul(accruedRewardPerToken().sub(_accruedRewardPerTokenPaid[account]))
				.div(_getStakingTokenBase())
				.add(_rewards[account]);
	}

	function hasStarted() public view override returns (bool) {
		return block.timestamp >= _periodStartTime;
	}

	function hasEnded() public view override returns (bool) {
		return block.timestamp >= _periodEndTime;
	}

	function lastTimeRewardApplicable() public view override returns (uint256) {
		// Returns 0 if we have never run a staking period.
		// Returns _periodEndTime if we have but we're not in a staking period.
		if (!hasStarted()) {
			return _lastUpdateTime;
		}
		return Math.min(block.timestamp, _periodEndTime);
	}

	function periodDuration() public view override returns (uint256) {
		return _periodEndTime.sub(_periodStartTime);
	}

	function periodEndTime() public view override returns (uint256) {
		return _periodEndTime;
	}

	function periodStartTime() public view override returns (uint256) {
		return _periodStartTime;
	}

	function rewardRate() public view override returns (uint256) {
		return _rewardRate;
	}

	function timeRemainingInPeriod()
		public
		view
		override
		whenStarted
		returns (uint256)
	{
		if (hasEnded()) {
			return 0;
		}
		return _periodEndTime.sub(block.timestamp);
	}

	/* Public Mutators */

	function addToRewardsAllocation(uint256 amount)
		public
		override
		nonReentrant
		onlyOwner
	{
		_addToRewardsAllocation(amount);
	}

	function setNewPeriod(uint256 startTime, uint256 endTime)
		public
		override
		onlyOwner
	{
		require(
			!hasStarted() || hasEnded(),
			"StakedRewardsPoolTimedRate: cannot change an ongoing staking period"
		);
		require(
			endTime > startTime,
			"StakedRewardsPoolTimedRate: endTime must be greater than startTime"
		);
		// The lastTimeRewardApplicable() function would not allow rewards for a
		// past period that was never started.
		require(
			startTime > block.timestamp,
			"StakedRewardsPoolTimedRate: startTime must be greater than the current block time"
		);
		// Ensure that rewards are fully granted before changing the period.
		_updateAccrual();

		if (hasEnded()) {
			// Reset reward rate if this a brand new period (not changing one)
			// Note that you MUST addToRewardsAllocation again if you forgot to call
			// this after the previous period ended but before adding rewards.
			_rewardRate = 0;
		} else {
			// Update reward rate for new duration
			uint256 totalReward = _rewardRate.mul(periodDuration());
			_rewardRate = totalReward.div(endTime.sub(startTime));
		}

		_periodStartTime = startTime;
		_periodEndTime = endTime;

		emit NewPeriodSet(startTime, endTime);
	}

	/* Internal Mutators */

	// Ensure that the amount param is equal to the amount you've added to the contract, otherwise the funds will run out before _periodEndTime.
	// If called during an ongoing staking period, the amount will be allocated
	// to the current staking period.
	// If called before or after a staking period, the amount will only be
	// applied to the next staking period.
	function _addToRewardsAllocation(uint256 amount) internal {
		// TODO Require that amount <= available rewards.
		_updateAccrual();

		// Update reward rate based on remaining time
		uint256 remainingTime;
		if (!hasStarted() || hasEnded()) {
			remainingTime = periodDuration();
		} else {
			remainingTime = timeRemainingInPeriod();
		}

		_rewardRate = _rewardRate.add(amount.div(remainingTime));

		emit RewardAdded(amount);
	}

	function _updateAccrual() internal {
		_accruedRewardPerToken = accruedRewardPerToken();
		_lastUpdateTime = lastTimeRewardApplicable();
	}

	// This logic is needed for any interaction that may manipulate rewards.
	function _updateRewardFor(address account) internal override {
		_updateAccrual();
		// Allocate due rewards.
		_rewards[account] = earned(account);
		// Remove ability to earn rewards on or before the current timestamp.
		_accruedRewardPerTokenPaid[account] = _accruedRewardPerToken;
	}
}