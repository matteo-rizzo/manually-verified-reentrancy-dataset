/**
 *Submitted for verification at Etherscan.io on 2021-02-24
*/

/*  __________________________________________________________________________
                              STAKING POOL DETAILS |

    1.StartTime                   : Starts immediately when deployed.        
    2.Reward Cycle                : 7 days                                   
    3.StartTime and Reward Reset  : Once someone notify reward after 7 days.
    __________________________________________________________________________
    
    -Codezeros Developers
    -https://www.codezeros.com/
    __________________________________________________________________________
*/


pragma solidity ^0.5.0;






contract Context {
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}







contract LPTokenWrapper is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public APE_APE = IERC20(0x10B66bFF6600782116C266E3b1a5b8f9D951Ab87); // Must be changed with Presale

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        APE_APE.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        APE_APE.safeTransfer(msg.sender, amount);
    }
}

contract Staking is LPTokenWrapper {
    IERC20 public ape = IERC20(0x10B66bFF6600782116C266E3b1a5b8f9D951Ab87); // Must be changed with Presale
    uint256 public constant duration = 7 days;                          

    uint256 public starttime = block.timestamp;              //-----| Starts immediately after deploy |-----                           
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    address public rewardCollector;
    
    uint256 rewardAmount = 0;

 
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Rewarded(address indexed from, address indexed to, uint256 value);

    modifier checkStart() {
        require(
            block.timestamp >= starttime,
            "ApeApe staking pool not started yet."
        );
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
    
    function setupRewardCollector(address _rewardCollector) public returns (bool) {
        require(rewardCollector == address(0), "Reward Collector is already set");
        rewardCollector = _rewardCollector;
        
        return true;
    }


    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
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
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function stake(uint256 amount) public updateReward(msg.sender) checkStart {
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
    }

    function withdraw(uint256 amount)
        public
        updateReward(msg.sender)
    {
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
    }

    // withdraw stake and get rewards at once
    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender){
        uint256 reward = earned(msg.sender);

        if (reward > 0) {
            rewards[msg.sender] = 0;
        
            ape.safeTransfer(msg.sender, reward);
        }

        
    }

    function permitNotifyReward() public view returns (bool) {    //-----| If current reward session has completed |---------
        
        if(block.timestamp > starttime.add(duration)){
           return true;
        }
         
    }

    function calculateTenPercent(uint256 amount)
        internal
        pure
        returns (uint256)
    {
        return amount.mul(100).div(1000);
    }

    function calculateNinetyPercent(uint256 amount)
        internal
        pure
        returns (uint256)
    {
        return amount.mul(900).div(1000);
    }

    function notifyRewardAmount() external updateReward(address(0)) returns (bool){
        require(rewardCollector != address(0), "RewardCollector contract is not set");
        require(msg.sender == rewardCollector, "Only rewardCollector contract can call this method");

        require(permitNotifyReward() == true, "Cannot notify until 7 days are completed");
        
        rewardAmount = calculateNinetyPercent(ape.balanceOf(rewardCollector));
        rewardRate = rewardAmount.div(duration);
       
        lastUpdateTime = block.timestamp;
        starttime = block.timestamp; 
        periodFinish = block.timestamp.add(duration);

        return true;

    }
}