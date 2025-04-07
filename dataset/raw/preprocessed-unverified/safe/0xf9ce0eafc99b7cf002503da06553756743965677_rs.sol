/**
 *Submitted for verification at Etherscan.io on 2019-06-20
*/

/**
 *Submitted for verification at Etherscan.io on 2019-02-09
*/

/**
 * Copyright (c) 2018-present, Leap DAO (leapdao.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */

pragma solidity 0.5.2;

/**
 * @title Math
 * @dev Assorted math operations
 */



contract Bridge {

  event NewHeight(uint256 height, bytes32 indexed root);
  event NewOperator(address operator);

  struct Period {
    uint32 height;  // the height of last block in period
    uint32 timestamp;
  }

  bytes32 constant GENESIS = 0x4920616d207665727920616e6772792c20627574206974207761732066756e21;

  bytes32 public tipHash; // hash of first period that has extended chain to some height
  uint256 public genesisBlockNumber;
  uint256 parentBlockInterval; // how often epochs can be submitted max
  uint256 public lastParentBlock; // last ethereum block when epoch was submitted
  address public operator; // the operator contract

  mapping(bytes32 => Period) public periods;

  function getParentBlockInterval() public view returns (uint256) {
    return parentBlockInterval;
  }

  function setParentBlockInterval(uint256 _parentBlockInterval) public {
    parentBlockInterval = _parentBlockInterval;
  }

  function submitPeriod(
    bytes32 _prevHash, 
    bytes32 _root) 
  public returns (uint256 newHeight) {

  }
}

contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

