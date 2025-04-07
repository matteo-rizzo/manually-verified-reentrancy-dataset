/**

 *Submitted for verification at Etherscan.io on 2019-03-13

*/



pragma solidity ^0.4.18;





 

 









/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) constant public returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) tokenBalances;



  /**

  * @dev transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(tokenBalances[msg.sender]>=_value);

    tokenBalances[msg.sender] = tokenBalances[msg.sender].sub(_value);

    tokenBalances[_to] = tokenBalances[_to].add(_value);

    Transfer(msg.sender, _to, _value);

    return true;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) constant public returns (uint256 balance) {

    return tokenBalances[_owner];

  }



}

//TODO: Change the name of the token

contract Arm is BasicToken,Ownable {



   using SafeMath for uint256;

   

   //TODO: Change the name and the symbol

   string public constant name = "Arbitrage Machine";

   string public constant symbol = "ARM";

   uint256 public constant decimals = 18;



   uint256 public constant INITIAL_SUPPLY = 10000000 * 10 ** 18;

   event Debug(string message, address addr, uint256 number);

  /**

   * @dev Contructor that gives msg.sender all of existing tokens.

   */

   //TODO: Change the name of the constructor

    function Arm(address wallet) public {

        owner = msg.sender;

        totalSupply = INITIAL_SUPPLY;

        tokenBalances[wallet] = INITIAL_SUPPLY;   

    }



  

  function showMyTokenBalance(address addr) public view returns (uint tokenBalance) {

        tokenBalance = tokenBalances[addr];

    }

}