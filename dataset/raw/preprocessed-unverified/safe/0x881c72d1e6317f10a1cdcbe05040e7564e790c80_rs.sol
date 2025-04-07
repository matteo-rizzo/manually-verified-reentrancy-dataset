/**
 *Submitted for verification at Etherscan.io on 2020-08-03
*/

pragma solidity 0.5.16;


contract ModuleKeys {

    // Governance
    // ===========
                                                // Phases
    // keccak256("Governance");                 // 2.x
    bytes32 internal constant KEY_GOVERNANCE = 0x9409903de1e6fd852dfc61c9dacb48196c48535b60e25abf92acc92dd689078d;
    //keccak256("Staking");                     // 1.2
    bytes32 internal constant KEY_STAKING = 0x1df41cd916959d1163dc8f0671a666ea8a3e434c13e40faef527133b5d167034;
    //keccak256("ProxyAdmin");                  // 1.0
    bytes32 internal constant KEY_PROXY_ADMIN = 0x96ed0203eb7e975a4cbcaa23951943fa35c5d8288117d50c12b3d48b0fab48d1;

    // mStable
    // =======
    // keccak256("OracleHub");                  // 1.2
    bytes32 internal constant KEY_ORACLE_HUB = 0x8ae3a082c61a7379e2280f3356a5131507d9829d222d853bfa7c9fe1200dd040;
    // keccak256("Manager");                    // 1.2
    bytes32 internal constant KEY_MANAGER = 0x6d439300980e333f0256d64be2c9f67e86f4493ce25f82498d6db7f4be3d9e6f;
    //keccak256("Recollateraliser");            // 2.x
    bytes32 internal constant KEY_RECOLLATERALISER = 0x39e3ed1fc335ce346a8cbe3e64dd525cf22b37f1e2104a755e761c3c1eb4734f;
    //keccak256("MetaToken");                   // 1.1
    bytes32 internal constant KEY_META_TOKEN = 0xea7469b14936af748ee93c53b2fe510b9928edbdccac3963321efca7eb1a57a2;
    // keccak256("SavingsManager");             // 1.0
    bytes32 internal constant KEY_SAVINGS_MANAGER = 0x12fe936c77a1e196473c4314f3bed8eeac1d757b319abb85bdda70df35511bf1;
}



contract Module is ModuleKeys {

    INexus public nexus;

    /**
     * @dev Initialises the Module by setting publisher addresses,
     *      and reading all available system module information
     */
    constructor(address _nexus) internal {
        require(_nexus != address(0), "Nexus is zero address");
        nexus = INexus(_nexus);
    }

    /**
     * @dev Modifier to allow function calls only from the Governor.
     */
    modifier onlyGovernor() {
        require(msg.sender == _governor(), "Only governor can execute");
        _;
    }

    /**
     * @dev Modifier to allow function calls only from the Governance.
     *      Governance is either Governor address or Governance address.
     */
    modifier onlyGovernance() {
        require(
            msg.sender == _governor() || msg.sender == _governance(),
            "Only governance can execute"
        );
        _;
    }

    /**
     * @dev Modifier to allow function calls only from the ProxyAdmin.
     */
    modifier onlyProxyAdmin() {
        require(
            msg.sender == _proxyAdmin(), "Only ProxyAdmin can execute"
        );
        _;
    }

    /**
     * @dev Modifier to allow function calls only from the Manager.
     */
    modifier onlyManager() {
        require(msg.sender == _manager(), "Only manager can execute");
        _;
    }

    /**
     * @dev Returns Governor address from the Nexus
     * @return Address of Governor Contract
     */
    function _governor() internal view returns (address) {
        return nexus.governor();
    }

    /**
     * @dev Returns Governance Module address from the Nexus
     * @return Address of the Governance (Phase 2)
     */
    function _governance() internal view returns (address) {
        return nexus.getModule(KEY_GOVERNANCE);
    }

    /**
     * @dev Return Staking Module address from the Nexus
     * @return Address of the Staking Module contract
     */
    function _staking() internal view returns (address) {
        return nexus.getModule(KEY_STAKING);
    }

    /**
     * @dev Return ProxyAdmin Module address from the Nexus
     * @return Address of the ProxyAdmin Module contract
     */
    function _proxyAdmin() internal view returns (address) {
        return nexus.getModule(KEY_PROXY_ADMIN);
    }

    /**
     * @dev Return MetaToken Module address from the Nexus
     * @return Address of the MetaToken Module contract
     */
    function _metaToken() internal view returns (address) {
        return nexus.getModule(KEY_META_TOKEN);
    }

    /**
     * @dev Return OracleHub Module address from the Nexus
     * @return Address of the OracleHub Module contract
     */
    function _oracleHub() internal view returns (address) {
        return nexus.getModule(KEY_ORACLE_HUB);
    }

    /**
     * @dev Return Manager Module address from the Nexus
     * @return Address of the Manager Module contract
     */
    function _manager() internal view returns (address) {
        return nexus.getModule(KEY_MANAGER);
    }

    /**
     * @dev Return SavingsManager Module address from the Nexus
     * @return Address of the SavingsManager Module contract
     */
    function _savingsManager() internal view returns (address) {
        return nexus.getModule(KEY_SAVINGS_MANAGER);
    }

    /**
     * @dev Return Recollateraliser Module address from the Nexus
     * @return  Address of the Recollateraliser Module contract (Phase 2)
     */
    function _recollateraliser() internal view returns (address) {
        return nexus.getModule(KEY_RECOLLATERALISER);
    }
}





