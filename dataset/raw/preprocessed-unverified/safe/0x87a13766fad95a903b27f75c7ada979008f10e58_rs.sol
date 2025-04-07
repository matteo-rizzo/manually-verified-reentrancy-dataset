/**
 *Submitted for verification at Etherscan.io on 2020-10-31
*/

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

contract YFIECFarm is Ownable {
    using SafeMath for uint256;
    
    uint256 public rewardDuration = 691200;
    uint256 public rewardRate = 9e11;
    uint256 public allocation;
    uint256 public unclaimedReward;
    uint256 public stakingDecimals;
    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    
    struct Stake {
        uint256 createdOn;
        uint256 amount;
        uint256 withdrawn;
    }
    
    mapping(address => Stake) stakes;
    
    constructor() {
        allocation = 3e10;
        unclaimedReward = allocation;
        stakingDecimals = 1e18;
        stakingToken = IERC20(0x5568CdaA87500A3770770100bFc3306d0986f1c1);
        rewardsToken = IERC20(0x2E6E152d29053B6337E434bc9bE17504170f8a5B);
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
        require(_amount > 0, "Cannot stake zero");
        uint256 prevAmount = stakes[_msgSender()].amount;
        
        if (prevAmount > 0) {
            withdraw();
        }
        _amount = _amount.add(prevAmount);
        uint256 estimate = estimateReward(_amount);
        require(unclaimedReward >= estimate, "Allocation exhausted");
        require(stakingToken.transferFrom(_msgSender(), address(this), _amount), "Could not transfer token");
        unclaimedReward = unclaimedReward.sub(estimate);
        stakes[_msgSender()] = Stake({createdOn: block.timestamp, amount: _amount, withdrawn: 0});
        emit NewStake(_msgSender(), _amount);
    }
    
    function unstake() public {
        Stake memory stake = stakes[_msgSender()];
        uint256 amount = stake.amount;
        uint256 thisReward = _earning(stake);
        uint256 offset = estimateReward(amount).sub(thisReward);
        uint256 finalReward = thisReward.sub(stake.withdrawn);
        unclaimedReward = unclaimedReward.add(offset);
        require(rewardsToken.transfer(_msgSender(), finalReward), "Could not transfer reward token");
        require(stakingToken.transfer(_msgSender(), amount), "Could not transfer staked token");
        
        delete stakes[_msgSender()];
        emit Unstake(_msgSender(), amount);
    }
    
    function withdraw() public {
        Stake storage stake = stakes[_msgSender()];
        if (stake.amount > 0) {
            uint256 thisReward = _earning(stake).sub(stake.withdrawn);
            stake.withdrawn = stake.withdrawn.add(thisReward);
            require(rewardsToken.transfer(_msgSender(), thisReward), "Could not transfer token");
            emit Withdrawal(_msgSender(), thisReward);   
        }
    }
    
    function withrawUnclaimed(uint256 _amount) public onlyOwner {
        require(_amount <= unclaimedReward, "Not enough balance");
        require(rewardsToken.balanceOf(address(this)) >= _amount, "Balance is less than amount");
        require(rewardsToken.transfer(owner(), _amount), "Token transfer failed");
        emit Withdrawal(owner(), _amount);
        unclaimedReward = unclaimedReward.sub(_amount);
    }
    
    function updateRewardRate(uint256 _rate) public onlyOwner {
        rewardRate = _rate;
    }
    
    function earning(address _stake) public view returns(uint256) {
        Stake memory stake = stakes[_stake];
        return _earning(stake);
    }
    
    
    function _earning(Stake memory _stake) internal view returns(uint256) {
        uint256 duration = block.timestamp.sub(_stake.createdOn);
        if (duration > rewardDuration) {
            duration = rewardDuration;
        }
        return duration.mul(_stake.amount).mul(rewardRate).div(86400).div(stakingDecimals);
    }
    
    function estimateReward(uint256 _amount) public view returns(uint256) {
        return _amount.mul(rewardDuration).mul(rewardRate).div(86400).div(stakingDecimals);
    }
    
    event NewStake(address indexed staker, uint256 amount);
    event Unstake(address indexed staker, uint256 amount);
    event Withdrawal(address indexed staker, uint256 amount);
}