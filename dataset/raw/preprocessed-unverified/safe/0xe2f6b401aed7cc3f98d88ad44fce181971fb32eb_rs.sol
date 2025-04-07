/**
 *Submitted for verification at Etherscan.io on 2019-12-27
*/

pragma solidity >=0.5.12;



contract LitionPool {
    using SafeMath for uint256;
    
    event NewStake(address indexed staker, uint256 totalStaked, uint16 lockupPeriod, bool compound);
    event StakeFinishedByUser(address indexed staker, uint256 totalRecovered, uint256 index);
    event StakeRemoved(address indexed staker, uint256 totalRecovered, uint256 index);
    event RewardsToBeAccreditedDistributed(uint256 total);
    event RewardsToBeAccreditedUpdated(address indexed staker, uint256 total, uint256 delta);
    event RewardsAccredited(uint256 total);
    event RewardsAccreditedToStaker(address indexed staker, uint256 total);
    event CompoundChanged(address indexed staker, uint256 index);
    event RewardsWithdrawn(address indexed staker, uint256 total);
    event StakeDeclaredAsFinished(address indexed staker, uint256 index);
    event StakeIncreased(address indexed staker, uint256 index, uint256 total, uint256 delta);
    event TransferredToVestingAccount(uint256 total);
    
    address public owner;
    IERC20 litionToken;
    uint256 public lastRewardedBlock = 0;
    bool public paused = false;

    struct StakeList {
        Stake[] stakes;
        uint256 rewards;
        uint256 rewardsToBeAccredited;
    }
    
    struct Stake {
        uint256 createdOn;
        uint256 totalStaked;
        uint16 lockupPeriod;
        bool compound;
        bool isFinished;
    }
    
    address[] public stakers;
    mapping (address => StakeList) public stakeListBySender;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor(IERC20 _litionToken) public {
        owner = msg.sender;
        litionToken = _litionToken;
    }
    
    function _switchPaused() public onlyOwner {
        paused = !paused;
    }

    function _addStakerIfNotExist(address _staker) internal {
        for (uint256 i = 0; i < stakers.length; i++) {
            if (stakers[i] == _staker) {
                return;
            }
        }
        stakers.push(_staker);
    }
    
    function _getTotalRewardsToBeAccredited() public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < stakers.length; i++) {
            total += stakeListBySender[stakers[i]].rewardsToBeAccredited;
        }
        return total;
    }
    
    function _getTotalAmountsForClosers() public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < stakers.length; i++) {
            Stake[] memory stakes = stakeListBySender[stakers[i]].stakes;
            for (uint256 j = 0; j < stakes.length; j++) {
                if (!stakes[j].isFinished && _isLockupPeriodFinished(stakes[j].createdOn, stakes[j].lockupPeriod)) {
                    total = total.add(stakes[j].totalStaked);
                }
            }
        }
        return total;
    }
    
    function createNewStake(uint256 _amount, uint16 _lockupPeriod, bool _compound) public {
        require(!paused, "New stakes are paused");
        uint8 month = Date.getMonth(now);
        uint8 day = Date.getDay(now);
        //require((month == 2 && day < 21) || (day < 23), "You can start a new stake until the day 20 in Februrary and day 22 in other months");
        require(_isValidLockupPeriod(_lockupPeriod), "The lockup period is invalid");
        require(_amount >= 5000000000000000000000, "You must stake at least 5000 LIT");
        require(IERC20(litionToken).transferFrom(msg.sender, address(this), _amount), "Couldn't take the LIT from the sender");
        
        Stake memory stake = Stake({createdOn:now, 
                                    totalStaked:_amount, 
                                    lockupPeriod:_lockupPeriod, 
                                    compound:_compound, 
                                    isFinished:false});
                                    
        stakeListBySender[msg.sender].stakes.push(stake);
        _addStakerIfNotExist(msg.sender);
        
        emit NewStake(msg.sender, _amount, _lockupPeriod, _compound);
    }
    
    function switchCompound(uint256 _index) public {
        require(stakeListBySender[msg.sender].stakes.length > _index, "The stake doesn't exist");
        stakeListBySender[msg.sender].stakes[_index].compound = !stakeListBySender[msg.sender].stakes[_index].compound;
        emit CompoundChanged(msg.sender, _index);
    }
    
    function finishStake(uint256 _index) public {
        require(stakeListBySender[msg.sender].stakes.length > _index, "The stake doesn't exist");
        Stake memory stake = stakeListBySender[msg.sender].stakes[_index];
        require (stake.isFinished, "The stake is not finished yet");
        uint256 total = _closeStake(msg.sender, _index);
        
        emit StakeFinishedByUser(msg.sender, total, _index);
    }
    
     function withdrawRewards() public {
        require(stakeListBySender[msg.sender].rewards > 0, "You don't have rewards to withdraw");
        
        uint256 total = stakeListBySender[msg.sender].rewards;
        stakeListBySender[msg.sender].rewards = 0;

        require(litionToken.transfer(msg.sender, total));

        emit RewardsWithdrawn(msg.sender, total);
    }
    
    // Will be called monthly, at the end of each month
    function _accreditRewards() public {
        uint256 totalToAccredit = _getTotalRewardsToBeAccredited();
        require(IERC20(litionToken).transferFrom(msg.sender, address(this), totalToAccredit), "Couldn't take the LIT from the sender");

        for (uint256 i = 0; i < stakers.length; i++) {
            StakeList storage stakeList = stakeListBySender[stakers[i]];
            uint256 rewardsToBeAccredited = stakeList.rewardsToBeAccredited;
            if (rewardsToBeAccredited > 0) {
                stakeList.rewardsToBeAccredited = 0;
                stakeList.rewards += rewardsToBeAccredited;
                
                emit RewardsAccreditedToStaker(stakers[i], rewardsToBeAccredited);
            }
        }
        
        emit RewardsAccredited(totalToAccredit);
    }
    
    function areThereFinishers() public view returns(bool) {
        for (uint256 i = 0; i < stakers.length; i++) {
            Stake[] storage stakes = stakeListBySender[stakers[i]].stakes;
            for (uint256 j = 0; j < stakes.length; j++) {
                if (!stakes[j].isFinished && _isLockupPeriodFinished(stakes[j].createdOn, stakes[j].lockupPeriod)) {
                    return true;
                }
            }
        }
        return false;
    }
    
    // Will be called monthly, at the end of each month
    function _declareFinishers() public onlyOwner {
        uint256 totalForClosers = _getTotalAmountsForClosers();
        require(totalForClosers > 0, "There are no finishers");
        require(IERC20(litionToken).transferFrom(msg.sender, address(this), totalForClosers), "Couldn't take the LIT from the sender");

        for (uint256 i = 0; i < stakers.length; i++) {
            Stake[] storage stakes = stakeListBySender[stakers[i]].stakes;
            for (uint256 j = 0; j < stakes.length; j++) {
                if (!stakes[j].isFinished && _isLockupPeriodFinished(stakes[j].createdOn, stakes[j].lockupPeriod)) {
                    stakes[j].isFinished = true;
                    
                    emit StakeDeclaredAsFinished(stakers[i], j);
                }
            }
        }
    }
    
    function getTotalInStakeWithFinished() public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < stakers.length; i++) {
            Stake[] memory stakes = stakeListBySender[stakers[i]].stakes;
            for (uint256 j = 0; j < stakes.length; j++) {
                total = total.add(stakes[j].totalStaked);
            }
        }
        return total;
    }
    
    function getTotalInStake() public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < stakers.length; i++) {
            Stake[] memory stakes = stakeListBySender[stakers[i]].stakes;
            for (uint256 j = 0; j < stakes.length; j++) {
                if (!stakes[j].isFinished) {
                    total = total.add(stakes[j].totalStaked);
                }
            }
        }
        return total;
    }
    
    function getTotalStakes() public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < stakers.length; i++) {
            Stake[] memory stakes = stakeListBySender[stakers[i]].stakes;
            for (uint256 j = 0; j < stakes.length; j++) {
                if (!stakes[j].isFinished) {
                    total += 1;
                }
            }
        }
        return total;
    }
    
    function getTotalStakers() public view returns (uint256) {
        return stakers.length;
    }
    
    function getLockupFinishTimestamp(address _staker, uint256 _index) public view returns (uint256) {
        require(stakeListBySender[_staker].stakes.length > _index, "The stake doesn't exist");
        Stake memory stake = stakeListBySender[_staker].stakes[_index];
        return stake.createdOn + stake.lockupPeriod * (30 days);
    }
    
    function _removeStaker(address _staker, uint256 _index) public onlyOwner {
        require(stakeListBySender[_staker].stakes.length > _index, "The stake doesn't exist");
        uint256 total = _closeStake(_staker, _index);

        emit StakeRemoved(_staker, total, _index);
    }

    function _closeStake(address _staker, uint256 _index) internal returns (uint256) {
        uint256 total = stakeListBySender[_staker].stakes[_index].totalStaked;

        _removeStakeByIndex(_staker, _index);
        if (stakeListBySender[msg.sender].stakes.length == 0) {
            _removeStakerByValue(_staker);
        }
        
        require(litionToken.transfer(_staker, total));

        return total;
    }
    
    function _findStaker(address _value) internal view returns(uint) {
        uint i = 0;
        while (stakers[i] != _value) {
            i++;
        }
        return i;
    }

    function _removeStakerByValue(address _value) internal {
        uint i = _findStaker(_value);
        _removeStakerByIndex(i);
    }

    function _removeStakerByIndex(uint _i) internal {
        while (_i<stakers.length-1) {
            stakers[_i] = stakers[_i+1];
            _i++;
        }
        stakers.length--;
    }
    
    function _removeStakeByIndex(address _staker, uint _i) internal {
        Stake[] storage stakes = stakeListBySender[_staker].stakes;
        while (_i<stakes.length-1) {
            stakes[_i] = stakes[_i+1];
            _i++;
        }
        stakes.length--;
    }
    
    function _extractRemainingLitSentByMistake(address _sendTo) public onlyOwner {
        require(stakers.length == 0, "There are still stakers in the contract");
        uint256 totalBalance = litionToken.balanceOf(address(this));
        require(litionToken.transfer(_sendTo, totalBalance));
    }
    
    function _extractCertainLitSentByMistake(uint256 amount, address _sendTo) public onlyOwner {
        require(litionToken.transfer(_sendTo, amount));
    }
    
    function _isValidLockupPeriod(uint16 n) internal pure returns (bool) {
        if (n == 1) {
            return true;
        }
        else if (n == 3) {
            return true;
        }
        else if (n == 6) {
            return true;
        }
        else if (n == 12) {
            return true;
        }
        return false;
    }
    
    function _isValidAndNotFinished(address _staker, uint256 _index) internal view returns (bool) {
        if (stakeListBySender[_staker].stakes.length <= _index) {
            return false;
        }
        return !stakeListBySender[_staker].stakes[_index].isFinished;
    }
    
    function _isLockupPeriodFinished(uint256 _timestamp, uint16 _lockupPeriod) internal view returns (bool) {
        return now > _timestamp + _lockupPeriod * (30 days);
    }

    function _transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner can't be the zero address");
        owner = newOwner;
    }

    // Will be called every day to distribute the accumulated new MiningReward events coming from LitionRegistry
    function _updateRewardsToBeAccredited(uint256 _lastMiningRewardBlock, uint256 _amount) public onlyOwner {
        lastRewardedBlock = _lastMiningRewardBlock;
        
        //Will distribute the amount between all stakes of all stakers
        //Won't consider any stake marked as isFinished
        
        uint256 fees = _amount.mul(5) / 100; // Amount the validator will keep for himself
        uint256 totalParts = _calculateParts();

        _distributeBetweenStakers(totalParts, _amount.sub(fees));

        emit RewardsToBeAccreditedDistributed(_amount);
    }
    
    function _distributeBetweenStakers(uint256 _totalParts, uint256 _amountMinusFees) internal {
        uint256 totalTransferred = 0;

        for (uint256 i = 0; i < stakers.length; i++) {
            StakeList storage stakeList = stakeListBySender[stakers[i]];
            
            for (uint256 j = 0; j < stakeList.stakes.length; j++) {
            
                if (!_isValidAndNotFinished(stakers[i], j)) {
                    continue;
                }
                
                Stake storage stake = stakeList.stakes[j];
                
                uint256 amountToTransfer = _getAmountToTransfer(_totalParts, _amountMinusFees, stake.lockupPeriod, stake.totalStaked);
                totalTransferred = totalTransferred.add(amountToTransfer);
                
                if (stake.compound) {
                    stake.totalStaked = stake.totalStaked.add(amountToTransfer);

                    emit StakeIncreased(stakers[i], j, stake.totalStaked, amountToTransfer);
                }
                else {
                    stakeList.rewardsToBeAccredited = stakeList.rewardsToBeAccredited.add(amountToTransfer);
                    
                    emit RewardsToBeAccreditedUpdated(stakers[i], stakeList.rewardsToBeAccredited, amountToTransfer);
                }
            }
        }
    }

    function _calculateParts() internal view returns (uint256) {
        uint256 divideInParts = 0;
        
        for (uint256 i = 0; i < stakers.length; i++) {
            StakeList memory stakeList = stakeListBySender[stakers[i]];
            
            for (uint256 j = 0; j < stakeList.stakes.length; j++) {
                if (!_isValidAndNotFinished(stakers[i], j)) {
                    continue;
                }
                
                Stake memory stake = stakeList.stakes[j];
                if (stake.lockupPeriod == 1) {
                    divideInParts = divideInParts.add(stake.totalStaked.mul(12));
                }
                else if (stake.lockupPeriod == 3) {
                    divideInParts = divideInParts.add(stake.totalStaked.mul(14));
                }
                else if (stake.lockupPeriod == 6) {
                    divideInParts = divideInParts.add(stake.totalStaked.mul(16));
                }
                else if (stake.lockupPeriod == 12) {
                    divideInParts = divideInParts.add(stake.totalStaked.mul(18));
                }
            }
        }
        
        return divideInParts;
    }
    
    function getStaker(address _staker) external view returns (uint256 rewards, uint256 rewardsToBeAccredited, uint256 totalStakes) {
        StakeList memory stakeList = stakeListBySender[_staker];
        rewards = stakeList.rewards;
        rewardsToBeAccredited = stakeList.rewardsToBeAccredited;
        totalStakes = stakeList.stakes.length;
    }
    
    function getStake(address _staker, uint256 _index) external view returns (uint256 createdOn, uint256 totalStaked, uint16 lockupPeriod, bool compound, bool isFinished, uint256 lockupFinishes) {
        require(stakeListBySender[_staker].stakes.length > _index, "The stake doesn't exist");
        Stake memory stake = stakeListBySender[_staker].stakes[_index];
        createdOn = stake.createdOn;
        totalStaked = stake.totalStaked;
        lockupPeriod = stake.lockupPeriod;
        compound = stake.compound;
        isFinished = stake.isFinished;
        lockupFinishes = getLockupFinishTimestamp(_staker, _index);
    }
    
    function _getAmountToTransfer(uint256 _totalParts,  uint256 _amount, uint16 _lockupPeriod, uint256 _rewards) internal pure returns (uint256) {
        uint256 factor;
        
        if (_lockupPeriod == 1) {
            factor = 12;
        }
        else if (_lockupPeriod == 3) {
            factor = 14;
        }
        else if (_lockupPeriod == 6) {
            factor = 16;
        }
        else if (_lockupPeriod == 12) {
            factor = 18;
        }

        return _amount.mul(factor).mul(_rewards).div(_totalParts);
    }
    
    function _transferLITToVestingAccount(uint256 total) public onlyOwner {
        require(litionToken.transfer(msg.sender, total));
        emit TransferredToVestingAccount(total);
    }

    function() external payable {
        revert();
    }
}



