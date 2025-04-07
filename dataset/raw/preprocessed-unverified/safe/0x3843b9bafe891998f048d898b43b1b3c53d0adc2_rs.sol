/**
 *Submitted for verification at Etherscan.io on 2021-05-11
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.6.12;



// Part: IAlphaStaking



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: OpenZeppelin/[email protected]/Initializable

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

// Part: Governable

contract Governable is Initializable {
  address public governor; // The current governor.
  address public pendingGovernor; // The address pending to become the governor once accepted.

  modifier onlyGov() {
    require(msg.sender == governor, 'not the governor');
    _;
  }

  /// @dev Initialize the bank smart contract, using msg.sender as the first governor.
  function __Governable__init() internal initializer {
    governor = msg.sender;
    pendingGovernor = address(0);
  }

  /// @dev Set the pending governor, which will be the governor once accepted.
  /// @param _pendingGovernor The address to become the pending governor.
  function setPendingGovernor(address _pendingGovernor) external onlyGov {
    pendingGovernor = _pendingGovernor;
  }

  /// @dev Accept to become the new governor. Must be called by the pending governor.
  function acceptGovernor() external {
    require(msg.sender == pendingGovernor, 'not the pending governor');
    pendingGovernor = address(0);
    governor = msg.sender;
  }
}

// File: AlphaStakingTier.sol

contract AlphaStakingTier is Initializable, Governable {
  using SafeMath for uint;

  event SetAlphaTier(uint index, uint upperLimit);
  event DeleteAlphaTier(uint index);

  IAlphaStaking public staking;
  mapping(uint => uint) public tiers;
  uint public tierCount;

  function initialize(address _staking) external initializer {
    __Governable__init();
    staking = IAlphaStaking(_staking);
  }

  /// @dev Get user's staking tier
  /// @param user user address to get tier of
  function getAlphaTier(address user) external view returns (uint index) {
    uint stakeAmount = staking.getStakeValue(user);
    uint _tierCount = tierCount;
    for (uint i = 0; i < _tierCount; i++) {
      if (stakeAmount < tiers[i]) {
        return i;
      }
    }
    // user that staked more than the last tier upper limit is treated as the last tier
    // note: this should technically not be reachable.
    return _tierCount.sub(1);
  }

  /// @dev Set staking tiers
  /// @param upperLimits array of tier upper limits
  function setAlphaTiers(uint[] calldata upperLimits) external onlyGov {
    for (uint lIndex = 0; lIndex < upperLimits.length; lIndex++) {
      if (lIndex > 0) {
        require(
          upperLimits[lIndex] > upperLimits[lIndex - 1],
          'setAlphaTiers: upperLimits should be strictly increasing'
        );
      } else {
        require(upperLimits[lIndex] > 0, 'setAlphaTiers: first tier upper limit should be > 0');
      }
      tiers[lIndex] = upperLimits[lIndex];
      emit SetAlphaTier(lIndex, upperLimits[lIndex]);
    }

    uint _tierCount = tierCount; // gas opt
    // Resetting previous values
    for (uint eIndex = upperLimits.length; eIndex < _tierCount; eIndex++) {
      delete tiers[eIndex];
      emit DeleteAlphaTier(eIndex);
    }

    tierCount = upperLimits.length;
  }

  /// @dev Update existing staking tier
  /// @param index index of tier to update
  /// @param upperLimit new upper limit of tier to update
  function updateAlphaTier(uint index, uint upperLimit) external onlyGov {
    require(index < tierCount, 'updateAlphaTier: index out of range');
    require(upperLimit != 0, 'updateAlphaTier: upper limit cannot be 0');
    if (0 < index) {
      require(
        tiers[index - 1] < upperLimit,
        'updateAlphaTier: new upper limit must be more than the previous tier'
      );
    }
    if (index < tierCount.sub(1)) {
      require(
        upperLimit < tiers[index + 1],
        'updateAlphaTier: new upper limit must be less than the next tier'
      );
    }
    tiers[index] = upperLimit;
    emit SetAlphaTier(index, upperLimit);
  }
}