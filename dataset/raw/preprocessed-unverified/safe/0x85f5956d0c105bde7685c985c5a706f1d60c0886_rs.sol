/**
 *Submitted for verification at Etherscan.io on 2021-02-03
*/

// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol

// pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */



// Dependency file: @openzeppelin/contracts/math/SafeMath.sol

// pragma solidity ^0.5.0;

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



// Dependency file: @openzeppelin/contracts/utils/Address.sol

// pragma solidity ^0.5.5;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

// pragma solidity ^0.5.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: @openzeppelin/contracts/math/Math.sol

// pragma solidity ^0.5.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */



// Dependency file: contracts/modules/ReentrancyGuard.sol

// pragma solidity >=0.5.0;

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
 *
 * _Since v2.5.0:_ this module is now much more gas efficient, given net gas
 * metering changes introduced in the Istanbul hardfork.
 */
contract ReentrancyGuard {
    bool private _notEntered;

    function initialize() internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
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
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

// Dependency file: contracts/interfaces/IPOWToken.sol

// pragma solidity >=0.5.0;



// Dependency file: contracts/interfaces/IUniswapV2ERC20.sol

// pragma solidity >=0.5.0;



// Dependency file: contracts/interfaces/IStaking.sol

// pragma solidity >=0.5.0;



// Dependency file: contracts/interfaces/IERC20Detail.sol

// pragma solidity >=0.5.0;



// Dependency file: contracts/modules/Ownable.sol

// pragma solidity >=0.5.0;




// Root file: contracts/POWLpStaking.sol

pragma solidity >=0.5.0;

// import '/Users/tercel/work/bmining/bmining-protocol/node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol';
// import '/Users/tercel/work/bmining/bmining-protocol/node_modules/@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
// import "@openzeppelin/contracts/math/Math.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "contracts/modules/ReentrancyGuard.sol";
// import 'contracts/interfaces/IPOWToken.sol';
// import 'contracts/interfaces/IUniswapV2ERC20.sol';
// import 'contracts/interfaces/IStaking.sol';
// import "contracts/interfaces/IERC20Detail.sol";
// import 'contracts/modules/Ownable.sol';

contract POWLpStaking is Ownable, ReentrancyGuard{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool internal initialized;
    bool public emergencyStop;
    address public hashRateToken;
    address public stakingLpToken;

    uint256 public incomeLastUpdateTime;
    uint256 public incomePerTokenStored;
    mapping(address => uint256) public userIncomePerTokenPaid;
    mapping(address => uint256) public incomes;
    mapping(address => uint256) public accumulatedIncomes;

    uint256 public rewardLastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    mapping(address => uint256) public balances;
    uint256 public totalSupply;

    function initialize(address _hashRateToken, address _stakingLpToken) public {
        require(!initialized, "already initialized");
        require(IPOWToken(_hashRateToken).isStakingPool(address(this)), 'invalid pool');
        super.initialize();
        initialized = true;
        stakingLpToken = _stakingLpToken;
        hashRateToken = _hashRateToken;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function setEmergencyStop(bool _emergencyStop) external onlyOwner {
        emergencyStop = _emergencyStop;
    }

    function calculateLpStakingIncomeRate(uint256 _incomeRate) internal view returns(uint256) {
        if (totalSupply == 0 || _incomeRate == 0) {
            //special case.
            return 0;
        }
        uint256 stakingSupply = IPOWToken(hashRateToken).getLpStakingSupply(address(this));
        return _incomeRate.mul(stakingSupply).div(totalSupply);
    }

    function stakeWithPermit(uint256 amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external nonReentrant updateIncome(msg.sender) updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        notifyStakingUpdateIncome();

        balances[msg.sender] = balances[msg.sender].add(amount);
        totalSupply = totalSupply.add(amount);

        // permit
        IUniswapV2ERC20(stakingLpToken).permit(msg.sender, address(this), amount, deadline, v, r, s);
        IERC20(stakingLpToken).safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function stake(uint256 amount) external nonReentrant updateIncome(msg.sender) updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        notifyStakingUpdateIncome();

        balances[msg.sender] = balances[msg.sender].add(amount);
        totalSupply = totalSupply.add(amount);
        IERC20(stakingLpToken).safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public nonReentrant updateIncome(msg.sender) updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        notifyStakingUpdateIncome();

        totalSupply = totalSupply.sub(amount);
        balances[msg.sender] = balances[msg.sender].sub(amount);
        IERC20(stakingLpToken).safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balances[msg.sender]);
        getIncome();
        getReward();
    }

    function incomeRateChanged() external updateIncome(address(0)) {

    }

    function getCurIncomeRate() public view returns (uint256) {
        uint startMiningTime = IPOWToken(hashRateToken).startMiningTime();
        //not start mining yet.
        if (block.timestamp <= startMiningTime) {
            return 0;
        }

        uint256 incomeRate = IPOWToken(hashRateToken).incomeRate();
        incomeRate = calculateLpStakingIncomeRate(incomeRate);
        return incomeRate;
    }

    function incomePerToken() public view returns (uint256) {
        uint startMiningTime = IPOWToken(hashRateToken).startMiningTime();
        //not start mining yet.
        if (block.timestamp <= startMiningTime) {
            return 0;
        }

        uint256 _incomeLastUpdateTime = incomeLastUpdateTime;
        if (_incomeLastUpdateTime == 0) {
            _incomeLastUpdateTime = startMiningTime;
        }

        uint256 incomeRate = getCurIncomeRate();
        uint256 normalIncome = block.timestamp.sub(_incomeLastUpdateTime).mul(incomeRate);
        return incomePerTokenStored.add(normalIncome);
    }

    function incomeEarned(address account) external view returns (uint256) {
        uint256 income = _incomeEarned(account);
        return IPOWToken(hashRateToken).weiToIncomeTokenValue(income);
    }

    function _incomeEarned(address account) internal view returns (uint256) {
        if(incomePerToken() < userIncomePerTokenPaid[account]) {
            return 0;
        }
        return balances[account].mul(incomePerToken().sub(userIncomePerTokenPaid[account])).div(1e18).add(incomes[account]);
    }

    function getUserAccumulatedWithdrawIncome(address account) public view returns (uint256) {
        uint256 amount = accumulatedIncomes[account];
        return IPOWToken(hashRateToken).weiToIncomeTokenValue(amount);
    }

    function getIncome() public nonReentrant updateIncome(msg.sender) nonEmergencyStop {
        uint256 income = incomes[msg.sender];
        if (income > 0 && IPOWToken(hashRateToken).isStakingPool(address(this))) {
            accumulatedIncomes[msg.sender] = accumulatedIncomes[msg.sender].add(income);
            incomes[msg.sender] = 0;
            uint256 amount = IPOWToken(hashRateToken).weiToIncomeTokenValue(income);
            IPOWToken(hashRateToken).claimIncome(msg.sender, amount);
            emit IncomePaid(msg.sender, income);
        }
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        uint256 periodFinish = IPOWToken(hashRateToken).rewardPeriodFinish();
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardRateChanged() external updateReward(address(0)) {
        rewardLastUpdateTime = block.timestamp;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        uint256 rewardRate = IPOWToken(hashRateToken).getStakingRewardRate(address(this));
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable().sub(rewardLastUpdateTime).mul(rewardRate).mul(1e18).div(totalSupply)
        );
    }

    function rewardEarned(address account) public view returns (uint256) {
        return balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    function getReward() public nonReentrant updateReward(msg.sender) nonEmergencyStop {
        uint256 reward = rewards[msg.sender];
        if (reward > 0 && IPOWToken(hashRateToken).isStakingPool(address(this))) {
            rewards[msg.sender] = 0;
            IPOWToken(hashRateToken).claimReward(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function inCaseTokensGetStuck(address _token, uint256 _amount) external onlyOwner {
        require(_token != address(stakingLpToken), 'stakingToken cannot transfer.');
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }

    function notifyStakingUpdateIncome() internal {
        IPOWToken(hashRateToken).updateStakingPoolsIncome();
    }

    /* ========== MODIFIERS ========== */

    modifier updateIncome(address account)  {
        uint startMiningTime = IPOWToken(hashRateToken).startMiningTime();
        if (block.timestamp > startMiningTime) {
            incomePerTokenStored = incomePerToken();
            incomeLastUpdateTime = block.timestamp;
            if (account != address(0)) {
                incomes[account] = _incomeEarned(account);
                userIncomePerTokenPaid[account] = incomePerTokenStored;
            }
        }
        _;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        rewardLastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = rewardEarned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    modifier nonEmergencyStop() {
        require(emergencyStop == false, "emergency stop");
        _;
    }

    /* ========== EVENTS ========== */

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event IncomePaid(address indexed user, uint256 income);
    event RewardPaid(address indexed user, uint256 reward);
}