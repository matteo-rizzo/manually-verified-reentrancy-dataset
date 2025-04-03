/**
 *Submitted for verification at Etherscan.io on 2020-05-11
*/

pragma solidity 0.6.2;

contract Whitelisted is Owned {

  bool public whitelistEnabled;
  mapping(address => bool) public whitelisted;

  event AddedToWhitelist(address user);
  event RemovedFromWhitelist(address user);
  event WhitelistEnabled();
  event WhitelistDisabled();

  constructor()
    public
  {
    whitelistEnabled = true;
  }

  /**
   * @notice Adds an address to the whitelist
   * @param _user The address to whitelist
   */
  function addToWhitelist(address _user) external onlyOwner() {
    whitelisted[_user] = true;
    emit AddedToWhitelist(_user);
  }

  /**
   * @notice Removes an address from the whitelist
   * @param _user The address to remove
   */
  function removeFromWhitelist(address _user) external onlyOwner() {
    delete whitelisted[_user];
    emit RemovedFromWhitelist(_user);
  }

  /**
   * @notice makes the whitelist check enforced
   */
  function enableWhitelist()
    external
    onlyOwner()
  {
    whitelistEnabled = true;

    emit WhitelistEnabled();
  }

  /**
   * @notice makes the whitelist check unenforced
   */
  function disableWhitelist()
    external
    onlyOwner()
  {
    whitelistEnabled = false;

    emit WhitelistDisabled();
  }

  /**
   * @dev reverts if the caller is not whitelisted
   */
  modifier isWhitelisted() {
    require(whitelisted[msg.sender] || !whitelistEnabled, "Not whitelisted");
    _;
  }
}

