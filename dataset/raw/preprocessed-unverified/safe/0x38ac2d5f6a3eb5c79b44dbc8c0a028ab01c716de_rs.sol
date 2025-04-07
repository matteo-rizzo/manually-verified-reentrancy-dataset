/**
 *Submitted for verification at Etherscan.io on 2021-08-30
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract DinoXLotteryPool is Ownable {
    
    using SafeMath for uint256;
    
    struct StakerInfo {
        uint256 amount;
        uint256 startStakeTime;
        uint256[] amounts;
        uint256[] times;
    }
    
    uint256 public maximumStakers;       // points generated per LP token per second staked
    uint256 public currentStakers;
    uint256 public minimumStake;
    uint256 public stakingFee;
    IERC20 dnxcToken;                    // token being staked
    
    address private _rewardDistributor;
    mapping(address => StakerInfo) public stakerInfo;
    uint256 internal fee;
    bool paused;
    
    constructor(uint256 _minimumStake, uint256 _stakingFee,  IERC20 _dnxcToken) 
     {
        
        minimumStake = _minimumStake;
        stakingFee = _stakingFee;
        paused = true;
        
        dnxcToken = _dnxcToken;
        _rewardDistributor = address(owner());
    }
    
    function changePause(bool _pause) onlyOwner public {
        paused = _pause;
    }
    
    function changeDistributor(address _address) onlyOwner public {
        _rewardDistributor = _address;
    }
    
    function changeStakingFees(uint256 _stakingFee) onlyOwner public {
        stakingFee = _stakingFee;
    }
    
    function stake(uint256 _amount) public payable {
        require (paused == false, "E09");
        
        StakerInfo storage user = stakerInfo[msg.sender];
        require (user.amount.add(_amount) >= minimumStake, "E01");
        require (dnxcToken.transferFrom(msg.sender, address(this), _amount), "E02");
        
        if(user.startStakeTime == 0) {
            require (msg.value >= stakingFee, "E04");
            user.startStakeTime = block.timestamp;
        }
        
        user.amount = user.amount.add(_amount);
        user.amounts.push(user.amount);
        user.times.push(block.timestamp);
    }
    
    function unstake(uint256 _amount) public {
        
        StakerInfo storage user = stakerInfo[msg.sender];
        require(user.amount > 0, "E06");
        if (_amount > user.amount) {
            _amount = user.amount;
        }
        
        dnxcToken.transfer(
            msg.sender,
            _amount
        );
        
        user.amount = user.amount.sub(_amount);
        user.amounts.push(user.amount);
        user.times.push(block.timestamp);
    }
    
    function getUsersAmounts(address _user) public view returns (uint256[] memory) {
        StakerInfo storage user = stakerInfo[_user];
        return user.amounts;
    }
    
    
    function getUsersTimes(address _user) public view returns (uint256[] memory) {
        StakerInfo storage user = stakerInfo[_user];
        return user.times;
    }
    
    function getTimestampOfStartedStaking(address _user) public view returns (uint256) {
        StakerInfo storage user = stakerInfo[_user];
        return user.startStakeTime;
    }
    
    function withdrawFees() onlyOwner external {
        require(payable(msg.sender).send(address(this).balance));
    }
    

}