contract RewardsDistributionRecipient is IRewardsDistributionRecipient, Module {

    // @abstract
    function notifyRewardAmount(uint256 reward) external;
    function getRewardToken() external view returns (IERC20);

    // This address has the ability to distribute the rewards
    address public rewardsDistributor;

    /** @dev Recipient is a module, governed by mStable governance */
    constructor(address _nexus, address _rewardsDistributor)
        internal
        Module(_nexus)
    {
        rewardsDistributor = _rewardsDistributor;
    }

    /**
     * @dev Only the rewards distributor can notify about rewards
     */
    modifier onlyRewardsDistributor() {
        require(msg.sender == rewardsDistributor, "Caller is not reward distributor");
        _;
    }

    /**
     * @dev Change the rewardsDistributor - only called by mStable governor
     * @param _rewardsDistributor   Address of the new distributor
     */
    function setRewardsDistribution(address _rewardsDistributor)
        external
        onlyGovernor
    {
        rewardsDistributor = _rewardsDistributor;
    }
}

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




contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
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

contract StakingTokenWrapper is ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public stakingToken;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    /**
     * @dev TokenWrapper constructor
     * @param _stakingToken Wrapped token to be staked
     */
    constructor(address _stakingToken) internal {
        stakingToken = IERC20(_stakingToken);
    }

    /**
     * @dev Get the total amount of the staked token
     * @return uint256 total supply
     */
    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _totalSupply;
    }

    /**
     * @dev Get the balance of a given account
     * @param _account User for which to retrieve balance
     */
    function balanceOf(address _account)
        public
        view
        returns (uint256)
    {
        return _balances[_account];
    }

    /**
     * @dev Deposits a given amount of StakingToken from sender
     * @param _amount Units of StakingToken
     */
    function _stake(address _beneficiary, uint256 _amount)
        internal
        nonReentrant
    {
        _totalSupply = _totalSupply.add(_amount);
        _balances[_beneficiary] = _balances[_beneficiary].add(_amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
    }

    /**
     * @dev Withdraws a given stake from sender
     * @param _amount Units of StakingToken
     */
    function _withdraw(uint256 _amount)
        internal
        nonReentrant
    {
        _totalSupply = _totalSupply.sub(_amount);
        _balances[msg.sender] = _balances[msg.sender].sub(_amount);
        stakingToken.safeTransfer(msg.sender, _amount);
    }
}





contract PlatformTokenVendor {

    IERC20 public platformToken;
    address public parentStakingContract;

    /** @dev Simple constructor that stores the parent address */
    constructor(IERC20 _platformToken) public {
        parentStakingContract = msg.sender;
        platformToken = _platformToken;
        MassetHelpers.safeInfiniteApprove(address(_platformToken), parentStakingContract);
    }

    /**
     * @dev Re-approves the StakingReward contract to spend the platform token.
     * Just incase for some reason approval has been reset.
     */
    function reApproveOwner() external {
        MassetHelpers.safeInfiniteApprove(address(platformToken), parentStakingContract);
    }
}

/**
 * @title  StakingRewardsWithPlatformToken
 * @author Stability Labs Pty. Ltd.
 * @notice Rewards stakers of a given LP token (a.k.a StakingToken) with RewardsToken, on a pro-rata basis
 * additionally, distributes the Platform token airdropped by the platform
 * @dev    Derives from ./StakingRewards.sol and implements a secondary token into the core logic
 */
