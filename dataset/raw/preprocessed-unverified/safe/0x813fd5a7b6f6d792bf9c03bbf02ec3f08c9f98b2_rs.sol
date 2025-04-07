//SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/ownership/Ownable.sol

pragma solidity ^0.7.1;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */


// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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


// File: contracts/CurveRewards.sol

contract LPTokenWrapper {
    uint256 public totalSupply;
    IERC20 public uniswapDonutEth = IERC20(0x718Dd8B743ea19d71BDb4Cb48BB984b73a65cE06);

    mapping(address => uint256) private _balances;
    
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint128 amount) public virtual {
        require(uniswapDonutEth.transferFrom(msg.sender, address(this), amount), "DONUT-ETH transfer failed");
        totalSupply += amount;
        _balances[msg.sender] += amount;
        emit Staked(msg.sender, amount);
    }

    function withdraw() public virtual {
        uint256 amount = balanceOf(msg.sender);
        _balances[msg.sender] = 0;
        totalSupply = totalSupply-amount;
        require(uniswapDonutEth.transfer(msg.sender, amount), "DONUT-ETH transfer failed");
        emit Withdrawn(msg.sender, amount);
    }
}

contract DonutUniswapRewards is LPTokenWrapper, Ownable {
    using SafeERC20 for IERC20;
    IERC20 public donut = IERC20(0xC0F9bD5Fa5698B6505F643900FFA515Ea5dF54A9);

    uint256 public rewardRate;
    uint64 public periodFinish;
    uint64 public lastUpdateTime;
    uint128 public rewardPerTokenStored;
    struct UserRewards {
        uint128 userRewardPerTokenPaid;
        uint128 rewards;
    }
    mapping(address => UserRewards) public userRewards;

    event RewardAdded(uint256 reward);
    event RewardPaid(address indexed user, uint256 reward);

    modifier updateReward(address account) {
        uint128 _rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        rewardPerTokenStored = _rewardPerTokenStored;
        userRewards[account].rewards = earned(account);
        userRewards[account].userRewardPerTokenPaid = _rewardPerTokenStored;
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint64) {
        uint64 blockTimestamp = uint64(block.timestamp);
        return blockTimestamp < periodFinish ? blockTimestamp : periodFinish;
    }

    function rewardPerToken() public view returns (uint128) {
        uint256 totalStakedSupply = totalSupply;
        if (totalStakedSupply == 0) {
            return rewardPerTokenStored;
        }
        uint256 rewardDuration = lastTimeRewardApplicable()-lastUpdateTime;
        return uint128(rewardPerTokenStored + rewardDuration*rewardRate*1e18/totalStakedSupply);
    }

    function earned(address account) public view returns (uint128) {
        return uint128(balanceOf(account)*(rewardPerToken()-userRewards[account].userRewardPerTokenPaid)/1e18 + userRewards[account].rewards);
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint128 amount) public override updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
    }

    function withdraw() public override updateReward(msg.sender) {
        super.withdraw();
    }

    function exit() external {
        withdraw();
        getReward();
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            userRewards[msg.sender].rewards = 0;
            require(donut.transfer(msg.sender, reward), "DONUT transfer failed");
            emit RewardPaid(msg.sender, reward);
        }
    }

    function setRewardParams(uint128 reward, uint64 duration) external onlyOwner {
        rewardPerTokenStored = rewardPerToken();
        uint64 blockTimestamp = uint64(block.timestamp);
        if (blockTimestamp >= periodFinish) {
            rewardRate = reward/duration;
        } else {
            uint256 remaining = periodFinish-blockTimestamp;
            uint256 leftover = remaining*rewardRate;
            rewardRate = (reward+leftover)/duration;
        }
        lastUpdateTime = blockTimestamp;
        periodFinish = blockTimestamp+duration;
        emit RewardAdded(reward);
    }
    
    /* to be used if users vote to stop the incentive program,
    also to withdraw possible airdrops and mistakenly sent uni tokens
    can't touch staked uniswap LP tokens */
    function recoverTokens(IERC20 token) external onlyOwner {
        if(token == uniswapDonutEth) {
            //unstaked balance - tokens sent directly to the contract address rather than staked
            //totalSupply always <= uniswapDonutEth.balanceOf(address(this)), no overflow possible
            uint256 unstakedSupply = uniswapDonutEth.balanceOf(address(this))-totalSupply;
            require(unstakedSupply > 0 && uniswapDonutEth.transfer(msg.sender, unstakedSupply));
        }
        else {
            uint256 tokenBalance = token.balanceOf(address(this));
            require(tokenBalance > 0);
            token.safeTransfer(msg.sender, tokenBalance);
        }
    }
}

/*
   ____            __   __        __   _
  / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
 _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
/___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
     /___/

* Synthetix: YFIRewards.sol
*
* Docs: https://docs.synthetix.io/
*
*
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
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