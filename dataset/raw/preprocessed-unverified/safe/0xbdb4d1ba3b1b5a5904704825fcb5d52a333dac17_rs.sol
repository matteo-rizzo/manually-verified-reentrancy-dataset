// Created By BitDNS.vip
// contact : Reward Pool
// SPDX-License-Identifier: MIT

pragma solidity ^0.5.8;

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
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */




contract IMinableERC20 is IERC20 {
    function mint(address account, uint amount) public;
}

contract USDTPool {
    using SafeMath for uint256;
    using Address for address;
    using SafeUSDT for IUSDT;
    using SafeERC20 for IMinableERC20;

    IUSDT public stakeToken;
    IMinableERC20 public rewardToken;
    
    bool public started;
    uint256 public totalSupply;
    uint256 public rewardFinishTime = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public balanceOf;
    address private governance;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount, uint256 beforeT, uint256 afterT);
    event Withdrawn(address indexed user, uint256 amount, uint256 beforeT, uint256 afterT);
    event RewardPaid(address indexed user, uint256 reward, uint256 beforeT, uint256 afterT);

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == governance, "!governance");
        _;
    }

    constructor () public {
        governance = msg.sender;
    }

    function start(address stake_token, address reward_token, uint256 reward, uint256 duration) public onlyOwner {
        require(!started, "already started");
        require(stake_token != address(0) && stake_token.isContract(), "stake token is non-contract");
        require(reward_token != address(0) && reward_token.isContract(), "reward token is non-contract");

        started = true;
        stakeToken = IUSDT(stake_token);
        rewardToken = IMinableERC20(reward_token);
        rewardRate = reward.mul(1e18).div(duration);
        lastUpdateTime = block.timestamp;
        rewardFinishTime = block.timestamp.add(duration);
    }

    function lastTimeRewardApplicable() internal view returns (uint256) {
        return block.timestamp < rewardFinishTime ? block.timestamp : rewardFinishTime;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable()
            .sub(lastUpdateTime)
            .mul(rewardRate)
            .mul(1e18)
            .div(totalSupply)
        );
    }

    function earned(address account) public view returns (uint256) {
        return
        balanceOf[account]
        .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
        .div(1e18)
        .add(rewards[account]);
    }

    function stake(uint256 amount) public updateReward(msg.sender) {
        require(started, "Not start yet");
        require(amount > 0, "Cannot stake 0");
        require(stakeToken.balanceOf(msg.sender) >= amount, "insufficient balance to stake");
        uint256 beforeT = stakeToken.balanceOf(address(this));
        
        stakeToken.safeTransferFrom(msg.sender, address(this), amount);
        totalSupply = totalSupply.add(amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        
        uint256 afterT = stakeToken.balanceOf(address(this));
        emit Staked(msg.sender, amount, beforeT, afterT);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {
        require(started, "Not start yet");
        require(amount > 0, "Cannot withdraw 0");
        require(balanceOf[msg.sender] >= amount, "insufficient balance to withdraw");
        uint256 beforeT = stakeToken.balanceOf(address(this));
        
        totalSupply = totalSupply.sub(amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount);
        stakeToken.safeTransfer(msg.sender, amount);

        uint256 afterT = stakeToken.balanceOf(address(this));
        emit Withdrawn(msg.sender, amount, beforeT, afterT);
    }

    function exit() external {
        require(started, "Not start yet");
        withdraw(balanceOf[msg.sender]);
        getReward();
    }

    function getReward() public updateReward(msg.sender) {
        require(started, "Not start yet");
        
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            uint256 beforeT = rewardToken.balanceOf(address(this));
            rewardToken.mint(msg.sender, reward);
            //rewardToken.safeTransfer(msg.sender, reward);
            uint256 afterT = rewardToken.balanceOf(address(this));
            emit RewardPaid(msg.sender, reward, beforeT, afterT);
        }
    }
}