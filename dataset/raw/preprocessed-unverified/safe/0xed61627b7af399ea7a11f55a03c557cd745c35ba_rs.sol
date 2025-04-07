/**

 *Submitted for verification at Etherscan.io on 2018-08-21

*/



pragma solidity ^0.4.11;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */









/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */









contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) constant returns (uint256);

  function transfer(address to, uint256 value) returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) constant returns (uint256);

  function transferFrom(address from, address to, uint256 value) returns (bool);

  function approve(address spender, uint256 value) returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



  /**

  * @dev transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) returns (bool) {

    // SafeMath.sub will throw if there is not enough balance.

    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    Transfer(msg.sender, _to, _value);

    return true;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) constant returns (uint256 balance) {

    return balances[_owner];

  }



}



contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) allowed;



  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {

    var _allowance = allowed[_from][msg.sender];



    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met

    // require (_value <= _allowance);



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = _allowance.sub(_value);

    Transfer(_from, _to, _value);

    return true;

  }



  /**

   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

   * @param _spender The address which will spend the funds.

   * @param _value The amount of tokens to be spent.

   */

  function approve(address _spender, uint256 _value) returns (bool) {



    // To change the approve amount you first have to reduce the addresses`

    //  allowance to zero by calling `approve(_spender, 0)` if it is not

    //  already 0 to mitigate the race condition described here:

    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

    require((_value == 0) || (allowed[msg.sender][_spender] == 0));



    allowed[msg.sender][_spender] = _value;

    Approval(msg.sender, _spender, _value);

    return true;

  }



  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param _owner address The address which owns the funds.

   * @param _spender address The address which will spend the funds.

   * @return A uint256 specifying the amount of tokens still available for the spender.

   */

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

    return allowed[_owner][_spender];

  }

}



contract BTCCToken is Ownable,StandardToken {



    uint public totalSupply = 3*10**27;

    string public constant name = "BTCCToken";

    string public constant symbol = "BTCC";

    uint8 public constant decimals = 18;



    function BTCCToken() {

        balances[msg.sender] = totalSupply;

        Transfer(address(0), msg.sender, totalSupply);

    }



    mapping (address => bool) stopTransfer;



    function setStopTransfer(address _to,bool stop) onlyOwner{

        stopTransfer[_to] = stop;

    }



    function getStopTransfer(address _to) constant public returns (bool) {

        return stopTransfer[_to];

    }



    function transfer(address _to, uint256 _value) public  returns (bool) {

        require(!stopTransfer[msg.sender]);

        bool result = super.transfer(_to, _value);

        return result;

    }

}