/**
 *Submitted for verification at Etherscan.io on 2021-09-15
*/

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
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


contract StakingPool {
    using Address for address;
    using SafeERC20 for IERC20;

    bool public stakingOpen = false;

    uint256 public duration;
    address public owner;
    address public rewardToken;
    address public depositToken;

    uint256 public finishTimestamp = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTimestamp;
    uint256 public cacheRewardPerToken;
    mapping(address => uint256) public userReward;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 rewardAmount);
    event Staked(address indexed who, uint256 amount);
    event Withdraw(address indexed who, uint256 amount);
    event GotReward(address indexed who, uint256 rewardAmount);

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Authorized");
        _;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    modifier updateReward(address account) {
        cacheRewardPerToken = rewardPerToken();
        lastUpdateTimestamp = lastTimeRewardApplicable();
        if(account != address(0)) {
            rewards[account] = earned(account);
            userReward[account] = cacheRewardPerToken;
        }
        _;
    }

    modifier canStake() {
        require(stakingOpen == true, "Staking is not open!");
        _;
    }

    constructor(
        address _rewardToken,
        address _depositToken,
        uint256 _stakingDurationRewardPay
    ) public {
        rewardToken = _rewardToken;
        depositToken = _depositToken;
        duration = _stakingDurationRewardPay;
        owner = msg.sender;
    }

    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function openStaking(bool _newStakeStatus) external onlyOwner {
        stakingOpen = _newStakeStatus;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        if (block.timestamp <= finishTimestamp) {
            return block.timestamp;
        } else {
            return finishTimestamp;
        }
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return cacheRewardPerToken;
        }
        return
            cacheRewardPerToken + ((lastTimeRewardApplicable() - lastUpdateTimestamp) * rewardRate * 1e18 / totalSupply());
    }

    function earned(address account) public view returns (uint256) {
        return (balanceOf(account) * (rewardPerToken() - userReward[account]) / 1e18) + rewards[account];
    }

    function stake(uint256 amount) public updateReward(msg.sender) canStake {
        require(amount > 0, "Amount cannot be 0");
        IERC20(depositToken).safeTransferFrom(msg.sender, address(this), amount);
        _totalSupply = _totalSupply + amount;
        _balances[msg.sender] = _balances[msg.sender] + amount;
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {
        require(amount > 0, "Amount cannot be 0");
        require(_balances[msg.sender] >= amount, "Withdraw overflow");
        _totalSupply = _totalSupply - amount;
        _balances[msg.sender] = _balances[msg.sender] - amount;
        IERC20(depositToken).safeTransfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = earned(msg.sender);
        if (address(depositToken) == address(rewardToken)) {
            uint256 _tokenBal = IERC20(depositToken).balanceOf(address(this));
            require(_tokenBal - reward >= _totalSupply, "Extra security check failed.");
        }
        if (reward > 0) {
            rewards[msg.sender] = 0;
            IERC20(rewardToken).safeTransfer(msg.sender, reward);
            emit GotReward(msg.sender, reward);
        }
    }

    function pushReward(address recipient) public updateReward(recipient) onlyOwner {
        uint256 reward = earned(recipient);
        if (reward > 0) {
            rewards[recipient] = 0;
            IERC20(rewardToken).safeTransfer(recipient, reward);
            emit GotReward(recipient, reward);
        }
    }

    function addedReward(uint256 reward) external onlyOwner updateReward(address(0)) {
        if (block.timestamp >= finishTimestamp) {
            rewardRate = reward / duration;
        } else {
            uint256 remaining = finishTimestamp - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardRate = (reward + leftover) / duration;
        }
        lastUpdateTimestamp = block.timestamp;
        finishTimestamp = block.timestamp + duration;
        emit RewardAdded(reward);
    }

}