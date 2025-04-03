// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '@lbertenasco/contract-utils/contracts/utils/CollectableDust.sol';
import '@lbertenasco/contract-utils/contracts/utils/Governable.sol';
import '@openzeppelin/contracts/utils/Address.sol';

import './interfaces/IStealthRelayer.sol';
import './StealthTx.sol';

/*
 * YearnStealthRelayer
 */
contract StealthRelayer is Governable, CollectableDust, StealthTx, IStealthRelayer {
  using Address for address;
  using EnumerableSet for EnumerableSet.AddressSet;

  EnumerableSet.AddressSet internal _jobs;

  bool public override forceBlockProtection;
  address public override caller;

  constructor(address _stealthVault) Governable(msg.sender) StealthTx(_stealthVault) {}

  modifier onlyValidJob(address _job) {
    require(_jobs.contains(_job), 'SR: invalid job');
    _;
  }

  modifier setsCaller() {
    caller = msg.sender;
    _;
    caller = address(0);
  }

  function execute(
    address _job,
    bytes memory _callData,
    bytes32 _stealthHash,
    uint256 _blockNumber
  )
    external
    payable
    override
    onlyValidJob(_job)
    validateStealthTxAndBlock(_stealthHash, _blockNumber)
    setsCaller()
    returns (bytes memory _returnData)
  {
    return _callWithValue(_job, _callData, msg.value);
  }

  function executeAndPay(
    address _job,
    bytes memory _callData,
    bytes32 _stealthHash,
    uint256 _blockNumber,
    uint256 _payment
  )
    external
    payable
    override
    onlyValidJob(_job)
    validateStealthTxAndBlock(_stealthHash, _blockNumber)
    setsCaller()
    returns (bytes memory _returnData)
  {
    _returnData = _callWithValue(_job, _callData, msg.value - _payment);
    block.coinbase.transfer(_payment);
  }

  function executeWithoutBlockProtection(
    address _job,
    bytes memory _callData,
    bytes32 _stealthHash
  ) external payable override onlyValidJob(_job) validateStealthTx(_stealthHash) setsCaller() returns (bytes memory _returnData) {
    require(!forceBlockProtection, 'SR: block protection required');
    return _callWithValue(_job, _callData, msg.value);
  }

  function executeWithoutBlockProtectionAndPay(
    address _job,
    bytes memory _callData,
    bytes32 _stealthHash,
    uint256 _payment
  ) external payable override onlyValidJob(_job) validateStealthTx(_stealthHash) setsCaller() returns (bytes memory _returnData) {
    require(!forceBlockProtection, 'SR: block protection required');
    _returnData = _callWithValue(_job, _callData, msg.value - _payment);
    block.coinbase.transfer(_payment);
  }

  function _callWithValue(
    address _job,
    bytes memory _callData,
    uint256 _value
  ) internal returns (bytes memory _returnData) {
    return _job.functionCallWithValue(_callData, _value, 'SR: call reverted');
  }

  function setForceBlockProtection(bool _forceBlockProtection) external override onlyGovernor {
    forceBlockProtection = _forceBlockProtection;
  }

  function jobs() external view override returns (address[] memory _jobsList) {
    _jobsList = new address[](_jobs.length());
    for (uint256 i; i < _jobs.length(); i++) {
      _jobsList[i] = _jobs.at(i);
    }
  }

  // Setup trusted contracts to call (jobs)
  function addJobs(address[] calldata _jobsList) external override onlyGovernor {
    for (uint256 i = 0; i < _jobsList.length; i++) {
      _addJob(_jobsList[i]);
    }
  }

  function addJob(address _job) external override onlyGovernor {
    _addJob(_job);
  }

  function _addJob(address _job) internal {
    require(_jobs.add(_job), 'SR: job already added');
  }

  function removeJobs(address[] calldata _jobsList) external override onlyGovernor {
    for (uint256 i = 0; i < _jobsList.length; i++) {
      _removeJob(_jobsList[i]);
    }
  }

  function removeJob(address _job) external override onlyGovernor {
    _removeJob(_job);
  }

  function _removeJob(address _job) internal {
    require(_jobs.remove(_job), 'SR: job not found');
  }

  // StealthTx: restricted-access
  function setPenalty(uint256 _penalty) external override onlyGovernor {
    _setPenalty(_penalty);
  }

  function setStealthVault(address _stealthVault) external override onlyGovernor {
    _setStealthVault(_stealthVault);
  }

  // Governable: restricted-access
  function setPendingGovernor(address _pendingGovernor) external override onlyGovernor {
    _setPendingGovernor(_pendingGovernor);
  }

  function acceptGovernor() external override onlyPendingGovernor {
    _acceptGovernor();
  }

  // Collectable Dust: restricted-access
  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external override onlyGovernor {
    _sendDust(_to, _token, _amount);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import '../../interfaces/utils/ICollectableDust.sol';

abstract
contract CollectableDust is ICollectableDust {
  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.AddressSet;

  address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  EnumerableSet.AddressSet internal protocolTokens;

  constructor() {}

  function _addProtocolToken(address _token) internal {
    require(!protocolTokens.contains(_token), 'collectable-dust/token-is-part-of-the-protocol');
    protocolTokens.add(_token);
  }

  function _removeProtocolToken(address _token) internal {
    require(protocolTokens.contains(_token), 'collectable-dust/token-not-part-of-the-protocol');
    protocolTokens.remove(_token);
  }

  function _sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) internal {
    require(_to != address(0), 'collectable-dust/cant-send-dust-to-zero-address');
    require(!protocolTokens.contains(_token), 'collectable-dust/token-is-part-of-the-protocol');
    if (_token == ETH_ADDRESS) {
      payable(_to).transfer(_amount);
    } else {
      IERC20(_token).safeTransfer(_to, _amount);
    }
    emit DustSent(_to, _token, _amount);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../../interfaces/utils/IGovernable.sol';

abstract
contract Governable is IGovernable {
  address public override governor;
  address public override pendingGovernor;

  constructor(address _governor) {
    require(_governor != address(0), 'governable/governor-should-not-be-zero-address');
    governor = _governor;
  }

  function _setPendingGovernor(address _pendingGovernor) internal {
    require(_pendingGovernor != address(0), 'governable/pending-governor-should-not-be-zero-addres');
    pendingGovernor = _pendingGovernor;
    emit PendingGovernorSet(_pendingGovernor);
  }

  function _acceptGovernor() internal {
    governor = pendingGovernor;
    pendingGovernor = address(0);
    emit GovernorAccepted();
  }

  function isGovernor(address _account) public view override returns (bool _isGovernor) {
    return _account == governor;
  }

  modifier onlyGovernor {
    require(isGovernor(msg.sender), 'governable/only-governor');
    _;
  }

  modifier onlyPendingGovernor {
    require(msg.sender == pendingGovernor, 'governable/only-pending-governor');
    _;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */


// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;



// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './interfaces/IStealthVault.sol';
import './interfaces/IStealthTx.sol';

/*
 * StealthTxAbstract
 */
abstract contract StealthTx is IStealthTx {
  address public override stealthVault;
  uint256 public override penalty = 1 ether;

  constructor(address _stealthVault) {
    _setStealthVault(_stealthVault);
  }

  modifier validateStealthTx(bytes32 _stealthHash) {
    // if not valid, do not revert execution. just return.
    if (!_validateStealthTx(_stealthHash)) return;
    _;
  }

  modifier validateStealthTxAndBlock(bytes32 _stealthHash, uint256 _blockNumber) {
    // if not valid, do not revert execution. just return.
    if (!_validateStealthTxAndBlock(_stealthHash, _blockNumber)) return;
    _;
  }

  function _validateStealthTx(bytes32 _stealthHash) internal returns (bool) {
    return IStealthVault(stealthVault).validateHash(msg.sender, _stealthHash, penalty);
  }

  function _validateStealthTxAndBlock(bytes32 _stealthHash, uint256 _blockNumber) internal returns (bool) {
    require(block.number == _blockNumber, 'ST: wrong block');
    return _validateStealthTx(_stealthHash);
  }

  function _setPenalty(uint256 _penalty) internal {
    require(_penalty > 0, 'ST: zero penalty');
    penalty = _penalty;
    emit PenaltySet(_penalty);
  }

  function _setStealthVault(address _stealthVault) internal {
    require(_stealthVault != address(0), 'ST: zero address');
    require(IStealthVault(_stealthVault).isStealthVault(), 'ST: not stealth vault');
    stealthVault = _stealthVault;
    emit StealthVaultSet(_stealthVault);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;



// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;



// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;



// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;



{
  "optimizer": {
    "enabled": true,
    "runs": 200
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