/**

 *Submitted for verification at Etherscan.io on 2018-12-04

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

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



  mapping(address => uint256) internal balances;



  uint256 internal totalSupply_;



  /**

  * @dev Total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  /**

  * @dev Transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_value <= balances[msg.sender]);

    require(_to != address(0));



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



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/issues/20

 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

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

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);

    require(_to != address(0));



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);

    return true;

  }



  /**

   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

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

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _addedValue The amount of tokens to increase the allowance by.

   */

  function increaseApproval(

    address _spender,

    uint256 _addedValue

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

   * approve should be called when allowed[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseApproval(

    address _spender,

    uint256 _subtractedValue

  )

    public

    returns (bool)

  {

    uint256 oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue >= oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

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

   * @param _token ERC20Basic The address of the token contract

   */

  function reclaimToken(ERC20Basic _token) external onlyOwner {

    uint256 balance = _token.balanceOf(this);

    _token.safeTransfer(owner, balance);

  }



}



// File: contracts/MovieCoin.sol



contract MovieCoin is StandardToken, CanReclaimToken {

    string constant public symbol = "MOV";

    string constant public name = "\"MovieCoin\" project utility token";

    uint8 constant public decimals = 18;

    string constant public version = "1.0";



    constructor() public {

        totalSupply_ = 2000000000 * (10 ** uint256(decimals));

		

		balances[0xfDC3881F0a0b7a086f8A9A461eB624c02622e9eB]=0.6e9*1e18;

		balances[0xb1AcA46DE8bff379Aae7bBee4f675845dB81745d]=0.6e9*1e18;

		balances[0x7b6293f76b1e85eab7671dBfe299757fD3CEF20D]=0.25e9*1e18;

		balances[0x8cE01936208706468692a49a31fB571B1A61D509]=0.25e9*1e18;

		balances[0x78091b201E26CDb3b2e8004Fb961c3FB1FF59d50]=0.2e9*1e18;

		balances[0xef0eA48627d1b3d851998B2a13898E32f0470248]=0.05e9*1e18;

		balances[0x150175f0D5c5A505bF4aF49a2DEdD68946E103fb]=0.05e9*1e18;

		

		

        emit Transfer(address(0), msg.sender, totalSupply_);

		emit Transfer(address(msg.sender), 0xfDC3881F0a0b7a086f8A9A461eB624c02622e9eB, 0.6e9*1e18);

		emit Transfer(address(msg.sender), 0xb1AcA46DE8bff379Aae7bBee4f675845dB81745d, 0.6e9*1e18);

		emit Transfer(address(msg.sender), 0x7b6293f76b1e85eab7671dBfe299757fD3CEF20D, 0.25e9*1e18);

		emit Transfer(address(msg.sender), 0x8cE01936208706468692a49a31fB571B1A61D509, 0.25e9*1e18);

		emit Transfer(address(msg.sender), 0x78091b201E26CDb3b2e8004Fb961c3FB1FF59d50, 0.2e9*1e18);

		emit Transfer(address(msg.sender), 0xef0eA48627d1b3d851998B2a13898E32f0470248, 0.05e9*1e18);

		emit Transfer(address(msg.sender), 0x150175f0D5c5A505bF4aF49a2DEdD68946E103fb, 0.05e9*1e18);	

    }

}