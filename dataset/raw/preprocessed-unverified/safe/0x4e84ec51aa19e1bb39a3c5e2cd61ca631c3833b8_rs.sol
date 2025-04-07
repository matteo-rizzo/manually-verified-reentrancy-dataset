/**
 *Submitted for verification at Etherscan.io on 2021-02-15
*/

pragma solidity ^0.5.0;

/*
    | Launch Date     : January 29, 2021 |
    | Reward Duration : 26 Weeks         | 
    | Total Rewards   : 80000            |
    | End Date        : July 16, 2021    |

*/





contract Context {

    constructor () internal { }
   
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
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
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}







contract IRewardDistributionRecipient is Ownable {
    address public rewardDistribution; 

    function notifyRewardAmount(uint256 reward) external;

    constructor () internal {
        rewardDistribution = owner(); 
    }

    modifier onlyRewardDistribution() {
        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

}

contract LPTokenWrapper is IRewardDistributionRecipient {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
   
    IERC20 public FAST_ETH_FLP = IERC20(0xbE380cb425D1094DEf80Ae5Dd3838422EbA2C4E3); //--|FLP|--

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
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        FAST_ETH_FLP.safeTransferFrom(_msgSender(), address(this), amount);
    }

    function withdraw(uint256 amount) public {
        _totalSupply = _totalSupply.sub(amount);
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount);
        FAST_ETH_FLP.safeTransfer(_msgSender(), amount);
    }
}
//-----------------------------------------------------------------------
// --------------------| REWARD AMOUNT: 80,000 |-----------------------
//-----------------------------------------------------------------------
contract FAST_GANG_Pool is LPTokenWrapper {
    IERC20 public fast = IERC20(0xC888A0Ab4831A29e6cA432BaBf52E353D23Db3c2);
    uint256 public constant DURATION = 26 weeks;  //-----| Ending |--------

    uint256 public starttime = 1611941400;       //-----| Friday 5:30 PM UTC |-----
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public rewardInterval = 48 hours;
    
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public lastTimeRewarded;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Rewarded(address indexed from, address indexed to, uint256 value);

    modifier checkStart(){
        require(block.timestamp >= starttime,"FAST_GANG_Pool not started yet.");
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

    //----------------------------| 48 hours |---------------------------
    function setRewardInterval(uint256  _rewardInterval) external onlyOwner {
           rewardInterval = _rewardInterval;
    }
 
    function collectRewardAmount() public onlyOwner {
            fast.safeTransfer(_msgSender(), fast.balanceOf(address(this)));
    }

    function tokensInThisPool() public view returns (uint256){
        return fast.balanceOf(address(this));
   }

    function stake(uint256 amount) public updateReward(_msgSender()) checkStart {
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        emit Staked(_msgSender(), amount);
    }

    function withdraw(uint256 amount) public updateReward(_msgSender()) checkStart {
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(_msgSender(), amount);

    }
     // withdraw stake and get rewards at once
    function exit() external {
        withdraw(balanceOf(_msgSender()));
        getReward();
    }

    function calculateFees(uint256 amount) internal pure returns (uint256) {
        return amount.mul(30).div(1000);
            
    }
    
    // reward can be withdrawn after 48 hour
    function getReward() public updateReward(_msgSender()) checkStart {
        uint256 reward = earned(_msgSender());

        uint256 leftTimeReward = block.timestamp.sub(lastTimeRewarded[_msgSender()]);
        require(leftTimeReward >= rewardInterval, "Can claim reward once 48 hour is completed");

        if (reward > 0) {
            rewards[_msgSender()] = 0;
            uint256 trueReward = reward;

            uint256 fee = calculateFees(trueReward);
            uint256 rewardMain = trueReward.sub(fee);
    
            fast.safeTransfer(_msgSender(), rewardMain);           //------|Transfer reward to Staker|-------------
            fast.safeTransfer(rewardDistribution, fee);      //-------| Transfer fee to owner |---------------

            lastTimeRewarded[_msgSender()] = block.timestamp;

            emit Rewarded(address(this), msg.sender, rewardMain);
            emit Rewarded(address(this), rewardDistribution, fee);
        }
    }


   
    function notifyRewardAmount(uint256 reward)
        external
        onlyRewardDistribution
        updateReward(address(0))
    {
        if (block.timestamp > starttime) {
          if (block.timestamp >= periodFinish) {
              rewardRate = reward.div(DURATION);
          } else {
              uint256 remaining = periodFinish.sub(block.timestamp);
              uint256 leftover = remaining.mul(rewardRate);
              rewardRate = reward.add(leftover).div(DURATION);
          }
          lastUpdateTime = block.timestamp;
          periodFinish = block.timestamp.add(DURATION);
          emit RewardAdded(reward);
        } else {
          rewardRate = reward.div(DURATION);
          lastUpdateTime = starttime;
          periodFinish = starttime.add(DURATION);
          emit RewardAdded(reward);
        }
    }
}