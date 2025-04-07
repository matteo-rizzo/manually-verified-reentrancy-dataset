/**
 *Submitted for verification at Etherscan.io on 2019-09-21
*/

pragma solidity ^0.5.0;








contract Operable is Ownable {
  event OperatorAdded(address indexed account);
  event OperatorRemoved(address indexed account);

  mapping (address => bool) private _operators;

  constructor() public {
    _addOperator(msg.sender);
  }

  modifier onlyOperator() {
    require(isOperator(msg.sender));
    _;
  }

  function isOperator(address account)
    public
    view
    returns (bool) 
  {
    require(account != address(0));
    return _operators[account];
  }

  function addOperator(address account)
    public
    onlyOwner
  {
    _addOperator(account);
  }

  function removeOperator(address account)
    public
    onlyOwner
  {
    _removeOperator(account);
  }

  function _addOperator(address account)
    internal
  {
    require(account != address(0));
    _operators[account] = true;
    emit OperatorAdded(account);
  }

  function _removeOperator(address account)
    internal
  {
    require(account != address(0));
    _operators[account] = false;
    emit OperatorRemoved(account);
  }
}

contract TimestampNotary is Operable {
  struct Time {
    uint32 declared;
    uint32 recorded;
  }
  mapping (bytes32 => Time) _hashTime;

  event Timestamp(
    bytes32 indexed hash,
    uint32 declaredTime,
    uint32 recordedTime
  );

  /**
   * @dev Allows an operator to timestamp a new hash value.
   * @param hash bytes32 The hash value to be stamped in the contract storage
   * @param declaredTime uint The timestamp associated with the given hash value
   */
  function addTimestamp(bytes32 hash, uint32 declaredTime)
    public
    onlyOperator
    returns (bool)
  {
    _addTimestamp(hash, declaredTime);
    return true;
  }

  /**
   * @dev Registers the timestamp hash value in the contract storage, along with
   * the current and declared timestamps.
   * @param hash bytes32 The hash value to be registered
   * @param declaredTime uint32 The declared timestamp of the hash value
   */
  function _addTimestamp(bytes32 hash, uint32 declaredTime) internal {
    uint32 recordedTime = uint32(block.timestamp);
    _hashTime[hash] = Time(declaredTime, recordedTime);
    emit Timestamp(hash, declaredTime, recordedTime);
  }

  /**
   * @dev Allows anyone to verify the declared timestamp for any given hash.
   */
  function verifyDeclaredTime(bytes32 hash)
    public
    view
    returns (uint32)
  {
    return _hashTime[hash].declared;
  }


  function verifyRecordedTime(bytes32 hash)
    public
    view
    returns (uint32)
  {
    return _hashTime[hash].recorded;
  }
}


contract LinkedTokenAbstract {
  function totalSupply() public view returns (uint256);
  function balanceOf(address account) public view returns (uint256);
}


contract LinkedToken is Ownable {
  address internal _token;
  event TokenChanged(address indexed token);
  

  function tokenAddress() public view returns (address) {
    return _token;
  }


  function setToken(address token) 
    public
    onlyOwner
    returns (bool)
  {
    _setToken(token);
    emit TokenChanged(token);
    return true;
  }


  function _setToken(address token) internal {
    require(token != address(0));
    _token = token;
  }
}


contract QUANTLCA is TimestampNotary, LinkedToken {
  string public constant name = 'QUANTL Certification Authority';

}