/**
 *Submitted for verification at Etherscan.io on 2021-07-26
*/

/**
 *Submitted for verification at BscScan.com on 2021-07-11
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

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

/**
 * @dev Contract module which provides a basic access control mechanism, where
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

/* users could create staking-reward model with this contract at single mode */

contract SimpleStaking is Ownable {
    using SafeMath for uint;

    uint constant doubleScale = 10 ** 36;

    // stake token
    IERC20 public stakeToken;

    // reward token
    IERC20 public rewardToken;

    // the number of reward token distribution for each block
    uint public rewardSpeed;

    // user deposit
    mapping(address => uint) public userCollateral;
    uint public totalCollateral;

    // use index to distribute reward token
    // index is compound exponential
    mapping(address => uint) public userIndex;
    uint public index;

    mapping(address => uint) public userAccrued;

    // record latest block height of reward token distributed
    uint public lastDistributedBlock;

    /* event */
    event Deposit(address user, uint amount);
    event Withdraw(address user, uint amount);
    event RewardSpeedUpdated(uint oldSpeed, uint newSpeed);
    event RewardDistributed(address indexed user, uint delta, uint index);

    constructor(IERC20 _stakeToken, IERC20 _rewardToken) Ownable(){
        stakeToken = _stakeToken;
        rewardToken = _rewardToken;
        index = doubleScale;
    }

    function deposit(uint amount) public {
        updateIndex();
        distributeReward(msg.sender);
        require(stakeToken.transferFrom(msg.sender, address(this), amount), "transferFrom failed");
        userCollateral[msg.sender] = userCollateral[msg.sender].add(amount);
        totalCollateral = totalCollateral.add(amount);
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint amount) public {
        updateIndex();
        distributeReward(msg.sender);
        require(stakeToken.transfer(msg.sender, amount), "transfer failed");
        userCollateral[msg.sender] = userCollateral[msg.sender].sub(amount);
        totalCollateral = totalCollateral.sub(amount);
        emit Withdraw(msg.sender, amount);
    }

    function setRewardSpeed(uint speed) public onlyOwner {
        updateIndex();
        uint oldSpeed = rewardSpeed;
        rewardSpeed = speed;
        emit RewardSpeedUpdated(oldSpeed, speed);
    }

    function updateIndex() private {
        uint blockDelta = block.number.sub(lastDistributedBlock);
        if (blockDelta == 0) {
            return;
        }
        uint rewardAccrued = blockDelta.mul(rewardSpeed);
        if (totalCollateral > 0) {
            uint indexDelta = rewardAccrued.mul(doubleScale).div(totalCollateral);
            index = index.add(indexDelta);
        }
        lastDistributedBlock = block.number;
    }

    function distributeReward(address user) private {
        if (userIndex[user] == 0 && index > 0) {
            userIndex[user] = doubleScale;
        }
        uint indexDelta = index - userIndex[user];
        userIndex[user] = index;
        uint rewardDelta = indexDelta.mul(userCollateral[user]).div(doubleScale);
        userAccrued[user] = userAccrued[user].add(rewardDelta);
        if (rewardToken.balanceOf(address(this)) >= userAccrued[user] && userAccrued[user] > 0) {
            if (rewardToken.transfer(user, userAccrued[user])) {
                userAccrued[user] = 0;
            }
        }
        emit RewardDistributed(user, rewardDelta, index);
    }

    function claimReward(address[] memory user) public {
        updateIndex();
        for (uint i = 0; i < user.length; i++) {
            distributeReward(user[i]);
        }
    }

    function withdrawRemainReward() public onlyOwner {
        uint amount = rewardToken.balanceOf(address(this));
        if (rewardToken == stakeToken) {
            amount = amount.sub(totalCollateral);
        }
        rewardToken.transfer(owner(), amount);
    }

    function pendingReward(address user) public view returns (uint){
        uint blockDelta = block.number.sub(lastDistributedBlock);
        uint rewardAccrued = blockDelta.mul(rewardSpeed);
        if (totalCollateral == 0) {
            return userAccrued[user];
        }
        uint ratio = rewardAccrued.mul(doubleScale).div(totalCollateral);
        uint currentIndex = index.add(ratio);
        uint uIndex = userIndex[user] == 0 && index > 0 ? doubleScale : userIndex[user];
        uint indexDelta = currentIndex - uIndex;
        uint rewardDelta = indexDelta.mul(userCollateral[user]).div(doubleScale);
        return rewardDelta + userAccrued[user];
    }
}