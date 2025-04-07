pragma solidity 0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d0b1a2b1b3b8beb9b490bebfa4b4bfa4febeb5a4">[email&#160;protected]</a>>
 *
 * @dev Functionality in this library is largely implemented using an
 *      abstraction called a &#39;slice&#39;. A slice represents a part of a string -
 *      anything from the entire string to a single character, or even no
 *      characters at all (a 0-length slice). Since a slice only has to specify
 *      an offset and a length, copying and manipulating slices is a lot less
 *      expensive than copying and manipulating the strings they reference.
 *
 *      To further reduce gas costs, most functions on slice that need to return
 *      a slice modify the original one instead of allocating a new one; for
 *      instance, `s.split(".")` will return the text up to the first &#39;.&#39;,
 *      modifying s to only contain the remainder of the string after the &#39;.&#39;.
 *      In situations where you do not want to modify the original slice, you
 *      can make a copy first with `.copy()`, for example:
 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since
 *      Solidity has no memory management, it will result in allocating many
 *      short-lived slices that are later discarded.
 *
 *      Functions that return two slices come in two versions: a non-allocating
 *      version that takes the second slice as an argument, modifying it in
 *      place, and an allocating version that allocates and returns the second
 *      slice; see `nextRune` for example.
 *
 *      Functions that have to copy string data will return strings rather than
 *      slices; these can be cast back to slices for further processing if
 *      required.
 *
 *      For convenience, some functions are provided with non-modifying
 *      variants that create a new slice and return both; for instance,
 *      `s.splitNew(&#39;.&#39;)` leaves s unmodified, and returns two values
 *      corresponding to the left and right parts of the string.
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 *      See RBAC.sol for example usage.
 */


/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 *      Supports unlimited numbers of roles and addresses.
 *      See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 *  for you to write your own implementation of this interface using Enums or similar.
 * It&#39;s also recommended that you define constants in the contract, like ROLE_ADMIN below,
 *  to avoid typos.
 */
contract RBAC is Ownable {
    using Roles for Roles.Role;

    mapping (string => Roles.Role) private roles;

    event RoleAdded(address addr, string roleName);
    event RoleRemoved(address addr, string roleName);

    /**
    * @dev constructor. Sets msg.sender as admin by default
    */
    function RBAC() public {
    }

    /**
    * @dev reverts if addr does not have role
    * @param addr address
    * @param roleName the name of the role
    * // reverts
    */
    function checkRole(address addr, string roleName) view public {
        roles[roleName].check(addr);
    }

    /**
    * @dev determine if addr has role
    * @param addr address
    * @param roleName the name of the role
    * @return bool
    */
    function hasRole(address addr, string roleName) view public returns (bool) {
        return roles[roleName].has(addr);
    }

    /**
    * @dev add a role to an address
    * @param addr address
    * @param roleName the name of the role
    */
    function adminAddRole(address addr, string roleName) onlyOwner public {
        roles[roleName].add(addr);
        RoleAdded(addr, roleName);
    }

    /**
    * @dev remove a role from an address
    * @param addr address
    * @param roleName the name of the role
    */
    function adminRemoveRole(address addr, string roleName) onlyOwner public {
        roles[roleName].remove(addr);
        RoleRemoved(addr, roleName);
    }

    /**
    * @dev modifier to scope access to a single role (uses msg.sender as addr)
    * @param roleName the name of the role
    * // reverts
    */
    modifier onlyRole(string roleName) {
        checkRole(msg.sender, roleName);
        _;
    }

    modifier onlyOwnerOr(string roleName) {
        require(msg.sender == owner || roles[roleName].has(msg.sender));
        _;
    }    
}

/**
 * @title Heritable
 * @dev The Heritable contract provides ownership transfer capabilities, in the
 * case that the current owner stops "heartbeating". Only the heir can pronounce the
 * owner&#39;s death.
 */
