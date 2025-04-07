pragma solidity ^0.4.23;

// File: contracts/interfaces/ContractManagerInterface.sol

/**
 * @title Contract Manager Interface
 * @author Bram Hoven
 * @notice Interface for communicating with the contract manager
 */


// File: contracts/interfaces/MemberManagerInterface.sol

/**
 * @title Member Manager Interface
 * @author Bram Hoven
 */


// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


// File: contracts/MemberManager.sol

/**
 * @title Member Manager
 * @author Bram Hoven
 * @notice Stores a list of member which can be used for something like authorization
 */
contract MemberManager is MemberManagerInterface {
  using SafeMath for uint256;
  
  // Map containing every member
  mapping(address => bool) public members;
  // Map containing amount of tokens bought
  mapping(address => uint256) public bought;
  // List containing all members
  address[] public memberKeys;

  // Name of this contract
  string public contractName;
  // Contract Manager
  ContractManagerInterface internal contractManager;

  /**
   * @notice Triggered when member is added
   * @param member Address of newly added member
   */
  event MemberAdded(address indexed member);

  /**
   * @notice Triggered when member is removed
   * @param member Address of removed member
   */
  event MemberRemoved(address indexed member);

  /**
   * @notice Triggered when member has bought tokens
   * @param member Address of member
   * @param tokensBought Amount of tokens bought
   * @param tokens Amount of total tokens bought by member
   */
  event TokensBought(address indexed member, uint256 tokensBought, uint256 tokens);

  /**
   * @notice Constructor for creating member manager
   * @param _contractName Name of this contract for lookup in contract manager
   * @param _contractManager Address where the contract manager is located
   */
  constructor(string _contractName, address _contractManager) public {
    contractName = _contractName;
    contractManager = ContractManagerInterface(_contractManager);
  }

  /**
   * @notice Add a member to this contract
   * @param _member Address of the new member
   */
  function _addMember(address _member) internal {
    require(contractManager.authorize(contractName, msg.sender));

    members[_member] = true;
    memberKeys.push(_member);

    emit MemberAdded(_member);
  }

  /**
   * @notice Remove a member from this contract
   * @param _member Address of member that will be removed
   */
  function removeMember(address _member) external {
    require(contractManager.authorize(contractName, msg.sender));
    require(members[_member] == true);

    delete members[_member];

    for (uint256 i = 0; i < memberKeys.length; i++) {
      if (memberKeys[i] == _member) {
        delete memberKeys[i];
        break;
      }
    }

    emit MemberRemoved(_member);
  }

  /**
   * @notice Add to the amount this member has bought
   * @param _member Address of the corresponding member
   * @param _amountBought Amount of tokens this member has bought
   */
  function addAmountBoughtAsMember(address _member, uint256 _amountBought) external {
    require(contractManager.authorize(contractName, msg.sender));
    require(_amountBought != 0);

    if(!members[_member]) {
      _addMember(_member);
    }

    bought[_member] = bought[_member].add(_amountBought);

    emit TokensBought(_member, _amountBought, bought[_member]);
  }
}