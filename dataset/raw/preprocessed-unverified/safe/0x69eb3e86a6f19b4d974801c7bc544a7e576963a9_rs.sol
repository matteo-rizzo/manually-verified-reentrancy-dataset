/**
 *Submitted for verification at Etherscan.io on 2020-11-27
*/

/**
 *Submitted for verification at Etherscan.io on 2020-11-20
*/

/**
 *Submitted for verification at Etherscan.io on 2020-11-13
*/

pragma solidity 0.5.17;






/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}









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



contract Pausable is Ownable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () public {
        _paused = false;
    }    

    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    modifier whenPaused() {
        require(_paused);
        _;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}


contract StakingDextoken is ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    event Freeze(address indexed account);
    event Unfreeze(address indexed account);
    event TokenDeposit(address account, uint amount);
    event TokenWithdraw(address account, uint amount);
    event TokenClaim(address account, uint amount);
    event RewardAdded(uint reward);

    uint public periodFinish = 0;
    uint public rewardRate = 0;
    uint public lastUpdateTime;
    uint public rewardPerTokenStored = 0;
    uint public rewardRounds = 0;
    uint public rewardsDuration = 0;
    bool public inStaking = true;

    // BAL beneficial address
    address public beneficial = address(this);

    // User award balance
    mapping(address => uint) public rewards;
    mapping(address => uint) public userRewardPerTokenPaid;

    uint private _start;
    uint private _end;

    /// Staking token
    IERC20 private _token0;

    /// Reward token
    IERC20 private _token1;

    /// Total rewards
    uint private _rewards;
    uint private _remainingRewards;

    /// Total amount of user staking tokens
    uint private _totalSupply;

    mapping(address => bool) public frozenAccount;

    /// The staking users
    mapping(address => bool) public stakeHolders;

    /// The amount of tokens staked
    mapping(address => uint) private _balances;

    /// The remaining withdrawals of staked tokens
    mapping(address => uint) internal withdrawalOf;  

    /// The remaining withdrawals of reward tokens
    mapping(address => uint) internal claimOf;

    constructor (address token0, address token1) public {
        require(token0 != address(0), "DEXToken: zero address");
        require(token1 != address(0), "DEXToken: zero address");

        _token0 = IERC20(token0);
        _token1 = IERC20(token1);
    }

    modifier notFrozen(address _account) {
        require(!frozenAccount[_account]);
        _;
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

    function setBeneficial(address _beneficial) onlyOwner external {
        require(_beneficial != address(this), "setBeneficial: can not send to self");
        require(_beneficial != address(0), "setBeneficial: can not burn tokens");
        beneficial = _beneficial;
    }

    /// Capture BAL tokens or any other tokens
    function capture(address _token, uint amount) onlyOwner external {
        require(_token != address(_token0), "capture: can not capture staking tokens");
        require(_token != address(_token1), "capture: can not capture reward tokens");
        require(beneficial != address(this), "capture: can not send to self");
        require(beneficial != address(0), "capture: can not burn tokens");
        IERC20(_token).safeTransfer(beneficial, amount);
    }  

    function lastTimeRewardApplicable() public view returns (uint) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint) {
        if (getTotalStakes() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(getTotalStakes())
            );
    }

    function earned(address account) public view returns (uint) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    /// setup the staking round
    function setRewardRound(uint round, uint reward, uint start, uint end) 
        external
        onlyOwner    
    {
        require(block.timestamp > periodFinish, "setRewardRound: previous rewards period not complete");
        require(rewardRounds < round, "setRewardRound: this round completed");

        rewardRounds = round;
        _rewards = reward;
        _start = start;
        _end = end;
        rewardsDuration = _end.sub(_start);

        inStaking = false;
    }

    /// launch the staking round
    function notifyRewards()
        external
        onlyOwner
        updateReward(address(0))
    {
        // staking started
        if (inStaking == true) {
            return;
        }

        if (block.timestamp >= periodFinish) {
            rewardRate = _rewards.div(rewardsDuration);
        } else {
            uint remaining = periodFinish.sub(block.timestamp);
            uint leftover = remaining.mul(rewardRate);
            rewardRate = _rewards.add(leftover).div(rewardsDuration);
            _remainingRewards = leftover;
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint balance = _token1.balanceOf(address(this));
        require(rewardRate <= balance.div(rewardsDuration), "notifyRewards: provided reward too high");

        inStaking = true;
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(_rewards);
    }

    function addStakeholder(address _stakeholder) internal {
        stakeHolders[_stakeholder] = true;
    }

    function removeStakeholder(address _stakeholder) internal {
        stakeHolders[_stakeholder] = false;
    }

    /// Deposit staking tokens
    function deposit(uint amount) 
        external 
        nonReentrant
        whenNotPaused 
        notFrozen(msg.sender) 
        updateReward(msg.sender)
    {
        require(amount > 0, "deposit: cannot stake 0");
        require(msg.sender != address(0), "withdraw: zero address");
        require(_token0.balanceOf(msg.sender) >= amount, "deposit: insufficient balance");
        _totalSupply = _totalSupply.add(amount);          
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        addStakeholder(msg.sender);
        _token0.safeTransferFrom(msg.sender, address(this), amount);
        emit TokenDeposit(msg.sender, amount);
    }

    /// Withdraw staked tokens
    function withdraw(uint amount) 
        external 
        nonReentrant
        whenNotPaused 
        notFrozen(msg.sender) 
        updateReward(msg.sender)
    {
        require(amount > 0, "withdraw: amount invalid");
        require(msg.sender != address(0), "withdraw: zero address");
        /// Not overflow
        require(_balances[msg.sender] >= amount);
        _totalSupply = _totalSupply.sub(amount);                
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        /// Keep track user withdraws
        withdrawalOf[msg.sender] = withdrawalOf[msg.sender].add(amount);  
        if (_balances[msg.sender] == 0) {
            removeStakeholder(msg.sender);   
        }
        _token0.safeTransfer(msg.sender, amount);
        emit TokenWithdraw(msg.sender, amount);
    }

    /// Claim reward tokens
    function claim() 
        external 
        nonReentrant
        whenNotPaused 
        notFrozen(msg.sender) 
        updateReward(msg.sender)
    {
        require(msg.sender != address(0), "claim: zero address");        
        require(block.timestamp > getEndTimestamp(), "claim: claim not open");   
        require(block.timestamp > periodFinish, "claim: current staking period not complete");

        uint reward = earned(msg.sender);
        /// Not overflow        
        require(_token1.balanceOf(address(this)) >= reward, "claim: insufficient balance");        
        require(reward > 0, "claim: zero rewards");                

        rewards[msg.sender] = 0;
        claimOf[msg.sender] = reward;
        _token1.safeTransfer(msg.sender, reward);
        emit TokenClaim(msg.sender, reward);
    }

    function freezeAccount(address account) external onlyOwner returns (bool) {
        require(!frozenAccount[account], "ERC20: account frozen");
        frozenAccount[account] = true;
        emit Freeze(account);
        return true;
    }

    function unfreezeAccount(address account) external onlyOwner returns (bool) {
        require(frozenAccount[account], "ERC20: account not frozen");
        frozenAccount[account] = false;
        emit Unfreeze(account);
        return true;
    }

    function getWithdrawalOf(address _stakeholder) external view returns (uint) {
        return withdrawalOf[_stakeholder];
    }

    function getClaimOf(address _stakeholder) external view returns (uint) {
        return claimOf[_stakeholder];
    }

    /// Get remaining rewards of the time period
    function remainingRewards() external view returns(uint) {
        return _remainingRewards;
    }

    /// Retrieve the stake for a stakeholder
    function stakeOf(address _stakeholder) external view returns (uint) {
        return _balances[_stakeholder];
    }

    /// Retrieve the stake for a stakeholder
    function rewardOf(address _stakeholder) external view returns (uint) {
        return earned(_stakeholder);
    }

    /// Get total original rewards
    function totalRewards() external view returns (uint) {
        return _rewards;
    }  

    function getStartTimestamp() public view returns (uint) {
        return _start;
    }

    function getEndTimestamp() public view returns (uint) {
        return _end;
    }

    /// The total supply of all staked tokens
    function getTotalStakes() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }    
}