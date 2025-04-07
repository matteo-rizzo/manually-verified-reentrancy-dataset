/**
 *Submitted for verification at Etherscan.io on 2020-11-29
*/

pragma solidity ^0.5.0;

/**
  * @title ArtDeco Finance
  *
  * @notice LPReward contract : Stake reward for Liquidity Provider
  * 
  */








/**
 * @dev Standard math utilities missing in the Solidity language.
 */






contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}






/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */





contract Governance {

    address public _governance;

    constructor() public {
        _governance = tx.origin;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance)  public  onlyGovernance
    {
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }


}


contract LPTokenWrapper is IPool,Governance {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    // APWR-ETH pair of UNISWAP
    IERC20 public _lpToken = IERC20(0xa7db6B6B38224AeDbae425E1D3D5948aa2dF08B6);

    address public _playerLink = address(0x4eD7A3721F203Cf108b4279061B36CC20b14E57A);

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    uint256 private _totalWeight;
    mapping(address => uint256) private _weightBalances;
    
    address public _stakeLevel = address(0x29630BDDc51dA9212f718a710B9e85fe8f3B2879);


    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function setStakeLevel(address contractaddr)  public  onlyGovernance{
        _stakeLevel = contractaddr;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function balanceOfWeight(address account) public view returns (uint256) {
        return _weightBalances[account];
    }



    function totalWeight() public view returns (uint256) {
        return _totalWeight;
    }


    function stake(uint256 amount, string memory affCode) public {
        
        _totalSupply = _totalSupply.add(amount);
 
        _balances[msg.sender] = _balances[msg.sender].add(amount);
    
        if( _stakeLevel != address(0x0)){ 
            _totalWeight = _totalWeight.sub(_weightBalances[msg.sender]);
            IStakeLevel(_stakeLevel).supplyLP(msg.sender, amount);

            _weightBalances[msg.sender] = IStakeLevel(_stakeLevel).getSupplyWeight(msg.sender);
            _totalWeight = _totalWeight.add(_weightBalances[msg.sender]);
        }else{
            _totalWeight = _totalSupply;
            _weightBalances[msg.sender] = _balances[msg.sender];
        }
     
        _lpToken.safeTransferFrom(msg.sender, address(this), amount);

      
        if (!IPlayerLink(_playerLink).hasRefer(msg.sender)) {
            IPlayerLink(_playerLink).bindRefer(msg.sender, affCode);
        }
      
        
    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "amout > 0");

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        
        if( _stakeLevel != address(0x0)){ 
            _totalWeight = _totalWeight.sub(_weightBalances[msg.sender]);
            IStakeLevel(_stakeLevel).withdrawLP(msg.sender, amount);
            _weightBalances[msg.sender] = IStakeLevel(_stakeLevel).getSupplyWeight(msg.sender);
            _totalWeight = _totalWeight.add(_weightBalances[msg.sender]);

        }else{
            _totalWeight = _totalSupply;
            _weightBalances[msg.sender] = _balances[msg.sender];
        }

        _lpToken.safeTransfer( msg.sender, amount);
    }

    
}



