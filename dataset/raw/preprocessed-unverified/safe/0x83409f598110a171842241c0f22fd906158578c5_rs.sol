/**

 *Submitted for verification at Etherscan.io on 2018-09-14

*/



pragma solidity ^0.4.18;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract VIDI7Token is Ownable, ERC20Basic {

  using SafeMath for uint256;



  string public constant name     = "Vidion token";

  string public constant symbol   = "VIDI7";

  uint8  public constant decimals = 18;



  bool public mintingFinished = false;



  mapping(address => uint256) public balances;

  address[] public holders;



  event Mint(address indexed to, uint256 amount);

  event MintFinished();



  /**

  * @dev Function to mint tokens

  * @param _to The address that will receive the minted tokens.

  * @param _amount The amount of tokens to mint.

  * @return A boolean that indicates if the operation was successful.

  */

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {

    totalSupply = totalSupply.add(_amount);

    if (balances[_to] == 0) { 

      holders.push(_to);

    }

    balances[_to] = balances[_to].add(_amount);



    Mint(_to, _amount);

    Transfer(address(0), _to, _amount);

    return true;

  }



  /**

  * @dev Function to stop minting new tokens.

  * @return True if the operation was successful.

  */

  function finishMinting() onlyOwner canMint public returns (bool) {

    mintingFinished = true;

    MintFinished();

    return true;

  }



  /**

  * @dev Current token is not transferred.

  * After start official token sale VIDI, you can exchange your tokens

  */

  function transfer(address, uint256) public returns (bool) {

    revert();

    return false;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) public view returns (uint256 balance) {

    return balances[_owner];

  }



  modifier canMint() {

    require(!mintingFinished);

    _;

  }

}