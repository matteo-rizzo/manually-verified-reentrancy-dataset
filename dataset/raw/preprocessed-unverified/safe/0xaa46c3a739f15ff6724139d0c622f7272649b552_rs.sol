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

contract YMISSILEStake is Ownable {
    using SafeMath for uint256;
    
    IERC20 public YMISSILE;
    uint256 public pool;
    uint256 public minimum;
    uint256 public maximum;
    uint256 public totalStaked;
    uint256 public totalStakers;
    uint256 public totalPaid;
    uint256 public withdrawable;
    
    uint256 private _roi = 1e2;
    uint256 private _tax = 2e3;
    uint256 private _divisor = 1e4;
    uint256 private _decimals = 1e8;
    uint256 private _uDuration = 864e2;
    uint256 private _duration = _uDuration.mul(_roi);
    uint256 private _minDuration = _uDuration.mul(25);
    
    struct Stake {
        bool exists;
        uint256 createdOn;
        uint256 amount;
        uint256 withdrawn;
    }
    
    mapping(address => Stake) stakes;
    
    constructor() {
        pool = _decimals.mul(2e3);
        withdrawable = pool;
        minimum = _decimals.mul(20);
        maximum = _decimals.mul(200);
        YMISSILE = IERC20(0x447c76582DdF1d33BAF37FdEC5c74CdD7fe9d2da);
    }
    
    function stakeExists(address _stake) public view returns(bool) {
        return stakes[_stake].exists;
    }
    
    function createdDate(address _stake) external view returns(uint256) {
        return stakes[_stake].createdOn;
    }
    
    function withdrawn(address _stake) external view returns(uint256) {
        return stakes[_stake].withdrawn;
    }
    
    function stakedAmount(address _stake) external view returns(uint256) {
        return stakes[_stake].amount;
    }
    
    function newStake(uint256 _amount) public {
        require(!stakeExists(_msgSender()), "Sender is already staking");
        require(!poolFilled(_amount), "Staking pool filled");
        require(_amount >= minimum, "Amount is lower than minimum");
        require(_amount <= maximum, "Amount is higher than maximum");
        require(YMISSILE.transferFrom(_msgSender(), address(this), _amount), "Could not transfer token");
        
        totalStaked = totalStaked.add(_amount);
        totalStakers = totalStakers.add(1);
        stakes[_msgSender()] = Stake({exists: true, createdOn: block.timestamp, amount: _amount, withdrawn: 0});
        withdrawable = withdrawable.sub(estimateRoi(_amount));
        emit NewStake(_msgSender(), _amount);
    }
    
    function unstake() public {
        require(stakeExists(_msgSender()), "Sender is not staking");
        Stake memory stake = stakes[_msgSender()];
        uint256 amount = stake.amount;
        uint256 duration = block.timestamp.sub(stake.createdOn);
        uint256 roi = _ROI(stake);
        uint256 offset = estimateRoi(amount).sub(roi);
        uint256 balance = roi.sub(stake.withdrawn);
        
        if (duration < _minDuration) {
            uint256 tax = amount.mul(_tax).div(_divisor);
            amount = amount.sub(tax);
            offset = offset.add(tax);
        }
        
        withdrawable = withdrawable.add(offset);
        uint256 total = amount.add(balance);
        totalPaid = totalPaid.add(balance);
        require(YMISSILE.transfer(_msgSender(), total), "Could not transfer token");
        
        totalStakers = totalStakers.sub(1);
        totalStaked = totalStaked.sub(stake.amount);
        delete stakes[_msgSender()];
        emit Unstake(_msgSender(), total);
    }
    
    function withdrawReward() public {
        require(stakeExists(_msgSender()), "Sender is not staking");
        Stake storage stake = stakes[_msgSender()];
        uint256 roi = _ROI(stake).sub(stake.withdrawn);
        totalPaid = totalPaid.add(roi);
        stake.withdrawn = stake.withdrawn.add(roi);
        require(YMISSILE.transfer(_msgSender(), roi), "Could not transfer token");
        emit Withdrawal(_msgSender(), roi);
    }
    
    function ownerWithraw(uint256 _amount) public onlyOwner {
        require(_amount <= withdrawable, "Not enough balance");
        require(YMISSILE.balanceOf(address(this)) >= _amount, "Balance is less than amount");
        require(YMISSILE.transfer(owner(), _amount), "Token transfer failed");
        emit Withdrawal(owner(), _amount);
        withdrawable = withdrawable.sub(_amount);
    }
    
    function ROI(address _stake) public view returns(uint256) {
        Stake memory stake = stakes[_stake];
        return _ROI(stake);
    }
    
    function estimateRoi(uint256 _amount) public view returns(uint256) {
        return _amount.mul(_roi).mul(_duration).div(_uDuration).div(_divisor);
    }
    
    function poolFilled(uint256 _amount) public view returns(bool) {
        uint256 (totalStaked.add(_amount)) > pool;
    }
    
    function _ROI(Stake memory _stake) internal view returns(uint256) {
        uint256 duration = block.timestamp.sub(_stake.createdOn);
        if (duration > _duration) {
            duration = _duration;
        }
        uint256 uDuration = duration.div(_uDuration);
        uint256 roi = uDuration.mul(_roi).mul(_stake.amount);
        return roi.div(_divisor);
    }
    
    event NewStake(address indexed staker, uint256 amount);
    event Unstake(address indexed staker, uint256 amount);
    event Withdrawal(address indexed staker, uint256 amount);
}