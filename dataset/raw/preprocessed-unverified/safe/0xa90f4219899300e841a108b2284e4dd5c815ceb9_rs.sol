/**

 *Submitted for verification at Etherscan.io on 2018-12-09

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol



/**

 * @title ERC20Detailed token

 * @dev The decimals are only for visualization purposes.

 * All the operations are done using the smallest and indivisible token unit,

 * just as on Ethereum all the operations are done in wei.

 */

contract ERC20Detailed is IERC20 {

  string private _name;

  string private _symbol;

  uint8 private _decimals;



  constructor(string name, string symbol, uint8 decimals) public {

    _name = name;

    _symbol = symbol;

    _decimals = decimals;

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

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract ERC20 is IERC20 {

  using SafeMath for uint256;



  mapping (address => uint256) private _balances;



  mapping (address => mapping (address => uint256)) private _allowed;



  uint256 private _totalSupply;



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

    _transfer(msg.sender, to, value);

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

    require(value <= _allowed[from][msg.sender]);



    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

    _transfer(from, to, value);

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



  /**

   * @dev Internal function that burns an amount of the token of a given

   * account.

   * @param account The account whose tokens will be burnt.

   * @param value The amount that will be burnt.

   */

  function _burn(address account, uint256 value) internal {

    require(account != 0);

    require(value <= _balances[account]);



    _totalSupply = _totalSupply.sub(value);

    _balances[account] = _balances[account].sub(value);

    emit Transfer(account, address(0), value);

  }



  /**

   * @dev Internal function that burns an amount of the token of a given

   * account, deducting from the sender's allowance for said account. Uses the

   * internal burn function.

   * @param account The account whose tokens will be burnt.

   * @param value The amount that will be burnt.

   */

  function _burnFrom(address account, uint256 value) internal {

    require(value <= _allowed[account][msg.sender]);



    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,

    // this function needs to emit an event with the updated approval.

    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(

      value);

    _burn(account, value);

  }

}



// File: openzeppelin-solidity/contracts/access/Roles.sol



/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */





// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol



contract MinterRole {

  using Roles for Roles.Role;



  event MinterAdded(address indexed account);

  event MinterRemoved(address indexed account);



  Roles.Role private minters;



  constructor() internal {

    _addMinter(msg.sender);

  }



  modifier onlyMinter() {

    require(isMinter(msg.sender));

    _;

  }



  function isMinter(address account) public view returns (bool) {

    return minters.has(account);

  }



  function addMinter(address account) public onlyMinter {

    _addMinter(account);

  }



  function renounceMinter() public {

    _removeMinter(msg.sender);

  }



  function _addMinter(address account) internal {

    minters.add(account);

    emit MinterAdded(account);

  }



  function _removeMinter(address account) internal {

    minters.remove(account);

    emit MinterRemoved(account);

  }

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol



/**

 * @title ERC20Mintable

 * @dev ERC20 minting logic

 */

contract ERC20Mintable is ERC20, MinterRole {

  /**

   * @dev Function to mint tokens

   * @param to The address that will receive the minted tokens.

   * @param value The amount of tokens to mint.

   * @return A boolean that indicates if the operation was successful.

   */

  function mint(

    address to,

    uint256 value

  )

    public

    onlyMinter

    returns (bool)

  {

    _mint(to, value);

    return true;

  }

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol



/**

 * @title Capped token

 * @dev Mintable token with a token cap.

 */

contract ERC20Capped is ERC20Mintable {



  uint256 private _cap;



  constructor(uint256 cap)

    public

  {

    require(cap > 0);

    _cap = cap;

  }



  /**

   * @return the cap for the token minting.

   */

  function cap() public view returns(uint256) {

    return _cap;

  }



  function _mint(address account, uint256 value) internal {

    require(totalSupply().add(value) <= _cap);

    super._mint(account, value);

  }

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol



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

}



// File: openzeppelin-solidity/contracts/utils/Address.sol



/**

 * Utility library of inline functions on addresses

 */





// File: openzeppelin-solidity/contracts/introspection/ERC165Checker.sol



/**

 * @title ERC165Checker

 * @dev Use `using ERC165Checker for address`; to include this library

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md

 */





// File: openzeppelin-solidity/contracts/introspection/IERC165.sol



/**

 * @title IERC165

 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md

 */





// File: openzeppelin-solidity/contracts/introspection/ERC165.sol



/**

 * @title ERC165

 * @author Matt Condon (@shrugs)

 * @dev Implements ERC165 using a lookup table.

 */

contract ERC165 is IERC165 {



  bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;

  /**

   * 0x01ffc9a7 ===

   *   bytes4(keccak256('supportsInterface(bytes4)'))

   */



  /**

   * @dev a mapping of interface id to whether or not it's supported

   */

  mapping(bytes4 => bool) private _supportedInterfaces;



  /**

   * @dev A contract implementing SupportsInterfaceWithLookup

   * implement ERC165 itself

   */

  constructor()

    internal

  {

    _registerInterface(_InterfaceId_ERC165);

  }



  /**

   * @dev implement supportsInterface(bytes4) using a lookup table

   */

  function supportsInterface(bytes4 interfaceId)

    external

    view

    returns (bool)

  {

    return _supportedInterfaces[interfaceId];

  }



  /**

   * @dev internal method for registering an interface

   */

  function _registerInterface(bytes4 interfaceId)

    internal

  {

    require(interfaceId != 0xffffffff);

    _supportedInterfaces[interfaceId] = true;

  }

}



// File: erc-payable-token/contracts/token/ERC1363/IERC1363.sol



/**

 * @title IERC1363 Interface

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Interface for a Payable Token contract as defined in

 *  https://github.com/ethereum/EIPs/issues/1363

 */

contract IERC1363 is IERC20, ERC165 {

  /*

   * Note: the ERC-165 identifier for this interface is 0x4bbee2df.

   * 0x4bbee2df ===

   *   bytes4(keccak256('transferAndCall(address,uint256)')) ^

   *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^

   *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^

   *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)'))

   */



  /*

   * Note: the ERC-165 identifier for this interface is 0xfb9ec8ce.

   * 0xfb9ec8ce ===

   *   bytes4(keccak256('approveAndCall(address,uint256)')) ^

   *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))

   */



  /**

   * @notice Transfer tokens from `msg.sender` to another address

   *  and then call `onTransferReceived` on receiver

   * @param to address The address which you want to transfer to

   * @param value uint256 The amount of tokens to be transferred

   * @return true unless throwing

   */

  function transferAndCall(address to, uint256 value) public returns (bool);



  /**

   * @notice Transfer tokens from `msg.sender` to another address

   *  and then call `onTransferReceived` on receiver

   * @param to address The address which you want to transfer to

   * @param value uint256 The amount of tokens to be transferred

   * @param data bytes Additional data with no specified format, sent in call to `to`

   * @return true unless throwing

   */

  function transferAndCall(address to, uint256 value, bytes data) public returns (bool); // solium-disable-line max-len



  /**

   * @notice Transfer tokens from one address to another

   *  and then call `onTransferReceived` on receiver

   * @param from address The address which you want to send tokens from

   * @param to address The address which you want to transfer to

   * @param value uint256 The amount of tokens to be transferred

   * @return true unless throwing

   */

  function transferFromAndCall(address from, address to, uint256 value) public returns (bool); // solium-disable-line max-len





  /**

   * @notice Transfer tokens from one address to another

   *  and then call `onTransferReceived` on receiver

   * @param from address The address which you want to send tokens from

   * @param to address The address which you want to transfer to

   * @param value uint256 The amount of tokens to be transferred

   * @param data bytes Additional data with no specified format, sent in call to `to`

   * @return true unless throwing

   */

  function transferFromAndCall(address from, address to, uint256 value, bytes data) public returns (bool); // solium-disable-line max-len, arg-overflow



  /**

   * @notice Approve the passed address to spend the specified amount of tokens on behalf of msg.sender

   *  and then call `onApprovalReceived` on spender

   *  Beware that changing an allowance with this method brings the risk that someone may use both the old

   *  and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

   *  race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

   *  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

   * @param spender address The address which will spend the funds

   * @param value uint256 The amount of tokens to be spent

   */

  function approveAndCall(address spender, uint256 value) public returns (bool); // solium-disable-line max-len



  /**

   * @notice Approve the passed address to spend the specified amount of tokens on behalf of msg.sender

   *  and then call `onApprovalReceived` on spender

   *  Beware that changing an allowance with this method brings the risk that someone may use both the old

   *  and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

   *  race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

   *  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

   * @param spender address The address which will spend the funds

   * @param value uint256 The amount of tokens to be spent

   * @param data bytes Additional data with no specified format, sent in call to `spender`

   */

  function approveAndCall(address spender, uint256 value, bytes data) public returns (bool); // solium-disable-line max-len

}



// File: erc-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol



/**

 * @title IERC1363Receiver Interface

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Interface for any contract that wants to support transferAndCall or transferFromAndCall

 *  from ERC1363 token contracts as defined in

 *  https://github.com/ethereum/EIPs/issues/1363

 */

contract IERC1363Receiver {

  /*

   * Note: the ERC-165 identifier for this interface is 0x88a7ca5c.

   * 0x88a7ca5c === bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))

   */



  /**

   * @notice Handle the receipt of ERC1363 tokens

   * @dev Any ERC1363 smart contract calls this function on the recipient

   *  after a `transfer` or a `transferFrom`. This function MAY throw to revert and reject the

   *  transfer. Return of other than the magic value MUST result in the

   *  transaction being reverted.

   *  Note: the token contract address is always the message sender.

   * @param operator address The address which called `transferAndCall` or `transferFromAndCall` function

   * @param from address The address which are token transferred from

   * @param value uint256 The amount of tokens transferred

   * @param data bytes Additional data with no specified format

   * @return `bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))`

   *  unless throwing

   */

  function onTransferReceived(address operator, address from, uint256 value, bytes data) external returns (bytes4); // solium-disable-line max-len, arg-overflow

}



// File: erc-payable-token/contracts/token/ERC1363/IERC1363Spender.sol



/**

 * @title IERC1363Spender Interface

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Interface for any contract that wants to support approveAndCall

 *  from ERC1363 token contracts as defined in

 *  https://github.com/ethereum/EIPs/issues/1363

 */

contract IERC1363Spender {

  /*

   * Note: the ERC-165 identifier for this interface is 0x7b04a2d0.

   * 0x7b04a2d0 === bytes4(keccak256("onApprovalReceived(address,uint256,bytes)"))

   */



  /**

   * @notice Handle the approval of ERC1363 tokens

   * @dev Any ERC1363 smart contract calls this function on the recipient

   *  after an `approve`. This function MAY throw to revert and reject the

   *  approval. Return of other than the magic value MUST result in the

   *  transaction being reverted.

   *  Note: the token contract address is always the message sender.

   * @param owner address The address which called `approveAndCall` function

   * @param value uint256 The amount of tokens to be spent

   * @param data bytes Additional data with no specified format

   * @return `bytes4(keccak256("onApprovalReceived(address,uint256,bytes)"))`

   *  unless throwing

   */

  function onApprovalReceived(address owner, uint256 value, bytes data) external returns (bytes4); // solium-disable-line max-len

}



// File: erc-payable-token/contracts/token/ERC1363/ERC1363.sol



/**

 * @title ERC1363

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Implementation of an ERC1363 interface

 */

contract ERC1363 is ERC20, IERC1363 { // solium-disable-line max-len

  using Address for address;



  /*

   * Note: the ERC-165 identifier for this interface is 0x4bbee2df.

   * 0x4bbee2df ===

   *   bytes4(keccak256('transferAndCall(address,uint256)')) ^

   *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^

   *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^

   *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)'))

   */

  bytes4 internal constant _InterfaceId_ERC1363Transfer = 0x4bbee2df;



  /*

   * Note: the ERC-165 identifier for this interface is 0xfb9ec8ce.

   * 0xfb9ec8ce ===

   *   bytes4(keccak256('approveAndCall(address,uint256)')) ^

   *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))

   */

  bytes4 internal constant _InterfaceId_ERC1363Approve = 0xfb9ec8ce;



  // Equals to `bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))`

  // which can be also obtained as `IERC1363Receiver(0).onTransferReceived.selector`

  bytes4 private constant _ERC1363_RECEIVED = 0x88a7ca5c;



  // Equals to `bytes4(keccak256("onApprovalReceived(address,uint256,bytes)"))`

  // which can be also obtained as `IERC1363Spender(0).onApprovalReceived.selector`

  bytes4 private constant _ERC1363_APPROVED = 0x7b04a2d0;



  constructor() public {

    // register the supported interfaces to conform to ERC1363 via ERC165

    _registerInterface(_InterfaceId_ERC1363Transfer);

    _registerInterface(_InterfaceId_ERC1363Approve);

  }



  function transferAndCall(

    address to,

    uint256 value

  )

    public

    returns (bool)

  {

    return transferAndCall(to, value, "");

  }



  function transferAndCall(

    address to,

    uint256 value,

    bytes data

  )

    public

    returns (bool)

  {

    require(transfer(to, value));

    require(

      _checkAndCallTransfer(

        msg.sender,

        to,

        value,

        data

      )

    );

    return true;

  }



  function transferFromAndCall(

    address from,

    address to,

    uint256 value

  )

    public

    returns (bool)

  {

    // solium-disable-next-line arg-overflow

    return transferFromAndCall(from, to, value, "");

  }



  function transferFromAndCall(

    address from,

    address to,

    uint256 value,

    bytes data

  )

    public

    returns (bool)

  {

    require(transferFrom(from, to, value));

    require(

      _checkAndCallTransfer(

        from,

        to,

        value,

        data

      )

    );

    return true;

  }



  function approveAndCall(

    address spender,

    uint256 value

  )

    public

    returns (bool)

  {

    return approveAndCall(spender, value, "");

  }



  function approveAndCall(

    address spender,

    uint256 value,

    bytes data

  )

    public

    returns (bool)

  {

    approve(spender, value);

    require(

      _checkAndCallApprove(

        spender,

        value,

        data

      )

    );

    return true;

  }



  /**

   * @dev Internal function to invoke `onTransferReceived` on a target address

   *  The call is not executed if the target address is not a contract

   * @param from address Representing the previous owner of the given token value

   * @param to address Target address that will receive the tokens

   * @param value uint256 The amount mount of tokens to be transferred

   * @param data bytes Optional data to send along with the call

   * @return whether the call correctly returned the expected magic value

   */

  function _checkAndCallTransfer(

    address from,

    address to,

    uint256 value,

    bytes data

  )

    internal

    returns (bool)

  {

    if (!to.isContract()) {

      return false;

    }

    bytes4 retval = IERC1363Receiver(to).onTransferReceived(

      msg.sender, from, value, data

    );

    return (retval == _ERC1363_RECEIVED);

  }



  /**

   * @dev Internal function to invoke `onApprovalReceived` on a target address

   *  The call is not executed if the target address is not a contract

   * @param spender address The address which will spend the funds

   * @param value uint256 The amount of tokens to be spent

   * @param data bytes Optional data to send along with the call

   * @return whether the call correctly returned the expected magic value

   */

  function _checkAndCallApprove(

    address spender,

    uint256 value,

    bytes data

  )

    internal

    returns (bool)

  {

    if (!spender.isContract()) {

      return false;

    }

    bytes4 retval = IERC1363Spender(spender).onApprovalReceived(

      msg.sender, value, data

    );

    return (retval == _ERC1363_APPROVED);

  }

}



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: eth-token-recover/contracts/TokenRecover.sol



/**

 * @title TokenRecover

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Allow to recover any ERC20 sent into the contract for error

 */

contract TokenRecover is Ownable {



  /**

   * @dev Remember that only owner can call so be careful when use on contracts generated from other contracts.

   * @param tokenAddress The token contract address

   * @param tokenAmount Number of tokens to be sent

   */

  function recoverERC20(

    address tokenAddress,

    uint256 tokenAmount

  )

    public

    onlyOwner

  {

    IERC20(tokenAddress).transfer(owner(), tokenAmount);

  }

}



// File: contracts/BaseToken.sol



/**

 * @title BaseToken

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Implementation of a BaseToken

 */

contract BaseToken is ERC20Detailed, ERC20Capped, ERC20Burnable, ERC1363, TokenRecover { // solium-disable-line max-len



  string public builtOn = "https://vittominacori.github.io/erc20-generator";



  constructor(

    string name,

    string symbol,

    uint8 decimals,

    uint256 cap,

    uint256 initialBalance

  )

    ERC20Detailed(name, symbol, decimals)

    ERC20Capped(cap)

    public

  {

    if (initialBalance > 0) {

      _mint(owner(), initialBalance);

    }

  }

}