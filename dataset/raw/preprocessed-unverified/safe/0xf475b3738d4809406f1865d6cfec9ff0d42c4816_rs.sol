/**
 *Submitted for verification at Etherscan.io on 2021-06-23
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */




abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}






abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
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
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

abstract contract IRewardDistributionRecipient is Ownable {
    address rewardDistribution;

    modifier onlyRewardDistribution() {
        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistributionAdmin(address _rewardDistribution)
        internal
    {
        require(rewardDistribution == address(0), "Reward distribution Admin already set");
        rewardDistribution = _rewardDistribution;
    }
    
    function updateRewardDistributionAdmin(address _rewardDistribution) public onlyOwner {
        require(rewardDistribution == address(0), "Reward distribution Admin already set");
        rewardDistribution = _rewardDistribution;
    }
    
}

contract GoldFarmFaaS is IRewardDistributionRecipient, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;
    
    IERC20 public rewardToken;// FEGtoken BSC20
    
    IERC20 public rewardToken1;// GoldFarm BSC20
    
    IERC20 public lpToken; // Direwolftoken.com BSC20
    
    address public devAddy = 0xdaC47d05e1aAa9Bd4DA120248E8e0d7480365CFB;//collects pool use fee
    uint256 public devtxfee = 1; //Fee for pool use, sent to GOLD farming pool
    uint256 public txfee = 2; //Amount of frictionless rewards of the LP token 
    
    uint256 public duration = 90 days;
    uint256 public duration1 = 90 days;
    bool public perform = true;
    
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    
    uint256 public periodFinish1 = 0;
    uint256 public rewardRate1 = 0;
    uint256 public lastUpdateTime1;
    uint256 public rewardPerTokenStored1;
    mapping(address => uint256) public userRewardPerTokenPaid1;
    mapping(address => uint256) public rewards1;
    
    mapping(address => uint) public farmTime; 
    bool public farmBreaker = false; // farm can be lock by admin,, default unlocked type=0
    bool public rewardBreaker = false; // getreward can be lock by admin,, default unlocked type=1
    bool public reward1Breaker = false; // getreward1 can be lock by admin,, default unlocked type=2
    bool public withdrawBreaker = false; // withdraw can be lock by admin,, default unlocked type=3
    
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    
    mapping(address => uint256) public lpTokenReward;

    event RewardAdded(uint256 reward);
    event Farmed(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    
    address[] public farmers;
    
    struct USER{
        bool initialized;
    }
    
    mapping(address => USER) stakers;

    constructor(address _lpToken, address _rewardToken, address _rewardToken1) {
        rewardToken = IERC20(_rewardToken);
        rewardToken1 = IERC20(_rewardToken1);
        lpToken = IERC20(_lpToken);
        setRewardDistributionAdmin(msg.sender);

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
    
    modifier updateReward1(address account) {
        rewardPerTokenStored1 = rewardPerToken1();
        lastUpdateTime1 = lastTimeRewardApplicable1();
        if (account != address(0)) {
            rewards1[account] = earned1(account);
            userRewardPerTokenPaid1[account] = rewardPerTokenStored1;
        }
        _;
    }


    modifier noContract(address account) {
        require(Address.isContract(account) == false, "Contracts are not allowed to interact with the farm");
        _;
    }
    
    function setdevAddy(address _addy) public onlyOwner {
        require(_addy != address(0), " Setting 0 as Addy "); 
        devAddy = _addy;
    }
    
    function setBreaker(bool _breaker, uint256 _type) external onlyOwner {
        if(_type==0){
            farmBreaker =_breaker;
            
        }
        else if(_type==1){
            rewardBreaker=_breaker;
            
        }
        else if(_type==2){
            reward1Breaker=_breaker;
            
        }else if(_type==3){
            withdrawBreaker=_breaker;
            
        }
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    function recoverLostTokensAfterFarmExpired(IERC20 _token, uint256 amount) external onlyOwner {
        // Recover lost tokens can only be used after farming duration expires
        require(duration < block.timestamp, "Cannot use if farm is live");
        _token.safeTransfer(owner(), amount);
    }
    
    receive() external payable {
        // Prevent ETH from being sent to the farming contract
        revert();
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }
    
    function lastTimeRewardApplicable1() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish1);
    }
    
    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e9)
                    .div(totalSupply())
            );
    }
    
    function rewardPerToken1() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored1;
        }

        return
            rewardPerTokenStored1.add(
                lastTimeRewardApplicable1()
                    .sub(lastUpdateTime1)
                    .mul(rewardRate1)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }



    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e9)
                .add(rewards[account]);
    }
    
    function earned1(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken1().sub(userRewardPerTokenPaid1[account]))
                .div(1e18)
                .add(rewards1[account]);
    }
    
    function isStakeholder(address _address)
       public
       view
       returns(bool)
   {
       
       if(stakers[_address].initialized) return true;
       else return false;
   }
   
   function addStakeholder(address _stakeholder)
       internal
   {
       (bool _isStakeholder) = isStakeholder(_stakeholder);
       if(!_isStakeholder) {
           farmTime[msg.sender] =  block.timestamp;
           stakers[_stakeholder].initialized = true;
       }
   }

    function farm(uint256 amount) external updateReward(msg.sender) updateReward1(msg.sender) noContract(msg.sender) nonReentrant {
        require(farmBreaker == false, "Admin Restricted function temporarily 0");
        require(amount > 0, "Cannot farm nothing");

        lpToken.safeTransferFrom(msg.sender, address(this), amount);
        
        uint256 devtax = amount.mul(devtxfee).div(100);
        uint256 _txfee = amount.mul(txfee).div(100);
        
        lpToken.safeTransfer(address(devAddy), devtax);
        
        uint256 finalAmount = amount.sub(_txfee).sub(devtax);
        
        _totalSupply = _totalSupply.add(finalAmount);
        _balances[msg.sender] = _balances[msg.sender].add(finalAmount);
        
        addStakeholder(msg.sender);
        
        emit Farmed(msg.sender,finalAmount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) updateReward1(msg.sender) noContract(msg.sender) nonReentrant {
        require(withdrawBreaker == false, "Admin Restricted function temporarily 3");
        require(amount > 0, "Cannot withdraw nothing");
        
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        lpToken.safeTransfer(msg.sender, amount);
        
        if( _balances[msg.sender] == 0) {
            stakers[msg.sender].initialized = false;
        }
        emit Withdrawn(msg.sender, amount);
        
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        ClaimLPReward(); 
        getReward();
        getReward1();
        }

    function getReward() public updateReward(msg.sender) noContract(msg.sender) {
        require(rewardBreaker == false, "Admin Restricted function temporarily 1");
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }
    
    function getReward1() public updateReward1(msg.sender) noContract(msg.sender) {
        require(reward1Breaker == false, "Admin Restricted function temporarily 2");
        uint256 reward1 = earned1(msg.sender);
        if (reward1 > 0) {
            rewards1[msg.sender] = 0;
            rewardToken1.safeTransfer(msg.sender, reward1);
            emit RewardPaid(msg.sender, reward1);
        }
    }
    
    function setFarmRewards(uint256 reward, uint256 _duration)
        public
        onlyRewardDistribution
        nonReentrant
        updateReward(address(0))
    {
        require(_duration > 0, "Duration must not be 0");
        if(rewardRate.mul(duration) <= rewardToken.balanceOf(address(this))){
            duration = _duration.mul(1 days);
            if (block.timestamp >= periodFinish) {
                rewardRate = reward.div(duration);
            } else {
                uint256 remaining = periodFinish.sub(block.timestamp);
                uint256 leftover = remaining.mul(rewardRate);
                rewardRate = reward.add(leftover).div(duration);
            }
            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(duration);
            require(rewardRate.mul(duration) <= rewardToken.balanceOf(address(this)), "Insufficient reward");
            emit RewardAdded(reward);
        }
    }
    
    function setFarmRewards1(uint256 _reward1, uint256 _duration2)
        public
        onlyRewardDistribution
        nonReentrant
        updateReward1(address(0))
    {
        require(_duration2 > 0, "Duration must not be 0");
        if(rewardRate1.mul(duration1) <= rewardToken1.balanceOf(address(this))){
            duration1 = _duration2.mul(1 days);
            if (block.timestamp >= periodFinish1) {
                rewardRate1 = _reward1.div(duration1);
            } else {
                uint256 remaining1 = periodFinish1.sub(block.timestamp);
                uint256 leftover1 = remaining1.mul(rewardRate1);
                rewardRate1 = _reward1.add(leftover1).div(duration1);
            }
            lastUpdateTime1 = block.timestamp;
            periodFinish1 = block.timestamp.add(duration1);
            require(rewardRate1.mul(duration1) <= rewardToken1.balanceOf(address(this)), "Insufficient reward");
            emit RewardAdded(_reward1);
        }
    }
    
    uint256 public aclaimed = 0;
    
    function DisributeLPTxFunds1() public { // distribute any TX rewards tokens sent to pool for tokens with TX rewards
        
        
        uint256 balanceOfContract = lpToken.balanceOf(address(this));
        uint256 transferToAmount = balanceOfContract.sub(_totalSupply.add(aclaimed));
        
        aclaimed = aclaimed.add(transferToAmount);
                   
        if(transferToAmount > 0 ){
            for (uint256 s = 0; s < farmers.length; s++){
                 address abc = farmers[s];
                 uint256 blnc = balanceOf(abc);
                 if(blnc > 0) {
                     uint256 userShare  = (transferToAmount).mul(blnc).div(_totalSupply); 
                       
                       lpTokenReward[abc] = lpTokenReward[abc].add(userShare);
                       
                       emit RewardAdded(userShare);
                 }
           }
        }
    }
    
    function ClaimAllRewards() public {
        ClaimLPReward();
        getReward();
        getReward1();
        if(perform==true){
        DisributeLPTxFunds1();}
    }
    
    
    function onePercent(uint256 _tokens) private pure returns (uint256){
        uint256 roundValue = _tokens.ceil(100);
        uint onePercentofTokens = roundValue.mul(100).div(100 * 10**uint(2));
        return onePercentofTokens;
    }
    
    function emergencySaveLostTokens(address _token) external onlyOwner {
        require(IERC20(_token).transfer(owner(), IERC20(_token).balanceOf(address(this))), "Error in retrieving tokens");
    }
    
    function ClaimLPReward() public {
        address _addy = msg.sender;
        
        if(lpTokenReward[_addy] > 0 ){
            aclaimed = aclaimed.sub(lpTokenReward[_addy]);
            
            lpToken.safeTransfer(msg.sender, lpTokenReward[_addy]);
            lpTokenReward[_addy] = 0;
        }
    }
    
    function changePerform(bool _bool) external onlyOwner{
        perform = _bool;
    }
}