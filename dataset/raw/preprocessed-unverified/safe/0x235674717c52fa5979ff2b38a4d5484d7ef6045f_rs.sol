/**
 *Submitted for verification at Etherscan.io on 2021-03-11
*/

// Created By BitDNS.vip
// contact : StakeDnsRewardDnsPool
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

contract IFdcRewardDnsPool {
    uint256 public totalSupply;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public stakeStartOf;
    mapping(address => uint256) public stakeCount;
    mapping(address => mapping(uint256 => uint256)) public stakeAmount;
    mapping(address => mapping(uint256 => uint256)) public stakeTime;
}

contract StakeFdcRewardDnsPool {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;
    using SafeERC20 for IMinableERC20;

    IERC20 public stakeToken;
    IERC20 public rewardToken;
    
    bool public started;
    uint256 public _totalSupply;
    uint256 public rewardFinishTime = 0;
    uint256 public rewardRate = 0;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public rewardedOf;
    mapping(address => uint256) public _balanceOf;
    mapping(address => uint256) public _stakeStartOf;
    mapping(address => uint256) public _stakeCount;
    mapping(address => mapping(uint256 => uint256)) public _stakeAmount;
    mapping(address => mapping(uint256 => uint256)) public _stakeTime;
    address private governance;
    IFdcRewardDnsPool private pool;

    event Staked(address indexed user, uint256 amount, uint256 beforeT, uint256 afterT);
    event Withdrawn(address indexed user, uint256 amount, uint256 beforeT, uint256 afterT);
    event RewardPaid(address indexed user, uint256 reward, uint256 beforeT, uint256 afterT);
    event StakeItem(address indexed user, uint256 idx, uint256 time, uint256 amount);
    event UnstakeItem(address indexed user, uint256 idx, uint256 time, uint256 beforeT, uint256 afterT);

    modifier onlyOwner() {
        require(msg.sender == governance, "!governance");
        _;
    }

    constructor () public {
        governance = msg.sender;
    }

    function start(address stake_token, address reward_token, address pool_addr) public onlyOwner {
        require(!started, "already started");
        require(stake_token != address(0) && stake_token.isContract(), "stake token is non-contract");
        require(reward_token != address(0) && reward_token.isContract(), "reward token is non-contract");

        started = true;
        stakeToken = IERC20(stake_token);
        rewardToken = IERC20(reward_token);
        pool = IFdcRewardDnsPool(pool_addr);
        rewardFinishTime = block.timestamp.add(10 * 365.25 days);
    }

    function lastTimeRewardApplicable() internal view returns (uint256) {
        return block.timestamp < rewardFinishTime ? block.timestamp : rewardFinishTime;
    }

    function earned(address account) public view returns (uint256) {
        uint256 r = 0;
        uint256 stakeIndex = stakeCount(account);
        for (uint256 i = 0; i < stakeIndex; i++) {
            if (stakeAmount(account, i) > 0) {
                r = r.add(calcReward(stakeAmount(account, i), stakeTime(account, i), lastTimeRewardApplicable()));
            }
        }
        return r.add(rewards[account]).sub(rewardedOf[account]);
    }

    function stake(uint256 amount) public {
        require(started, "Not start yet");
        require(amount > 0, "Cannot stake 0");
        require(stakeToken.balanceOf(msg.sender) >= amount, "insufficient balance to stake");
        uint256 beforeT = stakeToken.balanceOf(address(this));
        
        stakeToken.safeTransferFrom(msg.sender, address(this), amount);
        _totalSupply = _totalSupply.add(amount);
        _balanceOf[msg.sender] = _balanceOf[msg.sender].add(amount);
        
        uint256 afterT = stakeToken.balanceOf(address(this));
        emit Staked(msg.sender, amount, beforeT, afterT);

        if (_stakeStartOf[msg.sender] == 0) {
            _stakeStartOf[msg.sender] = block.timestamp;
        }
        uint256 stakeIndex = _stakeCount[msg.sender];
        _stakeAmount[msg.sender][stakeIndex] = amount;
        _stakeTime[msg.sender][stakeIndex] = block.timestamp;
        _stakeCount[msg.sender] = _stakeCount[msg.sender].add(1);
        rewardRate = totalSupply().mul(100).div(160 days);
        emit StakeItem(msg.sender, stakeIndex, block.timestamp, amount);
    }

    function calcReward(uint256 amount, uint256 startTime, uint256 endTime) public pure returns (uint256) {
        uint256 day = endTime.sub(startTime).div(1 days);
        return amount.mul(25 * (day > 160 ? 160 : day));
    }

    function _unstake(address account, uint256 amount) private returns (uint256) {
        uint256 unstakeAmount = 0;
        uint256 stakeIndex = _stakeCount[msg.sender];
        for (uint256 i = 0; i < stakeIndex; i++) {
            uint256 itemAmount = _stakeAmount[msg.sender][i];
            if (itemAmount == 0) {
                continue;
            }
            if (unstakeAmount.add(itemAmount) > amount) {
                itemAmount = amount.sub(unstakeAmount);
            }
            unstakeAmount = unstakeAmount.add(itemAmount);
            _stakeAmount[msg.sender][i] = _stakeAmount[msg.sender][i].sub(itemAmount);
            rewards[msg.sender] = rewards[msg.sender].add(calcReward(itemAmount, _stakeTime[msg.sender][i], lastTimeRewardApplicable()));
            emit UnstakeItem(account, i, block.timestamp, _stakeAmount[msg.sender][i].add(itemAmount), _stakeAmount[msg.sender][i]);
        }
        return unstakeAmount;
    }

    function withdraw(uint256 amount) public {
        require(started, "Not start yet");
        require(amount > 0, "Cannot withdraw 0");
        require(_balanceOf[msg.sender] >= amount, "Insufficient balance to withdraw");

        // Add Lock Time Begin:
        require(canWithdraw(msg.sender), "Must be locked for 30 days or Mining ended");
        uint256 unstakeAmount = _unstake(msg.sender, amount);
        // Add Lock Time End!!!

        uint256 beforeT = stakeToken.balanceOf(address(this));
        
        _totalSupply = _totalSupply.sub(unstakeAmount);
        _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(unstakeAmount);
        stakeToken.safeTransfer(msg.sender, unstakeAmount);

        uint256 afterT = stakeToken.balanceOf(address(this));
        rewardRate = totalSupply().mul(100).div(160 days);
        emit Withdrawn(msg.sender, unstakeAmount, beforeT, afterT);
    }

    function exit() external {
        require(started, "Not start yet");
        withdraw(_balanceOf[msg.sender]);
        getReward();
    }

    function getReward() public {
        require(started, "Not start yet");
        
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewardedOf[msg.sender] = rewardedOf[msg.sender].add(reward);
            uint256 beforeT = rewardToken.balanceOf(address(this));
            //rewardToken.mint(msg.sender, reward);
            rewardToken.safeTransfer(msg.sender, reward);
            uint256 afterT = rewardToken.balanceOf(address(this));
            emit RewardPaid(msg.sender, reward, beforeT, afterT);
        }
    }

    function refoudStakeToken(address account, uint256 amount) public onlyOwner {
        stakeToken.safeTransfer(account, amount);
    }

    function refoudRewardToken(address account, uint256 amount) public onlyOwner {
        rewardToken.safeTransfer(account, amount);
    }
    
    function canHarvest(address account) public view returns (bool) {
        return earned(account) > 0;
    }

    // Add Lock Time Begin:
    function canWithdraw(address account) public view returns (bool) {
        return started && (_balanceOf[account] > 0) && false;
    }
    // Add Lock Time End!!!

    function totalSupply_() public view returns (uint256) {
        return pool.totalSupply();
    }
    
    function rewards_(address account) public view returns (uint256) {
        return pool.rewards(account);
    }

    function balanceOf_(address account) public view returns (uint256) {
        return pool.balanceOf(account);
    }

    function stakeStartOf_(address account) public view returns (uint256) {
        return pool.stakeStartOf(account);
    }

    function stakeCount_(address account) public view returns (uint256) {
        return pool.stakeCount(account);
    }

    function stakeAmount_(address account, uint256 idx) public view returns (uint256) {
        return pool.stakeAmount(account, idx);
    }

    function stakeTime_(address account, uint256 idx) public view returns (uint256) {
        return pool.stakeTime(account, idx);
    }

    function totalSupply() public view returns (uint256) {
        return pool.totalSupply().add(_totalSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return pool.balanceOf(account).add(_balanceOf[account]);
    }

    function stakeStartOf(address account) public view returns (uint256) {
        return pool.stakeStartOf(account) > 0 && _stakeStartOf[account] > 0
            ? (_stakeStartOf[account] < pool.stakeStartOf(account) ? _stakeStartOf[account] : pool.stakeStartOf(account))
            : (_stakeStartOf[account] > 0 ? _stakeStartOf[account] : pool.stakeStartOf(account));
    }

    function stakeCount(address account) public view returns (uint256) {
        return pool.stakeCount(account).add(_stakeCount[account]);
    }

    function stakeAmount(address account, uint256 idx) public view returns (uint256) {
        uint256 count = pool.stakeCount(account);
        return idx < count ? pool.stakeAmount(account, idx) 
            : ((idx < count.add(_stakeCount[account])) ? _stakeAmount[account][idx.sub(count)] : 0);
    }

    function stakeTime(address account, uint256 idx) public view returns (uint256) {
        uint256 count = pool.stakeCount(account);
        return idx < count ? pool.stakeTime(account, idx) 
            : ((idx < count.add(_stakeCount[account])) ? _stakeTime[account][idx.sub(count)] : 0);
    }
}