contract StakingRewardsWithPlatformToken is StakingTokenWrapper, RewardsDistributionRecipient {

    using StableMath for uint256;

    IERC20 public rewardsToken;
    IERC20 public platformToken;
    PlatformTokenVendor public platformTokenVendor;

    uint256 public constant DURATION = 7 days;

    // Timestamp for current period finish
    uint256 public periodFinish = 0;
    // RewardRate for the rest of the PERIOD
    uint256 public rewardRate = 0;
    uint256 public platformRewardRate = 0;
    // Last time any user took action
    uint256 public lastUpdateTime;
    // Ever increasing rewardPerToken rate, based on % of total supply
    uint256 public rewardPerTokenStored;
    uint256 public platformRewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public userPlatformRewardPerTokenPaid;

    mapping(address => uint256) public rewards;
    mapping(address => uint256) public platformRewards;

    event RewardAdded(uint256 reward, uint256 platformReward);
    event Staked(address indexed user, uint256 amount, address payer);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward, uint256 platformReward);

    /** @dev StakingRewards is a TokenWrapper and RewardRecipient */
    constructor(
        address _nexus,
        address _stakingToken,
        address _rewardsToken,
        address _platformToken,
        address _rewardsDistributor
    )
        public
        StakingTokenWrapper(_stakingToken)
        RewardsDistributionRecipient(_nexus, _rewardsDistributor)
    {
        rewardsToken = IERC20(_rewardsToken);
        platformToken = IERC20(_platformToken);
        platformTokenVendor = new PlatformTokenVendor(platformToken);
    }

    /** @dev Updates the reward for a given address, before executing function */
    modifier updateReward(address _account) {
        // Setting of global vars
        (uint256 newRewardPerTokenStored, uint256 newPlatformRewardPerTokenStored) = rewardPerToken();

        // If statement protects against loss in initialisation case
        if(newRewardPerTokenStored > 0 || newPlatformRewardPerTokenStored > 0) {
            rewardPerTokenStored = newRewardPerTokenStored;
            platformRewardPerTokenStored = newPlatformRewardPerTokenStored;

            lastUpdateTime = lastTimeRewardApplicable();

            // Setting of personal vars based on new globals
            if (_account != address(0)) {
                (rewards[_account], platformRewards[_account]) = earned(_account);

                userRewardPerTokenPaid[_account] = newRewardPerTokenStored;
                userPlatformRewardPerTokenPaid[_account] = newPlatformRewardPerTokenStored;
            }
        }
        _;
    }

    /***************************************
                    ACTIONS
    ****************************************/

    /**
     * @dev Stakes a given amount of the StakingToken for the sender
     * @param _amount Units of StakingToken
     */
    function stake(uint256 _amount)
        external
    {
        _stake(msg.sender, _amount);
    }

    /**
     * @dev Stakes a given amount of the StakingToken for a given beneficiary
     * @param _beneficiary Staked tokens are credited to this address
     * @param _amount      Units of StakingToken
     */
    function stake(address _beneficiary, uint256 _amount)
        external
    {
        _stake(_beneficiary, _amount);
    }

    /**
     * @dev Internally stakes an amount by depositing from sender,
     * and crediting to the specified beneficiary
     * @param _beneficiary Staked tokens are credited to this address
     * @param _amount      Units of StakingToken
     */
    function _stake(address _beneficiary, uint256 _amount)
        internal
        updateReward(_beneficiary)
    {
        require(_amount > 0, "Cannot stake 0");
        super._stake(_beneficiary, _amount);
        emit Staked(_beneficiary, _amount, msg.sender);
    }

    /**
     * @dev Withdraws stake from pool and claims any rewards
     */
    function exit() external {
        withdraw(balanceOf(msg.sender));
        claimReward();
    }

    /**
     * @dev Withdraws given stake amount from the pool
     * @param _amount Units of the staked token to withdraw
     */
    function withdraw(uint256 _amount)
        public
        updateReward(msg.sender)
    {
        require(_amount > 0, "Cannot withdraw 0");
        _withdraw(_amount);
        emit Withdrawn(msg.sender, _amount);
    }

    /**
     * @dev Claims outstanding rewards (both platform and native) for the sender.
     * First updates outstanding reward allocation and then transfers.
     */
    function claimReward()
        public
        updateReward(msg.sender)
    {
        uint256 reward = _claimReward();
        uint256 platformReward = _claimPlatformReward();
        emit RewardPaid(msg.sender, reward, platformReward);
    }

    /**
     * @dev Claims outstanding rewards for the sender. Only the native
     * rewards token, and not the platform rewards
     */
    function claimRewardOnly()
        public
        updateReward(msg.sender)
    {
        uint256 reward = _claimReward();
        emit RewardPaid(msg.sender, reward, 0);
    }

    /**
     * @dev Credits any outstanding rewards to the sender
     */
    function _claimReward() internal returns (uint256) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
        return reward;
    }

    /**
     * @dev Claims any outstanding platform reward tokens
     */
    function _claimPlatformReward() internal returns (uint256)  {
        uint256 platformReward = platformRewards[msg.sender];
        if(platformReward > 0) {
            platformRewards[msg.sender] = 0;
            platformToken.safeTransferFrom(address(platformTokenVendor), msg.sender, platformReward);
        }
        return platformReward;
    }

    /***************************************
                    GETTERS
    ****************************************/

    /**
     * @dev Gets the RewardsToken
     */
    function getRewardToken()
        external
        view
        returns (IERC20)
    {
        return rewardsToken;
    }

    /**
     * @dev Gets the last applicable timestamp for this reward period
     */
    function lastTimeRewardApplicable()
        public
        view
        returns (uint256)
    {
        return StableMath.min(block.timestamp, periodFinish);
    }

    /**
     * @dev Calculates the amount of unclaimed rewards a user has earned
     * @return 'Reward' per staked token
     */
    function rewardPerToken()
        public
        view
        returns (uint256, uint256)
    {
        // If there is no StakingToken liquidity, avoid div(0)
        uint256 stakedTokens = totalSupply();
        if (stakedTokens == 0) {
            return (rewardPerTokenStored, platformRewardPerTokenStored);
        }
        // new reward units to distribute = rewardRate * timeSinceLastUpdate
        uint256 timeDelta = lastTimeRewardApplicable().sub(lastUpdateTime);
        uint256 rewardUnitsToDistribute = rewardRate.mul(timeDelta);
        uint256 platformRewardUnitsToDistribute = platformRewardRate.mul(timeDelta);
        // new reward units per token = (rewardUnitsToDistribute * 1e18) / totalTokens
        uint256 unitsToDistributePerToken = rewardUnitsToDistribute.divPrecisely(stakedTokens);
        uint256 platformUnitsToDistributePerToken = platformRewardUnitsToDistribute.divPrecisely(stakedTokens);
        // return summed rate
        return (
            rewardPerTokenStored.add(unitsToDistributePerToken),
            platformRewardPerTokenStored.add(platformUnitsToDistributePerToken)
        );
    }

    /**
     * @dev Calculates the amount of unclaimed rewards a user has earned
     * @param _account User address
     * @return Total reward amount earned
     */
    function earned(address _account)
        public
        view
        returns (uint256, uint256)
    {
        // current rate per token - rate user previously received
        (uint256 currentRewardPerToken, uint256 currentPlatformRewardPerToken) = rewardPerToken();
        uint256 userRewardDelta = currentRewardPerToken.sub(userRewardPerTokenPaid[_account]);
        uint256 userPlatformRewardDelta = currentPlatformRewardPerToken.sub(userPlatformRewardPerTokenPaid[_account]);
        // new reward = staked tokens * difference in rate
        uint256 stakeBalance = balanceOf(_account);
        uint256 userNewReward = stakeBalance.mulTruncate(userRewardDelta);
        uint256 userNewPlatformReward = stakeBalance.mulTruncate(userPlatformRewardDelta);
        // add to previous rewards
        return (
            rewards[_account].add(userNewReward),
            platformRewards[_account].add(userNewPlatformReward)
        );
    }


    /***************************************
                    ADMIN
    ****************************************/

    /**
     * @dev Notifies the contract that new rewards have been added.
     * Calculates an updated rewardRate based on the rewards in period.
     * @param _reward Units of RewardToken that have been added to the pool
     */
    function notifyRewardAmount(uint256 _reward)
        external
        onlyRewardsDistributor
        updateReward(address(0))
    {
        uint256 newPlatformRewards = platformToken.balanceOf(address(this));
        if(newPlatformRewards > 0){
            platformToken.safeTransfer(address(platformTokenVendor), newPlatformRewards);
        }

        uint256 currentTime = block.timestamp;
        // If previous period over, reset rewardRate
        if (currentTime >= periodFinish) {
            rewardRate = _reward.div(DURATION);
            platformRewardRate = newPlatformRewards.div(DURATION);
        }
        // If additional reward to existing period, calc sum
        else {
            uint256 remaining = periodFinish.sub(currentTime);

            uint256 leftoverReward = remaining.mul(rewardRate);
            rewardRate = _reward.add(leftoverReward).div(DURATION);

            uint256 leftoverPlatformReward = remaining.mul(platformRewardRate);
            platformRewardRate = newPlatformRewards.add(leftoverPlatformReward).div(DURATION);
        }

        lastUpdateTime = currentTime;
        periodFinish = currentTime.add(DURATION);

        emit RewardAdded(_reward, newPlatformRewards);
    }
}