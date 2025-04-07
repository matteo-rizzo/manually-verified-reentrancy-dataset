/**
 *Submitted for verification at Etherscan.io on 2021-02-27
*/

pragma solidity =0.8.0;











contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}





contract LockStakingRewardSameTokenFixedAPY is ILockStakingRewards, ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public token;
    uint256 public rewardRate; 
    uint256 public immutable lockDuration; 
    uint256 public constant rewardDuration = 365 days; 

    mapping(address => uint256) public weightedStakeDate;
    mapping(address => mapping(uint256 => uint256)) public stakeLocks;
    mapping(address => mapping(uint256 => uint256)) public stakeAmounts;
    mapping(address => uint256) public stakeNonces;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    event RewardUpdated(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event Rescue(address to, uint amount);
    event RescueToken(address to, address token, uint amount);

    constructor(
        address _token,
        uint _rewardRate,
        uint _lockDuration
    ) {
        token = IERC20(_token);
        rewardRate = _rewardRate;
        lockDuration = _lockDuration;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function earned(address account) public view override returns (uint256) {
        return (_balances[account].mul(block.timestamp.sub(weightedStakeDate[account])).mul(rewardRate)) / (100 * rewardDuration);
    }

    function stakeWithPermit(uint256 amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external nonReentrant {
        require(amount > 0, "LockStakingRewardSameTokenFixedAPY: Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        uint previousAmount = _balances[msg.sender];
        uint newAmount = previousAmount.add(amount);
        weightedStakeDate[msg.sender] = (weightedStakeDate[msg.sender].mul(previousAmount) / newAmount).add(block.timestamp.mul(amount) / newAmount);
        _balances[msg.sender] = newAmount;

        // permit
        IERC20Permit(address(token)).permit(msg.sender, address(this), amount, deadline, v, r, s);
        
        token.safeTransferFrom(msg.sender, address(this), amount);
        uint stakeNonce = stakeNonces[msg.sender]++;
        stakeLocks[msg.sender][stakeNonce] = block.timestamp + lockDuration;
        stakeAmounts[msg.sender][stakeNonce] = amount;
        emit Staked(msg.sender, amount);
    }

    function stake(uint256 amount) external override nonReentrant {
        require(amount > 0, "LockStakingRewardSameTokenFixedAPY: Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        uint previousAmount = _balances[msg.sender];
        uint newAmount = previousAmount.add(amount);
        weightedStakeDate[msg.sender] = (weightedStakeDate[msg.sender].mul(previousAmount) / newAmount).add(block.timestamp.mul(amount) / newAmount);
        _balances[msg.sender] = newAmount;
        token.safeTransferFrom(msg.sender, address(this), amount);
        uint stakeNonce = stakeNonces[msg.sender]++;
        stakeLocks[msg.sender][stakeNonce] = block.timestamp + lockDuration;
        stakeAmounts[msg.sender][stakeNonce] = amount;
        emit Staked(msg.sender, amount);
    }

    function stakeFor(uint256 amount, address user) external override nonReentrant {
        require(amount > 0, "LockStakingRewardSameTokenFixedAPY: Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        uint previousAmount = _balances[user];
        uint newAmount = previousAmount.add(amount);
        weightedStakeDate[user] = (weightedStakeDate[user].mul(previousAmount) / newAmount).add(block.timestamp.mul(amount) / newAmount);
        _balances[user] = newAmount;
        token.safeTransferFrom(msg.sender, address(this), amount);
        uint stakeNonce = stakeNonces[user]++;
        stakeLocks[user][stakeNonce] = block.timestamp + lockDuration;
        stakeAmounts[user][stakeNonce] = amount;
        emit Staked(user, amount);
    }

    //A user can withdraw its staking tokens even if there is no rewards tokens on the contract account
    function withdraw(uint256 nonce) public override nonReentrant {
        uint amount = stakeAmounts[msg.sender][nonce];
        require(stakeAmounts[msg.sender][nonce] > 0, "LockStakingRewardSameTokenFixedAPY: This stake nonce was withdrawn");
        require(stakeLocks[msg.sender][nonce] < block.timestamp, "LockStakingRewardSameTokenFixedAPY: Locked");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        token.safeTransfer(msg.sender, amount);
        stakeAmounts[msg.sender][nonce] = 0;
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public override nonReentrant {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            weightedStakeDate[msg.sender] = block.timestamp;
            token.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function withdrawAndGetReward(uint256 nonce) external override {
        getReward();
        withdraw(nonce);
    }

    function updateRewardAmount(uint256 reward) external onlyOwner {
        rewardRate = reward;
        emit RewardUpdated(reward);
    }

    function rescue(address to, address tokenAddress, uint256 amount) external onlyOwner {
        require(to != address(0), "LockStakingRewardSameTokenFixedAPY: Cannot rescue to the zero address");
        require(amount > 0, "LockStakingRewardSameTokenFixedAPY: Cannot rescue 0");
        require(tokenAddress != address(token), "LockStakingRewardSameTokenFixedAPY: Cannot rescue staking/reward token");

        IERC20(tokenAddress).safeTransfer(to, amount);
        emit RescueToken(to, address(tokenAddress), amount);
    }

    function rescue(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "LockStakingRewardSameTokenFixedAPY: Cannot rescue to the zero address");
        require(amount > 0, "LockStakingRewardSameTokenFixedAPY: Cannot rescue 0");

        to.transfer(amount);
        emit Rescue(to, amount);
    }
}