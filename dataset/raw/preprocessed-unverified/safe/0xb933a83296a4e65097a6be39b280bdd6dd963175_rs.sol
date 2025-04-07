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

contract YIIFIStaking is Ownable {
    using SafeMath for uint256;
    
    IERC20 private _YIIFIToken;
    uint256 private _dailyROI = 30;
    uint256 private _decimals = 1e18;
    uint256 private _divisor = 1e4;
    uint256 private _unitDuration = 864e2;
    uint256 private _minDuration = 1296e3;
    uint256 private _stakeDuration = 7776e3;
    uint256 private _stakingPool = _decimals.mul(111e2);
    uint256 private _minimumStake = _decimals.mul(15);
    uint256 private _maximumStake = _decimals.mul(5e2);
    
    uint256 private _totalStaked;
    uint256 private _totalStakers;
    uint256 private _totalDividends;
    uint256 private _offset;

    struct Staker {
        bool exists;
        uint256 createdAt;
        uint256 amount;
        uint256 withdrawn;
    }
    
    mapping(address => Staker) stakers;
    
    event OnStake(address indexed staker, uint256 amount);
    event OnUnstake(address indexed staker, uint256 amount);
    event OnWithdraw(address indexed staker, uint256 amount);
    
    constructor() {
        _YIIFIToken = IERC20(0x60CEE60BE1eE37e7787F3dFd18fEF3299d9fA216);
        _offset = _stakingPool;
    }
    
    function createStake(uint256 _amount) public {
        require(!isStaking(_msgSender()), "Stake: Already staking");       
        require(!stakingPoolFilled(_amount), "Stake: staking pool filled");
        require(_amount >= minimumStake(), "Stake: Not enough amount to stake");
        require(_amount <= maximumStake(), "Stake: More than acceptable stake amount");
        require(_YIIFIToken.transferFrom(_msgSender(), address(this), _amount), "Stake: Token transfer failed");
        _createStake(_msgSender(), _amount);
    }
    
    function _createStake(address _staker, uint256 _amount) internal {
        _offset = _offset.sub(maturedROI(_amount));
        stakers[_staker] = Staker(true, block.timestamp, _amount, 0);
        _totalStakers = _totalStakers.add(1);
        _totalStaked = _totalStaked.add(_amount);
        emit OnStake(_staker, _amount);
    }
    
    function withdraw() public {
        require(isStaking(_msgSender()), "Withdraw: sender is not staking");
        Staker storage staker = stakers[_msgSender()];
        uint256 roi = _stakingROI(staker).sub(staker.withdrawn);
        _totalDividends = _totalDividends.add(roi);
        staker.withdrawn = staker.withdrawn.add(roi);
        require(_YIIFIToken.transfer(_msgSender(), roi), "Withdraw: Token transfer failed");
        emit OnWithdraw(_msgSender(), roi);
    }
    
    function unstake() public {
        require(isStaking(_msgSender()), "Unstake: sender is not staking");
        Staker memory staker = stakers[_msgSender()];
        uint256 duration = block.timestamp.sub(staker.createdAt);
        require(duration > _minDuration, "Unstake: Too early to unstake");
        
        uint256 amount = staker.amount;
        uint256 roi = _stakingROI(staker);
        uint256 roiOffset = maturedROI(staker.amount).sub(roi);
        uint256 roiBalance = roi.sub(staker.withdrawn);
        
        if (duration < _stakeDuration) {
            uint256 tax = _calculateTax(amount, duration);
            amount = amount.sub(tax);
            roiOffset = roiOffset.add(tax);
        }
        
        _offset = _offset.add(roiOffset);
        uint256 total = amount.add(roiBalance);
        _totalDividends = _totalDividends.add(roiBalance);
        require(_YIIFIToken.transfer(_msgSender(), total), "Unstake: Token transfer failed");
        
        _totalStakers = _totalStakers.sub(1);
        _totalStaked = _totalStaked.sub(staker.amount);
        delete stakers[_msgSender()];
        emit OnUnstake(_msgSender(), total);
    }
    
    function maturedROI(uint256 _amount) public view returns(uint256) {
        return _stakeDuration.mul(_dailyROI).mul(_amount).div(_unitDuration).div(_divisor);
    }
    
    function _calculateTax(uint256 _amount, uint256 _duration) internal pure returns(uint256) {
        uint256 firstQtr = 2592e3;
        uint256 secondQtr = 5184e3;
        uint256 thirdQtr = 7776e3;
        uint256 divisor = 1e3;
        
        if (_duration <= firstQtr) {
            return _amount.mul(15).div(divisor);   
        } else if (_duration <= secondQtr) {
            return _amount.mul(10).div(divisor);   
        } else if (_duration <= thirdQtr) {
            return _amount.mul(5).div(divisor);
        }
    }
    
    function adminWithrawal(uint256 _amount) public onlyOwner {
        require(_amount <= _offset, "AdminWithrawal: Not enough balance");
        require(_YIIFIToken.balanceOf(address(this)) >= _amount, "AdminWithrawal: Balance is less than amount");
        require(_YIIFIToken.transfer(owner(), _amount), "AdminWithrawal: Token transfer failed");
        _offset = _offset.sub(_amount);
        emit OnWithdraw(owner(), _amount);
    }
    
    function _stakingROI(Staker memory _stake) internal view returns(uint256) {
        uint256 duration = block.timestamp.sub(_stake.createdAt);
        if (duration > _stakeDuration) {
            duration = _stakeDuration;
        }
        uint256 unitDuration = duration.div(_unitDuration);
        uint256 roi = unitDuration.mul(_dailyROI).mul(_stake.amount);
        return roi.div(_divisor);
    }
    
    function stakingROI(address _staker) public view returns(uint256) {
        Staker memory staker = stakers[_staker];
        return _stakingROI(staker);
    }
    
    function stakingPoolFilled(uint256 _amount) public view returns(bool) {
        uint256 temporaryPool = _totalStaked.add(_amount);
        return temporaryPool >= _stakingPool;
    }
    
    function isStaking(address _staker) public view returns(bool) {
        return stakers[_staker].exists;
    }
    
     function stakeCreatedAt(address _staker) external view returns(uint256) {
        return stakers[_staker].createdAt;
    }
    
    function stakingtill(address _staker) external view returns(uint256 date) {
        date = stakers[_staker].createdAt;
        if (date > 0) {
            date.add(_stakeDuration);
        }
    }
    
    function rewardWithdrawn(address _staker) external view returns(uint256) {
        return stakers[_staker].withdrawn;
    }
    
    function stakedAmount(address _staker) external view returns(uint256) {
        return stakers[_staker].amount;
    }
    
    function YIIFIToken() public view returns(IERC20) {
        return _YIIFIToken;
    }
    
    function minimumStake() public view returns(uint256) {
        return _minimumStake;
    }
    
    function maximumStake() public view returns(uint256) {
        return _maximumStake;
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

    function totalDividends() external view returns(uint256) {
        return _totalDividends;
    }
}