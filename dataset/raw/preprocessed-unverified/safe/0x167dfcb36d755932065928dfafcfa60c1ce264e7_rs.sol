/**

 *Submitted for verification at Etherscan.io on 2019-01-28

*/



pragma solidity ^0.4.24;



// File: node_modules/openzeppelin-solidity/contracts/access/Roles.sol



/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */





// File: node_modules/openzeppelin-solidity/contracts/access/roles/PauserRole.sol



contract PauserRole {

  using Roles for Roles.Role;



  event PauserAdded(address indexed account);

  event PauserRemoved(address indexed account);



  Roles.Role private pausers;



  constructor() internal {

    _addPauser(msg.sender);

  }



  modifier onlyPauser() {

    require(isPauser(msg.sender));

    _;

  }



  function isPauser(address account) public view returns (bool) {

    return pausers.has(account);

  }



  function addPauser(address account) public onlyPauser {

    _addPauser(account);

  }



  function renouncePauser() public {

    _removePauser(msg.sender);

  }



  function _addPauser(address account) internal {

    pausers.add(account);

    emit PauserAdded(account);

  }



  function _removePauser(address account) internal {

    pausers.remove(account);

    emit PauserRemoved(account);

  }

}



// File: node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is PauserRole {

  event Paused(address account);

  event Unpaused(address account);



  bool private _paused;



  constructor() internal {

    _paused = false;

  }



  /**

   * @return true if the contract is paused, false otherwise.

   */

  function paused() public view returns(bool) {

    return _paused;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!_paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(_paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() public onlyPauser whenNotPaused {

    _paused = true;

    emit Paused(msg.sender);

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyPauser whenPaused {

    _paused = false;

    emit Unpaused(msg.sender);

  }

}



// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/IGrowHops.sol







// File: contracts/SafeMath.sol



/**

 * @title SafeMath

 */





// File: contracts/GrowHops.sol







contract GrowHops is IGrowHops, Ownable, Pausable {



  using SafeMath for *;



  address public hopsAddress;

  address public lessAddress;



  struct PlanBase {

    uint256 minimumAmount;

    uint256 lockTime;

    uint32 lessToHops;

    bool isOpen;

  }



  struct Plan {

    bytes32 planBaseId;

    address plantuser;

    uint256 lessAmount;

    uint256 hopsAmount;

    uint256 lockAt;

    uint256 releaseAt;

    bool isWithdrawn;

  }

  bytes32[] public planBaseIds;



  mapping (bytes32 => bytes32[]) planIdsByPlanBase;

  mapping (bytes32 => PlanBase) planBaseIdToPlanBase;

  

  mapping (bytes32 => Plan) planIdToPlan;

  mapping (address => bytes32[]) userToPlanIds;



  constructor (address _hopsAddress, address _lessAddress) public {

    hopsAddress = _hopsAddress;

    lessAddress = _lessAddress;

  }



  function addPlanBase(uint256 minimumAmount, uint256 lockTime, uint32 lessToHops)

    onlyOwner external {

    bytes32 planBaseId = keccak256(

      abi.encodePacked(block.timestamp, minimumAmount, lockTime, lessToHops)

    );



    PlanBase memory planBase = PlanBase(

      minimumAmount,

      lockTime,

      lessToHops,

      true

    );



    planBaseIdToPlanBase[planBaseId] = planBase;

    planBaseIds.push(planBaseId);

    emit PlanBaseEvt(planBaseId, minimumAmount, lockTime, lessToHops, true);

  }



  function togglePlanBase(bytes32 planBaseId, bool isOpen) onlyOwner external {



    planBaseIdToPlanBase[planBaseId].isOpen = isOpen;

    emit TogglePlanBaseEvt(planBaseId, isOpen);

  }

  

  function growHops(bytes32 planBaseId, uint256 lessAmount) whenNotPaused external {

    address sender = msg.sender;

    require(IERC20(lessAddress).allowance(sender, address(this)) >= lessAmount);



    PlanBase storage planBase = planBaseIdToPlanBase[planBaseId];

    require(planBase.isOpen);

    require(lessAmount >= planBase.minimumAmount);

    bytes32 planId = keccak256(

      abi.encodePacked(block.timestamp, sender, planBaseId, lessAmount)

    );

    uint256 hopsAmount = lessAmount.mul(planBase.lessToHops);



    Plan memory plan = Plan(

      planBaseId,

      sender,

      lessAmount,

      hopsAmount,

      block.timestamp,

      block.timestamp.add(planBase.lockTime),

      false

    );

    

    require(IERC20(lessAddress).transferFrom(sender, address(this), lessAmount));

    require(IERC20(hopsAddress).mint(sender, hopsAmount));



    planIdToPlan[planId] = plan;

    userToPlanIds[sender].push(planId);

    planIdsByPlanBase[planBaseId].push(planId);

    emit PlanEvt(planId, planBaseId, sender, lessAmount, hopsAmount, block.timestamp, block.timestamp.add(planBase.lockTime), false);

  }



  function updateHopsAddress(address _address) external onlyOwner {

    hopsAddress = _address;

  }



  function updatelessAddress(address _address) external onlyOwner {

    lessAddress = _address;

  }



  function withdraw(bytes32 planId) whenNotPaused external {

    address sender = msg.sender;

    Plan storage plan = planIdToPlan[planId];

    require(!plan.isWithdrawn);

    require(plan.plantuser == sender);

    require(block.timestamp >= plan.releaseAt);

    require(IERC20(lessAddress).transfer(sender, plan.lessAmount));



    planIdToPlan[planId].isWithdrawn = true;

    emit WithdrawPlanEvt(planId, sender, plan.lessAmount, true, block.timestamp);

  }



  function checkPlanBase(bytes32 planBaseId)

    external view returns (uint256, uint256, uint32, bool){

    PlanBase storage planBase = planBaseIdToPlanBase[planBaseId];

    return (

      planBase.minimumAmount,

      planBase.lockTime,

      planBase.lessToHops,

      planBase.isOpen

    );

  }



  function checkPlanBaseIds() external view returns(bytes32[]) {

    return planBaseIds;

  }



  function checkPlanIdsByPlanBase(bytes32 planBaseId) external view returns(bytes32[]) {

    return planIdsByPlanBase[planBaseId];

  }



  function checkPlanIdsByUser(address user) external view returns(bytes32[]) {

    return userToPlanIds[user];

  }



  function checkPlan(bytes32 planId)

    external view returns (bytes32, address, uint256, uint256, uint256, uint256, bool) {

    Plan storage plan = planIdToPlan[planId];

    return (

      plan.planBaseId,

      plan.plantuser,

      plan.lessAmount,

      plan.hopsAmount,

      plan.lockAt,

      plan.releaseAt,

      plan.isWithdrawn

    );

  }

}