/**
 * @title Adminable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Adminable is Initializable {

  /**
   * @dev Storage slot with the admin of the contract.
   * This is the keccak-256 hash of "org.zeppelinos.proxy.admin", and is
   * validated in the constructor.
   */
  bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

  /**
   * @dev Modifier to check whether the `msg.sender` is the admin.
   * If it is, it will run the function. Otherwise, fails.
   */
  modifier ifAdmin() {
    require(msg.sender == _admin());
    _;
  }

  function admin() external view returns (address) {
    return _admin();
  }

    /**
   * @return The admin slot.
   */
  function _admin() internal view returns (address adm) {
    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */


/**
 * @title IERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */


contract TransferrableToken is ERC165 {
  function transferFrom(address _from, address _to, uint256 _valueOrTokenId) public;
  function approve(address _to, uint256 _value) public;
}






/**
 * @title PriorityQueue
 * @dev A priority queue implementation
 */



contract Vault is Adminable {

  event NewToken(address indexed tokenAddr, uint16 color);

  Bridge public bridge;

  uint16 public erc20TokenCount;
  uint16 public nftTokenCount;

  mapping(uint16 => PriorityQueue.Token) public tokens;
  mapping(address => bool) public tokenColors;

  function initialize(Bridge _bridge) public initializer {
    bridge = _bridge;
  } 

  function getTokenAddr(uint16 _color) public view returns (address) {
    return address(tokens[_color].addr);
  }

  function registerToken(address _token, bool _isERC721) public ifAdmin {
    // make sure token is not 0x0 and that it has not been registered yet
    require(_token != address(0), "Tried to register 0x0 address");
    require(!tokenColors[_token], "Token already registered");
    uint16 color;
    if (_isERC721) {
      require(TransferrableToken(_token).supportsInterface(0x80ac58cd) == true, "Not an ERC721 token");
      color = 32769 + nftTokenCount; // NFT color namespace starts from 2^15 + 1
      nftTokenCount += 1;
    } else {
      require(ERC20(_token).totalSupply() >= 0, "Not an ERC20 token");
      color = erc20TokenCount;
      erc20TokenCount += 1;
    }
    uint256[] memory arr = new uint256[](1);
    tokenColors[_token] = true;
    tokens[color] = PriorityQueue.Token({
      addr: TransferrableToken(_token),
      heapList: arr,
      currentSize: 0
    });
    emit NewToken(_token, color);
  }

  // solium-disable-next-line mixedcase
  uint256[50] private ______gap;

}

contract DepositHandler is Vault {

  event NewDeposit(
    uint32 indexed depositId, 
    address indexed depositor, 
    uint256 indexed color, 
    uint256 amount
  );
  event MinGasPrice(uint256 minGasPrice);

  struct Deposit {
    uint64 time;
    uint16 color;
    address owner;
    uint256 amount;
  }

  uint32 public depositCount;
  uint256 public minGasPrice;

  mapping(uint32 => Deposit) public deposits;

  function setMinGasPrice(uint256 _minGasPrice) public ifAdmin {
    minGasPrice = _minGasPrice;
    emit MinGasPrice(minGasPrice);
  }

   /**
   * @notice Add to the network `(_amountOrTokenId)` amount of a `(_color)` tokens
   * or `(_amountOrTokenId)` token id if `(_color)` is NFT.
   * @dev Token should be registered with the Bridge first.
   * @param _owner Account to transfer tokens from
   * @param _amountOrTokenId Amount (for ERC20) or token ID (for ERC721) to transfer
   * @param _color Color of the token to deposit
   */
  function deposit(address _owner, uint256 _amountOrTokenId, uint16 _color) public {
    TransferrableToken token = tokens[_color].addr;
    require(address(token) != address(0), "Token color not registered");
    require(_amountOrTokenId > 0 || _color > 32769, "no 0 deposits for fungible tokens");
    token.transferFrom(_owner, address(this), _amountOrTokenId);

    bytes32 tipHash = bridge.tipHash();
    uint256 timestamp;
    (, timestamp) = bridge.periods(tipHash);

    depositCount++;
    deposits[depositCount] = Deposit({
      time: uint32(timestamp),
      owner: _owner,
      color: _color,
      amount: _amountOrTokenId
    });
    emit NewDeposit(
      depositCount, 
      _owner, 
      _color, 
      _amountOrTokenId
    );
  }

  // solium-disable-next-line mixedcase
  uint256[50] private ______gap;
}




contract ExitHandler is DepositHandler {

  using PriorityQueue for PriorityQueue.Token;

  event ExitStarted(
    bytes32 indexed txHash, 
    uint8 indexed outIndex, 
    uint256 indexed color, 
    address exitor, 
    uint256 amount
  );

  struct Exit {
    uint256 amount;
    uint16 color;
    address owner;
    bool finalized;
    uint32 priorityTimestamp;
    uint256 stake;
  }

  uint256 public exitDuration;
  uint256 public exitStake;
  uint256 public nftExitCounter;

  /**
   * UTXO ¡ú Exit mapping. Contains exits for both NFT and ERC20 colors
   */
  mapping(bytes32 => Exit) public exits;

  function initializeWithExit(
    Bridge _bridge, 
    uint256 _exitDuration, 
    uint256 _exitStake) public initializer {
    initialize(_bridge);
    exitDuration = _exitDuration;
    exitStake = _exitStake;
    emit MinGasPrice(0);
  }

  function setExitStake(uint256 _exitStake) public ifAdmin {
    exitStake = _exitStake;
  }

  function setExitDuration(uint256 _exitDuration) public ifAdmin {
    exitDuration = _exitDuration;
  }

  function startExit(
    bytes32[] memory _youngestInputProof, bytes32[] memory _proof,
    uint8 _outputIndex, uint8 _inputIndex
  ) public payable {
    require(msg.value >= exitStake, "Not enough ether sent to pay for exit stake");
    uint32 timestamp;
    (, timestamp) = bridge.periods(_proof[0]);
    require(timestamp > 0, "The referenced period was not submitted to bridge");

    if (_youngestInputProof.length > 0) {
      (, timestamp) = bridge.periods(_youngestInputProof[0]);
      require(timestamp > 0, "The referenced period was not submitted to bridge");
    }

    // check exiting tx inclusion in the root chain block
    bytes32 txHash;
    bytes memory txData;
    uint64 txPos;
    (txPos, txHash, txData) = TxLib.validateProof(32 * (_youngestInputProof.length + 2) + 64, _proof);

    // parse exiting tx and check if it is exitable
    TxLib.Tx memory exitingTx = TxLib.parseTx(txData);
    TxLib.Output memory out = exitingTx.outs[_outputIndex];

    bytes32 utxoId = bytes32(uint256(_outputIndex) << 120 | uint120(uint256(txHash)));
    require(out.owner == msg.sender, "Only UTXO owner can start exit");
    require(out.value > 0, "UTXO has no value");
    require(exits[utxoId].amount == 0, "The exit for UTXO has already been started");
    require(!exits[utxoId].finalized, "The exit for UTXO has already been finalized");

    uint256 priority;
    if (_youngestInputProof.length > 0) {
      // check youngest input tx inclusion in the root chain block
      bytes32 inputTxHash;
      (txPos, inputTxHash,) = TxLib.validateProof(96, _youngestInputProof);
      require(
        inputTxHash == exitingTx.ins[_inputIndex].outpoint.hash, 
        "Input from the proof is not referenced in exiting tx"
      );
      
      if (isNft(out.color)) {
        priority = (nftExitCounter << 128) | uint128(uint256(utxoId));
        nftExitCounter++;
      } else {      
        priority = getERC20ExitPriority(timestamp, utxoId, txPos);
      }
    } else {
      require(exitingTx.txType == TxLib.TxType.Deposit, "Expected deposit tx");
      if (isNft(out.color)) {
        priority = (nftExitCounter << 128) | uint128(uint256(utxoId));
        nftExitCounter++;
      } else {      
        priority = getERC20ExitPriority(timestamp, utxoId, txPos);
      }
    }

    tokens[out.color].insert(priority);

    exits[utxoId] = Exit({
      owner: out.owner,
      color: out.color,
      amount: out.value,
      finalized: false,
      stake: exitStake,
      priorityTimestamp: timestamp
    });
    emit ExitStarted(
      txHash, 
      _outputIndex, 
      out.color, 
      out.owner, 
      out.value
    );
  }

  function startDepositExit(uint256 _depositId) public payable {
    require(msg.value >= exitStake, "Not enough ether sent to pay for exit stake");
    // check that deposit exits
    Deposit memory deposit = deposits[uint32(_depositId)];
    require(deposit.owner == msg.sender, "Only deposit owner can start exit");
    require(deposit.amount > 0, "deposit has no value");
    require(exits[bytes32(_depositId)].amount == 0, "The exit of deposit has already been started");
    require(!exits[bytes32(_depositId)].finalized, "The exit for deposit has already been finalized");
    
    uint256 priority;
    if (isNft(deposit.color)) {
      priority = (nftExitCounter << 128) | uint128(_depositId);
      nftExitCounter++;
    } else {      
      priority = getERC20ExitPriority(uint32(deposit.time), bytes32(_depositId), 0);
    }

    tokens[deposit.color].insert(priority);

    exits[bytes32(_depositId)] = Exit({
      owner: deposit.owner,
      color: deposit.color,
      amount: deposit.amount,
      finalized: false,
      stake: exitStake,
      priorityTimestamp: uint32(now)
    });
    emit ExitStarted(
      bytes32(_depositId), 
      0, 
      deposit.color, 
      deposit.owner, 
      deposit.amount
    );
  }

  // @dev Finalizes exit for the chosen color with the highest priority
  function finalizeExits(uint16 _color) public {
    bytes32 utxoId;
    uint256 exitableAt;
    Exit memory currentExit;

    (utxoId, exitableAt) = getNextExit(_color);

    require(tokens[_color].currentSize > 0, "Queue empty for color.");

    for (uint i = 0; i<20; i++) {
      // if queue is empty or top exit cannot be exited yet, stop
      if (exitableAt > block.timestamp) {
        return;
      }

      currentExit = exits[utxoId];

      if (currentExit.owner != address(0) || currentExit.amount != 0) { // exit was not removed
        // Note: for NFTs, the amount is actually the NFT id (both uint256)
        if (isNft(currentExit.color)) {
          tokens[currentExit.color].addr.transferFrom(address(this), currentExit.owner, currentExit.amount);
        } else {
          tokens[currentExit.color].addr.approve(address(this), currentExit.amount);
          tokens[currentExit.color].addr.transferFrom(address(this), currentExit.owner, currentExit.amount);
        }
        // Pay exit stake
        address(uint160(currentExit.owner)).send(currentExit.stake);

      }

      tokens[currentExit.color].delMin();
      exits[utxoId].finalized = true;

      if (tokens[currentExit.color].currentSize > 0) {
        (utxoId, exitableAt) = getNextExit(_color);
      } else {
        return;
      }
    }
  }

  // @dev For backwards compatibility reasons...
  function finalizeTopExit(uint16 _color) public {
    finalizeExits(_color);
  }

  function challengeExit(
    bytes32[] memory _proof, 
    bytes32[] memory _prevProof, 
    uint8 _outputIndex,
    uint8 _inputIndex
  ) public {
    // validate exiting tx
    uint256 offset = 32 * (_proof.length + 2);
    bytes32 txHash1;
    bytes memory txData;
    (, txHash1, txData) = TxLib.validateProof(offset + 64, _prevProof);
    bytes32 utxoId = bytes32(uint256(_outputIndex) << 120 | uint120(uint256(txHash1)));
    
    TxLib.Tx memory txn;
    if (_proof.length > 0) {
      // validate spending tx
      bytes32 txHash;
      (, txHash, txData) = TxLib.validateProof(96, _proof);
      txn = TxLib.parseTx(txData);

      // make sure one is spending the other one
      require(txHash1 == txn.ins[_inputIndex].outpoint.hash);
      require(_outputIndex == txn.ins[_inputIndex].outpoint.pos);

      // if transfer, make sure signature correct
      if (txn.txType == TxLib.TxType.Transfer) {
        bytes32 sigHash = TxLib.getSigHash(txData);
        address signer = ecrecover(
          sigHash, 
          txn.ins[_inputIndex].v, 
          txn.ins[_inputIndex].r, 
          txn.ins[_inputIndex].s
        );
        require(exits[utxoId].owner == signer);
      } else {
        revert("unknown tx type");
      }
    } else {
      // challenging deposit exit
      txn = TxLib.parseTx(txData);
      utxoId = txn.ins[_inputIndex].outpoint.hash;
      if (txn.txType == TxLib.TxType.Deposit) {
        // check that deposit was included correctly
        // only then it should be usable for challenge
        Deposit memory deposit = deposits[uint32(uint256(utxoId))];
        require(deposit.amount == txn.outs[0].value, "value mismatch");
        require(deposit.owner == txn.outs[0].owner, "owner mismatch");
        require(deposit.color == txn.outs[0].color, "color mismatch");
        // todo: check timely inclusion of deposit tx
        // this will prevent grieving attacks by the operator
      } else {
        revert("unexpected tx type");
      }
    }

    require(exits[utxoId].amount > 0, "exit not found");
    require(!exits[utxoId].finalized, "The exit has already been finalized");

    // award stake to challanger
    msg.sender.transfer(exits[utxoId].stake);
    // delete invalid exit
    delete exits[utxoId];
  }

  function challengeYoungestInput(
    bytes32[] memory _youngerInputProof,
    bytes32[] memory _exitingTxProof, 
    uint8 _outputIndex, 
    uint8 _inputIndex
  ) public {
    // validate exiting input tx
    bytes32 txHash;
    bytes memory txData;
    (, txHash, txData) = TxLib.validateProof(32 * (_youngerInputProof.length + 2) + 64, _exitingTxProof);
    bytes32 utxoId = bytes32(uint256(_outputIndex) << 120 | uint120(uint256(txHash)));

    // check the exit exists
    require(exits[utxoId].amount > 0, "There is no exit for this UTXO");

    TxLib.Tx memory exitingTx = TxLib.parseTx(txData);

    // validate younger input tx
    (,txHash,) = TxLib.validateProof(96, _youngerInputProof);
    
    // check younger input is actually an input of exiting tx
    require(txHash == exitingTx.ins[_inputIndex].outpoint.hash, "Given output is not referenced in exiting tx");
    
    uint32 youngerInputTimestamp;
    (,youngerInputTimestamp) = bridge.periods(_youngerInputProof[0]);
    require(youngerInputTimestamp > 0, "The referenced period was not submitted to bridge");

    require(exits[utxoId].priorityTimestamp < youngerInputTimestamp, "Challenged input should be older");

    // award stake to challanger
    msg.sender.transfer(exits[utxoId].stake);
    // delete invalid exit
    delete exits[utxoId];
  }

  function getNextExit(uint16 _color) internal view returns (bytes32 utxoId, uint256 exitableAt) {
    uint256 priority = tokens[_color].getMin();
    utxoId = bytes32(uint256(uint128(priority)));
    exitableAt = priority >> 192;
  }

  function isNft(uint16 _color) internal pure returns (bool) {
    return _color > 32768; // 2^15
  }

  function getERC20ExitPriority(
    uint32 timestamp, bytes32 utxoId, uint64 txPos
  ) internal view returns (uint256 priority) {
    uint256 exitableAt = Math.max(timestamp + (2 * exitDuration), block.timestamp + exitDuration);
    return (exitableAt << 192) | uint256(txPos) << 128 | uint128(uint256(utxoId));
  }

  // solium-disable-next-line mixedcase
  uint256[50] private ______gap;
}

contract FastExitHandlerMigration is ExitHandler {

  struct Data {
    uint32 timestamp;
    bytes32 txHash;
    uint64 txPos;
    bytes32 utxoId;
  }

  function deposit(address, uint256, uint16) public {
    revert("not implemented");
  }

  function startExit(bytes32[] memory, bytes32[] memory, uint8, uint8) public payable {
    revert("not implemented");
  }

  function startDepositExit(uint256) public payable {
    revert("not implemented");
  }

  function startBoughtExit(bytes32[] memory, bytes32[] memory, uint8, uint8, bytes32[] memory) public payable {
    revert("not implemented");
  }

}