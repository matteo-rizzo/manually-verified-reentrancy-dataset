/**

 *Submitted for verification at Etherscan.io on 2018-12-31

*/



pragma solidity ^0.4.24;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





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

contract ERC20 is IERC20, Ownable {

  using SafeMath for uint256;



  mapping (address => uint256) internal _balances;



  mapping (address => mapping (address => uint256)) internal _allowed;



  uint256 internal _totalSupply;



  uint256 internal _totalHolders;



  uint256 internal _totalTransfers;



  uint256 internal _initialSupply;



  function initialSupply() public view returns (uint256) {

    return _initialSupply;

  }



  /**

  * @dev Total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return _totalSupply;

  }



  function circulatingSupply() public view returns (uint256) {

    require(_totalSupply >= _balances[owner()]);

    return _totalSupply.sub(_balances[owner()]);

  }



  /**

  * @dev total number of token holders in existence

  */

  function totalHolders() public view returns (uint256) {

    return _totalHolders;

  }



  /**

  * @dev total number of token transfers

  */

  function totalTransfers() public view returns (uint256) {

    return _totalTransfers;

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

    require(value <= _balances[msg.sender]);

    require(to != address(0));



    _balances[msg.sender] = _balances[msg.sender].sub(value);

    if (_balances[msg.sender] == 0 && _totalHolders > 0) {

      _totalHolders = _totalHolders.sub(1);

    }

    if (_balances[to] == 0) {

      _totalHolders = _totalHolders.add(1);

    }

    _balances[to] = _balances[to].add(value);

    _totalTransfers = _totalTransfers.add(1);

    emit Transfer(msg.sender, to, value);

    return true;

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

    if (msg.sender == from) {

      return transfer(to, value);

    }



    require(value <= _balances[from]);

    require(value <= _allowed[from][msg.sender]);

    require(to != address(0));



    _balances[from] = _balances[from].sub(value);



    if (_balances[from] == 0 && _totalHolders > 0) {

      _totalHolders = _totalHolders.sub(1);

    }

    if (_balances[to] == 0) {

      _totalHolders = _totalHolders.add(1);

    }



    _balances[to] = _balances[to].add(value);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

    _totalTransfers = _totalTransfers.add(1);

    emit Transfer(from, to, value);

    return true;

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

   * @dev Internal function that mints an amount of the token and assigns it to

   * an account. This encapsulates the modification of balances such that the

   * proper events are emitted.

   * @param account The account that will receive the created tokens.

   * @param amount The amount that will be created.

   */

  function _mint(address account, uint256 amount) internal {

    require(account != 0);

    _totalSupply = _totalSupply.add(amount);

    if (_balances[account] == 0) {

      _totalHolders = _totalHolders.add(1);

    }

    _balances[account] = _balances[account].add(amount);

    emit Transfer(address(0), account, amount);

  }



  /**

   * @dev Internal function that burns an amount of the token of a given

   * account.

   * @param account The account whose tokens will be burnt.

   * @param amount The amount that will be burnt.

   */

  function _burn(address account, uint256 amount) internal {

    require(account != 0);

    require(amount <= _balances[account]);



    _totalSupply = _totalSupply.sub(amount);

    _balances[account] = _balances[account].sub(amount);

    if (_balances[account] == 0 && _totalHolders > 0) {

      _totalHolders = _totalHolders.sub(1);

    }

    emit Transfer(account, address(0), amount);

  }



  /**

   * @dev Internal function that burns an amount of the token of a given

   * account, deducting from the sender's allowance for said account. Uses the

   * internal burn function.

   * @param account The account whose tokens will be burnt.

   * @param amount The amount that will be burnt.

   */

  function _burnFrom(address account, uint256 amount) internal {

    require(amount <= _allowed[account][msg.sender]);



    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,

    // this function needs to emit an event with the updated approval.

    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(

      amount);

    _burn(account, amount);

  }

}



contract AgentRole is Ownable {

  using Roles for Roles.Role;



  event AgentAdded(address indexed account);

  event AgentRemoved(address indexed account);



  Roles.Role private agencies;



  constructor() public {

    agencies.add(msg.sender);

  }



  modifier onlyAgent() {

    require(isOwner() || isAgent(msg.sender));

    _;

  }



  function isAgent(address account) public view returns (bool) {

    return agencies.has(account);

  }



  function addAgent(address account) public onlyAgent {

    agencies.add(account);

    emit AgentAdded(account);

  }



  function renounceAgent() public onlyAgent {

    agencies.remove(msg.sender);

  }



  function _removeAgent(address account) internal {

    agencies.remove(account);

    emit AgentRemoved(account);

  }

}



/**

 * @title Agent token

 * @dev ERC20 modified with agentable transfers.

 **/

contract ERC20Agentable is ERC20, AgentRole {



  function removeAgent(address account) public onlyAgent {

    _removeAgent(account);

  }



  function _removeAgent(address account) internal {

    super._removeAgent(account);

  }



  function transferProxy(

    address from,

    address to,

    uint256 value

  )

    public

    onlyAgent

    returns (bool)

  {

    if (msg.sender == from) {

      return transfer(to, value);

    }



    require(value <= _balances[from]);

    require(to != address(0));



    _balances[from] = _balances[from].sub(value);



    if (_balances[from] == 0 && _totalHolders > 0) {

      _totalHolders = _totalHolders.sub(1);

    }

    if (_balances[to] == 0) {

      _totalHolders = _totalHolders.add(1);

    }



    _balances[to] = _balances[to].add(value);

    _totalTransfers = _totalTransfers.add(1);

    emit Transfer(from, to, value);

    return true;

  }



  function approveProxy(

    address from,

    address spender,

    uint256 value

  )

    public

    onlyAgent

    returns (bool)

  {

    require(spender != address(0));



    _allowed[from][spender] = value;

    emit Approval(from, spender, value);

    return true;

  }



  function increaseAllowanceProxy(

    address from,

    address spender,

    uint addedValue

  )

    public

    onlyAgent

    returns (bool success)

  {

    require(spender != address(0));



    _allowed[from][spender] = (

      _allowed[from][spender].add(addedValue));

    emit Approval(from, spender, _allowed[from][spender]);

    return true;

  }



  function decreaseAllowanceProxy(

    address from,

    address spender,

    uint subtractedValue

  )

    public

    onlyAgent

    returns (bool success)

  {

    require(spender != address(0));



    _allowed[from][spender] = (

      _allowed[from][spender].sub(subtractedValue));

    emit Approval(from, spender, _allowed[from][spender]);

    return true;

  }

}



/**

 * @title Burnable Token

 * @dev Token that can be irreversibly burned (destroyed).

 */

contract ERC20Burnable is ERC20 {



  /**

   * @dev Burns a specific amount of tokens.

   * @param value The amount of token to be burned.

   */

  function burn(uint256 value) public {

    _burn(msg.sender, value);

  }



  /**

   * @dev Burns a specific amount of tokens from the target address and decrements allowance

   * @param from address The address which you want to send tokens from

   * @param value uint256 The amount of token to be burned

   */

  function burnFrom(address from, uint256 value) public {

    _burnFrom(from, value);

  }



  /**

   * @dev Overrides ERC20._burn in order for burn and burnFrom to emit

   * an additional Burn event.

   */

  function _burn(address who, uint256 value) internal {

    super._burn(who, value);

  }

}



contract MinterRole is Ownable {

  using Roles for Roles.Role;



  event MinterAdded(address indexed account);

  event MinterRemoved(address indexed account);



  Roles.Role private minters;



  constructor() public {

    minters.add(msg.sender);

  }



  modifier onlyMinter() {

    require(isOwner() || isMinter(msg.sender));

    _;

  }



  function isMinter(address account) public view returns (bool) {

    return minters.has(account);

  }



  function addMinter(address account) public onlyMinter {

    minters.add(account);

    emit MinterAdded(account);

  }



  function renounceMinter() public onlyMinter {

    minters.remove(msg.sender);

  }



  function _removeMinter(address account) internal {

    minters.remove(account);

    emit MinterRemoved(account);

  }

}



/**

 * @title ERC20Mintable

 * @dev ERC20 minting logic

 */

contract ERC20Mintable is ERC20, MinterRole {

  event MintingFinished();



  bool private _mintingFinished = false;



  modifier onlyBeforeMintingFinished() {

    require(!_mintingFinished);

    _;

  }



  function removeMinter(address account) public onlyMinter {

    _removeMinter(account);

  }



  function _removeMinter(address account) internal {

    super._removeMinter(account);

  }



  /**

   * @return true if the minting is finished.

   */

  function mintingFinished() public view returns(bool) {

    return _mintingFinished;

  }



  /**

   * @dev Function to mint tokens

   * @param to The address that will receive the minted tokens.

   * @param amount The amount of tokens to mint.

   * @return A boolean that indicates if the operation was successful.

   */

  function mint(

    address to,

    uint256 amount

  )

    public

    onlyMinter

    onlyBeforeMintingFinished

    returns (bool)

  {

    _mint(to, amount);

    return true;

  }



  /**

   * @dev Function to stop minting new tokens.

   * @return True if the operation was successful.

   */

  function finishMinting()

    public

    onlyMinter

    onlyBeforeMintingFinished

    returns (bool)

  {

    _mintingFinished = true;

    emit MintingFinished();

    return true;

  }

}



contract PauserRole is Ownable {

  using Roles for Roles.Role;



  event PauserAdded(address indexed account);

  event PauserRemoved(address indexed account);



  Roles.Role private pausers;



  constructor() public {

    pausers.add(msg.sender);

  }



  modifier onlyPauser() {

    require(isOwner() || isPauser(msg.sender));

    _;

  }



  function isPauser(address account) public view returns (bool) {

    return pausers.has(account);

  }



  function addPauser(address account) public onlyPauser {

    pausers.add(account);

    emit PauserAdded(account);

  }



  function renouncePauser() public onlyPauser {

    pausers.remove(msg.sender);

  }



  function _removePauser(address account) internal {

    pausers.remove(account);

    emit PauserRemoved(account);

  }

}



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is PauserRole {

  event Paused();

  event Unpaused();



  bool private _paused = false;





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

    emit Paused();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyPauser whenPaused {

    _paused = false;

    emit Unpaused();

  }

}



/**

 * @title Pausable token

 * @dev ERC20 modified with pausable transfers.

 **/

contract ERC20Pausable is ERC20, Pausable {



  function removePauser(address account) public onlyPauser {

    _removePauser(account);

  }



  function _removePauser(address account) internal {

    super._removePauser(account);

  }



  function transfer(

    address to,

    uint256 value

  )

    public

    whenNotPaused

    returns (bool)

  {

    return super.transfer(to, value);

  }



  function transferFrom(

    address from,

    address to,

    uint256 value

  )

    public

    whenNotPaused

    returns (bool)

  {

    return super.transferFrom(from, to, value);

  }



  function approve(

    address spender,

    uint256 value

  )

    public

    whenNotPaused

    returns (bool)

  {

    return super.approve(spender, value);

  }



  function increaseAllowance(

    address spender,

    uint addedValue

  )

    public

    whenNotPaused

    returns (bool success)

  {

    return super.increaseAllowance(spender, addedValue);

  }



  function decreaseAllowance(

    address spender,

    uint subtractedValue

  )

    public

    whenNotPaused

    returns (bool success)

  {

    return super.decreaseAllowance(spender, subtractedValue);

  }

}







/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */





/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





contract Token is ERC20Burnable, ERC20Mintable, ERC20Pausable, ERC20Agentable {



  string private _name;

  string private _symbol;

  uint8 private _decimals;



  constructor(string name, string symbol, uint8 decimals, uint256 initialSupply) public {

    _name = name;

    _symbol = symbol;

    _decimals = decimals;

    _initialSupply = initialSupply;

    _totalSupply = _initialSupply;

    _balances[msg.sender] = _initialSupply;

    emit Transfer(0x0, msg.sender, _initialSupply);

  }



  /**

   * @return the name of the token.

   */

  function name() public view returns(string) {

    return _name;

  }



  /**

   * @return the symbol of the token.

   */

  function symbol() public view returns(string) {

    return _symbol;

  }



  /**

   * @return the number of decimals of the token.

   */

  function decimals() public view returns(uint8) {

    return _decimals;

  }



  function meta(address account) public view returns (string, string, uint8, uint256, uint256, uint256, uint256, uint256, uint256) {

    uint256 circulating = 0;

    if (_totalSupply > _balances[owner()]) {

      circulating = _totalSupply.sub(_balances[owner()]);

    }

    uint256 balance = 0;

    if (account != address(0)) {

      balance = _balances[account];

    } else if (msg.sender != address(0)) {

      balance = _balances[msg.sender];

    }

    return (_name, _symbol, _decimals, _initialSupply, _totalSupply, _totalTransfers, _totalHolders, circulating, balance);

  }



  function batchTransfer(address[] addresses, uint256[] tokenAmount) public returns (bool) {

    require(addresses.length > 0 && addresses.length == tokenAmount.length);

    for (uint i = 0; i < addresses.length; i++) {

        address _to = addresses[i];

        uint256 _value = tokenAmount[i];

        super.transfer(_to, _value);

    }

    return true;

  }



  function batchTransferFrom(address _from, address[] addresses, uint256[] tokenAmount) public returns (bool) {

    require(addresses.length > 0 && addresses.length == tokenAmount.length);

    for (uint i = 0; i < addresses.length; i++) {

        address _to = addresses[i];

        uint256 _value = tokenAmount[i];

        super.transferFrom(_from, _to, _value);

    }

    return true;

  }





}