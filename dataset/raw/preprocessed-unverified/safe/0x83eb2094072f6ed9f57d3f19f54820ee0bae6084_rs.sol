/**
 *Submitted for verification at Etherscan.io on 2021-08-07
*/

pragma solidity 0.8.3;

/** 
 @author Tellor Inc.
 @title ITellor
 @dev  This contract holds the interface for all Tellor functions
**/


/**
  @author Tellor Inc.
  @title TellorStorage
  @dev Contains all the variables/structs used by Tellor
*/
contract TellorStorage {
    //Internal struct for use in proof-of-work submission
    struct Details {
        uint256 value;
        address miner;
    }
    struct Dispute {
        bytes32 hash; //unique hash of dispute: keccak256(_miner,_requestId,_timestamp)
        int256 tally; //current tally of votes for - against measure
        bool executed; //is the dispute settled
        bool disputeVotePassed; //did the vote pass?
        bool isPropFork; //true for fork proposal NEW
        address reportedMiner; //miner who submitted the 'bad value' will get disputeFee if dispute vote fails
        address reportingParty; //miner reporting the 'bad value'-pay disputeFee will get reportedMiner's stake if dispute vote passes
        address proposedForkAddress; //new fork address (if fork proposal)
        mapping(bytes32 => uint256) disputeUintVars;
        mapping(address => bool) voted; //mapping of address to whether or not they voted
    }
    struct StakeInfo {
        uint256 currentStatus; //0-not Staked, 1=Staked, 2=LockedForWithdraw 3= OnDispute 4=ReadyForUnlocking 5=Unlocked
        uint256 startDate; //stake start date
    }
    //Internal struct to allow balances to be queried by blocknumber for voting purposes
    struct Checkpoint {
        uint128 fromBlock; // fromBlock is the block number that the value was generated from
        uint128 value; // value is the amount of tokens at a specific block number
    }
    struct Request {
        uint256[] requestTimestamps; //array of all newValueTimestamps requested
        mapping(bytes32 => uint256) apiUintVars;
        mapping(uint256 => uint256) minedBlockNum; //[apiId][minedTimestamp]=>block.number
        //This the time series of finalValues stored by the contract where uint UNIX timestamp is mapped to value
        mapping(uint256 => uint256) finalValues;
        mapping(uint256 => bool) inDispute; //checks if API id is in dispute or finalized.
        mapping(uint256 => address[5]) minersByValue;
        mapping(uint256 => uint256[5]) valuesByTimestamp;
    }
    uint256[51] requestQ; //uint50 array of the top50 requests by payment amount
    uint256[] public newValueTimestamps; //array of all timestamps requested
    //This is a boolean that tells you if a given challenge has been completed by a given miner
    mapping(uint256 => uint256) requestIdByTimestamp; //minedTimestamp to apiId
    mapping(uint256 => uint256) requestIdByRequestQIndex; //link from payoutPoolIndex (position in payout pool array) to apiId
    mapping(uint256 => Dispute) public disputesById; //disputeId=> Dispute details
    mapping(bytes32 => uint256) public requestIdByQueryHash; // api bytes32 gets an id = to count of requests array
    mapping(bytes32 => uint256) public disputeIdByDisputeHash; //maps a hash to an ID for each dispute
    mapping(bytes32 => mapping(address => bool)) public minersByChallenge;
    Details[5] public currentMiners; //This struct is for organizing the five mined values to find the median
    mapping(address => StakeInfo) stakerDetails; //mapping from a persons address to their staking info
    mapping(uint256 => Request) requestDetails;
    mapping(bytes32 => uint256) public uints;
    mapping(bytes32 => address) public addresses;
    mapping(bytes32 => bytes32) public bytesVars;
    //ERC20 storage
    mapping(address => Checkpoint[]) public balances;
    mapping(address => mapping(address => uint256)) public _allowances;
    //Migration storage
    mapping(address => bool) public migrated;

}


// File contracts/Parachute.sol

//SPDX-License-Identifier: Unlicense
contract Parachute is TellorStorage {
  address constant tellorMaster = 0x88dF592F8eb5D7Bd38bFeF7dEb0fBc02cf3778a0;
  address constant multis = 0x39E419bA25196794B595B2a595Ea8E527ddC9856;
  bytes32 challenge;
  uint256 challengeUpdate;

  /**
   * @dev Use this function to end parachutes ability to reinstate Tellor's admin key
   */
  function killContract() external {
    require(msg.sender == multis,"only multis wallet can call this");
    ITellor(tellorMaster).changeDeity(address(0));
  }

  /**
   * @dev This function allows the Tellor Team to migrate old TRB token to the new one
   * @param _destination is the destination adress to migrate tokens to
   * @param _amount is the amount of tokens to migrate
   */
  function migrateFor(address _destination,uint256 _amount) external {
    require(msg.sender == multis,"only multis wallet can call this");
    ITellor(tellorMaster).transfer(_destination, _amount);
  }

  /**
   * @dev This function allows the Tellor community to reinstate and admin key if an attacker
   * is able to get 51% or more of the total TRB supply.
   * @param _tokenHolder address to check if they hold more than 51% of TRB
   */
  function rescue51PercentAttack(address _tokenHolder) external {
    require(
      ITellor(tellorMaster).balanceOf(_tokenHolder) * 100 / ITellor(tellorMaster).totalSupply() >= 51,
      "attacker balance is < 51% of total supply"
    );
    ITellor(tellorMaster).changeDeity(multis);
  }

  /**
   * @dev Allows the TellorTeam to reinstate the admin key if a long time(timeBeforeRescue)
   * has gone by without a value being added on-chain
   */
  function rescueBrokenDataReporting() external {
    bytes32 _newChallenge;
    (_newChallenge,,,) = ITellor(tellorMaster).getNewCurrentVariables();
    if(_newChallenge == challenge){
      if(block.timestamp - challengeUpdate > 7 days){
        ITellor(tellorMaster).changeDeity(multis);
      }
    }
    else{
      challenge = _newChallenge;
      challengeUpdate = block.timestamp;
    }
  }

  /**
   * @dev Allows the Tellor community to reinstate the admin key if tellor is updated
   * to an invalid address.
   */
  function rescueFailedUpdate() external {
    (bool success, bytes memory data) =
        address(tellorMaster).call(
            abi.encodeWithSelector(0xfc735e99, "") //verify() signature
        );
    uint _val;
    if(data.length > 0){
      _val = abi.decode(data, (uint256));
    }
    require(!success || _val < 2999,"new tellor is valid");
    ITellor(tellorMaster).changeDeity(multis);
  }
}