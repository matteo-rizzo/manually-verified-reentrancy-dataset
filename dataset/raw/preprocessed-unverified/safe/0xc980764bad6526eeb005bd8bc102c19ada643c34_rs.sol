/**
 *Submitted for verification at Etherscan.io on 2021-09-01
*/

pragma solidity 0.6.6;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

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
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

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
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


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

    uint256[49] private __gap;
}

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
contract ReentrancyGuardUpgradeSafe is Initializable {
    bool private _notEntered;


    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {


        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;

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
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// SPDX-License-Identifier: MIT
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


// SPDX-License-Identifier: MIT
/**
 * @dev Collection of functions related to the address type
 */


// SPDX-License-Identifier: MIT
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// SPDX-License-Identifier: UNLICENSED
abstract contract IFeesController {
    function feesTo() public view virtual returns (address);
    function setFeesTo(address) public virtual;

    function feesPpm() public view virtual returns (uint);
    function setFeesPpm(uint) public virtual;

    function candyFarmBurnPpm() public view virtual returns (uint);
    function setCandyFarmBurnPpm(uint) public virtual;
}

// SPDX-License-Identifier: UNLICENSED
abstract contract IBurnable {
     function  burn(uint256 _amount) public virtual;
}

// SPDX-License-Identifier: UNLICENSED
// Adapted from Pancakeswap syrup pools
contract CandyFarm is Initializable, OwnableUpgradeSafe, ReentrancyGuardUpgradeSafe {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 private constant REWARD_PRECISION = 10**9;

    // The precision factor
    uint256 private constant PRECISION_FACTOR_MUL = uint256(10**24);
    uint256 private constant PRECISION_FACTOR_DIV = PRECISION_FACTOR_MUL * REWARD_PRECISION;

    // Accrued token per share
    uint256 private accTokenPerShare;

    // The time when POP mining ends.
    uint256 public endDate;

    // The time when POP mining starts.
    uint256 public startDate;

    // Total reward token amount
    uint256 public rewardTokenAmount;

    // The time of the last pool update
    uint256 public lastRewardTime;

    // POP tokens created per time multiplied by REWARD_PRECISION
    uint256 public rewardPerTime;

    // The reward token
    IERC20 public rewardToken;

    // The staked token
    IERC20 public stakedTokenPop;

    // Fee controller
    IFeesController public feesController;

    // Info of each user that stakes tokens (stakedTokenPop)
    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt
    }

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event ExtendDuration(uint256 newEndDate);
    event RewardTokenAmountIncreased(uint256 newRewardAmount);

    modifier isActive() {
        require(endDate > block.timestamp, "Candy farm not active");
        _;
    }

    /**
     * @notice Initialize the contract
     * @param _feesController: fees controller address
     * @param _stakedTokenPop: staked (POP) token address
     * @param _rewardToken: reward token address
     * @param _rewardTokenAmount: reward token amount
     * @param _endDate: end time
     */
    function initialize(
        address _feesController,
        address _stakedTokenPop,
        address _rewardToken,
        uint256 _rewardTokenAmount,
        uint256 _endDate
    ) external initializer {
        require(_endDate > block.timestamp, "Candy farm must be in the future");
        require(_endDate < block.timestamp + 60*60*24*365*10, "Candy farm must last less than 10 years!");
        OwnableUpgradeSafe.__Ownable_init();
        ReentrancyGuardUpgradeSafe.__ReentrancyGuard_init();

        feesController = IFeesController(_feesController);
        stakedTokenPop = IERC20(_stakedTokenPop);
        rewardToken = IERC20(_rewardToken);
        startDate = block.timestamp;
        endDate = _endDate;
        rewardTokenAmount = _rewardTokenAmount;

        rewardPerTime = _rewardTokenAmount.mul(REWARD_PRECISION).div(_endDate - block.timestamp);

        lastRewardTime = block.timestamp;
    }

    /**
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function deposit(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _updatePool();

        if (user.amount > 0) {
            uint256 pending = _getUserPendingReward(user.amount, user.rewardDebt);
            if (pending > 0) {
                rewardToken.safeTransfer(address(msg.sender), pending);
            }
        }

        if (_amount > 0) {
            stakedTokenPop.safeTransferFrom(address(msg.sender), address(this), _amount);
            uint256 stakedAmount = _burnAndReturnStakedAmount(_amount);
            user.amount = user.amount.add(stakedAmount);

            emit Deposit(msg.sender, stakedAmount);
        }

        user.rewardDebt = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR_DIV);
    }

    /**
     * @notice Withdraw staked tokens and collect reward tokens. To withdraw only reward tokens set function input _amount to 0.
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function withdraw(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Amount to withdraw too high");

        _updatePool();

        uint256 pending = _getUserPendingReward(user.amount, user.rewardDebt);

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            stakedTokenPop.safeTransfer(address(msg.sender), _amount);
        }

        if (pending > 0) {
            rewardToken.safeTransfer(address(msg.sender), pending);
        }

        user.rewardDebt = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR_DIV);

        emit Withdraw(msg.sender, _amount);
    }

    /**
     * @notice extend pool duration
     * @param _newEndDate: new end date
     * @return Amount new reward tokens added to keep the same reward rate
     */
    function extendPool(uint256 _newEndDate) external isActive returns(uint256) {
        uint256 newRewardAmount = _extendPoolInternal(_newEndDate);
        rewardToken.safeTransferFrom(msg.sender, address(this), newRewardAmount);
        return newRewardAmount;
    }

    /**
     * @notice extend pool duration
     * @param _newEndDate: new end date
     * @return Amount new reward tokens added to keep the same reward rate
     */
    function _extendPoolInternal(uint256 _newEndDate) internal returns(uint256) {
        require(_newEndDate < block.timestamp + 60*60*24*365*10, "Candy farm must last less than 10 years!");
        uint256 additionalRewardAmount = getAdditionalTokensRequiredToExtend(_newEndDate);

        endDate = _newEndDate;
        rewardTokenAmount = rewardTokenAmount.add(additionalRewardAmount);

        emit ExtendDuration(_newEndDate);
        emit RewardTokenAmountIncreased(rewardTokenAmount);

        return additionalRewardAmount;
    }

    /**
     * @notice Calculate additional amount of tokens needed to extend 
     * @param _newEndDate: new end date
     * @return Additional amount of tokens needed
     */
    function getAdditionalTokensRequiredToExtend(uint256 _newEndDate) public view returns(uint256) {
        uint256 timeDiff = _newEndDate.sub(endDate, "New end date must be larger than before");
        return timeDiff.mul(rewardPerTime).div(REWARD_PRECISION).add(1);
    }

    /**
     * @notice increase reward per time based on new reward tokens added to the pool
     * @param _additionalAmount: additional reward token amount
     */
    function increaseReward(uint256 _additionalAmount) external isActive {
        _increaseRewardInternal(_additionalAmount);
        rewardToken.safeTransferFrom(msg.sender, address(this), _additionalAmount);
    }

    /**
     * @notice increase reward per time based on new reward tokens added to the pool
     * @param _additionalAmount: additional reward token amount
     */
    function _increaseRewardInternal(uint256 _additionalAmount) internal {
        _updatePool();
        
        uint256 additionalRewardPerTime = _additionalAmount.mul(REWARD_PRECISION).div(endDate - block.timestamp);

        rewardPerTime = rewardPerTime.add(additionalRewardPerTime);
        rewardTokenAmount = rewardTokenAmount.add(_additionalAmount);

        emit RewardTokenAmountIncreased(rewardTokenAmount);
    }

    /**
     * @notice increase end date and reward amont
     * @param _newEndDate: new end date
     * @param _additionalAmount: additional reward token amount
     */
    function increaseRewardAndDuration(uint256 _newEndDate, uint256 _additionalAmount) external isActive {
        uint256 extendAmount = _extendPoolInternal(_newEndDate);

        require(_additionalAmount >= extendAmount, "_additionalAmount less than extendAmount");

        uint256 increaseRewardAmount = _additionalAmount.sub(extendAmount);
        _increaseRewardInternal(increaseRewardAmount);

        rewardToken.safeTransferFrom(msg.sender, address(this), _additionalAmount);
    }

    /**
     * @notice Stop rewards
     * @dev Only callable by owner
     */
    function stopReward() external onlyOwner {
        endDate = block.timestamp;
    }

    function resumeReward(uint256 _bonusEndTime) external onlyOwner {
        require(endDate <= block.timestamp, "endDate in the future");
        endDate = _bonusEndTime;
    }

    /**
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 stakedTokenSupply = stakedTokenPop.balanceOf(address(this));
        if (block.timestamp > lastRewardTime && stakedTokenSupply != 0) {
            uint256 multiplier = _getMultiplier(lastRewardTime, block.timestamp);
            uint256 bonusReward = multiplier.mul(rewardPerTime);
            uint256 adjustedTokenPerShare =
                accTokenPerShare.add(bonusReward.mul(PRECISION_FACTOR_MUL).div(stakedTokenSupply));
            return (user.amount.mul(adjustedTokenPerShare).div(PRECISION_FACTOR_DIV)).sub(user.rewardDebt);
        } else {
            return _getUserPendingReward(user.amount, user.rewardDebt);
        }
    }

    function _getUserPendingReward(uint256 userAmount, uint256 userRewardDebt) private view returns(uint256) {
        return (userAmount.mul(accTokenPerShare).div(PRECISION_FACTOR_DIV)).sub(userRewardDebt);
    }

    /**
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool() internal {
        if (block.timestamp <= lastRewardTime) {
            return;
        }

        uint256 stakedTokenSupply = stakedTokenPop.balanceOf(address(this));

        if (stakedTokenSupply == 0) {
            lastRewardTime = block.timestamp;
            return;
        }

        uint256 multiplier = _getMultiplier(lastRewardTime, block.timestamp);
        uint256 bonusReward = multiplier.mul(rewardPerTime);
        accTokenPerShare = accTokenPerShare.add(bonusReward.mul(PRECISION_FACTOR_MUL).div(stakedTokenSupply));
        lastRewardTime = block.timestamp;
    }

    /**
     * @notice Burn percentage of tokens and return the remainder
     * @param _amount: Amount before burn
     * @return Amount after burn
     */
    function _burnAndReturnStakedAmount(uint256 _amount) private returns(uint256) {
        // Calculate burn amount
        uint256 burnAmount = _amount.mul(feesController.candyFarmBurnPpm()).div(1000);

        // Burn
        IBurnable(address(stakedTokenPop)).burn(burnAmount);

        // Return amount after fees 
        return _amount.sub(burnAmount);
    }

    /**
     * @notice Return reward multiplier over the given _from to _to time.
     * @param _from: time to start
     * @param _to: time to finish
     */
    function _getMultiplier(uint256 _from, uint256 _to) internal view returns (uint256) {
        if (_to <= endDate) {
            return _to.sub(_from);
        } else if (_from >= endDate) {
            return 0;
        } else {
            return endDate.sub(_from);
        }
    }
}