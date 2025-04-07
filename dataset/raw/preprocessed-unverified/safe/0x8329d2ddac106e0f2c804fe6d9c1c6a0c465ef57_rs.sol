// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Collection of functions related to the address type
 */


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


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


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

/**
 * @title The DUSK Provisioner Prestaking Contract.
 * @author Jules de Smit
 * @notice This contract will facilitate staking for the DUSK ERC-20 token.
 */
contract PrestakingProvisioner is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    // The DUSK contract.
    IERC20 private _token;
    
    // Holds all of the information for a staking individual.
    struct Staker {
        uint    startTime;
        uint    endTime;
        uint256 amount;
        uint256 accumulatedReward;
        uint    cooldownTime;
        uint256 pendingReward;
        uint256 dailyReward;
        uint    lastUpdated;
    }
    
    mapping(address => Staker) public stakersMap;
    uint256 public stakersAmount;

    uint public deactivationTime;
        
    modifier onlyStaker() {
        Staker storage staker = stakersMap[msg.sender];
        uint startTime = staker.startTime;
        require(startTime.add(1 days) <= block.timestamp && startTime != 0, "No stake is active for sender address");
        _;
    }

    modifier onlyActive() {
        require(deactivationTime == 0);
        _;
    }

    modifier onlyInactive() {
        require(deactivationTime != 0);
        _;
    }
    
    constructor(IERC20 token) public {
        _token = token;
    }
    
    /**
     * @notice Ensure nobody can send Ether to this contract, as it is not supposed to have any.
     */
    receive() external payable {
        revert();
    }

    /**
     * @notice Deactivate the contract. Only to be used once the campaign
     * comes to an end.
     *
     * NOTE that this sets the contract to inactive indefinitely, and will
     * not be usable from this point onwards.
     */
    function deactivate() external onlyOwner onlyActive {
        deactivationTime = block.timestamp;
    }

    /**
     * @notice Can be used by the contract owner to return a user's stake back to them,
     * without need for going through the withdrawal period. This should only really be used
     * at the end of the campaign, if a user does not manually withdraw their stake.
     * @dev This function only works on single addresses, in order to avoid potential
     * deadlocks caused by high gas requirements.
     */
    function returnStake(address _staker) external onlyOwner {
        Staker storage staker = stakersMap[_staker];
        require(staker.amount > 0, "This person is not staking");

        uint comparisonTime = block.timestamp;
        if (deactivationTime != 0) {
            comparisonTime = deactivationTime;
        }

        distributeRewards(staker, comparisonTime);

        // If this user has a pending reward, add it to the accumulated reward before
        // paying him out.
        staker.accumulatedReward = staker.accumulatedReward.add(staker.pendingReward);
        removeUser(staker, _staker);
    }
    
    /**
     * @notice Lock up a given amount of DUSK in the pre-staking contract.
     * @dev A user is required to approve the amount of DUSK prior to calling this function.
     */
    function stake(uint256 amount) external onlyActive {
        // Ensure this staker does not exist yet.
        Staker storage staker = stakersMap[msg.sender];
        require(staker.amount == 0, "Address already known");

        if (amount > 1000000 ether || amount < 10000 ether) {
            revert("Amount to stake is out of bounds");
        }
        
        // Set information for this staker.
        uint blockTimestamp = block.timestamp;
        staker.amount = amount;
        staker.startTime = blockTimestamp;
        staker.lastUpdated = blockTimestamp;
        staker.dailyReward = amount.mul(100033).div(100000).sub(amount);
        stakersAmount++;
        
        // Transfer the DUSK to this contract.
        _token.safeTransferFrom(msg.sender, address(this), amount);
    }
    
    /**
     * @notice Start the cooldown period for withdrawing a reward.
     */
    function startWithdrawReward() external onlyStaker onlyActive {
        Staker storage staker = stakersMap[msg.sender];
        uint blockTimestamp = block.timestamp;
        require(staker.cooldownTime == 0, "A withdrawal call has already been triggered");
        require(staker.endTime == 0, "Stake already withdrawn");
        distributeRewards(staker, blockTimestamp);
        
        staker.cooldownTime = blockTimestamp;
        staker.pendingReward = staker.accumulatedReward;
        staker.accumulatedReward = 0;
    }
    
    /**
     * @notice Withdraw the reward. Will only work after the cooldown period has ended.
     */
    function withdrawReward() external onlyStaker {
        Staker storage staker = stakersMap[msg.sender];
        uint cooldownTime = staker.cooldownTime;
        require(cooldownTime != 0, "The withdrawal cooldown has not been triggered");

        if (block.timestamp.sub(cooldownTime) >= 7 days) {
            uint256 reward = staker.pendingReward;
            staker.cooldownTime = 0;
            staker.pendingReward = 0;
            _token.safeTransfer(msg.sender, reward);
        }
    }
    
    /**
     * @notice Start the cooldown period for withdrawing the stake.
     */
    function startWithdrawStake() external onlyStaker onlyActive {
        Staker storage staker = stakersMap[msg.sender];
        uint blockTimestamp = block.timestamp;
        require(staker.startTime.add(30 days) <= blockTimestamp, "Stakes can only be withdrawn 30 days after initial lock up");
        require(staker.endTime == 0, "Stake withdrawal already in progress");
        require(staker.cooldownTime == 0, "A withdrawal call has been triggered - please wait for it to complete before withdrawing your stake");
        
        // We distribute the rewards first, so that the withdrawing staker
        // receives all of their allocated rewards, before setting an `endTime`.
        distributeRewards(staker, blockTimestamp);
        staker.endTime = blockTimestamp;
    }
    
    /**
     * @notice Start the cooldown period for withdrawing the stake.
     * This function can only be called once the contract is deactivated.
     * @dev This function is nearly identical to `startWithdrawStake`,
     * but it was included in order to prevent adding a `SLOAD` call
     * to `distributeRewards`, making contract usage a bit cheaper during
     * the campaign.
     */
    function startWithdrawStakeAfterDeactivation() external onlyStaker onlyInactive {
        Staker storage staker = stakersMap[msg.sender];
        uint blockTimestamp = block.timestamp;
        require(staker.startTime.add(30 days) <= blockTimestamp, "Stakes can only be withdrawn 30 days after initial lock up");
        require(staker.endTime == 0, "Stake withdrawal already in progress");
        require(staker.cooldownTime == 0, "A withdrawal call has been triggered - please wait for it to complete before withdrawing your stake");
        
        // We distribute the rewards first, so that the withdrawing staker
        // receives all of their allocated rewards, before setting an `endTime`.
        distributeRewards(staker, deactivationTime);
        staker.endTime = blockTimestamp;
    }
    
    /**
     * @notice Withdraw the stake, and clear the entry of the caller.
     */
    function withdrawStake() external onlyStaker {
        Staker storage staker = stakersMap[msg.sender];
        uint endTime = staker.endTime;
        require(endTime != 0, "Stake withdrawal call was not yet initiated");
        
        if (block.timestamp.sub(endTime) >= 7 days) {
            removeUser(staker, msg.sender);
        }
    }
    
    /**
     * @notice Update the reward allocation for a given staker.
     * @param staker The staker to update the reward allocation for.
     */
    function distributeRewards(Staker storage staker, uint comparisonTime) internal {
        uint numDays = comparisonTime.sub(staker.lastUpdated).div(1 days);
        if (numDays == 0) {
            return;
        }
        
        uint256 reward = staker.dailyReward.mul(numDays);
        staker.accumulatedReward = staker.accumulatedReward.add(reward);
        staker.lastUpdated = staker.lastUpdated.add(numDays.mul(1 days));
    }

    /**
     * @notice Remove a user from the staking pool. This ensures proper deletion from
     * the stakers map and the stakers array, and ensures that all DUSK is returned to
     * the rightful owner.
     * @param staker The information of the staker in question
     * @param sender The address of the staker in question
     */
    function removeUser(Staker storage staker, address sender) internal {
        uint256 balance = staker.amount.add(staker.accumulatedReward);
        delete stakersMap[sender];
        stakersAmount--;
        
        _token.safeTransfer(sender, balance);
    }
}