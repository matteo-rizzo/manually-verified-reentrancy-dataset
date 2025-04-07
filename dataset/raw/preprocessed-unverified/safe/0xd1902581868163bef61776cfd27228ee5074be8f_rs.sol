/*

    /     |  __    / ____|
   /      | |__) | | |
  / /    |  _  /  | |
 / ____   | |    | |____
/_/    _ |_|  _  _____|

* ARC: staking/StakingRewardsAccrualCapped.sol
*
* Latest source (may be newer): https://github.com/arcxgame/contracts/blob/master/contracts/staking/StakingRewardsAccrualCapped.sol
*
* Contract Dependencies: 
*	- Accrual
*	- Context
*	- IStakingRewards
*	- Ownable
*	- RewardsDistributionRecipient
*	- StakingRewards
*	- StakingRewardsAccrual
* Libraries: 
*	- Address
*	- Math
*	- SafeERC20
*	- SafeMath
*
* MIT License
* ===========
*
* Copyright (c) 2020 ARC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

/* ===============================================
* Flattened with Solidifier by Coinage
* 
* https://solidifier.coina.ge
* ===============================================
*/


pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
 * @dev Collection of functions related to the address type
 */



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



/**
 * @dev Standard math utilities missing in the Solidity language.
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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// SPDX-License-Identifier: MIT
// Copied directly from https://github.com/Synthetixio/synthetix/blob/v2.26.3/contracts/RewardsDistributionRecipient.sol


contract RewardsDistributionRecipient is Ownable {
    address public rewardsDistribution;

    function notifyRewardAmount(uint256 reward) external;

    modifier onlyRewardsDistribution() {
        require(
            msg.sender == rewardsDistribution,
            "Caller is not RewardsDistribution contract"
        );
        _;
    }

    function setRewardsDistribution(
        address _rewardsDistribution
    )
        external
        onlyOwner
    {
        rewardsDistribution = _rewardsDistribution;
    }
}

// SPDX-License-Identifier: MIT
// Copied directly from https://github.com/Synthetixio/synthetix/blob/v2.26.3/contracts/StakingRewards.sol


contract StakingRewards is IStakingRewards, RewardsDistributionRecipient {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    address public arcDAO;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration = 7 days;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        rewardPerTokenStored = actualRewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();

        if (account != address(0)) {
            rewards[account] = actualEarned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _arcDAO,
        address _rewardsDistribution,
        address _rewardsToken,
        address _stakingToken
    )
        public
    {
        arcDAO = _arcDAO;
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
        rewardsDistribution = _rewardsDistribution;
    }

    /* ========== VIEWS ========== */

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _totalSupply;
    }

    function balanceOf(
        address account
    )
        public
        view
        returns (uint256)
    {
        return _balances[account];
    }

    function lastTimeRewardApplicable()
        public
        view
        returns (uint256)
    {
        return Math.min(block.timestamp, periodFinish);
    }

    function actualRewardPerToken()
        internal
        view
        returns (uint256)
    {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(_totalSupply)
            );
    }

    function rewardPerToken()
        public
        view
        returns (uint256)
    {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(_totalSupply)
                    .mul(2)
                    .div(3)
            );
    }

    function actualEarned(
        address account
    )
        internal
        view
        returns (uint256)
    {
        return _balances[account]
            .mul(actualRewardPerToken().sub(userRewardPerTokenPaid[account]))
            .div(1e18)
            .add(rewards[account]);
    }

    function earned(
        address account
    )
        public
        view
        returns (uint256)
    {
        return _balances[account]
            .mul(actualRewardPerToken().sub(userRewardPerTokenPaid[account]))
            .div(1e18)
            .add(rewards[account])
            .mul(2)
            .div(3);
    }

    function getRewardForDuration()
        public
        view
        returns (uint256)
    {
        return rewardRate.mul(rewardsDuration);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(
        uint256 amount
    )
        public
        updateReward(msg.sender)
    {
        require(
            amount > 0,
            "Cannot stake 0"
        );

        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);

        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount);
    }

    function withdraw(
        uint256 amount
    )
        public
        updateReward(msg.sender)
    {
        require(
            amount > 0,
            "Cannot withdraw 0"
        );

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);

        stakingToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    function getReward()
        public
        updateReward(msg.sender)
    {
        uint256 reward = rewards[msg.sender];

        if (reward > 0) {
            rewards[msg.sender] = 0;

            rewardsToken.safeTransfer(msg.sender, reward.mul(2).div(3));
            rewardsToken.safeTransfer(arcDAO, reward.sub(reward.mul(2).div(3)));

            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit() external {
        withdraw(_balances[msg.sender]);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function notifyRewardAmount(
        uint256 reward
    )
        external
        onlyRewardsDistribution
        updateReward(address(0))
    {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(rewardsDuration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint balance = rewardsToken.balanceOf(address(this));
        require(
            rewardRate <= balance.div(rewardsDuration),
            "Provided reward too high"
        );

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
    }

    // Added to support recovering LP Rewards from other systems to be distributed to holders
    function recoverERC20(
        address tokenAddress,
        uint256 tokenAmount
    )
        public
        onlyOwner
    {
        // Cannot recover the staking token or the rewards token
        require(
            tokenAddress != address(stakingToken) && tokenAddress != address(rewardsToken),
            "Cannot withdraw the staking or rewards tokens"
        );

        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setRewardsDuration(
        uint256 _rewardsDuration
    )
        external
        onlyOwner
    {
        require(
            periodFinish == 0 || block.timestamp > periodFinish,
            "Prev period must be complete before changing duration for new period"
        );
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }
}


// SPDX-License-Identifier: MIT
// Modified from https://github.com/iearn-finance/audit/blob/master/contracts/yGov/YearnGovernanceBPT.sol


/**
 * @title Accrual is an abstract contract which allows users of some
 *        distribution to claim a portion of tokens based on their share.
 */
contract Accrual {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public accrualToken;

    uint256 public accruedIndex = 0; // previously accumulated index
    uint256 public accruedBalance = 0; // previous calculated balance

    mapping(address => uint256) public supplyIndex;

    constructor(
        address _accrualToken
    )
        public
    {
        accrualToken = IERC20(_accrualToken);
    }

    function getUserBalance(
        address owner
    )
        public
        view
        returns (uint256);

    function getTotalBalance()
        public
        view
        returns (uint256);

    function updateFees()
        public
    {
        if (getTotalBalance() == 0) {
            return;
        }

        uint256 contractBalance = accrualToken.balanceOf(address(this));

        if (contractBalance == 0) {
            return;
        }

        // Find the difference since the last balance stored in the contract
        uint256 difference = contractBalance.sub(accruedBalance);

        if (difference == 0) {
            return;
        }

        // Use the difference to calculate a ratio
        uint256 ratio = difference.mul(1e18).div(getTotalBalance());

        if (ratio == 0) {
            return;
        }

        // Update the index by adding the existing index to the ratio index
        accruedIndex = accruedIndex.add(ratio);

        // Update the accrued balance
        accruedBalance = contractBalance;
    }

    function claimFees()
        public
    {
        claimFor(msg.sender);
    }

    function claimFor(
        address recipient
    )
        public
    {
        updateFees();

        uint256 userBalance = getUserBalance(recipient);

        if (userBalance == 0) {
            supplyIndex[recipient] = accruedIndex;
            return;
        }

        // Store the existing user's index before updating it
        uint256 existingIndex = supplyIndex[recipient];

        // Update the user's index to the current one
        supplyIndex[recipient] = accruedIndex;

        // Calculate the difference between the current index and the old one
        // The difference here is what the user will be able to claim against
        uint256 delta = accruedIndex.sub(existingIndex);

        require(
            delta > 0,
            "TokenAccrual: no tokens available to claim"
        );

        // Get the user's current balance and multiply with their index delta
        uint256 share = userBalance.mul(delta).div(1e18);

        // Transfer the tokens to the user
        accrualToken.safeTransfer(recipient, share);

        // Update the accrued balance
        accruedBalance = accrualToken.balanceOf(address(this));
    }

}

// SPDX-License-Identifier: MIT


contract StakingRewardsAccrual is StakingRewards, Accrual {

    constructor(
        address _arcDAO,
        address _rewardsDistribution,
        address _rewardsToken,
        address _stakingToken,
        address _feesToken
    )
        public
        StakingRewards(
            _arcDAO,
            _rewardsDistribution,
            _rewardsToken,
            _stakingToken
        )
        Accrual(
            _feesToken
        )
    {}

    function getUserBalance(
        address owner
    )
        public
        view
        returns (uint256)
    {
        return balanceOf(owner);
    }

    function getTotalBalance()
        public
        view
        returns (uint256)
    {
        return totalSupply();
    }

}




// SPDX-License-Identifier: MIT


contract StakingRewardsAccrualCapped is StakingRewardsAccrual {

    /* ========== Variables ========== */

    uint256 public hardCap;

    bool public tokensClaimable;

    mapping (address => bool) public kyfInstances;

    address[] public kyfInstancesArray;

    /* ========== Events ========== */

    event HardCapSet(uint256 _cap);

    event KyfStatusUpdated(address _address, bool _status);

    event ClaimableStatusUpdated(bool _status);

    /* ========== Constructor ========== */

    constructor(
        address _arcDAO,
        address _rewardsDistribution,
        address _rewardsToken,
        address _stakingToken,
        address _feesToken
    )
        public
        StakingRewardsAccrual(
            _arcDAO,
            _rewardsDistribution,
            _rewardsToken,
            _stakingToken,
            _feesToken
        )
    {

    }

    /* ========== Public View Functions ========== */

    function getApprovedKyfInstancesArray()
        public
        view
        returns (address[] memory)
    {
        return kyfInstancesArray;
    }

    function isVerified(
        address _user
    )
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i < kyfInstancesArray.length; i++) {
            IKYFV2 kyfContract = IKYFV2(kyfInstancesArray[i]);
            if (kyfContract.checkVerified(_user) == true) {
                return true;
            }
        }

        return false;
    }

    /* ========== Admin Functions ========== */

    function setStakeHardCap(
        uint256 _hardCap
    )
        public
        onlyOwner
    {
        hardCap = _hardCap;

        emit HardCapSet(_hardCap);
    }

    function setTokensClaimable(
        bool _enabled
    )
        public
        onlyOwner
    {
        tokensClaimable = _enabled;

        emit ClaimableStatusUpdated(_enabled);
    }

    function setApprovedKYFInstance(
        address _kyfContract,
        bool _status
    )
        public
        onlyOwner
    {
        if (_status == true) {
            kyfInstancesArray.push(_kyfContract);
            kyfInstances[_kyfContract] = true;
            emit KyfStatusUpdated(_kyfContract, true);
            return;
        }

        // Remove the kyfContract from the kyfInstancesArray array.
        for (uint i = 0; i < kyfInstancesArray.length; i++) {
            if (address(kyfInstancesArray[i]) == _kyfContract) {
                delete kyfInstancesArray[i];
                kyfInstancesArray[i] = kyfInstancesArray[kyfInstancesArray.length - 1];

                // Decrease the size of the array by one.
                kyfInstancesArray.length--;
                break;
            }
        }

        // And remove it from the synths mapping
        delete kyfInstances[_kyfContract];
        emit KyfStatusUpdated(_kyfContract, false);
    }

    /* ========== Public Functions ========== */

    function stake(
        uint256 _amount
    )
        public
        updateReward(msg.sender)
    {
        uint256 totalBalance = balanceOf(msg.sender).add(_amount);

        require(
            totalBalance <= hardCap,
            "Cannot stake more than the hard cap"
        );

        require(
            isVerified(msg.sender) == true,
            "Must be KYF registered to participate"
        );

        super.stake(_amount);
    }

    function getReward()
        public
        updateReward(msg.sender)
    {
        require(
            tokensClaimable == true,
            "Tokens cannnot be claimed yet"
        );

        super.getReward();
    }

}