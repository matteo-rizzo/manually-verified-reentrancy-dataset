/**
 *Submitted for verification at Etherscan.io on 2019-11-05
*/

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */


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


// Fund for Cycling Activity reward
contract Fund is
    Ownable
{
  /////////////////////////
  // Member Variable
  /*
    name:               member name or nickname
    usedKm:             when member claim, usedKm add activityKm
    activityKm:         activityKm for claim, just valid current activity
    updatedActivityID:  last km updated activityID
    isClaimed:            is current activity claimed?

    * if no claim and activity over, activityKm invalid
  */
  struct Member {
    string name;
    uint256 usedKm;
    uint256 activityKm;
    uint256 updatedActivityID;
    bool isClaimed;
  }

  mapping(address=>Member) public members;
  mapping(address=>bool) public isMember;
  // End of Member Variable
  /////////////////////////

  /////////////////////////
  // Activity Variable
  enum ActivityStatus {
    END,    // default Activity End
    START,
    CLAIM
  }

  uint256 public totalKm;
  uint256 public activityID;
  uint256 public activityTotalKm;
  ActivityStatus public activityStatus;

  mapping(uint256=>bool) private isUsedActivityID;
  // End of Activity Variable
  /////////////////////////

  /////////////////////////
  // Reward Variable
  uint256 public totalReward;
  uint256 public usedReward;
  // End of Reward Variable
  /////////////////////////

  /////////////////////////
  // Events
  event RegisterMember(address member, string name);
  event DeregisterMember(address member);
  event SetName(address member, string name);
  event SetAddress(address oldAddress,  address newAddress);
  event StartActivity(uint256 id, uint256 reward);
  event AdditionalReward(uint256 id, uint256 addReward);
  event AddKm(uint256 id, address member, uint256 addKm);
  event SubKm(uint256 id, address member, uint256 subKm);
  event StartClaim();
  event Claim(uint256 id, address member, uint256 activityKm, uint256 reward);
  event EndActivity(uint256 surplus);
  // End of Events
  /////////////////////////

  /////////////////////////
  // Member Manage
  modifier onlyMember() {
    require(
      isMember[msg.sender],
      "NOT_MEMBER"
    );
    _;
  }

  function registerMembers(address[] memory _members, string[] memory _names) public onlyOwner {
    require(
      _members.length == _names.length,
      "REGISTER_LENGTH_NOT_EQUAL"
    );

    for(uint i = 0; i < _members.length; i++) {
      require(
        !isMember[_members[i]],
        "MEMBER_REGISTERED"
      );

      members[_members[i]] = Member({
        name: _names[i],
        usedKm: 0,
        activityKm: 0,
        updatedActivityID: 0,
        isClaimed: false});
      isMember[_members[i]] = true;

      emit RegisterMember(_members[i], _names[i]);
    }
  }

  function deregisterMembers(address[] memory _members) public onlyOwner {
    for(uint i = 0; i < _members.length; i++) {
      isMember[_members[i]] = false;

      emit DeregisterMember(_members[i]);
    }
  }

  function setName(string memory _name) public onlyMember {
    members[msg.sender].name = _name;

    emit SetName(msg.sender, _name);
  }

  function setAddress(address _newAddress) public onlyMember {
    require(
      !isMember[_newAddress],
      "MEMBER_REGISTERED"
    );

    members[_newAddress] = members[msg.sender];
    isMember[_newAddress] = true;
    isMember[msg.sender] = false;

    emit SetAddress(msg.sender, _newAddress);
  }
  // End of Member Manage
  /////////////////////////


  /////////////////////////
  // Organize Activity
  /* activity flow:
    start(owner) ->  update Km(owner, add or sub) -> startClaim(owner)
    -> claim(member) -> end(owner)
  */
  function startActivity(uint256 _id) public payable onlyOwner {
    require(
      activityStatus == ActivityStatus.END,
      "ACTIVITY_NOT_END"
    );

    require(
      !isUsedActivityID[_id],
      "USED_ACTIVITYID"
    );

    activityID = _id;
    activityStatus = ActivityStatus.START;

    totalReward = msg.value;

    isUsedActivityID[activityID] = true;

    emit StartActivity(activityID, totalReward);
  }

  // Send more ETH to Fund Conctact be activity reward
  function() external payable{
    require(
      activityStatus == ActivityStatus.START,
      "ACTIVITY_NOT_START"
    );

    totalReward = SafeMath.add(totalReward, msg.value);

    emit AdditionalReward(activityID, msg.value);
  }

  function addKm(address[] memory _members, uint256[] memory _kms) public onlyOwner{
    require(
      activityStatus == ActivityStatus.START,
      "ACTIVITY_NOT_START"
    );

    require(
      _members.length == _kms.length,
      "UPDATEKM_LENGTH_NOT_EQUAL"
    );

    for(uint i = 0; i < _members.length; i++) {
      require(
        isMember[_members[i]],
        "NOT_MEMBER"
      );

      if(members[_members[i]].updatedActivityID != activityID) {
        members[_members[i]].activityKm = 0;
        members[_members[i]].updatedActivityID = activityID;
        members[_members[i]].isClaimed = false;
      }

      members[_members[i]].activityKm = SafeMath.add(
        members[_members[i]].activityKm,
        _kms[i]); 

      activityTotalKm = SafeMath.add(activityTotalKm, _kms[i]);

      emit AddKm(activityID, _members[i], _kms[i]);
    }
  }

  function subKm(address[] memory _members, uint256[] memory _kms) public onlyOwner{
    require(
      activityStatus == ActivityStatus.START,
      "ACTIVITY_NOT_START"
    );

    require(
      _members.length == _kms.length,
      "UPDATEKM_LENGTH_NOT_EQUAL"
    );

    for(uint i = 0; i < _members.length; i++) {
      require(
        isMember[_members[i]],
        "NOT_MEMBER"
      );

      require(
        members[_members[i]].updatedActivityID == activityID,
        "NO_KM_UPDATE"
      );

      require(
        members[_members[i]].activityKm > _kms[i],
        "KM_MORE_THEN_ACTIVITYKM"
      );

      members[_members[i]].activityKm = SafeMath.sub(
        members[_members[i]].activityKm,
        _kms[i]);

      activityTotalKm = SafeMath.sub(activityTotalKm, _kms[i]);

      emit SubKm(activityID, _members[i], _kms[i]);
    }
  }

  function startClaim() public onlyOwner {
    require(
      activityStatus == ActivityStatus.START,
      "ACTIVITY_NOT_START"
    );

    activityStatus = ActivityStatus.CLAIM;

    emit StartClaim();
  }

  function claim() public onlyMember {
    require(
      activityStatus == ActivityStatus.CLAIM,
      "ACTIVITY_NOT_CLAIM"
    );

    require(
      members[msg.sender].updatedActivityID == activityID,
      "ACTIVITYID_NOT_EQUAL"
    );

    require(
      !members[msg.sender].isClaimed,
      "IS_CLAIMED"
    );

    members[msg.sender].isClaimed = true;
    members[msg.sender].usedKm = SafeMath.add(
      members[msg.sender].usedKm,
      members[msg.sender].activityKm
    );
    totalKm = SafeMath.add(totalKm, members[msg.sender].activityKm);

    uint256 value = SafeMath.div(
      SafeMath.mul(
        totalReward,
        members[msg.sender].activityKm),
      activityTotalKm
    );

    usedReward = SafeMath.add(usedReward, value);
    msg.sender.transfer(value);

    emit Claim(activityID, msg.sender, members[msg.sender].activityKm, value);
  }

  // endActivity whatever activity status
  function endActivity() public onlyOwner {
    activityStatus = ActivityStatus.END;

    activityID = 0;
    activityTotalKm = 0;
    totalReward = 0;
    usedReward = 0;

    uint256 value = address(this).balance;
    msg.sender.transfer(value);

    emit EndActivity(value);
  }
  // End of Organize Activity
  /////////////////////////
}