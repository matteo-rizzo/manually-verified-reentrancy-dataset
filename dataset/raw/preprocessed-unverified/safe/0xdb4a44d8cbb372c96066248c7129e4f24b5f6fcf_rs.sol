/**

 *Submitted for verification at Etherscan.io on 2019-04-17

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: openzeppelin-solidity/contracts/access/Roles.sol



/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */





// File: contracts/access/RBACManager.sol



contract RBACManager is Ownable {

  using Roles for Roles.Role;



  event ManagerAdded(address indexed account);

  event ManagerRemoved(address indexed account);



  Roles.Role private managers;



  modifier onlyOwnerOrManager() {

    require(

      msg.sender == owner() || isManager(msg.sender),

      "unauthorized"

    );

    _;

  }



  constructor() public {

    addManager(msg.sender);

  }



  function isManager(address account) public view returns (bool) {

    return managers.has(account);

  }



  function addManager(address account) public onlyOwner {

    managers.add(account);

    emit ManagerAdded(account);

  }



  function removeManager(address account) public onlyOwner {

    managers.remove(account);

    emit ManagerRemoved(account);

  }

}



// File: contracts/CharityProject.sol



contract CharityProject is RBACManager {

  using SafeMath for uint256;

  using SafeERC20 for IERC20;



  modifier canWithdraw() {

    require(

      _canWithdrawBeforeEnd || _closingTime == 0 || block.timestamp > _closingTime, // solium-disable-line security/no-block-members

      "can't withdraw");

    _;

  }



  uint256 private _feeInMillis;

  uint256 private _withdrawnTokens;

  uint256 private _withdrawnFees;

  uint256 private _maxGoal;

  uint256 private _openingTime;

  uint256 private _closingTime;

  address private _wallet;

  IERC20 private _token;

  bool private _canWithdrawBeforeEnd;



  constructor (

    uint256 feeInMillis,

    uint256 maxGoal,

    uint256 openingTime,

    uint256 closingTime,

    address wallet,

    IERC20 token,

    bool canWithdrawBeforeEnd,

    address additionalManager

  ) public {

    require(wallet != address(0), "wallet can't be zero");

    require(token != address(0), "token can't be zero");

    require(

      closingTime == 0 || closingTime >= openingTime,

      "wrong value for closingTime"

    );



    _feeInMillis = feeInMillis;

    _maxGoal = maxGoal;

    _openingTime = openingTime;

    _closingTime = closingTime;

    _wallet = wallet;

    _token = token;

    _canWithdrawBeforeEnd = canWithdrawBeforeEnd;



    if (_wallet != owner()) {

      addManager(_wallet);

    }



    // solium-disable-next-line max-len

    if (additionalManager != address(0) && additionalManager != owner() && additionalManager != _wallet) {

      addManager(additionalManager);

    }

  }



  // -----------------------------------------

  // GETTERS

  // -----------------------------------------



  function feeInMillis() public view returns(uint256) {

    return _feeInMillis;

  }



  function withdrawnTokens() public view returns(uint256) {

    return _withdrawnTokens;

  }



  function withdrawnFees() public view returns(uint256) {

    return _withdrawnFees;

  }



  function maxGoal() public view returns(uint256) {

    return _maxGoal;

  }



  function openingTime() public view returns(uint256) {

    return _openingTime;

  }



  function closingTime() public view returns(uint256) {

    return _closingTime;

  }



  function wallet() public view returns(address) {

    return _wallet;

  }



  function token() public view returns(IERC20) {

    return _token;

  }



  function canWithdrawBeforeEnd() public view returns(bool) {

    return _canWithdrawBeforeEnd;

  }



  // -----------------------------------------

  // SETTERS

  // -----------------------------------------



  function setMaxGoal(uint256 newMaxGoal) public onlyOwner {

    _maxGoal = newMaxGoal;

  }



  function setTimes(

    uint256 newOpeningTime,

    uint256 newClosingTime

  )

  public

  onlyOwner

  {

    require(

      newClosingTime == 0 || newClosingTime >= newOpeningTime,

      "wrong value for closingTime"

    );



    _openingTime = newOpeningTime;

    _closingTime = newClosingTime;

  }



  function setCanWithdrawBeforeEnd(

    bool newCanWithdrawBeforeEnd

  )

  public

  onlyOwner

  {

    _canWithdrawBeforeEnd = newCanWithdrawBeforeEnd;

  }



  // -----------------------------------------

  // CHECKS

  // -----------------------------------------



  function totalRaised() public view returns (uint256) {

    uint256 raised = _token.balanceOf(this);

    return raised.add(_withdrawnTokens).add(_withdrawnFees);

  }



  function totalFee() public view returns (uint256) {

    return totalRaised().mul(_feeInMillis).div(1000);

  }



  function hasStarted() public view returns (bool) {

    // solium-disable-next-line security/no-block-members

    return _openingTime == 0 ? true : block.timestamp > _openingTime;

  }



  function hasClosed() public view returns (bool) {

    // solium-disable-next-line security/no-block-members

    return _closingTime == 0 ? false : block.timestamp > _closingTime;

  }



  function maxGoalReached() public view returns (bool) {

    return totalRaised() >= _maxGoal;

  }



  // -----------------------------------------

  // ACTIONS

  // -----------------------------------------



  function withdrawTokens(

    address to,

    uint256 value

  )

  public

  onlyOwnerOrManager

  canWithdraw

  {

    uint256 expectedTotalWithdraw = _withdrawnTokens.add(value);

    require(

      expectedTotalWithdraw <= totalRaised().sub(totalFee()),

      "can't withdraw more than available token"

    );

    _withdrawnTokens = expectedTotalWithdraw;

    _token.safeTransfer(to, value);

  }



  function withdrawFees(

    address to,

    uint256 value

  )

  public

  onlyOwner

  canWithdraw

  {

    uint256 expectedTotalWithdraw = _withdrawnFees.add(value);

    require(

      expectedTotalWithdraw <= totalFee(),

      "can't withdraw more than available fee"

    );

    _withdrawnFees = expectedTotalWithdraw;

    _token.safeTransfer(to, value);

  }



  function recoverERC20(

    address tokenAddress,

    address receiverAddress,

    uint256 amount

  )

  public

  onlyOwnerOrManager

  {

    require(

      tokenAddress != address(_token),

      "to transfer project's funds use withdrawTokens"

    );

    IERC20(tokenAddress).safeTransfer(receiverAddress, amount);

  }

}