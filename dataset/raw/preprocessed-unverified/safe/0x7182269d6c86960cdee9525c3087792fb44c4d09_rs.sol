/**
 *Submitted for verification at Etherscan.io on 2021-03-30
*/

pragma solidity ^0.4.24;

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title Template token that can be purchased
 * @dev World's smallest crowd sale
 */
contract HashLipsToken is ERC20Basic, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;
 
  string public constant name = "HashLips";
  string public constant symbol = "HLPS";
  uint8 public constant decimals = 18;  // 18 is the most common number of decimal places
 
  constructor() public {  
balances[0xde3b22caaad25e65c839c2a3d852d665669edd5c] = 500000000000000000000000000;
balances[0xc1B368E83147309eEb030e453bBc97Ffb19927B1] = 500000000000000000000000000;
    }  

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token to a specified address
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
 
  /**
  * @dev This sells 1000 tokens in exchange for 1 ether
  */
  function () public payable {
      uint256 amount = msg.value.mul(100000);
      balances[msg.sender] = balances[msg.sender].add(amount);
      totalSupply_ = totalSupply_.add(amount);
      owner.transfer(msg.value);
      emit Transfer(0x0, msg.sender, amount);
  }
}