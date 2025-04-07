/**
 *Submitted for verification at Etherscan.io on 2021-04-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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
 * @dev Standard math utilities missing in the Solidity language.
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



pragma experimental ABIEncoderV2;

contract Staking is Ownable {
    using SafeMath for uint256;

    uint256 public _startTime;
    uint256 public _endTime;
    uint256 public _getRewardEndTime;
    uint256 public _rewardRate;
    
    uint256 public _releaseInterval = 1 weeks;
    uint256 public _getRewardInterval = 35 weeks;
    
    uint256 lockTimes = 20;

    IERC20 public _stakingToken;
    IERC20 public _rewardToken;

    uint256 public _rewardPerTokenStored;
    uint256 public _lastUpdateTime;

    mapping(address => uint256) public _rewards;
    mapping(address => uint256) public _userRewardPerTokenPaid;
    mapping(address => uint256) public _receivedRewards;

    uint256 public _supply;
    mapping(address => uint256) public _balance;

    mapping(address => LockAmount) public _lockAmount;

    struct LockAmount {
        uint256[] amount;
        uint256 releaseTime;
        uint256 pos;
    }

    event Staked(address indexed sender, uint256 indexed amount);
    event Withdrawn(address indexed sender, uint256 indexed amount);
    event GotReward(address indexed sender, uint256 indexed amount);

    constructor(
        uint256 startTime_,
        uint256 endTime_,
        uint256 rewardRate_,
        address stakingToken_,
        address rewardToken_
    ) {
        _startTime = startTime_;
        _endTime = endTime_;
        _getRewardEndTime = startTime_ + _getRewardInterval;
        _rewardRate = rewardRate_;
        _stakingToken = IERC20(stakingToken_);
        _rewardToken = IERC20(rewardToken_);
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balance[account];
    }

    modifier updateReward(address account) {
        _rewardPerTokenStored = rewardPerToken();
        _lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            _rewards[account] = earned(account);
            _userRewardPerTokenPaid[account] = _rewardPerTokenStored;
        }
        _;
    }

    function lockedIncomeBalanceOf(address account) public view returns (LockAmount memory) {
        return _lockAmount[account];
    }

    function rewardPart(address account) public view returns (uint256 unlocked, uint256 locked) {
        uint256 earn = earned(account);
        unlocked = unlocked.add(earn.div(lockTimes));
        locked = locked.add(earn.sub(earn.div(lockTimes)));

        LockAmount memory amount = _lockAmount[account];
        uint256 lockTime = amount.releaseTime;
        for (uint256 i = amount.pos; i < amount.amount.length; i++) {
            if (lockTime < block.timestamp) {
                unlocked = unlocked.add(amount.amount[i]);
            } else {
                locked = locked.add(amount.amount[i]);
            }
            lockTime = lockTime.add(_releaseInterval);
        }
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(_userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(_rewards[account]);
    }

    function stake(uint256 amount) public updateReward(msg.sender) {
        require(block.timestamp < _endTime, "the end");
        require(amount > 0, "cannot stake 0");

        _balance[msg.sender] = _balance[msg.sender].add(amount);
        _supply = _supply.add(amount);

        require(
            _stakingToken.transferFrom(msg.sender, address(this), amount),
            "transferFrom fail"
        );

        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {
        require(amount > 0, "cannot withdraw 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient funds");

        _balance[msg.sender] = _balance[msg.sender].sub(amount);
        _supply = _supply.sub(amount);

        require(_stakingToken.transfer(msg.sender, amount), "withdraw fail");

        emit Withdrawn(msg.sender, amount);
    }

    function exit() public {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) {
        require(block.timestamp < _getRewardEndTime, "get reward timeout");
        LockAmount storage lockAmount = _lockAmount[msg.sender];
        
        uint256 releaseAmount = 0;

        for (uint256 i = lockAmount.pos; i < lockAmount.amount.length; i++) {
            if (lockAmount.releaseTime > block.timestamp) {
                break;
            }
            releaseAmount = releaseAmount.add(lockAmount.amount[i]);
            lockAmount.releaseTime = lockAmount.releaseTime.add(_releaseInterval);
            lockAmount.pos = lockAmount.pos.add(1);
        }

        uint256 reward = _rewards[msg.sender];
        if (reward > 0) {
            _rewards[msg.sender] = 0;
            
            uint256 part = reward.div(lockTimes);
            
            releaseAmount = releaseAmount.add(part);

            if (lockAmount.amount.length == lockAmount.pos) {
                lockAmount.releaseTime = block.timestamp.add(_releaseInterval);
            }

            
            uint256 pos;
            for (uint256 i = 0; i < lockTimes - 2; i++) {
                pos = lockAmount.pos.add(i);
                if (pos < lockAmount.amount.length) {
                    lockAmount.amount[pos] = lockAmount.amount[pos].add(part);
                } else {
                    lockAmount.amount.push(part);
                }
            }

            pos = pos.add(1);
            
            uint256 lastAmount = reward.sub(part.mul(lockTimes - 1));
            if (pos < lockAmount.amount.length) {
                lockAmount.amount[pos] = lockAmount.amount[pos].add(lastAmount);
            } else {
                lockAmount.amount.push(lastAmount);
            }
        }

        if (releaseAmount > 0) {
            _receivedRewards[msg.sender] = _receivedRewards[msg.sender].add(releaseAmount);

            require(
                _rewardToken.transfer(msg.sender, releaseAmount),
                "reward token fail"
            );

            emit GotReward(msg.sender, releaseAmount);
        }
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.max(_startTime, Math.min(block.timestamp, _endTime));
    }

    function rewardPerToken() public view returns (uint256) {
        if (_supply == 0) {
            return _rewardPerTokenStored;
        }
        return
            _rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(_lastUpdateTime)
                    .mul(_rewardRate)
                    .mul(1e18)
                    .div(_supply)
            );
    }


    function transferERCToken(address tokenContractAddress, address to, uint256 amount) public onlyOwner {
        require(IERC20(tokenContractAddress).transfer(to, amount), "transfer other token fail");
    }
}