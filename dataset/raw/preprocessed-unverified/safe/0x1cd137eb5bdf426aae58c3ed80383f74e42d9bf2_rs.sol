// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

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



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


 /* @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
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

contract SpazStake is Ownable {
    using SafeMath for uint256;
    
    uint256 private _dailyROI = 100; // 1%
    uint256 private _immatureUnstakeTax = 2000; //20%
    uint256 private _referralcommission = 25; // 0.25%
    
    IERC20 private _spazToken;
    uint256 private _tokenDecimals = 1e8;
    uint256 private _stakeDuration = 100 days;
    uint256 private _unitDuration = 1 days;
    uint256 private _withdrawalInterval = 1 weeks;
    uint256 private _stakingPool = _tokenDecimals.mul(5000000);
    uint256 private _referralPool = _tokenDecimals.mul(12500);
    uint256 private _minimumStakAmount = _tokenDecimals.mul(500);
    uint256 private _maximumStakeAmount = _tokenDecimals.mul(100000);
    
    uint256 private _totalStaked;
    uint256 private _totalStakers;
    uint256 private _totalDividend;
    uint256 private _refBonusPulled;
    
    struct Stake {
        bool exists;
        uint256 createdAt;
        uint256 amount;
        uint256 withdrawn;
        uint256 lastWithdrewAt;
        uint256 refBonus;
    }
    
    mapping(address => Stake) stakers;
    
    event OnStake(address indexed staker, uint256 amount);
    event OnUnstake(address indexed staker, uint256 amount);
    event OnWithdraw(address indexed staker, uint256 amount);
    
    constructor() {
        _spazToken = IERC20(0x810908B285f85Af668F6348cD8B26D76B3EC12e1);
    }
    
    function stake(uint256 _amount, address _referrer) public {
        require(!stakingPoolFilled(_amount), "Stake: staking pool filled");
        require(!isStaking(_msgSender()), "Stake: Already staking");
        require(_amount >= minimumStakeAmount(), "Stake: Not enough amount to stake");
        require(_amount <= maximumStakeAmount(), "Stake: More than acceptable stake amount");
        require(_spazToken.transferFrom(_msgSender(), address(this), _amount), "Stake: Token transfer failed");
                
        _createStake(_msgSender(), _amount);
        _handleReferrer(_referrer, _amount);
    }
    
    function withdraw() public {
        require(isStaking(_msgSender()), "Withdraw: sender is not a staking");
        Stake storage targetStaker = stakers[_msgSender()];
        uint256 lastWithdrawalTillNow = block.timestamp.sub(targetStaker.lastWithdrewAt);
        // maximum: once per week;
        require(targetStaker.lastWithdrewAt == 0 || lastWithdrawalTillNow > _withdrawalInterval, "Withdraw: can only withdraw once in a week");
        uint256 roi = _stakingROI(targetStaker).sub(targetStaker.withdrawn); // sub past withdrawals
        
        require(roi > 0, "Withdraw: Withdrawable amount is zero");
        uint256 total = roi.add(targetStaker.refBonus);
        _totalDividend = _totalDividend.add(total);

        targetStaker.withdrawn = targetStaker.withdrawn.add(roi); // increase withdrawn amount
        targetStaker.lastWithdrewAt = block.timestamp; // update last withdrawal date
        targetStaker.refBonus = 0;
       
        require(_spazToken.transfer(_msgSender(), total), "Withdraw: Token transfer failed");
        
        emit OnWithdraw(_msgSender(), roi);
        
    }
    
    function unStake() public {
        require(isStaking(_msgSender()), "Unstake: sender is not staking");
        Stake memory targetStaker = stakers[_msgSender()];
        uint256 roi = _stakingROI(targetStaker).sub(targetStaker.withdrawn); // sub past withdrawals
        uint256 amount = targetStaker.amount;
        
        _totalStakers = _totalStakers.sub(1);
        _totalStaked = _totalStaked.sub(targetStaker.amount);
        
        if (!isMaturedStaking(_msgSender())) {
            uint256 tax = amount.mul(_immatureUnstakeTax).div(10000);
            amount = amount.sub(tax); // sub tax fee for unstaking immaturely
        }
        uint256 total = amount.add(roi).add(targetStaker.refBonus);
        _totalDividend = _totalDividend.add(total);

        delete stakers[_msgSender()];
        require(_spazToken.transfer(_msgSender(), total), "Unstake: Token transfer failed");
        emit OnUnstake(_msgSender(), total);
    }
    
    function adminWithrawal(uint256 _amount) public onlyOwner {
        require(_amount > 0, "Amount cannot be zero");
        require(_spazToken.balanceOf(address(this)) >= _amount, "Balance is less than amount");
        require(_spazToken.transfer(owner(), _amount), "Token transfer failed");
        emit OnWithdraw(owner(), _amount);
        
    }

    function _createStake(address _staker, uint256 _amount) internal {
        stakers[_staker] = Stake(true, block.timestamp, _amount, 0, 0, 0);
        _totalStakers = _totalStakers.add(1);
        _totalStaked = _totalStaked.add(_amount);
        emit OnStake(_msgSender(), _amount);
    }
    
    function _handleReferrer(address _referrer, uint256 _amount) internal {
        if (_referrer != _msgSender() && isStaking(_referrer)) {
            uint256 bonus = _amount.mul(_referralcommission).div(10000);
            uint256 tempRefPulled = _refBonusPulled.add(bonus);
            
            if (tempRefPulled <= _referralPool) {
                _refBonusPulled = tempRefPulled;
                stakers[_referrer].refBonus += bonus;
            }
        }
    }
    
    function _stakingROI(Stake memory _stake) internal view returns(uint256) {
        uint256 duration = block.timestamp.sub(_stake.createdAt);
        
        if (duration > _stakeDuration) {
            duration = _stakeDuration;
        }
        
        uint256 unitDuration = duration.div(_unitDuration);
        uint256 roi = unitDuration.mul(_dailyROI).mul(_stake.amount);
        return roi.div(10000);
    }
    
    function stakingROI(address _staker) public view returns(uint256) {
        Stake memory targetStaker = stakers[_staker];
        return _stakingROI(targetStaker);
    }
    
    function isMaturedStaking(address _staker) public view returns(bool) {
        
        if (isStaking(_staker) && block.timestamp.sub(stakers[_staker].createdAt) > _stakeDuration) {
            return true;
        }
        return false;
    }
    
    function stakingPoolFilled(uint256 _amount) public view returns(bool) {
        uint256 temporaryPool = _totalStaked.add(_amount);
        return temporaryPool >= _stakingPool;
    }
    
    function isStaking(address _staker) public view returns(bool) {
        return stakers[_staker].exists;
    }
    
    function spazToken() public view returns(IERC20) {
        return _spazToken;
    }
    
    function minimumStakeAmount() public view returns(uint256) {
        return _minimumStakAmount;
    }
    
    function maximumStakeAmount() public view returns(uint256) {
        return _maximumStakeAmount;
    }
    
    function totalStaked() external view returns(uint256) {
        return _totalStaked;
    }
    
    function totalStakers() external view returns(uint256) {
        return _totalStakers;
    }
    
    function stakingPool() external view returns(uint256) {
        return _stakingPool;
    }
    
    function referralPool() external view returns(uint256) {
        return _referralPool;
    }
    
    function referralBonus(address _staker) external view returns(uint256) {
        return stakers[_staker].refBonus;
    }
    
    function stakeCreatedAt(address _staker) external view returns(uint256) {
        return stakers[_staker].createdAt;
    }
    
    function stakingUntil(address _staker) external view returns(uint256) {
        return stakers[_staker].createdAt.add(_stakeDuration);
    }
    
    function rewardWithdrawn(address _staker) external view returns(uint256) {
        return stakers[_staker].withdrawn;
    }
    
    function lastWithdrawalDate(address _staker) external view returns(uint256) {
        return stakers[_staker].lastWithdrewAt;
    }
    
    function stakedAmount(address _staker) external view returns(uint256) {
        return stakers[_staker].amount;
    }
}