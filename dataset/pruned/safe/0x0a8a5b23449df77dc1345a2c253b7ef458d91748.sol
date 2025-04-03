pragma solidity 0.7.6;

import './IERC2917.sol';
import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/Initializable.sol";

contract ERC2917 is IERC2917, Initializable {
    using SafeMath for uint256;

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'Locked');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    address public implementor;
    modifier onlyImplementor() {
        require(msg.sender == implementor, 'Only implementor');
        _;
    }

    uint256 public totalInterestPaid;
    uint256 public interestPerBlock;
    uint256 public lastRewardBlock;
    uint256 public totalProductivity;
    uint256 public accAmountPerShare;

    struct UserStakeInfo {
        uint amount;     // LP tokens the user has provided.
        uint rewardDebt; // Reward debt. 
    }

    mapping(address => UserStakeInfo) public users;

    function initialize() external override initializer {
        implementor = msg.sender;
    }

    function setImplementor(address newImplementor) external override onlyImplementor {
        require(newImplementor != implementor, "no change");
        require(newImplementor != address(0), "invalid address");
        implementor = newImplementor;
    }

    // External function call
    // This function adjust how many tokens are produced by each block, eg:
    // changeAmountPerBlock(100)
    // will set the produce rate to 100/block.
    function changeInterestRatePerBlock(uint value) external override onlyImplementor returns (bool) {
        uint old = interestPerBlock;
        require(value != old, 'AMOUNT_PER_BLOCK_NO_CHANGE');

        interestPerBlock = value;

        emit InterestRatePerBlockChanged(old, value);
        return true;
    }

    // Update reward variables of the given pool to be up-to-date.
    function _update() private {
        if (block.number <= lastRewardBlock) {
            return;
        }

        if (totalProductivity == 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number.sub(lastRewardBlock);
        uint256 reward = multiplier.mul(interestPerBlock);

        accAmountPerShare = accAmountPerShare.add(reward.mul(1e12).div(totalProductivity));
        lastRewardBlock = block.number;
    }

    // External function call
    // This function increase user's productivity and updates the global productivity.
    // the users' actual share percentage is calculated by user_productivity / global_productivity
    function increaseProductivity(address user, uint value) external override onlyImplementor returns (bool, uint, uint) {
        require(value > 0, 'PRODUCTIVITY_VALUE_MUST_BE_GREATER_THAN_ZERO');

        UserStakeInfo storage userStakeInfo = users[user];
        _update();
        uint pending;
        if (userStakeInfo.amount > 0) {
            pending = userStakeInfo.amount.mul(accAmountPerShare).div(1e12).sub(userStakeInfo.rewardDebt);
            totalInterestPaid = totalInterestPaid.add(pending);
        }

        totalProductivity = totalProductivity.add(value);

        userStakeInfo.amount = userStakeInfo.amount.add(value);
        userStakeInfo.rewardDebt = userStakeInfo.amount.mul(accAmountPerShare).div(1e12);
        emit ProductivityIncreased(user, value);
        return (true, pending, totalProductivity);
    }

    // External function call 
    // This function will decreases user's productivity by value, and updates the global productivity
    // it will record which block this is happenning and accumulates the area of (productivity * time)
    function decreaseProductivity(address user, uint value) external override onlyImplementor returns (bool, uint, uint) {
        require(value > 0, 'INSUFFICIENT_PRODUCTIVITY');
        
        UserStakeInfo storage userStakeInfo = users[user];
        require(userStakeInfo.amount >= value, "not enough stake");
        _update();
        uint pending = userStakeInfo.amount.mul(accAmountPerShare).div(1e12).sub(userStakeInfo.rewardDebt);
        totalInterestPaid = totalInterestPaid.add(pending);
        userStakeInfo.amount = userStakeInfo.amount.sub(value);
        userStakeInfo.rewardDebt = userStakeInfo.amount.mul(accAmountPerShare).div(1e12);
        totalProductivity = totalProductivity.sub(value);

        emit ProductivityDecreased(user, value);
        return (true, pending, totalProductivity);
    }

    function takeWithAddress(address user) public view returns (uint) {
        UserStakeInfo storage userStakeInfo = users[user];
        uint _accAmountPerShare = accAmountPerShare;
        if (block.number > lastRewardBlock && totalProductivity != 0) {
            uint multiplier = block.number.sub(lastRewardBlock);
            uint reward = multiplier.mul(interestPerBlock);
            _accAmountPerShare = _accAmountPerShare.add(reward.mul(1e12).div(totalProductivity));
        }
        return userStakeInfo.amount.mul(_accAmountPerShare).div(1e12).sub(userStakeInfo.rewardDebt);
    }

    function take() public override view returns (uint) {
        return takeWithAddress(msg.sender);
    }

    // Returns how much a user could earn plus the giving block number.
    function takeWithBlock() public override view returns (uint, uint) {
        return (take(), block.number);
    }

    // External function call
    // When user calls this function, it will calculate how many token will mint to user from his productivity * time and sends them to the user
    // Also it calculates global token supply from last time the user mint to this time.
    function mint() external override lock returns (uint) {
        // currently not implemented
        return 0;
    }

    // Returns how much productivity a user has and global has.
    function getProductivity(address user) external override view returns (uint, uint) {
        return (users[user].amount, totalProductivity);
    }

    // Returns the current gross product rate.
    function interestsPerBlock() external override view returns (uint) {
        return accAmountPerShare;
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.7.6;


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


// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */


{
  "optimizer": {
    "enabled": true,
    "runs": 1000
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {}
}