contract Heritable is RBAC {
  address private heir_;

  // Time window the owner has to notify they are alive.
  uint256 private heartbeatTimeout_;

  // Timestamp of the owner&#39;s death, as pronounced by the heir.
  uint256 private timeOfDeath_;

  event HeirChanged(address indexed owner, address indexed newHeir);
  event OwnerHeartbeated(address indexed owner);
  event OwnerProclaimedDead(address indexed owner, address indexed heir, uint256 timeOfDeath);
  event HeirOwnershipClaimed(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev Throw an exception if called by any account other than the heir&#39;s.
   */
  modifier onlyHeir() {
    require(msg.sender == heir_);
    _;
  }


  /**
   * @notice Create a new Heritable Contract with heir address 0x0.
   * @param _heartbeatTimeout time available for the owner to notify they are alive,
   * before the heir can take ownership.
   */
  function Heritable(uint256 _heartbeatTimeout) public {
    setHeartbeatTimeout(_heartbeatTimeout);
  }

  function setHeir(address newHeir) public onlyOwner {
    require(newHeir != owner);
    heartbeat();
    HeirChanged(owner, newHeir);
    heir_ = newHeir;
  }

  /**
   * @dev Use these getter functions to access the internal variables in
   * an inherited contract.
   */
  function heir() public view returns(address) {
    return heir_;
  }

  function heartbeatTimeout() public view returns(uint256) {
    return heartbeatTimeout_;
  }
  
  function timeOfDeath() public view returns(uint256) {
    return timeOfDeath_;
  }

  /**
   * @dev set heir = 0x0
   */
  function removeHeir() public onlyOwner {
    heartbeat();
    heir_ = 0;
  }

  /**
   * @dev Heir can pronounce the owners death. To claim the ownership, they will
   * have to wait for `heartbeatTimeout` seconds.
   */
  function proclaimDeath() public onlyHeir {
    require(ownerLives());
    OwnerProclaimedDead(owner, heir_, timeOfDeath_);
    timeOfDeath_ = block.timestamp;
  }

  /**
   * @dev Owner can send a heartbeat if they were mistakenly pronounced dead.
   */
  function heartbeat() public onlyOwner {
    OwnerHeartbeated(owner);
    timeOfDeath_ = 0;
  }

  /**
   * @dev Allows heir to transfer ownership only if heartbeat has timed out.
   */
  function claimHeirOwnership() public onlyHeir {
    require(!ownerLives());
    require(block.timestamp >= timeOfDeath_ + heartbeatTimeout_);
    OwnershipTransferred(owner, heir_);
    HeirOwnershipClaimed(owner, heir_);
    owner = heir_;
    timeOfDeath_ = 0;
  }

  function setHeartbeatTimeout(uint256 newHeartbeatTimeout) internal onlyOwner {
    require(ownerLives());
    heartbeatTimeout_ = newHeartbeatTimeout;
  }

  function ownerLives() internal view returns (bool) {
    return timeOfDeath_ == 0;
  }
}

contract BettingBase {
    enum BetStatus {
        None,
        Won
    }

    enum LineStages {
        OpenedUntilStart,
        ResultSubmitted,
        Cancelled,
        Refunded,
        Paid
    }    

    enum LineType {
        ThreeWay,
        TwoWay,
        DoubleChance,
        SomeOfMany
    }

    enum TwoWayLineType {
        Standart,
        YesNo,
        OverUnder,
        AsianHandicap,
        HeadToHead
    }

    enum PaymentType {
        No,
        Gain, 
        Refund
    }
}

contract AbstractBetStorage is BettingBase {
    function addBet(uint lineId, uint betId, address player, uint amount) external;
    function addLine(uint lineId, LineType lineType, uint start, uint resultCount) external;
    function cancelLine(uint lineId) external;
    function getBetPool(uint lineId, uint betId) external view returns (BetStatus status, uint sum);
    function getLineData(uint lineId) external view returns (uint startTime, uint resultCount, LineType lineType, LineStages stage);
    function getLineData2(uint lineId) external view returns (uint resultCount, LineStages stage);
    function getLineSum(uint lineId) external view returns (uint sum);
    function getPlayerBet(uint lineId, uint betId, address player) external view returns (uint result);
    function getSumOfPlayerBetsById(uint lineId, uint playerId, PaymentType paymentType) external view returns (address player, uint amount);
    function isBetStorage() external pure returns (bool);
    function setLineStartTime(uint lineId, uint time) external;    
    function startPayments(uint lineId, uint chunkSize) external returns (PaymentType paymentType, uint startId, uint endId, uint luckyPool, uint unluckyPool);
    function submitResult(uint lineId, uint[] results) external;
    function transferOwnership(address newOwner) public;
    function tryCloseLine(uint lineId, uint lastPlayerId, PaymentType paymentType) external returns (bool lineClosed);
}

contract BettingCore is BettingBase, Heritable {
    using SafeMath for uint;
    using strings for *;

    enum ActivityType{
        Soccer,
        IceHockey,
        Basketball,
        Tennis,
        BoxingAndMMA, 
        Formula1,               
        Volleyball,
        Chess,
        Athletics,
        Biathlon,
        Baseball,
        Rugby,
        AmericanFootball,
        Cycling,
        AutoMotorSports,        
        Other
    }    
    
    struct Activity {
        string title;
        ActivityType activityType;
    }

    struct Event {
        uint activityId;
        string title;
    }    

    struct Line {
        uint eventId;
        string title;
        string outcomes;
    }

    struct FeeDiscount {
        uint64 till;
        uint8 discount;
    }    

    // it&#39;s not possible to take off players bets
    bool public payoutToOwnerIsLimited;
    // total sum of bets
    uint public blockedSum; 
    uint public fee;
    uint public minBetAmount;
    string public contractMessage;
   
    Activity[] public activities;
    Event[] public events;
    Line[] private lines;

    mapping(address => FeeDiscount) private discounts;

    event NewActivity(uint indexed activityId, ActivityType activityType, string title);
    event NewEvent(uint indexed activityId, uint indexed eventId, string title);
    event NewLine(uint indexed eventId, uint indexed lineId, string title, LineType lineType, uint start, string outcomes);     
    event BetMade(uint indexed lineId, uint betId, address indexed player, uint amount);
    event PlayerPaid(uint indexed lineId, address indexed player, uint amount);
    event ResultSubmitted(uint indexed lineId, uint[] results);
    event LineCanceled(uint indexed lineId, string comment);
    event LineClosed(uint indexed lineId, PaymentType paymentType, uint totalPool);
    event LineStartTimeChanged(uint indexed lineId, uint newTime);

    AbstractBetStorage private betStorage;

    function BettingCore() Heritable(2592000) public {
        minBetAmount = 5 finney; // 0.005 ETH
        fee = 200; // 2 %
        payoutToOwnerIsLimited = true;
        blockedSum = 1 wei;
        contractMessage = "betdapp.co";
    }

    function() external onlyOwner payable {
    }

    function addActivity(ActivityType activityType, string title) external onlyOwnerOr("Edit") returns (uint activityId) {
        Activity memory _activity = Activity({
            title: title, 
            activityType: activityType
        });

        activityId = activities.push(_activity) - 1;
        NewActivity(activityId, activityType, title);
    }

    function addDoubleChanceLine(uint eventId, string title, uint start) external onlyOwnerOr("Edit") {
        addLine(eventId, title, LineType.DoubleChance, start, "1X_12_X2");
    }

    function addEvent(uint activityId, string title) external onlyOwnerOr("Edit") returns (uint eventId) {
        Event memory _event = Event({
            activityId: activityId, 
            title: title
        });

        eventId = events.push(_event) - 1;
        NewEvent(activityId, eventId, title);      
    }

    function addThreeWayLine(uint eventId, string title, uint start) external onlyOwnerOr("Edit") {
        addLine(eventId, title, LineType.ThreeWay, start,  "1_X_2");
    }

    function addSomeOfManyLine(uint eventId, string title, uint start, string outcomes) external onlyOwnerOr("Edit") {
        addLine(eventId, title, LineType.SomeOfMany, start, outcomes);
    }

    function addTwoWayLine(uint eventId, string title, uint start, TwoWayLineType customType) external onlyOwnerOr("Edit") {
        string memory outcomes;

        if (customType == TwoWayLineType.YesNo) {
            outcomes = "Yes_No";
        } else if (customType == TwoWayLineType.OverUnder) {
            outcomes = "Over_Under";
        } else {
            outcomes = "1_2";
        }
        
        addLine(eventId, title, LineType.TwoWay, start, outcomes);
    }

    function bet(uint lineId, uint betId) external payable {
        uint amount = msg.value;
        require(amount >= minBetAmount);
        address player = msg.sender;
        betStorage.addBet(lineId, betId, player, amount);
        blockedSum = blockedSum.add(amount);
        BetMade(lineId, betId, player, amount);
    }

    function cancelLine(uint lineId, string comment) external onlyOwnerOr("Submit") {
        betStorage.cancelLine(lineId);
        LineCanceled(lineId, comment);
    }   

    function getMyBets(uint lineId) external view returns (uint[] result) {
        return getPlayerBets(lineId, msg.sender);
    }

    function getMyDiscount() external view returns (uint discount, uint till) {
        (discount, till) = getPlayerDiscount(msg.sender);
    }

    function getLineData(uint lineId) external view returns (uint eventId, string title, string outcomes, uint startTime, uint resultCount, LineType lineType, LineStages stage, BetStatus[] status, uint[] pool) {
        (startTime, resultCount, lineType, stage) = betStorage.getLineData(lineId);

        Line storage line = lines[lineId];
        eventId = line.eventId;
        title = line.title;
        outcomes = line.outcomes;
        status = new BetStatus[](resultCount);
        pool = new uint[](resultCount);

        for (uint i = 0; i < resultCount; i++) {
            (status[i], pool[i]) = betStorage.getBetPool(lineId, i);
        }
    }

    function getLineStat(uint lineId) external view returns (LineStages stage, BetStatus[] status, uint[] pool) {       
        uint resultCount;
        (resultCount, stage) = betStorage.getLineData2(lineId);
        status = new BetStatus[](resultCount);
        pool = new uint[](resultCount);

        for (uint i = 0; i < resultCount; i++) {
            (status[i], pool[i]) = betStorage.getBetPool(lineId, i);
        }
    }

    // emergency
    function kill() external onlyOwner {
        selfdestruct(msg.sender);
    }

    function payout(uint sum) external onlyOwner {
        require(sum > 0);
        require(!payoutToOwnerIsLimited || (this.balance - blockedSum) >= sum);
        msg.sender.transfer(sum);
    }    

    function payPlayers(uint lineId, uint chunkSize) external onlyOwnerOr("Pay") {
        uint startId;
        uint endId;
        PaymentType paymentType;
        uint luckyPool;
        uint unluckyPool;

        (paymentType, startId, endId, luckyPool, unluckyPool) = betStorage.startPayments(lineId, chunkSize);

        for (uint i = startId; i < endId; i++) {
            address player;
            uint amount; 
            (player, amount) = betStorage.getSumOfPlayerBetsById(lineId, i, paymentType);

            if (amount == 0) {
                continue;
            }

            uint payment;            
            
            if (paymentType == PaymentType.Gain) {
                payment = amount.add(amount.mul(unluckyPool).div(luckyPool)).div(10000).mul(10000 - getFee(player));

                if (payment < amount) {
                    payment = amount;
                }
            } else {
                payment = amount;               
            }

            if (payment > 0) {
                player.transfer(payment);
                PlayerPaid(lineId, player, payment);
            }
        }

        if (betStorage.tryCloseLine(lineId, endId, paymentType)) {
            uint totalPool = betStorage.getLineSum(lineId);
            blockedSum = blockedSum.sub(totalPool);
            LineClosed(lineId, paymentType, totalPool);
        }
    }
    
    function setContractMessage(string value) external onlyOwner {
        contractMessage = value;
    }    

    function setDiscountForPlayer(address player, uint discount, uint till) external onlyOwner {
        require(till > now && discount > 0 && discount <= 100);
        discounts[player].till = uint64(till);
        discounts[player].discount = uint8(discount);
    }

    function setFee(uint value) external onlyOwner {
        // 100 = 1% fee;
        require(value >= 0 && value <= 500);
        fee = value;
    }

    function setLineStartTime(uint lineId, uint time) external onlyOwnerOr("Edit") {
        betStorage.setLineStartTime(lineId, time);
        LineStartTimeChanged(lineId, time);
    }    

    function setMinBetAmount(uint value) external onlyOwner {
        require(value > 0);
        minBetAmount = value;
    }

    // if something goes wrong with contract, we can turn on this function
    // and then withdraw balance and pay players by hand without need to kill contract
    function setPayoutLimit(bool value) external onlyOwner {
        payoutToOwnerIsLimited = value;
    }

    function setStorage(address contractAddress) external onlyOwner {        
        AbstractBetStorage candidateContract = AbstractBetStorage(contractAddress);
        require(candidateContract.isBetStorage());
        betStorage = candidateContract;
        // betStorage.transferOwnership(address(this));
    }

    function setStorageOwner(address newOwner) external onlyOwner {
        betStorage.transferOwnership(newOwner);
    }    

    function submitResult(uint lineId, uint[] results) external onlyOwnerOr("Submit") {
        betStorage.submitResult(lineId, results);
        ResultSubmitted(lineId, results);
    }    

    function addLine(uint eventId, string title, LineType lineType, uint start, string outcomes) private {
        require(start > now);

        Line memory line = Line({
            eventId: eventId, 
            title: title, 
            outcomes: outcomes
        });

        uint lineId = lines.push(line) - 1;
        uint resultCount;

        if (lineType == LineType.ThreeWay || lineType == LineType.DoubleChance) {
            resultCount = 3;           
        } else if (lineType == LineType.TwoWay) {
            resultCount = 2; 
        } else {
            resultCount = getSplitCount(outcomes);
        }       

        betStorage.addLine(lineId, lineType, start, resultCount);
        NewLine(eventId, lineId, title, lineType, start, outcomes);
    }

    function getFee(address player) private view returns (uint newFee) {
        var data = discounts[player];

        if (data.till > now) {
            return fee * (100 - data.discount) / 100;
        }

        return fee;
    }    

    function getPlayerBets(uint lineId, address player) private view returns (uint[] result) {
        Line storage line = lines[lineId];
        uint count = getSplitCount(line.outcomes);
        result = new uint[](count);

        for (uint i = 0; i < count; i++) {
            result[i] = betStorage.getPlayerBet(lineId, i, player);
        }
    }

    function getPlayerDiscount(address player) private view returns (uint discount, uint till) {
        FeeDiscount storage discountFee = discounts[player];
        discount = discountFee.discount;
        till = discountFee.till;
    }    

    function getSplitCount(string input) private returns (uint) { 
        var s = input.toSlice();
        var delim = "_".toSlice();
        var parts = new string[](s.count(delim) + 1);

        for (uint i = 0; i < parts.length; i++) {
            parts[i] = s.split(delim).toString();
        }

        return parts.length;
    }
}