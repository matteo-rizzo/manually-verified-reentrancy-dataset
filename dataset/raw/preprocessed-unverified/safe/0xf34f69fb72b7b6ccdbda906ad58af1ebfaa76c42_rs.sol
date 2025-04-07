/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

// "SPDX-License-Identifier: MIT"
pragma solidity 0.7.3;

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}





contract EthanolVault is Ownable {
    using SafeMath for uint;
    IERC20 public EthanolAddress;
    address public admin;
    uint public rewardPool;
    uint public totalSharedRewards;

    mapping(address => uint) private rewardsEarned;
    mapping(address => Savings) private _savings;

    struct Savings {
        address user;
        uint startTime;
        uint duration;
        uint amount;
    }

    event _LockSavings(
        address indexed stakeholder, 
        uint indexed stake,
        uint indexed unlockTime
    );

    event _UnLockSavings(
        address indexed stakeholder,
        uint indexed value,
        uint indexed timestamp
    );

    event _RewardShared(
        uint indexed timestamp,
        uint indexed rewards
    );

    constructor(IERC20 _EthanolAddress) {
        EthanolAddress = _EthanolAddress;
        admin = _msgSender();
    }

    function shareReward(address[] memory _accounts, uint[] memory _rewards) public {
        require(_msgSender() == admin, "Caller is not a validator");
        uint _totalRewards = 0;

        for(uint i = 0; i < _accounts.length; i++) {
            address _user = _accounts[i];
            uint _reward = _rewards[i];
            _totalRewards = _totalRewards.add(_reward);
            rewardsEarned[_user] = rewardsEarned[_user].add(_reward);
        }
        
        totalSharedRewards = totalSharedRewards.add(_totalRewards);
        EthanolAddress.transferFrom(_msgSender(), address(this), _totalRewards);
        emit _RewardShared(block.timestamp, _totalRewards);
    }

    
    function checkRewards(address _user) public view returns(uint) {
        return rewardsEarned[_user];
    }
    
    function withdrawRewards(uint _amount) public {
        require(rewardsEarned[_msgSender()] > 0, "You have zero rewards to claim");

        rewardsEarned[_msgSender()] = rewardsEarned[_msgSender()].sub(_amount);
        uint _taxedAmount = _amount.mul(10).div(100);
        uint _totalBalance = _amount.sub(_taxedAmount);
        
        rewardPool = rewardPool.add(_taxedAmount);
        EthanolAddress.transfer(_msgSender(), _totalBalance);
    }

    function monthlySave(uint _numberOfMonths, uint _amount) public {
        uint _numberOfDays = _numberOfMonths.mul(31 days);
        timeLock(_numberOfDays, _amount);
    }

    function yearlySave(uint _amount) public {
        uint _numberOfDays = 365 days;
        timeLock(_numberOfDays, _amount);
    }

    function timeLock(uint _duration, uint _amount) private {
        require(_savings[_msgSender()].amount == 0, "Funds has already been locked");
        
        uint _taxAmount = _amount.mul(4).div(100);
        uint _balance = _amount.sub(_taxAmount);

        EthanolAddress.transferFrom(_msgSender(), address(this), _amount);
        
        rewardPool = rewardPool.add(_taxAmount);
        _savings[_msgSender()] = Savings(
            _msgSender(), 
            block.timestamp, 
            _duration, 
            _balance
        );  
        emit _LockSavings(_msgSender(), _balance, block.timestamp);             
    }

    function releaseTokens() public {
        require(
            block.timestamp > _savings[_msgSender()].startTime.add(_savings[_msgSender()].duration), 
            "Unable to withdraw funds while tokens is still locked"
        );
        require(_savings[_msgSender()].amount > 0, "You have zero savings");

        uint _amount = _savings[_msgSender()].amount;
        _savings[_msgSender()].amount = 0;

        
        if(_savings[_msgSender()].duration >= 365 days) {
            uint _rewards = _amount.mul(500).div(100);
            _amount = _amount.add(_rewards);
            
        } else {
            uint _rewards = _amount.mul(40).div(100);
            uint _numberOfMonths = _savings[_msgSender()].duration.div(31 days);
            _rewards = _rewards.mul(_numberOfMonths);
            _amount = _amount.add(_rewards);
        }
        
        rewardPool = rewardPool.sub(_amount);
        EthanolAddress.transfer(_msgSender(), _amount);
        emit _UnLockSavings(_msgSender(), _amount, block.timestamp);
    }
    
    function getLockedTokens(address _user) external view returns(uint) {
        return _savings[_user].amount;
    }

    receive() external payable {
        revert("You can not send token directly to the contract");
    }
}