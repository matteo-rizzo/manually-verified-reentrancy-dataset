/**

 *Submitted for verification at Etherscan.io on 2018-10-15

*/



pragma solidity ^0.4.25;









/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */









/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract HuaLiToken is IERC20 , Owned{



  string public constant name = "HuaLiToken";

  string public constant symbol = "HHLC";

  uint8 public constant decimals = 18;



  uint256 private constant INITIAL_SUPPLY = 10000000000 * (10 ** uint256(decimals));



  using SafeMath for uint256;



  mapping (address => uint256) private _balances;



  mapping (address => mapping (address => uint256)) private _allowed;



  uint256 private _totalSupply;



  

  mapping(address => uint256) balances;

  uint256[] public releaseTimeLines=[1539748800,1545019200,1550376000,1555473600,1560744000,1566014400,1571284800,1576555200,1581912000,1587096000,1592366400,1597636800,1602907200,1608177600,1613534400,1618632000,1623902400,1629172800,1634443200,1639713600,1645070400,1650168000,1655438400,1660708800];

    

  struct Role {

    address roleAddress;

    uint256 amount;

    uint256 firstRate;

    uint256 round;

    uint256 rate;

  }

   

  mapping (address => mapping (uint256 => Role)) public mapRoles;

  mapping (address => address) private lockList;

  

  event Lock(address from, uint256 value, uint256 lockAmount , uint256 balance);

  

  constructor() public {

    _mint(msg.sender, INITIAL_SUPPLY);

  }



  /**

  * @dev Total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return _totalSupply;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param owner The address to query the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address owner) public view returns (uint256) {

    return _balances[owner];

  }



  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param owner address The address which owns the funds.

   * @param spender address The address which will spend the funds.

   * @return A uint256 specifying the amount of tokens still available for the spender.

   */

  function allowance(

    address owner,

    address spender

   )

    public

    view

    returns (uint256)

  {

    return _allowed[owner][spender];

  }



  /**

  * @dev Transfer token for a specified address

  * @param to The address to transfer to.

  * @param value The amount to be transferred.

  */

  function transfer(address to, uint256 value) public returns (bool) {

    if(_canTransfer(msg.sender,value)){ 

      _transfer(msg.sender, to, value);

      return true;

    } else {

      emit Lock(msg.sender,value,getLockAmount(msg.sender),balanceOf(msg.sender));

      return false;

    }

  }



  /**

   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

   * Beware that changing an allowance with this method brings the risk that someone may use both the old

   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

   * @param spender The address which will spend the funds.

   * @param value The amount of tokens to be spent.

   */

  function approve(address spender, uint256 value) public returns (bool) {

    require(spender != address(0));



    _allowed[msg.sender][spender] = value;

    emit Approval(msg.sender, spender, value);

    return true;

  }



  /**

   * @dev Transfer tokens from one address to another

   * @param from address The address which you want to send tokens from

   * @param to address The address which you want to transfer to

   * @param value uint256 the amount of tokens to be transferred

   */

  function transferFrom(

    address from,

    address to,

    uint256 value

  )

    public

    returns (bool)

  {

    require(value <= _allowed[from][msg.sender]);

    

    if (_canTransfer(from, value)) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        return true;

    } else {

        emit Lock(from,value,getLockAmount(from),balanceOf(from));

        return false;

    }

  }



  /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed_[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param spender The address which will spend the funds.

   * @param addedValue The amount of tokens to increase the allowance by.

   */

  function increaseAllowance(

    address spender,

    uint256 addedValue

  )

    public

    returns (bool)

  {

    require(spender != address(0));



    _allowed[msg.sender][spender] = (

      _allowed[msg.sender][spender].add(addedValue));

    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

    return true;

  }



  /**

   * @dev Decrease the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed_[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param spender The address which will spend the funds.

   * @param subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseAllowance(

    address spender,

    uint256 subtractedValue

  )

    public

    returns (bool)

  {

    require(spender != address(0));



    _allowed[msg.sender][spender] = (

      _allowed[msg.sender][spender].sub(subtractedValue));

    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

    return true;

  }



  /**

  * @dev Transfer token for a specified addresses

  * @param from The address to transfer from.

  * @param to The address to transfer to.

  * @param value The amount to be transferred.

  */

  function _transfer(address from, address to, uint256 value) internal {

    require(value <= _balances[from]);

    require(to != address(0));

    

    _balances[from] = _balances[from].sub(value);

    _balances[to] = _balances[to].add(value);

    emit Transfer(from, to, value);

    

  }



  /**

   * @dev Internal function that mints an amount of the token and assigns it to

   * an account. This encapsulates the modification of balances such that the

   * proper events are emitted.

   * @param account The account that will receive the created tokens.

   * @param value The amount that will be created.

   */

  function _mint(address account, uint256 value) internal {

    require(account != 0);

    _totalSupply = _totalSupply.add(value);

    _balances[account] = _balances[account].add(value);

    emit Transfer(address(0), account, value);

  }

  

  function setTimeLine(uint256[] timeLine) onlyOwner public {

    releaseTimeLines = timeLine;

  }

  

  /**

   * @dev getRoleReleaseSeting

   * @param roleType 1:Seed 2:Angel 3:PE 4:AirDrop

   */

  function getRoleReleaseSeting(uint256 roleType) pure public returns (uint256,uint256,uint256) {

    if(roleType == 1){

      return (50,1,10);

    }else if(roleType == 2){

      return (30,1,10);

    }else if(roleType == 3){

      return (40,3,20);

    }else if(roleType == 4){

      return (5,1,5);

    }else {

      return (0,0,0);

    }

  }

  

  function addLockUser(address roleAddress,uint256 amount,uint256 roleType) onlyOwner public {

    (uint256 firstRate, uint256 round, uint256 rate) = getRoleReleaseSeting(roleType);

    mapRoles[roleAddress][roleType] = Role(roleAddress,amount,firstRate,round,rate);

    lockList[roleAddress] = roleAddress;

  }

  

  function addLockUsers(address[] roleAddress,uint256[] amounts,uint256 roleType) onlyOwner public {

    for(uint i= 0;i<roleAddress.length;i++){

      addLockUser(roleAddress[i],amounts[i],roleType);

    }

  }

  

  function removeLockUser(address roleAddress,uint256 role) onlyOwner public {

    mapRoles[roleAddress][role] = Role(0x0,0,0,0,0);

    lockList[roleAddress] = 0x0;

  }

  

  function getRound() constant public returns (uint) {

    for(uint i= 0;i<releaseTimeLines.length;i++){

      if(now<releaseTimeLines[i]){

        if(i>0){

          return i-1;

        }else{

          return 0;

        }

      }

    }

  }

   

  function isUserInLockList(address from) constant public returns (bool) {

    if(lockList[from]==0x0){

      return false;

    } else {

      return true;

    }

  }

  

  function _canTransfer(address from,uint256 _amount) private returns (bool) {

    if(!isUserInLockList(from)){

      return true;

    }

    if((balanceOf(from))<=0){

      return true;

    }

    uint256 _lock = getLockAmount(from);

    if(_lock<=0){

      lockList[from] = 0x0;

    }

    if((balanceOf(from).sub(_amount))<_lock){

      return false;

    }

    return true;

  }

  

  function getLockAmount(address from) constant public returns (uint256) {

    uint256 _lock = 0;

    for(uint i= 1;i<=4;i++){

      if(mapRoles[from][i].roleAddress != 0x0){

        _lock = _lock.add(getLockAmountByRoleType(from,i));

      }

    }

    return _lock;

  }

  

  function getLockAmountByRoleType(address from,uint roleType) constant public returns (uint256) {

    uint256 _rount = getRound();

    uint256 round = 0;

    if(_rount>0){

      round = _rount.div(mapRoles[from][roleType].round);

    }

    if(mapRoles[from][roleType].firstRate.add(round.mul(mapRoles[from][roleType].rate))>=100){

      return 0;

    }

    uint256 firstAmount = mapRoles[from][roleType].amount.mul(mapRoles[from][roleType].firstRate).div(100);

    uint256 rountAmount = 0;

    if(round>0){

      rountAmount = mapRoles[from][roleType].amount.mul(mapRoles[from][roleType].rate.mul(round)).div(100);

    }

    return mapRoles[from][roleType].amount.sub(firstAmount.add(rountAmount));

  }

    

}