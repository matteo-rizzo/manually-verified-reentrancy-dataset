/**
 *Submitted for verification at Etherscan.io on 2021-02-16
*/

// File: @openzeppelin/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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


// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @openzeppelin/contracts/utils/Context.sol


pragma solidity >=0.6.0 <0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol


pragma solidity >=0.6.0 <0.8.0;

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

// File: contracts/interfaces/Owned.sol

pragma solidity 0.7.5;


abstract contract Owned is Ownable {
    constructor(address _owner) {
        transferOwnership(_owner);
    }
}

// File: contracts/LinearVesting.sol

pragma solidity 0.7.5;

// Inheritance




/// @title   Umbrella Rewards contract
/// @author  umb.network
/// @notice  This contract serves TOKEN DISTRIBUTION AT LAUNCH for:
///           - node, founders, early contributors etc...
///          It can be used for future distributions for next milestones also
///          as its functionality stays the same.
///          It supports linear vesting
/// @dev     Deploy contract. Mint tokens reward for this contract.
///          Then as owner call .setupDistribution() and then start()
contract LinearVesting is Owned {
    using SafeMath for uint256;

    IERC20 public umbToken;

    uint256 public totalVestingAmount;
    uint256 public paidSoFar;

    mapping(address => Reward) public rewards;

    struct Reward {
        uint256 total;
        uint256 duration;
        uint256 paid;
        uint256 startTime;
    }

    // ========== CONSTRUCTOR ========== //

    constructor(address _owner, address _token) Owned(_owner) {
        require(_token != address(0x0), "empty _token");

        umbToken = IERC20(_token);
    }

    // ========== VIEWS ========== //

    function balanceOf(address _address) public view returns (uint256) {
        Reward memory reward = rewards[_address];

        if (block.timestamp <= reward.startTime) {
            return 0;
        }

        if (block.timestamp >= reward.startTime.add(reward.duration)) {
            return reward.total - reward.paid;
        }

        return reward.total.mul(block.timestamp - reward.startTime).div(reward.duration) - reward.paid;
    }

    // ========== MUTATIVE FUNCTIONS ========== //

    function claim() external {
        _claim(msg.sender);
    }

    function claimFor(address[] calldata _participants) external {
        for (uint i = 0; i < _participants.length; i++) {
            _claim(_participants[i]);
        }
    }

    // ========== RESTRICTED FUNCTIONS ========== //

    function _claim(address _participant) internal {
        uint256 balance = balanceOf(_participant);
        require(balance != 0, "you have no tokens to claim");

        // no need for safe math because sum was calculated using safeMath
        rewards[_participant].paid += balance;
        paidSoFar += balance;

        // this is our token, we can save gas and simple use transfer instead safeTransfer
        require(umbToken.transfer(_participant, balance), "umb.transfer failed");

        emit LogClaimed(_participant, balance);
    }

    function addRewards(
        address[] calldata _participants,
        uint256[] calldata _rewards,
        uint256[] calldata _durations,
        uint256[] calldata _startTimes
    )
    external onlyOwner {
        require(_participants.length != 0, "there is no _participants");
        require(_participants.length == _rewards.length, "_participants count must match _rewards count");
        require(_participants.length == _durations.length, "_participants count must match _durations count");
        require(_participants.length == _startTimes.length, "_participants count must match _startTimes count");

        uint256 sum = totalVestingAmount;

        for (uint256 i = 0; i < _participants.length; i++) {
            require(_participants[i] != address(0x0), "empty participant");
            require(_durations[i] != 0, "empty duration");
            require(_durations[i] < 5 * 365 days, "duration too long");
            require(_rewards[i] != 0, "empty reward");
            require(_startTimes[i] != 0, "empty startTime");

            uint256 total = rewards[_participants[i]].total;

            if (total < _rewards[i]) {
                // we increased existing reward, so sum will be higher
                sum = sum.add(_rewards[i] - total);
            } else {
                // we decreased existing reward, so sum will be lower
                sum = sum.sub(total - _rewards[i]);
            }

            if (total != 0) {
                require(rewards[_participants[i]].startTime == _startTimes[i], "can't change start time");
                require(_rewards[i] >= balanceOf(_participants[i]), "can't take what's already done");
            }

            rewards[_participants[i]] = Reward(_rewards[i], _durations[i], 0, _startTimes[i]);
        }

        emit LogSetup(totalVestingAmount, sum);
        totalVestingAmount = sum;
    }

    // ========== EVENTS ========== //

    event LogSetup(uint256 prevSum, uint256 newSum);
    event LogClaimed(address indexed recipient, uint256 amount);
}