interface AggregatorInterface is HistoricAggregatorInterface {
  function decimals() external returns (uint8);
  function getRoundData(uint256 _roundId)
    external
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    );
  function latestRoundData()
    external
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    );
}
contract AggregatorProxy is AggregatorInterface, Owned {

  AggregatorInterface public aggregator;

  constructor(address _aggregator) public Owned() {
    setAggregator(_aggregator);
  }

  /**
   * @notice Reads the current answer from aggregator delegated to.
   */
  function latestAnswer()
    external
    virtual
    override
    returns (int256)
  {
    return _latestAnswer();
  }

  /**
   * @notice Reads the last updated height from aggregator delegated to.
   */
  function latestTimestamp()
    external
    virtual
    override
    returns (uint256)
  {
    return _latestTimestamp();
  }

  /**
   * @notice get past rounds answers
   * @param _roundId the answer number to retrieve the answer for
   */
  function getAnswer(uint256 _roundId)
    external
    virtual
    override
    returns (int256)
  {
    return _getAnswer(_roundId);
  }

  /**
   * @notice get block timestamp when an answer was last updated
   * @param _roundId the answer number to retrieve the updated timestamp for
   */
  function getTimestamp(uint256 _roundId)
    external
    virtual
    override
    returns (uint256)
  {
    return _getTimestamp(_roundId);
  }

  /**
   * @notice get the latest completed round where the answer was updated
   */
  function latestRound()
    external
    virtual
    override
    returns (uint256)
  {
    return _latestRound();
  }

  /**
   * @notice get data about a round. Consumers are encouraged to check
   * that they're receiving fresh data by inspecting the updatedAt and
   * answeredInRound return values.
   * Note that different underlying implementations of AggregatorInterface
   * have slightly different semantics for some of the return values. Consumers
   * should determine what implementations they expect to receive
   * data from and validate that they can properly handle return data from all
   * of them.
   * @param _roundId the round ID to retrieve the round data for
   * @return roundId is the round ID for which data was retrieved
   * @return answer is the answer for the given round
   * @return startedAt is the timestamp when the round was started.
   * (Only some AggregatorInterface implementations return meaningful values)
   * @return updatedAt is the timestamp when the round last was updated (i.e.
   * answer was last computed)
   * @return answeredInRound is the round ID of the round in which the answer
   * was computed.
   * (Only some AggregatorInterface implementations return meaningful values)
   * @dev Note that answer and updatedAt may change between queries.
   */
  function getRoundData(uint256 _roundId)
    external
    virtual
    override
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    )
  {
    return _getRoundData(_roundId);
  }

  /**
   * @notice get data about the latest round. Consumers are encouraged to check
   * that they're receiving fresh data by inspecting the updatedAt and
   * answeredInRound return values.
   * Note that different underlying implementations of AggregatorInterface
   * have slightly different semantics for some of the return values. Consumers
   * should determine what implementations they expect to receive
   * data from and validate that they can properly handle return data from all
   * of them.
   * @return roundId is the round ID for which data was retrieved
   * @return answer is the answer for the given round
   * @return startedAt is the timestamp when the round was started.
   * (Only some AggregatorInterface implementations return meaningful values)
   * @return updatedAt is the timestamp when the round last was updated (i.e.
   * answer was last computed)
   * @return answeredInRound is the round ID of the round in which the answer
   * was computed.
   * (Only some AggregatorInterface implementations return meaningful values)
   * @dev Note that answer and updatedAt may change between queries.
   */
  function latestRoundData()
    external
    virtual
    override
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    )
  {
    return _latestRoundData();
  }

  /**
   * @notice represents the number of decimals the aggregator responses represent.
   */
  function decimals()
    external
    override
    returns (uint8)
  {
    return aggregator.decimals();
  }

  /**
   * @notice Allows the owner to update the aggregator address.
   * @param _aggregator The new address for the aggregator contract
   */
  function setAggregator(address _aggregator)
    public
    onlyOwner()
  {
    aggregator = AggregatorInterface(_aggregator);
  }

  /*
   * Internal
   */

  function _latestAnswer()
    internal
    returns (int256)
  {
    return aggregator.latestAnswer();
  }

  function _latestTimestamp()
    internal
    returns (uint256)
  {
    return aggregator.latestTimestamp();
  }

  function _getAnswer(uint256 _roundId)
    internal
    returns (int256)
  {
    return aggregator.getAnswer(_roundId);
  }

  function _getTimestamp(uint256 _roundId)
    internal
    returns (uint256)
  {
    return aggregator.getTimestamp(_roundId);
  }

  function _latestRound()
    internal
    returns (uint256)
  {
    return aggregator.latestRound();
  }

  function _getRoundData(uint256 _roundId)
    internal
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    )
  {
    return aggregator.getRoundData(_roundId);
  }

  function _latestRoundData()
    internal
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    )
  {
    return aggregator.latestRoundData();
  }
}
contract WhitelistedAggregatorProxy is AggregatorProxy, Whitelisted {

  constructor(address _aggregator) public AggregatorProxy(_aggregator) {
  }

  /**
   * @notice Reads the current answer from aggregator delegated to.
   * @dev overridden function to add the isWhitelisted() modifier
   */
  function latestAnswer()
    external
    override
    isWhitelisted()
    returns (int256)
  {
    return _latestAnswer();
  }

  /**
   * @notice Reads the last updated height from aggregator delegated to.
   * @dev overridden function to add the isWhitelisted() modifier
   */
  function latestTimestamp()
    external
    override
    isWhitelisted()
    returns (uint256)
  {
    return _latestTimestamp();
  }

  /**
   * @notice get past rounds answers
   * @param _roundId the answer number to retrieve the answer for
   * @dev overridden function to add the isWhitelisted() modifier
   */
  function getAnswer(uint256 _roundId)
    external
    override
    isWhitelisted()
    returns (int256)
  {
    return _getAnswer(_roundId);
  }

  /**
   * @notice get block timestamp when an answer was last updated
   * @param _roundId the answer number to retrieve the updated timestamp for
   * @dev overridden function to add the isWhitelisted() modifier
   */
  function getTimestamp(uint256 _roundId)
    external
    override
    isWhitelisted()
    returns (uint256)
  {
    return _getTimestamp(_roundId);
  }

  /**
   * @notice get the latest completed round where the answer was updated
   * @dev overridden function to add the isWhitelisted() modifier
   */
  function latestRound()
    external
    override
    isWhitelisted()
    returns (uint256)
  {
    return _latestRound();
  }

  /**
   * @notice get data about a round. Consumers are encouraged to check
   * that they're receiving fresh data by inspecting the updatedAt and
   * answeredInRound return values.
   * Note that different underlying implementations of AggregatorInterface
   * have slightly different semantics for some of the return values. Consumers
   * should determine what implementations they expect to receive
   * data from and validate that they can properly handle return data from all
   * of them.
   * @param _roundId the round ID to retrieve the round data for
   * @return roundId is the round ID for which data was retrieved
   * @return answer is the answer for the given round
   * @return startedAt is the timestamp when the round was started.
   * (Only some AggregatorInterface implementations return meaningful values)
   * @return updatedAt is the timestamp when the round last was updated (i.e.
   * answer was last computed)
   * @return answeredInRound is the round ID of the round in which the answer
   * was computed.
   * (Only some AggregatorInterface implementations return meaningful values)
   * @dev Note that answer and updatedAt may change between queries.
   */
  function getRoundData(uint256 _roundId)
    external
    isWhitelisted()
    override
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    )
  {
    return _getRoundData(_roundId);
  }

  /**
   * @notice get data about the latest round. Consumers are encouraged to check
   * that they're receiving fresh data by inspecting the updatedAt and
   * answeredInRound return values.
   * Note that different underlying implementations of AggregatorInterface
   * have slightly different semantics for some of the return values. Consumers
   * should determine what implementations they expect to receive
   * data from and validate that they can properly handle return data from all
   * of them.
   * @return roundId is the round ID for which data was retrieved
   * @return answer is the answer for the given round
   * @return startedAt is the timestamp when the round was started.
   * (Only some AggregatorInterface implementations return meaningful values)
   * @return updatedAt is the timestamp when the round last was updated (i.e.
   * answer was last computed)
   * @return answeredInRound is the round ID of the round in which the answer
   * was computed.
   * (Only some AggregatorInterface implementations return meaningful values)
   * @dev Note that answer and updatedAt may change between queries.
   */
  function latestRoundData()
    external
    isWhitelisted()
    override
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    )
  {
    return _latestRoundData();
  }

}