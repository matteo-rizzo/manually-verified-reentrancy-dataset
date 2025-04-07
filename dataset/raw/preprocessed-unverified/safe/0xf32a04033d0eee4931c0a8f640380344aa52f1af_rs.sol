/**
 *Submitted for verification at Etherscan.io on 2021-02-06
*/

// SPDX-License-Identifier: -- ðŸ’° --

pragma solidity ^0.7.5;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Generic SafeMath Library, can be removed if the
 * contract will be rewritten to ^0.8.0 Solidity compiler
 */


/**
 * @dev Standard math utilities missing in the Solidity language.
 */


/*
 * @dev Context for msg.sender and msg.data can be removed
 * used in Ownable to determine msg.sender through _msgSender();
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(
            address(0),
            _owner
        );
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
        require(
            isOwner(),
            'Ownable: caller is not the owner'
        );
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
        emit OwnershipTransferred(
            _owner,
            address(0x0)
        );
        _owner = address(0x0);
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
        require(
            newOwner != address(0x0),
            'Ownable: new owner is the zero address'
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
 */


/**
 * @title LPTokenWrapper
 * @dev Wraps around ERC20 that is represented as Liquidity token
 * contract and is being distributed for providing liquidity for the pair.
 * This token is the staking token in this system / contract.
 */
contract LPTokenWrapper {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ONBOARDING: Specify Liquidity Token Address
    IERC20 public uni = IERC20(
        0xB6E544c3e420154C2C663f14eDAd92737d7FbdE5
    );

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    /**
     * @dev Returns total supply of staked token
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns balance of specific user
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev internal function for staking LP tokens
     */
    function _stake(uint256 amount) internal {

        _totalSupply = _totalSupply.add(amount);

        _balances[msg.sender] =
        _balances[msg.sender].add(amount);

        uni.safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
    }

    /**
     * @dev internal function for withdrwaing LP tokens
     */
    function _withdraw(uint256 amount) internal {

        _totalSupply = _totalSupply.sub(amount);

        _balances[msg.sender] =
        _balances[msg.sender].sub(amount);

        uni.safeTransfer(
            msg.sender,
            amount
        );
    }
}

contract FeyLPStaking is LPTokenWrapper, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ONBOARDING: Specify Reward Token Address (FEY)
    IERC20 public fey = IERC20(
        0xe8E06a5613dC86D459bC8Fb989e173bB8b256072
    );

    // ONBOARDING: Specify duration of single cycle for the reward distribution
    // reward distribution should be announced through {notifyRewardAmount} call
    uint256 public constant DURATION = 52 weeks;

    uint256 public periodFinish;
    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(
        uint256 reward
    );

    event Staked(
        address indexed user,
        uint256 amount
    );

    event Withdrawn(
        address indexed user,
        uint256 amount
    );

    event RewardPaid(
        address indexed user,
        uint256 reward
    );

    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();

        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /**
     * @dev Checks when last time the reward
     * was changed based on when the distribution
     * is about to be finished
     */
    function lastTimeRewardApplicable()
        public
        view
        returns (uint256)
    {
        return Math.min(
            block.timestamp,
            periodFinish
        );
    }

    /**
     * @dev Determines the ratio of reward per each token
     * stakd so the relative value can be calculated
     */
    function rewardPerToken()
        public
        view
        returns (uint256)
    {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }

        return rewardPerTokenStored.add(
            lastTimeRewardApplicable()
                .sub(lastUpdateTime)
                .mul(rewardRate)
                .mul(1e18)
                .div(totalSupply())
        );
    }

    /**
     * @dev Returns amount of tokens specific address or
     * staker has earned so far based on his stake and time
     * the stake been active so far.
     */
    function earned(
        address account
    )
        public
        view
        returns (uint256)
    {
        return balanceOf(account)
            .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
            .div(1E18)
            .add(rewards[account]);
    }

    /**
     * @dev Ability to stake liquidity tokens
     */
    function stake(
        uint256 amount
    )
        public
        updateReward(msg.sender)
    {
        require(
            amount > 0,
            'Cannot stake 0'
        );

        _stake(amount);

        emit Staked(
            msg.sender,
            amount
        );
    }

    /**
     * @dev Ability to withdraw liquidity tokens
     */
    function withdraw(
        uint256 amount
    )
        public
        updateReward(msg.sender)
    {
        require(
            amount > 0,
            'Cannot withdraw 0'
        );

        _withdraw(amount);

        emit Withdrawn(
            msg.sender,
            amount
        );
    }

    /**
     * @dev allows to withdraw staked tokens
     *
     * withdraws all staked tokens by user
     * also withdraws rewards as user exits
     */
    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    /**
     * @dev allows to withdraw staked tokens
     *
     * withdraws all staked tokens by user
     * also withdraws rewards as user exits
     */
    function getReward()
        public
        updateReward(msg.sender)
        returns (uint256 reward)
    {
        reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            fey.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    /**
     * @dev Starts the distribution
     *
     * This must be called to start the distribution cycle
     * and allow stakers to start earning rewards
     */
    function notifyRewardAmount(uint256 reward)
        external
        onlyOwner
        updateReward(address(0x0))
    {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(DURATION);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(DURATION);
        }
        uint256 balance = fey.balanceOf(address(this));
        require(
            rewardRate <= balance.div(DURATION),
            'Provided reward too high'
        );
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(DURATION);
        emit RewardAdded(reward);
    }
}