/**
 *Submitted for verification at Etherscan.io on 2021-08-09
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.6.12;



// Part: ChainlinkDetailedERC20



// Part: IAggregatorV3Interface



// Part: IBaseOracle



// Part: OpenZeppelin/[email protected]/SafeCast

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
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


// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
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
  event SetGovernor(address governor);
  event SetPendingGovernor(address pendingGovernor);
  event AcceptGovernor(address governor);

  address public governor; // The current governor.
  address public pendingGovernor; // The address pending to become the governor once accepted.

  bytes32[64] _gap; // reserve space for upgrade

  modifier onlyGov() {
    require(msg.sender == governor, 'not the governor');
    _;
  }

  /// @dev Initialize using msg.sender as the first governor.
  function __Governable__init() internal initializer {
    governor = msg.sender;
    pendingGovernor = address(0);
    emit SetGovernor(msg.sender);
  }

  /// @dev Set the pending governor, which will be the governor once accepted.
  /// @param _pendingGovernor The address to become the pending governor.
  function setPendingGovernor(address _pendingGovernor) external onlyGov {
    pendingGovernor = _pendingGovernor;
    emit SetPendingGovernor(_pendingGovernor);
  }

  /// @dev Accept to become the new governor. Must be called by the pending governor.
  function acceptGovernor() external {
    require(msg.sender == pendingGovernor, 'not the pending governor');
    pendingGovernor = address(0);
    governor = msg.sender;
    emit AcceptGovernor(msg.sender);
  }
}

// File: ChainlinkAdapterOracle.sol

contract ChainlinkAdapterOracle is IBaseOracle, Governable {
  using SafeMath for uint;
  using SafeCast for int;

  event SetRefETH(address token, address ref);
  event SetRefUSD(address token, address ref);
  event SetMaxDelayTime(address token, uint maxDelayTime);
  event SetRefETHUSD(address ref);

  address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address public refETHUSD = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419; // ETH-USD price reference
  mapping(address => address) public refsETH; // Mapping from token address to ETH price reference
  mapping(address => address) public refsUSD; // Mapping from token address to USD price reference
  mapping(address => uint) public maxDelayTimes; // Mapping from token address to max delay time

  constructor() public {
    __Governable__init();
  }

  /// @dev Set price reference for ETH pair
  /// @param tokens list of tokens to set reference
  /// @param refs list of reference contract addresses
  function setRefsETH(address[] calldata tokens, address[] calldata refs) external onlyGov {
    require(tokens.length == refs.length, 'tokens & refs length mismatched');
    for (uint idx = 0; idx < tokens.length; idx++) {
      refsETH[tokens[idx]] = refs[idx];
      emit SetRefETH(tokens[idx], refs[idx]);
    }
  }

  /// @dev Set price reference for USD pair
  /// @param tokens list of tokens to set reference
  /// @param refs list of reference contract addresses
  function setRefsUSD(address[] calldata tokens, address[] calldata refs) external onlyGov {
    require(tokens.length == refs.length, 'tokens & refs length mismatched');
    for (uint idx = 0; idx < tokens.length; idx++) {
      refsUSD[tokens[idx]] = refs[idx];
      emit SetRefUSD(tokens[idx], refs[idx]);
    }
  }

  /// @dev Set max delay time for each token
  /// @param tokens list of tokens to set max delay
  /// @param maxDelays list of max delay times to set to
  function setMaxDelayTimes(address[] calldata tokens, uint[] calldata maxDelays) external onlyGov {
    require(tokens.length == maxDelays.length, 'tokens & maxDelays length mismatched');
    for (uint idx = 0; idx < tokens.length; idx++) {
      maxDelayTimes[tokens[idx]] = maxDelays[idx];
      emit SetMaxDelayTime(tokens[idx], maxDelays[idx]);
    }
  }

  /// @dev Set ETH-USD to the new reference
  /// @param _refETHUSD The new ETH-USD reference address to set to
  function setRefETHUSD(address _refETHUSD) external onlyGov {
    refETHUSD = _refETHUSD;
    emit SetRefETHUSD(_refETHUSD);
  }

  /// @dev Return token price in ETH, multiplied by 2**112
  /// @param token Token address to get price
  function getETHPx(address token) external view override returns (uint) {
    if (token == WETH || token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) return uint(2**112);
    uint decimals = uint(ChainlinkDetailedERC20(token).decimals());
    uint maxDelayTime = maxDelayTimes[token];
    require(maxDelayTime != 0, 'max delay time not set');

    // 1. Check token-ETH price ref
    address refETH = refsETH[token];
    if (refETH != address(0)) {
      (, int answer, , uint updatedAt, ) = IAggregatorV3Interface(refETH).latestRoundData();
      require(updatedAt >= block.timestamp.sub(maxDelayTime), 'delayed update time');
      return answer.toUint256().mul(2**112).div(10**decimals);
    }

    // 2. Check token-USD price ref
    address refUSD = refsUSD[token];
    if (refUSD != address(0)) {
      (, int answer, , uint updatedAt, ) = IAggregatorV3Interface(refUSD).latestRoundData();
      require(updatedAt >= block.timestamp.sub(maxDelayTime), 'delayed update time');
      (, int ethAnswer, , uint ethUpdatedAt, ) = IAggregatorV3Interface(refETHUSD)
        .latestRoundData();
      require(ethUpdatedAt >= block.timestamp.sub(maxDelayTime), 'delayed eth-usd update time');

      if (decimals > 18) {
        return answer.toUint256().mul(2**112).div(ethAnswer.toUint256()).div(10**(decimals - 18));
      } else {
        return answer.toUint256().mul(2**112).mul(10**(18 - decimals)).div(ethAnswer.toUint256());
      }
    }

    revert('no valid price reference for token');
  }
}