contract LPReward is LPTokenWrapper{
    using SafeERC20 for IERC20;

    IERC20 public _artd = IERC20(0xA23F8462d90dbc60a06B9226206bFACdEAD2A26F);
    
    address public _teamWallet = 0x3b2b4f84cFE480289df651bE153c147fa417Fb8A;
    address public _rewardPool = 0x4D732FA01032b41eE0fA152398B22Bfab6689DCb;

    uint256 public constant DURATION = 30 days;   // 30 days;

    uint256 public _initReward = 300 * 1e18;   //300 * 1e18;
    uint256 public _startTime =  now + 365 days;
    uint256 public _periodFinish = 0;
    uint256 public _rewardRate = 0;
    uint256 public _lastUpdateTime;
    uint256 public _rewardPerTokenStored;

    uint256 public _teamRewardRate = 500;
    uint256 public _poolRewardRate = 1000;
    uint256 public _baseRate = 10000;
    uint256 public _punishTime = 5 days;

    mapping(address => uint256) public _userRewardPerTokenPaid;
    mapping(address => uint256) public _rewards;
    mapping(address => uint256) public _lastStakedTime;

    bool public _hasStart = false;

    mapping (address => uint256) private stakerId;
    address[] private stakerAddr;
    
    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);


    modifier updateReward(address account) {
        _rewardPerTokenStored = rewardPerToken();
        _lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            _rewards[account] = earned(account);
            _userRewardPerTokenPaid[account] = _rewardPerTokenStored;
        }
        _;
    }

    constructor()  public
    {
        stakerAddr.push(0x6666666666666666666666666666666666666666);
    }
    
    /* Fee collection for any other token */
    function seize(IERC20 token, uint256 amount) external onlyGovernance{
        require(token != _artd, "reward");
        require(token != _lpToken, "stake");
        token.safeTransfer(_governance, amount);
    }

    function setTeamRewardRate( uint256 teamRewardRate ) public onlyGovernance{
        _teamRewardRate = teamRewardRate;
    }

    function setPoolRewardRate( uint256  poolRewardRate ) public onlyGovernance{
        _poolRewardRate = poolRewardRate;
    }

    function setWithDrawPunishTime( uint256  punishTime ) public onlyGovernance{
        _punishTime = punishTime;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, _periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalWeight() == 0) {
            return _rewardPerTokenStored;
        }
        return
            _rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(_lastUpdateTime)
                    .mul(_rewardRate)
                    .mul(1e18)
                    .div(totalWeight())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOfWeight(account)
                .mul(rewardPerToken().sub(_userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(_rewards[account]);
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount, string memory affCode)
        public
        updateReward(msg.sender)
        checkHalve
        checkStart
    {
        require(amount > 0, "Cannot stake 0");
        super.stake(amount, affCode);

        addUserId();
        _lastStakedTime[msg.sender] = now;

        emit Staked(msg.sender, amount);
    }
/*
    function XXX_stake()
        public
    {
        addUserId();
        _lastStakedTime[msg.sender] = now;
    }
    
    function XXXX_withdrawall() public
    {
        quitUser(msg.sender);
    }
*/    
    
    // To take back all LP what last staked
    function withdrawall()
        public
        updateReward(msg.sender)
        checkHalve
        checkStart
    {
        uint256 amount = balanceOf(msg.sender);
        super.withdraw(amount);
        
        quitUser(msg.sender);
        
        emit Withdrawn(msg.sender, amount);
    }
    
    // To take back a part of staked LP
    function withdraw(uint256 amount)
        public
        updateReward(msg.sender)
        checkHalve
        checkStart
    {
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }


    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
        
        quitUser(msg.sender);
    }

    function getReward() public updateReward(msg.sender) checkHalve checkStart {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            _rewards[msg.sender] = 0;

            uint256 fee = IPlayerLink(_playerLink).settleReward(msg.sender, reward);
            if(fee > 0){
                _artd.safeTransfer(_playerLink, fee);
            }
            
            uint256 teamReward = reward.mul(_teamRewardRate).div(_baseRate);
            if(teamReward>0){
                _artd.safeTransfer(_teamWallet, teamReward);
            }
            uint256 leftReward = reward.sub(fee).sub(teamReward);
            uint256 poolReward = 0;

            //withdraw time check

            if(now  < (_lastStakedTime[msg.sender] + _punishTime) ){
                poolReward = leftReward.mul(_poolRewardRate).div(_baseRate);
            }
            if(poolReward>0){
                _artd.safeTransfer(_rewardPool, poolReward);
                leftReward = leftReward.sub(poolReward);
            }

            if(leftReward>0){
                _artd.safeTransfer(msg.sender, leftReward );
            }
      
            emit RewardPaid(msg.sender, leftReward);
        }
    }

    modifier checkHalve() {
        if (block.timestamp >= _periodFinish) {
            _initReward = _initReward.mul(50).div(100);

            _artd.mint(address(this), _initReward);

            _rewardRate = _initReward.div(DURATION);
            _periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(_initReward);
        }
        _;
    }
    
    modifier checkStart() {
        require(block.timestamp > _startTime, "not start");
        _;
    }

    // set fix time to start reward
    function startReward(uint256 startTime)
        external
        onlyGovernance
        updateReward(address(0))
    {
        require(_hasStart == false, "has started");
        _hasStart = true;
        
        _startTime = startTime;

        _rewardRate = _initReward.div(DURATION); 
        _artd.mint(address(this), _initReward);

        _lastUpdateTime = _startTime;
        _periodFinish = _startTime.add(DURATION);

        emit RewardAdded(_initReward);
    }

    //for extra reward
    function notifyRewardAmount(uint256 reward)
        external
        onlyGovernance
        updateReward(address(0))
    {
        IERC20(_artd).safeTransferFrom(msg.sender, address(this), reward);
        if (block.timestamp >= _periodFinish) {
            _rewardRate = reward.div(DURATION);
        } else {
            uint256 remaining = _periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(_rewardRate);
            _rewardRate = reward.add(leftover).div(DURATION);
        }
        _lastUpdateTime = block.timestamp;
        _periodFinish = block.timestamp.add(DURATION);
        emit RewardAdded(reward);
    }
    
    function stakeInfo(uint256 number) public view returns( address, uint256, uint256, uint256 )
    {
        address staker = stakerAddr[number];
        uint256 balance = balanceOf(staker);
        uint256 weight = balanceOfWeight(staker);
        uint256 earnedacc = earned(staker);
        return (staker, balance, weight, earnedacc);
    }    
    
    function addUserId() private 
    {
       if( stakerId[msg.sender] == 0 )
       {
          uint256 index = stakerAddr.push(msg.sender)-1;
          stakerId[msg.sender] = index;
       }
    }

    function quitUser(address account) private returns(uint256 index)
    {
        uint256 toDeleteId = stakerId[account];
        address lastaddr = stakerAddr[stakerAddr.length-1];
        if( toDeleteId == (stakerAddr.length-1) )
        {
            stakerId[lastaddr] = 0;
        }
        else
        {
            stakerId[lastaddr] = toDeleteId;
        }
        
        stakerAddr[toDeleteId] = lastaddr;
        stakerAddr.pop();
        
        //delete stakerAddr[stakerAddr.length-1];
        
        
        return toDeleteId;   
    } 
      
    function stakerid(address account) public view returns( uint256 ) 
    {
        return stakerId[account];
    }  
    
    function stakeraddr(uint256 number) public view returns( address )
    {
        return stakerAddr[number];
    }   
    
    function stakeCount() public view returns( uint )
    {
        return stakerAddr.length-1;
    }  
    
}