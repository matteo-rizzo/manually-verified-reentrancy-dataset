/**
 *Submitted for verification at Etherscan.io on 2021-08-25
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.6.12;



// Part: ChainlinkDetailedERC20



// Part: IBaseOracle



// Part: IFeedRegistry



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

// File: ChainlinkAdapterOracleV2.sol

contract ChainlinkAdapterOracleV2 is IBaseOracle, Governable {
  using SafeMath for uint;
  using SafeCast for int;

  event SetMaxDelayTime(address indexed token, uint maxDelayTime);
  event SetTokenRemapping(address indexed token, address indexed remappedToken);
  event SetRemappedTokenDecimal(address indexed token, uint8 decimal);

  // Chainlink denominations (source: https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/Denominations.sol)
  IFeedRegistry public constant registry =
    IFeedRegistry(0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf);
  address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  address public constant BTC = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;
  address public constant USD = address(840);

  mapping(address => address) public remappedTokens; // Mapping from original token to remapped token for price querying (e.g. WBTC -> BTC, renBTC -> BTC)
  mapping(address => uint8) public remappedTokenDecimals; // Mapping from remapped token to decimals
  mapping(address => uint) public maxDelayTimes; // Mapping from token address to max delay time

  constructor() public {
    __Governable__init();
    remappedTokenDecimals[ETH] = 18;
    remappedTokenDecimals[BTC] = 8;
    emit SetRemappedTokenDecimal(ETH, 18);
    emit SetRemappedTokenDecimal(BTC, 8);
  }

  /// @dev Set max delay time for each token
  /// @param _remappedTokens List of remapped tokens to set max delay
  /// @param _maxDelayTimes List of max delay times to set to
  function setMaxDelayTimes(address[] calldata _remappedTokens, uint[] calldata _maxDelayTimes)
    external
    onlyGov
  {
    require(
      _remappedTokens.length == _maxDelayTimes.length,
      '_remappedTokens & _maxDelayTimes length mismatched'
    );
    for (uint idx = 0; idx < _remappedTokens.length; idx++) {
      maxDelayTimes[_remappedTokens[idx]] = _maxDelayTimes[idx];
      emit SetMaxDelayTime(_remappedTokens[idx], _maxDelayTimes[idx]);
    }
  }

  /// @dev Set decimal for remapped tokens, e.g. ETH, BTC
  /// @param _remappedTokens List of remapped tokens to set decimals
  /// @param _decimals List of decimals to set
  function setRemappedTokenDecimals(address[] calldata _remappedTokens, uint8[] calldata _decimals)
    external
    onlyGov
  {
    require(
      _remappedTokens.length == _decimals.length,
      '_remappedTokens & _decimals length mismatched'
    );
    for (uint idx = 0; idx < _remappedTokens.length; idx++) {
      remappedTokenDecimals[_remappedTokens[idx]] = _decimals[idx];
      emit SetRemappedTokenDecimal(_remappedTokens[idx], _decimals[idx]);
    }
  }

  /// @dev Set token remapping
  /// @param _tokens List of tokens to set remapping
  /// @param _remappedTokens List of tokens to set remapping to
  /// @notice Token decimals of the original and remapped tokens should be the same
  function setTokenRemappings(address[] calldata _tokens, address[] calldata _remappedTokens)
    external
    onlyGov
  {
    require(
      _tokens.length == _remappedTokens.length,
      '_tokens & _remappedTokens length mismatched'
    );
    for (uint idx = 0; idx < _tokens.length; idx++) {
      require(
        ChainlinkDetailedERC20(_tokens[idx]).decimals() ==
          remappedTokenDecimals[_remappedTokens[idx]],
        'incorrect token decimals'
      );
      remappedTokens[_tokens[idx]] = _remappedTokens[idx];
      emit SetTokenRemapping(_tokens[idx], _remappedTokens[idx]);
    }
  }

  /// @dev Return token decimals (use remappedTokenDecimals if possible, otherwise use ERC20.decimals)
  /// @param _token Token to get decimals for
  function getRemappedTokenDecimals(address _token) public view returns (uint8) {
    uint8 decimals = remappedTokenDecimals[_token];
    if (decimals > 0) return decimals;
    return ChainlinkDetailedERC20(_token).decimals();
  }

  /// @dev Return token price in ETH, multiplied by 2**112
  /// @param _token Token address to get price of
  function getETHPx(address _token) external view override returns (uint) {
    // remap token if possible
    address token = remappedTokens[_token];
    if (token == address(0)) token = _token;

    if (token == ETH) return uint(2**112);

    uint decimals = getRemappedTokenDecimals(token);

    uint maxDelayTime = maxDelayTimes[token];
    require(maxDelayTime != 0, 'max delay time not set');

    // try to get token-ETH price
    // if feed not available, use token-USD price with ETH-USD
    try registry.latestRoundData(token, ETH) returns (
      uint80,
      int answer,
      uint,
      uint updatedAt,
      uint80
    ) {
      require(updatedAt >= block.timestamp.sub(maxDelayTime), 'delayed token-eth update time');
      return answer.toUint256().mul(2**112).div(10**decimals);
    } catch {
      (, int answer, , uint updatedAt, ) = registry.latestRoundData(token, USD);
      require(updatedAt >= block.timestamp.sub(maxDelayTime), 'delayed token-usd update time');
      (, int ethAnswer, , uint ethUpdatedAt, ) = registry.latestRoundData(ETH, USD);
      require(
        ethUpdatedAt >= block.timestamp.sub(maxDelayTimes[ETH]),
        'delayed eth-usd update time'
      );

      if (decimals > 18) {
        return answer.toUint256().mul(2**112).div(ethAnswer.toUint256()).div(10**(decimals - 18));
      } else {
        return answer.toUint256().mul(2**112).mul(10**(18 - decimals)).div(ethAnswer.toUint256());
      }
    }

    revert('no valid price reference for token');
  }
}