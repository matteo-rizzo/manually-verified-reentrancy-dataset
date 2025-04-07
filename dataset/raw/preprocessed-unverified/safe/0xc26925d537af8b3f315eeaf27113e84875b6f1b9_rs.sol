pragma solidity ^0.4.13;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) constant returns (uint256);

  function transfer(address to, uint256 value) returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}





/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances. 

 */

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



  /**

  * @dev transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) returns (bool) {

    require(_to != address(0));



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



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) constant returns (uint256);

  function transferFrom(address from, address to, uint256 value) returns (bool);

  function approve(address spender, uint256 value) returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * @dev https://github.com/ethereum/EIPs/issues/20

 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) allowed;





  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {

    require(_to != address(0));



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

  

  /**

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until 

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   */

  function increaseApproval (address _spender, uint _addedValue) 

    returns (bool success) {

    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



  function decreaseApproval (address _spender, uint _subtractedValue) 

    returns (bool success) {

    uint oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}



/**

 * §´§à§Ü§Ö§ß §á§â§à§Õ§Ñ§Ø

 *

 * ERC-20 §ä§à§Ü§Ö§ß

 *

 */



contract SaleToken is StandardToken, Ownable {

    using SafeMath for uint;



    /* §°§á§Ú§ã§Ñ§ß§Ú§Ö §ã§Þ. §Ó §Ü§à§ß§ã§ä§â§å§Ü§ä§à§â§Ö */

    string public name;



    string public symbol;



    uint public decimals;



    address public mintAgent;



    /** §³§à§Ò§í§ä§Ú§Ö §à§Ò§ß§à§Ó§Ý§Ö§ß§Ú§ñ §ä§à§Ü§Ö§ß§Ñ (§Ú§Þ§ñ §Ú §ã§Ú§Þ§Ó§à§Ý) */

    event UpdatedTokenInformation(string newName, string newSymbol);



    /**

     * §¬§à§ß§ã§ä§â§å§Ü§ä§à§â

     *

     * @param _name - §Ú§Þ§ñ §ä§à§Ü§Ö§ß§Ñ

     * @param _symbol - §ã§Ú§Þ§Ó§à§Ý §ä§à§Ü§Ö§ß§Ñ

     * @param _decimals - §Ü§à§Ý-§Ó§à §Ù§ß§Ñ§Ü§à§Ó §á§à§ã§Ý§Ö §Ù§Ñ§á§ñ§ä§à§Û

     */

    function SaleToken(string _name, string _symbol, uint _decimals) {

        name = _name;

        symbol = _symbol;



        decimals = _decimals;

    }



    /**

     * §®§à§Ø§Ö§ä §Ó§í§Ù§Ó§Ñ§ä§î §ä§à§Ý§î§Ü§à §Ñ§Ô§Ö§ß§ä

     */

    function mint(uint amount) public onlyMintAgent {

        balances[mintAgent] = balances[mintAgent].add(amount);



        totalSupply = balances[mintAgent];

    }



    /**

     * §£§Ý§Ñ§Õ§Ö§Ý§Ö§è §Þ§à§Ø§Ö§ä §à§Ò§ß§à§Ó§Ú§ä§î §Ú§ß§æ§å §á§à §ä§à§Ü§Ö§ß§å

     */

    function setTokenInformation(string _name, string _symbol) external onlyOwner {

        name = _name;

        symbol = _symbol;



        // §£§í§Ù§í§Ó§Ñ§Ö§Þ §ã§à§Ò§í§ä§Ú§Ö

        UpdatedTokenInformation(name, symbol);

    }



    /**

     * §®§à§Ø§Ö§ä §Ó§í§Ù§Ó§Ñ§ä§î §ä§à§Ý§î§Ü§à §Ó§Ý§Ñ§Õ§Ö§Ý§Ö§è

     * §µ§ã§ä§Ñ§ß§à§Ó§Ú§ä§î §Þ§à§Ø§ß§à §ä§à§Ý§î§Ü§à 1 §â§Ñ§Ù

     */

    function setMintAgent(address mintAgentAddress) external emptyMintAgent onlyOwner {

        mintAgent = mintAgentAddress;

    }



    /**

     * §®§à§Õ§Ú§æ§Ú§Ü§Ñ§ä§à§â§í

     */

    modifier onlyMintAgent() {

        require(msg.sender == mintAgent);

        _;

    }



    modifier emptyMintAgent() {

        require(mintAgent == 0);

        _;

    }



}