/**
 *Submitted for verification at Etherscan.io on 2020-11-29
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.5.16;









contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {

        _notEntered = true;
    }

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

contract FarmingTokenWrapper is ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public farmingToken;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    constructor(address _farmingToken) internal {
        farmingToken = IERC20(_farmingToken);
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _totalSupply;
    }

    function balanceOf(address _account)
        public
        view
        returns (uint256)
    {
        return _balances[_account];
    }

    function _farm(address _beneficiary, uint256 _amount)
        internal
        nonReentrant
    {
        _totalSupply = _totalSupply.add(_amount);
        _balances[_beneficiary] = _balances[_beneficiary].add(_amount);
        farmingToken.safeTransferFrom(msg.sender, address(this), _amount);
    }

    function _withdraw(uint256 _amount)
        internal
        nonReentrant
    {
        _totalSupply = _totalSupply.sub(_amount);
        _balances[msg.sender] = _balances[msg.sender].sub(_amount);
        farmingToken.safeTransfer(msg.sender, _amount);
    }
}



contract RewardsDistributionRecipient is IRewardsDistributionRecipient {

    // @abstract
    // function notifyRewardAmount(uint256 reward) external;
    function getRewardToken() external view returns (IERC20);

    // This address has the ability to distribute the rewards
    address public rewardsDistributor;

    /** @dev Recipient is a module, governed by mStable governance */
    constructor(address _rewardsDistributor) 
        internal
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
}



contract Farming is FarmingTokenWrapper, RewardsDistributionRecipient {

    using StableMath for uint256;

    IERC20 public rewardsToken;

    uint256 public constant ONE_DAY = 86400; // in seconds

    uint256 public rewardPercent = 1; // 1%
    // Timestamp of farming duration
    uint256 public farmingDuration = 0;
    
    // Amount the user has farmed
    mapping(address => uint256) public userFarmedTokens;
    // Reward the user will get after farming period ends
    mapping(address => uint256) public rewards;
    // Rewards paid to user
    mapping(address => uint256) public userRewardsPaid;
    // Farm starting timestamp
    mapping(address => uint256) public farmStarted;
    // Farm ending timestamp
    mapping(address => uint256) public farmEnded;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount, address payer);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    /***************************************
                    CONSTRUCTOR
    ****************************************/

    constructor (
        address _farmingToken,
        address _rewardsToken,
        address _rewardsDistributor,
        uint256 _farmingDurationDays
    )
        public
        FarmingTokenWrapper(_farmingToken)
        RewardsDistributionRecipient(_rewardsDistributor)
    {
        rewardsToken = IERC20(_rewardsToken);
        farmingDuration = _farmingDurationDays.mul(ONE_DAY);
    }
    
    /***************************************
                    MODIFIERS
    ****************************************/

    modifier isAccount(address _account) {
        require(!Address.isContract(_account), "Only external owned accounts allowed");
        _;
    }
    
    /***************************************
                    ACTIONS
    ****************************************/

    function farm(uint256 _amount)
        external
    {
        _farm(msg.sender, _amount);
    }

    function _farm(address _beneficiary, uint256 _amount)
        internal
        isAccount(_beneficiary)
    {
        require(_amount >= 1, "Minimum staking amount is 1");
        
        super._farm(_beneficiary, _amount);
        
        userFarmedTokens[_beneficiary] = userFarmedTokens[_beneficiary].add(_amount);
        uint256 __userAmount = userFarmedTokens[_beneficiary];
        
        // calculation is on the basis:
        // (tokenAmount * 3hr * rewardPercent * 10**21) / 10**27
        // e.g: (50 * 3*3600 * 1% * 10**21) / 10**27 = 0.54 

        uint256 _rewardAmount = (__userAmount.mul(3 * 3600 * (rewardPercent.mul(10**21)))).div(10**27);
        rewards[_beneficiary] = _rewardAmount;
        farmStarted[_beneficiary] = block.timestamp;
        farmEnded[_beneficiary] = (block.timestamp).add(farmingDuration);

        emit Staked(_beneficiary, _amount, msg.sender);
    }

    function unfarm() 
        external 
    {
        require(block.timestamp >= farmEnded[msg.sender], "Reward cannot be claimed before 30 days");
        
        withdraw(balanceOf(msg.sender));
        claimReward();
        
        farmStarted[msg.sender] = 0;
        farmEnded[msg.sender] = 0;
    }

    function withdraw(uint256 _amount)
        public
        isAccount(msg.sender)
    {
        require(_amount > 0, "Cannot withdraw 0");
        require(block.timestamp >= farmEnded[msg.sender], "Reward cannot be claimed before 30 days");
        userFarmedTokens[msg.sender] = userFarmedTokens[msg.sender].sub(_amount);
        _withdraw(_amount);
        emit Withdrawn(msg.sender, _amount);
    }

    function claimReward()
        public
        isAccount(msg.sender)
    {
        require(block.timestamp >= farmEnded[msg.sender], "Reward cannot be claimed before 30 days");
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
            userRewardsPaid[msg.sender] = userRewardsPaid[msg.sender].add(reward);
            emit RewardPaid(msg.sender, reward);
        }
    }


    /***************************************
                    GETTERS
    ****************************************/

    function getRewardToken()
        external
        view
        returns (IERC20)
    {
        return rewardsToken;
    }

    function earned(address _account)
        public
        view
        returns (uint256)
    {
        return rewards[_account];
    }

    function tokensFarmed(address _account)
        public
        view
        returns (uint256)
    {
        return userFarmedTokens[_account];
    }


    /***************************************
                    ADMIN
    ****************************************/

    function sendRewardTokens(uint256 _amount) 
        public 
        onlyRewardsDistributor 
    {
        require(rewardsToken.transferFrom(msg.sender, address(this), _amount), "Transfering not approved!");
    }
    
    function withdrawRewardTokens(address receiver, uint256 _amount) 
        public 
        onlyRewardsDistributor 
    {
        require(rewardsToken.transfer(receiver, _amount), "Not enough tokens on contract!");
    }
    
    function withdrawFarmTokens(address receiver, uint256 _amount) 
        public 
        onlyRewardsDistributor 
    {
        require(farmingToken.transfer(receiver, _amount), "Not enough tokens on contract!");
    }
}