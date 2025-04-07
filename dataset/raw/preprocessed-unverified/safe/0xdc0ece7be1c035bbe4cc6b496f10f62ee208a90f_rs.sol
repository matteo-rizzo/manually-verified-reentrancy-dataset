pragma solidity ^0.4.24;



// File: contracts/token/TransferAndCallbackInterface.sol



/**

    Declares an interface for functionality allowing to notify the receiving contract 

    of the transfer of tokens or approval.

 */



contract TransferAndCallbackInterface {

    function transferAndCallback(address _to, uint256 _value, bytes _data) public returns (bool);

}



// File: contracts/token/TransferAndCallbackReceiver.sol



/**

 * An interface for a contract that receives tokens and gets notified after the transfer

 */

contract TransferAndCallbackReceiver { 

/**

 * @param _from  Token sender address.

 * @param _value Amount of tokens.

 * @param _data  Transaction metadata.

 */

    function balanceTransferred(address _from, uint256 _value, bytes _data) public;

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: contracts/token/TransferAndCallback.sol



contract TransferAndCallback is ERC20Basic, TransferAndCallbackInterface {



/**

     * @dev Transfer the specified amount of tokens to the specified address.

     *      Invokes the `balanceTransferred` function if the recipient is a contract.

     *      The token transfer fails if the recipient is NOT a contract

    *       or is a contract but does not implement the `balanceTransferred` function

     *      or the fallback function to receive funds.

     *

     * @param _to    Receiver address.

     * @param _value Amount of tokens that will be transferred.

     * @param _data  Transaction metadata.

     */

    function transferAndCallback(address _to, uint256 _value, bytes _data) public returns(bool) {

        

        // First make sure that _to address is a contract

        uint256 codeLength;

        /* solium-disable-next-line security/no-inline-assembly */

        assembly {

            codeLength := extcodesize(_to)

        }



        require(codeLength > 0, "'_to' address must be a contract");



        // transfer funds

        super.transfer(_to, _value);



        TransferAndCallbackReceiver receiver = TransferAndCallbackReceiver(_to);

        receiver.balanceTransferred(msg.sender, _value, _data);



        return true;

    }

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



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





// File: openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol



/**

 * @title Contracts that should be able to recover tokens

 * @author SylTi

 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.

 * This will prevent any accidental loss of tokens.

 */

contract CanReclaimToken is Ownable {

  using SafeERC20 for ERC20Basic;



  /**

   * @dev Reclaim all ERC20Basic compatible tokens

   * @param token ERC20Basic The address of the token contract

   */

  function reclaimToken(ERC20Basic token) external onlyOwner {

    uint256 balance = token.balanceOf(this);

    token.safeTransfer(owner, balance);

  }



}



// File: openzeppelin-solidity/contracts/ownership/Claimable.sol



/**

 * @title Claimable

 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.

 * This allows the new owner to accept the transfer.

 */

contract Claimable is Ownable {

  address public pendingOwner;



  /**

   * @dev Modifier throws if called by any account other than the pendingOwner.

   */

  modifier onlyPendingOwner() {

    require(msg.sender == pendingOwner);

    _;

  }



  /**

   * @dev Allows the current owner to set the pendingOwner address.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) onlyOwner public {

    pendingOwner = newOwner;

  }



  /**

   * @dev Allows the pendingOwner address to finalize the transfer.

   */

  function claimOwnership() onlyPendingOwner public {

    emit OwnershipTransferred(owner, pendingOwner);

    owner = pendingOwner;

    pendingOwner = address(0);

  }

}



// File: openzeppelin-solidity/contracts/ownership/HasNoEther.sol



/**

 * @title Contracts that should not own Ether

 * @author Remco Bloemen <[email protected]π.com>

 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up

 * in the contract, it will allow the owner to reclaim this ether.

 * @notice Ether can still be sent to this contract by:

 * calling functions labeled `payable`

 * `selfdestruct(contract_address)`

 * mining directly to the contract address

 */

contract HasNoEther is Ownable {



  /**

  * @dev Constructor that rejects incoming Ether

  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we

  * leave out payable, then Solidity will allow inheriting contracts to implement a payable

  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively

  * we could use assembly to access msg.value.

  */

  constructor() public payable {

    require(msg.value == 0);

  }



  /**

   * @dev Disallows direct send by settings a default function without the `payable` flag.

   */

  function() external {

  }



  /**

   * @dev Transfer all Ether held by the contract to the owner.

   */

  function reclaimEther() external onlyOwner {

    owner.transfer(address(this).balance);

  }

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol



/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



  uint256 totalSupply_;



  /**

  * @dev total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  /**

  * @dev transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[msg.sender]);



    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];

  }



}



// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * @dev https://github.com/ethereum/EIPs/issues/20

 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) internal allowed;





  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

  function transferFrom(

    address _from,

    address _to,

    uint256 _value

  )

    public

    returns (bool)

  {

    require(_to != address(0));

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);

    return true;

  }



  /**

   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

   *

   * Beware that changing an allowance with this method brings the risk that someone may use both the old

   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

   * @param _spender The address which will spend the funds.

   * @param _value The amount of tokens to be spent.

   */

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);

    return true;

  }



  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param _owner address The address which owns the funds.

   * @param _spender address The address which will spend the funds.

   * @return A uint256 specifying the amount of tokens still available for the spender.

   */

  function allowance(

    address _owner,

    address _spender

   )

    public

    view

    returns (uint256)

  {

    return allowed[_owner][_spender];

  }



  /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   *

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _addedValue The amount of tokens to increase the allowance by.

   */

  function increaseApproval(

    address _spender,

    uint _addedValue

  )

    public

    returns (bool)

  {

    allowed[msg.sender][_spender] = (

      allowed[msg.sender][_spender].add(_addedValue));

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



  /**

   * @dev Decrease the amount of tokens that an owner allowed to a spender.

   *

   * approve should be called when allowed[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseApproval(

    address _spender,

    uint _subtractedValue

  )

    public

    returns (bool)

  {

    uint oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}



// File: contracts/PathToken.sol



/**

    PathToken is a standard ERC20 token with additional transfer function 

    that notifies the receiving contract of the transfer.

 */

contract PathToken is StandardToken, TransferAndCallback, Claimable, CanReclaimToken, HasNoEther {

    string public name;

    string public symbol;

    uint8 public decimals;



    constructor() public {

        name = "Path Token";

        symbol = "PATH";

        decimals = 6;

        totalSupply_ = 500000000 * 10 ** uint(decimals);

        balances[owner] = totalSupply_;

    }

}