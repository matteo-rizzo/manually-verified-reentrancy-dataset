/**
 *Submitted for verification at Etherscan.io on 2021-03-29
*/

// Dependency file: contracts/libraries/Math.sol

// pragma solidity ^0.6.12;

// a library for performing various math operations




// Dependency file: contracts/libraries/SafeMath.sol

// pragma solidity ^0.6.12;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)
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




// Dependency file: contracts/interfaces/IERC20.sol

// pragma solidity ^0.6.12;




// Dependency file: contracts/libraries/Address.sol

// pragma solidity ^0.6.12;

/**
 * @dev Collection of functions related to the address type
 */


// Dependency file: contracts/libraries/SafeERC20.sol

// pragma solidity ^0.6.12;

// import "contracts/interfaces/IERC20.sol";
// import "contracts/libraries/SafeMath.sol";
// import "contracts/libraries/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// Dependency file: contracts/interfaces/IStakingRewards.sol

// pragma solidity ^0.6.12;




// Dependency file: contracts/ReentrancyGuard.sol

// pragma solidity ^0.6.0;

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

    constructor () internal {
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


// Root file: contracts/staking/StakingRewardsV2.sol

pragma solidity ^0.6.12;


// import 'contracts/libraries/Math.sol';
// import 'contracts/libraries/SafeMath.sol';
// import "contracts/libraries/SafeERC20.sol";

// import 'contracts/interfaces/IERC20.sol';
// import 'contracts/interfaces/IStakingRewards.sol';

// import 'contracts/ReentrancyGuard.sol';

contract StakingRewardsV2 is ReentrancyGuard, IStakingRewards {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public initialized;
    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    address public rewardsDistributor;
    address public externalController;

    struct RewardEpoch {
        uint id;
        uint totalSupply;
        uint startEpoch;
        uint finishEpoch;
        uint rewardRate;
        uint lastUpdateTime;
        uint rewardPerTokenStored;
    }
    // epoch
    mapping(uint => RewardEpoch) public epochData;
    mapping(uint => mapping(address => uint)) public userRewardPerTokenPaid;
    mapping(uint => mapping(address => uint)) public rewards;
    mapping(uint => mapping(address => uint)) private _balances;
    mapping(address => uint) public lastAccountEpoch;
    uint public currentEpochId;

    function initialize(
        address _externalController,
        address _rewardsDistributor,
        address _rewardsToken,
        address _stakingToken
        ) external {
            require(initialized == false, "Contract already initialized.");
            rewardsToken = IERC20(_rewardsToken);
            stakingToken = IERC20(_stakingToken);
            rewardsDistributor = _rewardsDistributor;
            externalController = _externalController;
    }

    function _totalSupply(uint epoch) internal view returns (uint) {
        return epochData[epoch].totalSupply;
    }

    function _balanceOf(uint epoch, address account) public view returns (uint) {
        return _balances[epoch][account];
    }

    function _lastTimeRewardApplicable(uint epoch) internal view returns (uint) {
        if (block.timestamp < epochData[epoch].startEpoch) {
            return 0;
        }
        return Math.min(block.timestamp, epochData[epoch].finishEpoch);
    }

    function totalSupply() external override view returns (uint) {
        return _totalSupply(currentEpochId);
    }

    function balanceOf(address account) external override view returns (uint) {
        return _balanceOf(currentEpochId, account);
    }

    function lastTimeRewardApplicable() public override view returns (uint) {
        return _lastTimeRewardApplicable(currentEpochId);
    }

    function _rewardPerToken(uint _epoch) internal view returns (uint) {
        RewardEpoch memory epoch = epochData[_epoch];
        if (block.timestamp < epoch.startEpoch) {
            return 0;
        }
        if (epoch.totalSupply == 0) {
            return epoch.rewardPerTokenStored;
        }
        return
            epoch.rewardPerTokenStored.add(
                _lastTimeRewardApplicable(_epoch).sub(epoch.lastUpdateTime).mul(epoch.rewardRate).mul(1e18).div(epoch.totalSupply)
            );
    }

    function rewardPerToken() public override view returns (uint) {
        _rewardPerToken(currentEpochId);
    }

    function _earned(uint _epoch, address account) internal view returns (uint256) {
        return _balances[_epoch][account].mul(_rewardPerToken(_epoch).sub(userRewardPerTokenPaid[_epoch][account])).div(1e18).add(rewards[_epoch][account]);
    }

    function earned(address account) public override view returns (uint256) {
        return _earned(currentEpochId, account);
    }

    function getRewardForDuration() external override view returns (uint256) {
        RewardEpoch memory epoch = epochData[currentEpochId];
        return epoch.rewardRate.mul(epoch.finishEpoch - epoch.startEpoch);
    }

    function _stake(uint amount, bool withDepositTransfer) internal {
        require(amount > 0, "Cannot stake 0");
        require(lastAccountEpoch[msg.sender] == currentEpochId || lastAccountEpoch[msg.sender] == 0, "Account should update epoch to stake.");
        epochData[currentEpochId].totalSupply = epochData[currentEpochId].totalSupply.add(amount);
        _balances[currentEpochId][msg.sender] = _balances[currentEpochId][msg.sender].add(amount);
        if(withDepositTransfer) {
            stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        }
        lastAccountEpoch[msg.sender] = currentEpochId;
        emit Staked(msg.sender, amount, currentEpochId);
    }

    function stake(uint256 amount) nonReentrant updateReward(msg.sender) override external {
        _stake(amount, true);
    }

    function withdraw(uint256 amount) override public nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        uint lastEpoch = lastAccountEpoch[msg.sender];
        epochData[lastEpoch].totalSupply = epochData[lastEpoch].totalSupply.sub(amount);
        _balances[lastEpoch][msg.sender] = _balances[lastEpoch][msg.sender].sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount, lastEpoch);
    }

    function getReward() override public nonReentrant updateReward(msg.sender) {
        uint lastEpoch = lastAccountEpoch[msg.sender];
        uint reward = rewards[lastEpoch][msg.sender];
        if (reward > 0) {
            rewards[lastEpoch][msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit() override external {
        withdraw(_balances[lastAccountEpoch[msg.sender]][msg.sender]);
        getReward();
    }

    function updateStakingEpoch() public {
        uint lastEpochId = lastAccountEpoch[msg.sender];
        _updateRewardForEpoch(msg.sender, lastEpochId);

        // Remove record about staking on last account epoch
        uint stakedAmount = _balances[lastEpochId][msg.sender];
        _balances[lastEpochId][msg.sender] = 0;
        epochData[lastEpochId].totalSupply = epochData[lastEpochId].totalSupply.sub(stakedAmount);
        // Move collected rewards from last epoch to the current
        rewards[currentEpochId][msg.sender] = rewards[lastEpochId][msg.sender];
        rewards[lastEpochId][msg.sender] = 0;

        // Restake
        lastAccountEpoch[msg.sender] = currentEpochId;
        _stake(stakedAmount, false);
    }

    function _updateRewardForEpoch(address account, uint epoch) internal {
        epochData[epoch].rewardPerTokenStored = _rewardPerToken(epoch);
        epochData[epoch].lastUpdateTime = _lastTimeRewardApplicable(epoch);
        if (account != address(0)) {
            rewards[epoch][account] = _earned(epoch, account);
            userRewardPerTokenPaid[epoch][account] = epochData[epoch].rewardPerTokenStored;
        }
    }


    modifier updateReward(address account) {
        uint lastEpoch = lastAccountEpoch[account];
        if(account == address(0)) {
            lastEpoch = currentEpochId;
        }
        _updateRewardForEpoch(account, lastEpoch);
        _;
    }

    function notifyRewardAmount(uint reward, uint startEpoch, uint finishEpoch) nonReentrant external {
        require(msg.sender == rewardsDistributor, "Only reward distribured allowed.");
        require(startEpoch >= block.timestamp, "Provided start date too late.");
        require(finishEpoch > startEpoch, "Wrong end date epoch.");
        require(reward > 0, "Wrong reward amount");
        uint rewardsDuration = finishEpoch - startEpoch;

        RewardEpoch memory newEpoch;
        // Initialize new epoch
        currentEpochId++;
        newEpoch.id = currentEpochId;
        newEpoch.startEpoch = startEpoch;
        newEpoch.finishEpoch = finishEpoch;
        newEpoch.rewardRate = reward.div(rewardsDuration);
        // last update time will be right when epoch starts
        newEpoch.lastUpdateTime = startEpoch;

        epochData[newEpoch.id] = newEpoch;

        emit EpochAdded(newEpoch.id, startEpoch, finishEpoch, reward);
    }

    function externalWithdraw() external {
        require(msg.sender == externalController, "Only external controller allowed.");
        rewardsToken.transfer(msg.sender, rewardsToken.balanceOf(msg.sender));
    }

    event EpochAdded(uint epochId, uint startEpoch, uint finishEpoch, uint256 reward);
    event Staked(address indexed user, uint amount, uint epoch);
    event Withdrawn(address indexed user, uint amount, uint epoch);
    event RewardPaid(address indexed user, uint reward);


}