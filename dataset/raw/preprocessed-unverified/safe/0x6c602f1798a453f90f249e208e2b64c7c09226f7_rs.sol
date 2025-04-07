/**

 *Submitted for verification at Etherscan.io on 2018-12-10

*/



pragma solidity ^0.4.24;



// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: node_modules/openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol



/**

 * @title Helps contracts guard against reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>

 * @dev If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {



  /// @dev counter to allow mutex lock with only one SSTORE operation

  uint256 private _guardCounter;



  constructor() internal {

    // The counter starts at one to prevent changing it from zero to a non-zero

    // value, which is a more expensive operation.

    _guardCounter = 1;

  }



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * Calling a `nonReentrant` function from another `nonReentrant`

   * function is not supported. It is possible to prevent this from happening

   * by making the `nonReentrant` function external, and make it call a

   * `private` function that does the actual work.

   */

  modifier nonReentrant() {

    _guardCounter += 1;

    uint256 localCounter = _guardCounter;

    _;

    require(localCounter == _guardCounter);

  }



}



// File: node_modules/openzeppelin-solidity/contracts/math/Safemath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





// File: lib/CanReclaimToken.sol



/**

 * @title Contracts that should be able to recover tokens

 * @author SylTi

 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.

 * This will prevent any accidental loss of tokens.

 */

contract CanReclaimToken is Ownable {



  /**

   * @dev Reclaim all ERC20 compatible tokens

   * @param token ERC20 The address of the token contract

   */

  function reclaimToken(IERC20 token) external onlyOwner {

    if (address(token) == address(0)) {

      owner().transfer(address(this).balance);

      return;

    }

    uint256 balance = token.balanceOf(this);

    token.transfer(owner(), balance);

  }



}



// File: contracts/Mentoring.sol









