/**
 *Submitted for verification at Etherscan.io on 2021-03-18
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.12;


// 
/**
 * @dev Standard math utilities missing in the Solidity language.
 */


// 
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


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
struct AttoDecimal {
    uint256 mantissa;
}



// 
abstract contract TwoStageOwnable {
    address public nominatedOwner;
    address public owner;

    event OwnerChanged(address newOwner);
    event OwnerNominated(address nominatedOwner);

    constructor(address _owner) internal {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        owner = nominatedOwner;
        nominatedOwner = address(0);
        emit OwnerChanged(owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }
}

// 
/**
 * @dev Collection of functions related to the address type
 */


// 
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// 
abstract contract UniStakingTokensStorage {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 private _rewardPool;
    uint256 private _rewardSupply;
    uint256 private _totalSupply;
    IERC20 private _rewardsToken;
    IERC20 private _stakingToken;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _claimed;
    mapping(address => uint256) private _rewards;

    function rewardPool() public view returns (uint256) {
        return _rewardPool;
    }

    function rewardSupply() public view returns (uint256) {
        return _rewardSupply;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function rewardsToken() public view returns (IERC20) {
        return _rewardsToken;
    }

    function stakingToken() public view returns (IERC20) {
        return _stakingToken;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function claimedOf(address account) public view returns (uint256) {
        return _claimed[account];
    }

    function rewardOf(address account) public view returns (uint256) {
        return _rewards[account];
    }

    constructor(IERC20 rewardsToken_, IERC20 stakingToken_) public {
        _rewardsToken = rewardsToken_;
        _stakingToken = stakingToken_;
    }

    function _onMint(address account, uint256 amount) internal virtual {}
    function _onBurn(address account, uint256 amount) internal virtual {}

    function _stake(address account, uint256 amount) internal {
        _stakingToken.safeTransferFrom(account, address(this), amount);
        _balances[account] = _balances[account].add(amount);
        _totalSupply = _totalSupply.add(amount);
        _onMint(account, amount);
    }

    function _unstake(address account, uint256 amount) internal {
        _stakingToken.safeTransfer(account, amount);
        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        _onBurn(account, amount);
    }

    function _increaseRewardPool(address owner, uint256 amount) internal {
        _rewardsToken.safeTransferFrom(owner, address(this), amount);
        _rewardSupply = _rewardSupply.add(amount);
        _rewardPool = _rewardPool.add(amount);
    }

    function _reduceRewardPool(address owner, uint256 amount) internal {
        _rewardsToken.safeTransfer(owner, amount);
        _rewardSupply = _rewardSupply.sub(amount);
        _rewardPool = _rewardPool.sub(amount);
    }

    function _addReward(address account, uint256 amount) internal {
        _rewards[account] = _rewards[account].add(amount);
        _rewardPool = _rewardPool.sub(amount);
    }

    function _withdraw(address account, uint256 amount) internal {
        _rewardsToken.safeTransfer(account, amount);
        _claimed[account] = _claimed[account].sub(amount);
    }

    function _claim(address account, uint256 amount) internal {
        _rewards[account] = _rewards[account].sub(amount);
        _rewardSupply = _rewardSupply.sub(amount);
        _claimed[account] = _claimed[account].add(amount);
    }

    function _transferBalance(
        address from,
        address to,
        uint256 amount
    ) internal {
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
    }
}

// 
contract UniStaking is TwoStageOwnable, UniStakingTokensStorage {
    using SafeMath for uint256;
    using AttoDecimalLib for AttoDecimal;

    struct PaidRate {
        AttoDecimal rate;
        bool active;
    }

    function getBlockNumber() internal virtual view returns (uint256) {
        return block.number;
    }

    function getTimestamp() internal virtual view returns (uint256) {
        return block.timestamp;
    }

    uint256 public constant SECONDS_PER_BLOCK = 15;
    uint256 public constant BLOCKS_PER_DAY = 1 days / SECONDS_PER_BLOCK;
    uint256 public constant MAX_DISTRIBUTION_DURATION = 90 * BLOCKS_PER_DAY;

    mapping(address => uint256) public rewardUnlockingTime;

    uint256 private _lastUpdateBlockNumber;
    uint256 private _perBlockReward;
    uint256 private _blockNumberOfDistributionEnding;
    uint256 private _initialStrategyStartBlockNumber;
    AttoDecimal private _initialStrategyRewardPerToken;
    AttoDecimal private _rewardPerToken;
    mapping(address => PaidRate) private _paidRates;

    function getRewardUnlockingTime() public virtual pure returns (uint256) {
        return 8 days;
    }

    function lastUpdateBlockNumber() public view returns (uint256) {
        return _lastUpdateBlockNumber;
    }

    function perBlockReward() public view returns (uint256) {
        return _perBlockReward;
    }

    function blockNumberOfDistributionEnding() public view returns (uint256) {
        return _blockNumberOfDistributionEnding;
    }

    function initialStrategyStartBlockNumber() public view returns (uint256) {
        return _initialStrategyStartBlockNumber;
    }

    function getRewardPerToken() internal view returns (AttoDecimal memory) {
        uint256 lastRewardBlockNumber = Math.min(getBlockNumber(), _blockNumberOfDistributionEnding.add(1));
        if (lastRewardBlockNumber <= _lastUpdateBlockNumber) return _rewardPerToken;
        return _getRewardPerToken(lastRewardBlockNumber);
    }

    function _getRewardPerToken(uint256 forBlockNumber) internal view returns (AttoDecimal memory) {
        if (_initialStrategyStartBlockNumber >= forBlockNumber) return AttoDecimal(0);
        uint256 totalSupply_ = totalSupply();
        if (totalSupply_ == 0) return AttoDecimalLib.convert(0);
        uint256 totalReward = forBlockNumber
            .sub(Math.max(_lastUpdateBlockNumber, _initialStrategyStartBlockNumber))
            .mul(_perBlockReward);
        AttoDecimal memory newRewardPerToken = AttoDecimalLib.div(totalReward, totalSupply_);
        return _rewardPerToken.add(newRewardPerToken);
    }

    function rewardPerToken()
        external
        view
        returns (
            uint256 mantissa,
            uint256 base,
            uint256 exponentiation
        )
    {
        return (getRewardPerToken().mantissa, AttoDecimalLib.BASE, AttoDecimalLib.EXPONENTIATION);
    }

    function paidRateOf(address account)
        external
        view
        returns (
            uint256 mantissa,
            uint256 base,
            uint256 exponentiation
        )
    {
        return (_paidRates[account].rate.mantissa, AttoDecimalLib.BASE, AttoDecimalLib.EXPONENTIATION);
    }

    function earnedOf(address account) public view returns (uint256) {
        uint256 currentBlockNumber = getBlockNumber();
        PaidRate memory userRate = _paidRates[account];
        if (currentBlockNumber <= _initialStrategyStartBlockNumber || !userRate.active) return 0;
        AttoDecimal memory rewardPerToken_ = getRewardPerToken();
        AttoDecimal memory initRewardPerToken = _initialStrategyRewardPerToken.mantissa > 0
            ? _initialStrategyRewardPerToken
            : _getRewardPerToken(_initialStrategyStartBlockNumber.add(1));
        AttoDecimal memory rate = userRate.rate.lte((initRewardPerToken)) ? initRewardPerToken : userRate.rate;
        uint256 balance = balanceOf(account);
        if (balance == 0) return 0;
        if (rewardPerToken_.lte(rate)) return 0;
        AttoDecimal memory ratesDiff = rewardPerToken_.sub(rate);
        return ratesDiff.mul(balance).floor();
    }

    event RewardStrategyChanged(uint256 perBlockReward, uint256 duration);
    event InitialRewardStrategySetted(uint256 startBlockNumber, uint256 perBlockReward, uint256 duration);
    event Staked(address indexed account, uint256 amount);
    event Unstaked(address indexed account, uint256 amount);
    event Claimed(address indexed account, uint256 amount, uint256 rewardUnlockingTime);
    event Withdrawed(address indexed account, uint256 amount);

    constructor(
        IERC20 rewardsToken_,
        IERC20 stakingToken_,
        address owner_
    ) public TwoStageOwnable(owner_) UniStakingTokensStorage(rewardsToken_, stakingToken_) {
    }

    function stake(uint256 amount) public onlyPositiveAmount(amount) {
        address sender = msg.sender;
        _lockRewards(sender);
        _stake(sender, amount);
        emit Staked(sender, amount);
    }

    function unstake(uint256 amount) public onlyPositiveAmount(amount) {
        address sender = msg.sender;
        require(amount <= balanceOf(sender), "Unstaking amount exceeds staked balance");
        _lockRewards(sender);
        _unstake(sender, amount);
        emit Unstaked(sender, amount);
    }

    function claim(uint256 amount) public onlyPositiveAmount(amount) {
        address sender = msg.sender;
        _lockRewards(sender);
        require(amount <= rewardOf(sender), "Claiming amount exceeds received rewards");
        uint256 rewardUnlockingTime_ = getTimestamp().add(getRewardUnlockingTime());
        rewardUnlockingTime[sender] = rewardUnlockingTime_;
        _claim(sender, amount);
        emit Claimed(sender, amount, rewardUnlockingTime_);
    }

    function withdraw(uint256 amount) public onlyPositiveAmount(amount) {
        address sender = msg.sender;
        require(getTimestamp() >= rewardUnlockingTime[sender], "Reward not unlocked yet");
        require(amount <= claimedOf(sender), "Withdrawing amount exceeds claimed balance");
        _withdraw(sender, amount);
        emit Withdrawed(sender, amount);
    }

    function setInitialRewardStrategy(
        uint256 startBlockNumber,
        uint256 perBlockReward_,
        uint256 duration
    ) public onlyOwner returns (bool succeed) {
        uint256 currentBlockNumber = getBlockNumber();
        require(_initialStrategyStartBlockNumber == 0, "Initial reward strategy already setted");
        require(currentBlockNumber < startBlockNumber, "Initial reward strategy start block number less than current");
        _initialStrategyStartBlockNumber = startBlockNumber;
        _setRewardStrategy(currentBlockNumber, startBlockNumber, perBlockReward_, duration);
        emit InitialRewardStrategySetted(startBlockNumber, perBlockReward_, duration);
        return true;
    }

    function setRewardStrategy(uint256 perBlockReward_, uint256 duration) public onlyOwner returns (bool succeed) {
        uint256 currentBlockNumber = getBlockNumber();
        require(_initialStrategyStartBlockNumber > 0, "Set initial reward strategy first");
        require(currentBlockNumber >= _initialStrategyStartBlockNumber, "Wait for initial reward strategy start");
        _setRewardStrategy(currentBlockNumber, currentBlockNumber, perBlockReward_, duration);
        emit RewardStrategyChanged(perBlockReward_, duration);
        return true;
    }

    function lockRewards() public {
        _lockRewards(msg.sender);
    }

    function _moveStake(
        address from,
        address to,
        uint256 amount
    ) internal {
        _lockRewards(from);
        _lockRewards(to);
        _transferBalance(from, to, amount);
    }

    function _lockRatesForBlock(uint256 blockNumber) private {
        _rewardPerToken = _getRewardPerToken(blockNumber);
        _lastUpdateBlockNumber = blockNumber;
    }

    function _lockRates(uint256 blockNumber) private {
        uint256 totalSupply_ = totalSupply();
        if (_initialStrategyStartBlockNumber <= blockNumber && _initialStrategyRewardPerToken.mantissa == 0 && totalSupply_ > 0)
            _initialStrategyRewardPerToken = AttoDecimalLib.div(_perBlockReward, totalSupply_);
        if (_perBlockReward > 0 && blockNumber >= _blockNumberOfDistributionEnding) {
            _lockRatesForBlock(_blockNumberOfDistributionEnding);
            _perBlockReward = 0;
        }
        _lockRatesForBlock(blockNumber);
    }

    function _lockRewards(address account) private {
        uint256 currentBlockNumber = getBlockNumber();
        _lockRates(currentBlockNumber);
        uint256 earned = earnedOf(account);
        if (earned > 0) _addReward(account, earned);
        _paidRates[account].rate = _rewardPerToken;
        _paidRates[account].active = true;
    }

    function _setRewardStrategy(
        uint256 currentBlockNumber,
        uint256 startBlockNumber,
        uint256 perBlockReward_,
        uint256 duration
    ) private {
        require(duration > 0, "Duration is zero");
        require(duration <= MAX_DISTRIBUTION_DURATION, "Distribution duration too long");
        _lockRates(currentBlockNumber);
        uint256 nextDistributionRequiredPool = perBlockReward_.mul(duration);
        uint256 notDistributedReward = _blockNumberOfDistributionEnding <= currentBlockNumber
            ? 0
            : _blockNumberOfDistributionEnding.sub(currentBlockNumber).mul(_perBlockReward);
        if (nextDistributionRequiredPool > notDistributedReward) {
            _increaseRewardPool(owner, nextDistributionRequiredPool.sub(notDistributedReward));
        } else if (nextDistributionRequiredPool < notDistributedReward) {
            _reduceRewardPool(owner, notDistributedReward.sub(nextDistributionRequiredPool));
        }
        _perBlockReward = perBlockReward_;
        _blockNumberOfDistributionEnding = startBlockNumber.add(duration);
    }

    modifier onlyPositiveAmount(uint256 amount) {
        require(amount > 0, "Amount is not positive");
        _;
    }
}

// 
contract UniStakingSyntheticToken is UniStaking {
    uint256 public decimals;
    string public name;
    string public symbol;
    mapping(address => mapping(address => uint256)) internal _allowances;

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        IERC20 rewardsToken_,
        IERC20 stakingToken_,
        address owner_
    ) public UniStaking(rewardsToken_, stakingToken_, owner_) {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
    }

    function _onMint(address account, uint256 amount) internal override {
        emit Transfer(address(0), account, amount);
    }

    function _onBurn(address account, uint256 amount) internal override {
        emit Transfer(account, address(0), amount);
    }

    function transfer(address recipient, uint256 amount) external onlyPositiveAmount(amount) returns (bool) {
        require(balanceOf(msg.sender) >= amount, "Transfer amount exceeds balance");
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external onlyPositiveAmount(amount) returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "Transfer amount exceeds allowance");
        require(balanceOf(sender) >= amount, "Transfer amount exceeds balance");
        _transfer(sender, recipient, amount);
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        _moveStake(sender, recipient, amount);
        emit Transfer(sender, recipient, amount);
    }
}