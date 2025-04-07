// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

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
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


contract Context {
    constructor () internal {}
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}











contract YFVGovernanceVault {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IFreeFromUpTo public constant chi = IFreeFromUpTo(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    modifier discountCHI {
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
        chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41130);
    }

    IERC20 public yfv; // stake token
    IERC20 public value; // reward token
    IERC20 public vUSD; // reward token
    IERC20 public vETH; // reward token

    uint256 public fundCap = 9500; // use up to 95% of fund (to keep small withdrawals cheap)
    uint256 public constant FUND_CAP_DENOMINATOR = 10000;

    uint256 public earnLowerlimit;

    address public governance;
    address public controller;
    address public rewardReferral;

    struct Staker {
        uint256 stake;
        uint256 payout;
        uint256 total_out;
    }

    mapping(address => Staker) public stakers; // stakerAddress -> staker's info

    struct Global {
        uint256 total_stake;
        uint256 total_out;
        uint256 earnings_per_share;
    }

    Global public global; // global data
    uint256 constant internal magnitude = 10 ** 40;

    string public getName;

    uint256 public vETH_REWARD_FRACTION_RATE = 1000;

    uint256 public constant DURATION = 7 days;
    uint8 public constant NUMBER_EPOCHS = 36;

    uint256 public constant REFERRAL_COMMISSION_PERCENT = 1;

    uint256 public currentEpochReward = 0;
    uint256 public totalAccumulatedReward = 0;
    uint8 public currentEpoch = 0;
    uint256 public starttime = 1598968800; // Tuesday, September 1, 2020 2:00:00 PM (GMT+0)
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public valueRewardRateMultipler = 0;
    bool public isOpened;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    uint256 public constant DEFAULT_EPOCH_REWARD = 230000 * (10 ** 9); // 230,000 vUSD (and 230 vETH)
    uint256 public constant TOTAL_REWARD = DEFAULT_EPOCH_REWARD * NUMBER_EPOCHS; // 8,740,000 vUSD (and 8,740 vETH)
    uint256 public constant DEFAULT_VALUE_EPOCH_REWARD = 23000 * (10 ** 18); // 23,000 VALUE

    uint256 public epochReward = DEFAULT_EPOCH_REWARD;
    uint256 public valueEpochReward = DEFAULT_VALUE_EPOCH_REWARD;
    uint256 public minStakingAmount = 0 ether;
    uint256 public unstakingFrozenTime = 40 hours;
    uint256 public minStakeTimeToClaimVaultReward = 24 hours;

    // ** unlockWithdrawFee = 1.92%: stakers will need to pay 1.92% (sent to insurance fund)of amount they want to withdraw if the coin still frozen
    uint256 public unlockWithdrawFee = 0; // per ten thousand (eg. 15 -> 0.15%)

    address public yfvInsuranceFund = 0xb7b2Ea8A1198368f950834875047aA7294A2bDAa; // set to Governance Multisig at start

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public lastStakeTimes;

    mapping(address => uint256) public accumulatedStakingPower; // will accumulate every time staker does getReward()

    event RewardAdded(uint256 reward);
    event YfvRewardAdded(uint256 reward);
    event Burned(uint256 reward);
    event Staked(address indexed user, uint256 amount, uint256 actualStakeAmount);
    event Withdrawn(address indexed user, uint256 amount, uint256 actualWithdrawAmount);
    event RewardPaid(address indexed user, uint256 reward);
    event CommissionPaid(address indexed user, uint256 reward);

    constructor (address _yfv, address _value, address _vUSD, address _vETH, uint256 _earnLowerlimit) public {
        yfv = IERC20(_yfv);
        value = IERC20(_value);
        vUSD = IERC20(_vUSD);
        vETH = IERC20(_vETH);
        getName = string(abi.encodePacked("YFV:GovVault:v2"));
        earnLowerlimit = _earnLowerlimit * 1e18;
        governance = msg.sender;
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function balance() public view returns (uint256) {
        uint256 bal = yfv.balanceOf(address(this));
        if (controller != address(0)) bal = bal.add(IController(controller).balanceOf(address(yfv)));
        return bal;
    }

    function setFundCap(uint256 _fundCap) external {
        require(msg.sender == governance, "!governance");
        fundCap = _fundCap;
    }

    function setController(address _controller) public {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }

    function setRewardReferral(address _rewardReferral) external {
        require(msg.sender == governance, "!governance");
        rewardReferral = _rewardReferral;
    }

    function setIsOpened(bool _isOpened) external {
        require(msg.sender == governance, "!governance");
        isOpened = _isOpened;
    }

    function setEarnLowerlimit(uint256 _earnLowerlimit) public {
        require(msg.sender == governance, "!governance");
        earnLowerlimit = _earnLowerlimit;
    }

    function setYfvInsuranceFund(address _yfvInsuranceFund) public {
        require(msg.sender == governance, "!governance");
        yfvInsuranceFund = _yfvInsuranceFund;
    }

    function setEpochReward(uint256 _epochReward) public {
        require(msg.sender == governance, "!governance");
        require(_epochReward <= DEFAULT_EPOCH_REWARD * 10, "Insane big _epochReward!"); // At most 10x only
        epochReward = _epochReward;
    }

    function setValueEpochReward(uint256 _valueEpochReward) public {
        require(msg.sender == governance, "!governance");
        valueEpochReward = _valueEpochReward;
    }

    function setMinStakingAmount(uint256 _minStakingAmount) public {
        require(msg.sender == governance, "!governance");
        minStakingAmount = _minStakingAmount;
    }

    function setUnstakingFrozenTime(uint256 _unstakingFrozenTime) public {
        require(msg.sender == governance, "!governance");
        unstakingFrozenTime = _unstakingFrozenTime;
    }

    function setUnlockWithdrawFee(uint256 _unlockWithdrawFee) public {
        require(msg.sender == governance, "!governance");
        require(_unlockWithdrawFee <= 1000, "Dont be too greedy"); // <= 10%
        unlockWithdrawFee = _unlockWithdrawFee;
    }

    function setMinStakeTimeToClaimVaultReward(uint256 _minStakeTimeToClaimVaultReward) public {
        require(msg.sender == governance, "!governance");
        minStakeTimeToClaimVaultReward = _minStakeTimeToClaimVaultReward;
    }

    // To upgrade vUSD contract (v1 is still experimental, we may need vUSDv2 with rebase() function working soon - then governance will call this upgrade)
    function upgradeVUSDContract(address _vUSDContract) public {
        require(msg.sender == governance, "!governance");
        vUSD = IERC20(_vUSDContract);
    }

    // To upgrade vETH contract (v1 is still experimental, we may need vETHv2 with rebase() function working soon - then governance will call this upgrade)
    function upgradeVETHContract(address _vETHContract) public {
        require(msg.sender == governance, "!governance");
        vETH = IERC20(_vETHContract);
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        if (block.timestamp < periodFinish) return block.timestamp;
        else return periodFinish;
    }

    function rewardPerToken() public view returns (uint256) {
        if (global.total_stake == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable()
            .sub(lastUpdateTime)
            .mul(rewardRate)
            .mul(1e18)
            .div(global.total_stake)
        );
    }

    // vUSD balance
    function earned(address account) public view returns (uint256) {
        uint256 calculatedEarned = stakers[account].stake
            .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
            .div(1e18)
            .add(rewards[account]);
        uint256 poolBalance = vUSD.balanceOf(address(this));
        // some rare case the reward can be slightly bigger than real number, we need to check against how much we have left in pool
        if (calculatedEarned > poolBalance) return poolBalance;
        return calculatedEarned;
    }

    function stakingPower(address account) public view returns (uint256) {
        return accumulatedStakingPower[account].add(earned(account));
    }

    function earnedVETH(address account) public view returns (uint256) {
        return earned(account).div(vETH_REWARD_FRACTION_RATE);
    }

    function earnedValue(address account) public view returns (uint256) {
        return earned(account).mul(valueRewardRateMultipler);
    }

    // Custom logic in here for how much the vault allows to be borrowed
    // Sets minimum required on-hand to keep small withdrawals cheap
    function available() public view returns (uint256) {
        return yfv.balanceOf(address(this)).mul(fundCap).div(FUND_CAP_DENOMINATOR);
    }

    function doHardWork() public discountCHI {
        if (controller != address(0)) {
            uint256 _amount = available();
            uint256 _accepted = IController(controller).maxAcceptAmount(address(yfv));
            if (_amount > _accepted) _amount = _accepted;
            if (_amount > 0) {
                yfv.safeTransfer(controller, _amount);
                IController(controller).doHardWork(address(yfv), _amount);
            }
        }
    }

    function stake(uint256 amount, address referrer) public discountCHI updateReward(msg.sender) checkNextEpoch {
        require(isOpened, "Pool is not opening to stake");
        yfv.safeTransferFrom(msg.sender, address(this), amount);
        stakers[msg.sender].stake = stakers[msg.sender].stake.add(amount);
        require(stakers[msg.sender].stake > minStakingAmount, "Cannot stake below minStakingAmount");

        if (global.earnings_per_share != 0) {
            stakers[msg.sender].payout = stakers[msg.sender].payout.add(
                global.earnings_per_share.mul(amount).sub(1).div(magnitude).add(1)
            );
        }
        global.total_stake = global.total_stake.add(amount);

        if (yfv.balanceOf(address(this)) > earnLowerlimit) {
            doHardWork();
        }

        lastStakeTimes[msg.sender] = block.timestamp;
        if (rewardReferral != address(0) && referrer != address(0)) {
            IYFVReferral(rewardReferral).setReferrer(msg.sender, referrer);
        }
    }

    function unfrozenStakeTime(address account) public view returns (uint256) {
        return lastStakeTimes[account] + unstakingFrozenTime;
    }

    // No rebalance implementation for lower fees and faster swaps
    function withdraw(uint256 amount) public discountCHI updateReward(msg.sender) checkNextEpoch {
        require(amount > 0, "Cannot withdraw 0");
        claim();
        require(amount <= stakers[msg.sender].stake, "!balance");
        uint256 actualWithdrawAmount = amount;

        // Check balance
        uint256 b = yfv.balanceOf(address(this));
        if (b < actualWithdrawAmount) {
            if (controller != address(0)) {
                uint256 _withdraw = actualWithdrawAmount.sub(b);
                IController(controller).withdraw(address(yfv), _withdraw);
                uint256 _after = yfv.balanceOf(address(this));
                uint256 _diff = _after.sub(b);
                if (_diff < _withdraw) {
                    actualWithdrawAmount = b.add(_diff);
                }
            } else {
                actualWithdrawAmount = b;
            }
        }

        stakers[msg.sender].payout = stakers[msg.sender].payout.sub(
            global.earnings_per_share.mul(amount).div(magnitude)
        );

        stakers[msg.sender].stake = stakers[msg.sender].stake.sub(amount);
        global.total_stake = global.total_stake.sub(amount);

        if (block.timestamp < unfrozenStakeTime(msg.sender)) {
            // if coin is still frozen and governance does not allow stakers to unstake before timer ends
            if (unlockWithdrawFee == 0) revert("Coin is still frozen");

            // otherwise withdrawFee will be calculated based on the rate
            uint256 withdrawFee = amount.mul(unlockWithdrawFee).div(10000);
            uint256 r = amount.sub(withdrawFee);
            if (actualWithdrawAmount > r) {
                withdrawFee = actualWithdrawAmount.sub(r);
                actualWithdrawAmount = r;
                if (yfvInsuranceFund != address(0)) { // send fee to insurance
                    safeTokenTransfer(yfv, yfvInsuranceFund, withdrawFee);
                    emit RewardPaid(yfvInsuranceFund, withdrawFee);
                } else { // or burn
                    yfv.burn(withdrawFee);
                    emit Burned(withdrawFee);
                }
            }
        }

        safeTokenTransfer(yfv, msg.sender, actualWithdrawAmount);
        emit Withdrawn(msg.sender, amount, actualWithdrawAmount);
    }

    function make_profit(uint256 amount) public discountCHI {
        require(amount > 0, "not 0");
        value.safeTransferFrom(msg.sender, address(this), amount);
        global.earnings_per_share = global.earnings_per_share.add(
            amount.mul(magnitude).div(global.total_stake)
        );
        global.total_out = global.total_out.add(amount);
    }

    function cal_out(address user) public view returns (uint256) {
        uint256 _cal = global.earnings_per_share.mul(stakers[user].stake).div(magnitude);
        if (_cal < stakers[user].payout) {
            return 0;
        } else {
            return _cal.sub(stakers[user].payout);
        }
    }

    function cal_out_pending(uint256 _pendingBalance, address user) public view returns (uint256) {
        uint256 _earnings_per_share = global.earnings_per_share.add(
            _pendingBalance.mul(magnitude).div(global.total_stake)
        );
        uint256 _cal = _earnings_per_share.mul(stakers[user].stake).div(magnitude);
        _cal = _cal.sub(cal_out(user));
        if (_cal < stakers[user].payout) {
            return 0;
        } else {
            return _cal.sub(stakers[user].payout);
        }
    }

    function claim() public discountCHI {
        uint256 out = cal_out(msg.sender);
        stakers[msg.sender].payout = global.earnings_per_share.mul(stakers[msg.sender].stake).div(magnitude);
        stakers[msg.sender].total_out = stakers[msg.sender].total_out.add(out);

        if (out > 0) {
            uint256 _stakeTime = now - lastStakeTimes[msg.sender];
            if (controller != address(0) && _stakeTime < minStakeTimeToClaimVaultReward) { // deposit in less than requirement
                uint256 actually_out = _stakeTime.mul(out).mul(1e18).div(minStakeTimeToClaimVaultReward).div(1e18);
                uint256 to_team = out.sub(actually_out);
                safeTokenTransfer(value, IController(controller).performanceReward(), to_team);
                out = actually_out;
            }
            safeTokenTransfer(value, msg.sender, out);
        }
    }

    function exit() external discountCHI {
        withdraw(stakers[msg.sender].stake);
        getReward();
    }

    function getReward() public discountCHI updateReward(msg.sender) checkNextEpoch {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            accumulatedStakingPower[msg.sender] = accumulatedStakingPower[msg.sender].add(rewards[msg.sender]);
            rewards[msg.sender] = 0;

            safeTokenTransfer(vUSD, msg.sender, reward);
            safeTokenTransfer(vETH, msg.sender, reward.div(vETH_REWARD_FRACTION_RATE));
            emit RewardPaid(msg.sender, reward);

            uint256 valueReward = reward.mul(valueRewardRateMultipler);
            uint256 actualValuePaid = valueReward.mul(100 - REFERRAL_COMMISSION_PERCENT).div(100); // 99%
            uint256 valueCommission = valueReward - actualValuePaid; // 1%

            safeTokenTransfer(value, msg.sender, actualValuePaid);

            address referrer = address(0);
            if (rewardReferral != address(0)) {
                referrer = IYFVReferral(rewardReferral).getReferrer(msg.sender);
            }
            if (referrer != address(0)) { // send commission to referrer
                safeTokenTransfer(value, referrer, valueCommission);
            } else {// or burn
                safeTokenBurn(value, valueCommission);
                emit Burned(valueCommission);
            }
        }
    }

    modifier checkNextEpoch() {
        if (block.timestamp >= periodFinish) {
            currentEpochReward = epochReward;

            if (totalAccumulatedReward.add(currentEpochReward) > TOTAL_REWARD) {
                currentEpochReward = TOTAL_REWARD.sub(totalAccumulatedReward); // limit total reward
            }

            if (currentEpochReward > 0) {
                if (!vUSD.minters(address(this)) || !vETH.minters(address(this))) {
                    currentEpochReward = 0;
                } else {
                    vUSD.mint(address(this), currentEpochReward);
                    vETH.mint(address(this), currentEpochReward.div(vETH_REWARD_FRACTION_RATE));
                    totalAccumulatedReward = totalAccumulatedReward.add(currentEpochReward);
                }
                currentEpoch++;
            }

            rewardRate = currentEpochReward.div(DURATION);

            if (currentEpochReward > 0) {
                value.mint(address(this), valueEpochReward);
                valueRewardRateMultipler = valueEpochReward.div(currentEpochReward);
            } else {
                valueRewardRateMultipler = 0;
            }

            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(currentEpochReward);
        }
        _;
    }

    function addValueReward(uint256 _amount) external discountCHI {
        require(periodFinish > 0, "Pool has not started yet");
        uint256 remaining = periodFinish.sub(block.timestamp);
        require(remaining > 1 days, "Too little time to distribute. Wait for next epoch");
        value.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 leftover = remaining.mul(rewardRate);
        uint256 valueLeftover = leftover.mul(valueRewardRateMultipler);
        valueRewardRateMultipler = valueLeftover.add(_amount).div(leftover);
    }

    // Safe token transfer function, just in case if rounding error causes pool to not have enough token.
    function safeTokenTransfer(IERC20 _token, address _to, uint256 _amount) internal {
        uint256 bal = _token.balanceOf(address(this));
        if (_amount > bal) {
            _token.safeTransfer(_to, bal);
        } else {
            _token.safeTransfer(_to, _amount);
        }
    }

    // Safe token burn function, just in case if rounding error causes pool to not have enough token.
    function safeTokenBurn(IERC20 _token, uint256 _amount) internal {
        uint256 bal = _token.balanceOf(address(this));
        if (_amount > bal) {
            _token.burn(bal);
        } else {
            _token.burn(_amount);
        }
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw() public discountCHI {
        require(block.timestamp >= unfrozenStakeTime(msg.sender), "Wait until coin unfrozen");
        uint256 amount = stakers[msg.sender].stake;
        uint256 b = yfv.balanceOf(address(this));
        if (b < amount) amount = b;
        stakers[msg.sender].payout = stakers[msg.sender].payout.sub(
            global.earnings_per_share.mul(amount).div(magnitude)
        );
        stakers[msg.sender].stake = stakers[msg.sender].stake.sub(amount);
        global.total_stake = global.total_stake.sub(amount);
        safeTokenTransfer(yfv, msg.sender, amount);
        emit Withdrawn(msg.sender, amount, amount);
    }

    // This function allows governance to take unsupported tokens out of the contract, since this pool exists longer than the other pools.
    // This is in an effort to make someone whole, should they seriously mess up.
    // There is no guarantee governance will vote to return these.
    // It also allows for removal of airdropped tokens.
    function governanceRecoverUnsupported(IERC20 _token, uint256 amount, address to) external {
        require(msg.sender == governance, "!governance");

        // cant take staked asset
        require(_token != yfv || global.total_stake.add(amount) <= yfv.balanceOf(address(this)), "cant withdraw more than stuck YFV");

        // transfer to
        _token.safeTransfer(to, amount);
    }
}