contract Mentoring is Ownable, ReentrancyGuard, CanReclaimToken  {

  using SafeMath for uint256;



  event BecomeMentor(uint256 indexed mentorId);

  event BreakMentoring(uint256 indexed mentorId);

  event ChangeLevelPrice(uint256 indexed mentorId, uint256 newLevelPrice);

  event Income(address source, uint256 amount);



  event StartLecture(uint256 indexed lectureId,

    uint256 indexed mentorId,

    uint256 indexed studentId,

    uint256 mentorLevel,

    uint256 studentLevel,

    uint256 levelUp,

    uint256 levelPrice,

    uint256 startedAt,

    uint256 endsAt);



//  event Withdraw(address to, uint256 amount);



  struct Lecture {

    uint256 mentorId;

    uint256 studentId;

    uint256 mentorLevel;

    uint256 studentLevel;

    uint256 levelUp;

    uint256 levelPrice;

//    uint256 cost;

    uint256 startedAt;

    uint256 endsAt;

  }



  HEROES public heroes;



  uint256 public fee = 290; //2.9%

  uint256 public levelUpTime = 20 minutes;



  mapping(uint256 => uint256) internal prices;



  Lecture[] internal lectures;

  /* tokenId => lecture index */

  mapping(uint256 => uint256[]) studentToLecture;

  mapping(uint256 => uint256[]) mentorToLecture;



  modifier onlyOwnerOf(uint256 _tokenId) {

    require(heroes.ownerOf(_tokenId) == msg.sender);

    _;

  }



  constructor (HEROES _heroes) public {

    require(address(_heroes) != address(0));

    heroes = _heroes;



    //fix lectureId issue - add zero lecture

    lectures.length = 1;

  }



  /// @notice The fallback function payable

  function() external payable {

    require(msg.value > 0);

    _flushBalance();

  }



  function _flushBalance() private {

    uint256 balance = address(this).balance;

    if (balance > 0) {

      address(heroes).transfer(balance);

      emit Income(address(this), balance);

    }

  }





  function _distributePayment(address _account, uint256 _amount) internal {

    uint256 pcnt = _getPercent(_amount, fee);

    uint256 amount = _amount.sub(pcnt);

    _account.transfer(amount);

  }



  /**

   * Set fee

   */

  function setFee(uint256 _fee) external onlyOwner

  {

    fee = _fee;

  }



  // MENTORING



  /**

   * Set the one level up time

   */



  function setLevelUpTime(uint256 _newLevelUpTime) external onlyOwner

  {

    levelUpTime = _newLevelUpTime;

  }



  function isMentor(uint256 _mentorId) public view returns (bool)

  {

    //проверяем установлена ли цена обучения и текущий агент пресонажа =менторство

    return heroes.isCallerAgentOf(_mentorId); // && prices[_mentorId] != 0;

  }



  function inStudying(uint256 _tokenId) public view returns (bool) {

    return now <= lectures[getLastLectureIdAsStudent(_tokenId)].endsAt;

  }



  function inMentoring(uint256 _tokenId) public view returns (bool) {

    return now <= lectures[getLastLectureIdAsMentor(_tokenId)].endsAt;

  }



  function inLecture(uint256 _tokenId) public view returns (bool)

  {

    return inMentoring(_tokenId) || inStudying(_tokenId);

  }



  /**

   * Set the character as mentor

   */

  function becomeMentor(uint256 _mentorId, uint256 _levelPrice) external onlyOwnerOf(_mentorId) {

    require(_levelPrice > 0);

    require(heroes.lock(_mentorId, 0, false));

    prices[_mentorId] = _levelPrice;

    emit BecomeMentor(_mentorId);

    emit ChangeLevelPrice(_mentorId, _levelPrice);

  }



  /**

   * Change price

   */

  function changeLevelPrice(uint256 _mentorId, uint256 _levelPrice) external onlyOwnerOf(_mentorId) {

    require(_levelPrice > 0);

    require(isMentor(_mentorId));

    prices[_mentorId] = _levelPrice;

    emit ChangeLevelPrice(_mentorId, _levelPrice);

  }



  /**

   * Break mentoring for character

   */

  function breakMentoring(uint256 _mentorId) external onlyOwnerOf(_mentorId)

  {

    require(heroes.unlock(_mentorId));

    emit BreakMentoring(_mentorId);

  }



  function getMentor(uint256 _mentorId) external view returns (uint256 level, uint256 price) {

    require(isMentor(_mentorId));

    return (heroes.getLevel(_mentorId), prices[_mentorId]);

  }



  function _calcLevelIncrease(uint256 _mentorLevel, uint256 _studentLevel) internal pure returns (uint256) {

    if (_mentorLevel < _studentLevel) {

      return 0;

    }

    uint256 levelDiff = _mentorLevel - _studentLevel;

    return (levelDiff >> 1) + (levelDiff & 1);

  }



  /**

   * calc full cost of study

   */

  function calcCost(uint256 _mentorId, uint256 _studentId) external view returns (uint256) {

    uint256 levelUp = _calcLevelIncrease(heroes.getLevel(_mentorId), heroes.getLevel(_studentId));

    return levelUp.mul(prices[_mentorId]);

  }



  function isRaceSuitable(uint256 _mentorId, uint256 _studentId) public view returns (bool) {

    uint256 mentorRace = heroes.getGenes(_mentorId) & 0xFFFF;

    uint256 studentRace = heroes.getGenes(_studentId) & 0xFFFF;

    return (mentorRace == 1 || mentorRace == studentRace);

  }



  /**

   * Start the study

   */

  function startLecture(uint256 _mentorId, uint256 _studentId) external payable onlyOwnerOf(_studentId) {

    require(isMentor(_mentorId));



    // Check race

    require(isRaceSuitable(_mentorId, _studentId));



    uint256 mentorLevel = heroes.getLevel(_mentorId);

    uint256 studentLevel = heroes.getLevel(_studentId);



    uint256 levelUp = _calcLevelIncrease(mentorLevel, studentLevel);

    require(levelUp > 0);



    // check sum is enough

    uint256 cost = levelUp.mul(prices[_mentorId]);

    require(cost == msg.value);



    Lecture memory lecture = Lecture({

      mentorId : _mentorId,

      studentId : _studentId,

      mentorLevel: mentorLevel,

      studentLevel: studentLevel,

      levelUp: levelUp,

      levelPrice : prices[_mentorId],

      startedAt : now,

      endsAt : now + levelUp.mul(levelUpTime)

      });



    //locking mentor

    require(heroes.lock(_mentorId, lecture.endsAt, true));



    //locking student

    require(heroes.lock(_studentId, lecture.endsAt, true));





    //save lecture

    //id starts from 1

    uint256 lectureId = lectures.push(lecture) - 1;



    studentToLecture[_studentId].push(lectureId);

    mentorToLecture[_mentorId].push(lectureId);



    heroes.addWin(_studentId, 0, levelUp);



    emit StartLecture(

      lectureId,

      _mentorId,

      _studentId,

      lecture.mentorLevel,

      lecture.studentLevel,

      lecture.levelUp,

      lecture.levelPrice,

      lecture.startedAt,

      lecture.endsAt

    );



    _distributePayment(heroes.ownerOf(_mentorId), cost);



    _flushBalance();

  }



  function lectureExists(uint256 _lectureId) public view returns (bool)

  {

    return (_lectureId > 0 && _lectureId < lectures.length);

  }



  function getLecture(uint256 lectureId) external view returns (

    uint256 mentorId,

    uint256 studentId,

    uint256 mentorLevel,

    uint256 studentLevel,

    uint256 levelUp,

    uint256 levelPrice,

    uint256 cost,

    uint256 startedAt,

    uint256 endsAt)

  {

    require(lectureExists(lectureId));

    Lecture memory l = lectures[lectureId];

    return (l.mentorId, l.studentId, l.mentorLevel, l.studentLevel, l.levelUp, l.levelPrice, l.levelUp.mul(l.levelPrice), l.startedAt, l.endsAt);

  }



  function getLastLectureIdAsMentor(uint256 _tokenId) public view returns (uint256) {

    return mentorToLecture[_tokenId].length > 0 ? mentorToLecture[_tokenId][mentorToLecture[_tokenId].length - 1] : 0;

  }

  function getLastLectureIdAsStudent(uint256 _tokenId) public view returns (uint256) {

    return studentToLecture[_tokenId].length > 0 ? studentToLecture[_tokenId][studentToLecture[_tokenId].length - 1] : 0;

  }

 



  function getLastLecture(uint256 tokenId) external view returns (

    uint256 lectureId,

    uint256 mentorId,

    uint256 studentId,

    uint256 mentorLevel,

    uint256 studentLevel,

    uint256 levelUp,

    uint256 levelPrice,

    uint256 cost,

    uint256 startedAt,

    uint256 endsAt)

  {

    uint256 mentorLectureId = getLastLectureIdAsMentor(tokenId);

    uint256 studentLectureId = getLastLectureIdAsStudent(tokenId);

    lectureId = studentLectureId > mentorLectureId ? studentLectureId : mentorLectureId;

    require(lectureExists(lectureId));

    Lecture storage l = lectures[lectureId];

    return (lectureId, l.mentorId, l.studentId, l.mentorLevel, l.studentLevel, l.levelUp, l.levelPrice, l.levelUp.mul(l.levelPrice), l.startedAt, l.endsAt);

  }



  //// SERVICE

  //1% - 100, 10% - 1000 50% - 5000

  function _getPercent(uint256 _v, uint256 _p) internal pure returns (uint)    {

    return _v.mul(_p).div(10000);

  }

}