pragma solidity ^0.4.17;



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

   * From MonolithDAO ImpToken.sol

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



























contract ValidationUtil {

    function requireNotEmptyAddress(address value){

        require(isAddressNotEmpty(value));

    }



    function isAddressNotEmpty(address value) internal returns (bool result){

        return value != 0;

    }

}

























/**

 * §¬§à§ß§ä§â§Ñ§Ü§ä ERC-20 §ä§à§Ü§Ö§ß§Ñ

 */



contract ImpToken is StandardToken, Ownable {

    using SafeMath for uint;



    string public name;

    string public symbol;

    uint public decimals;

    bool public isDistributed;

    uint public distributedAmount;



    event UpdatedTokenInformation(string name, string symbol);



    /**

     * §¬§à§ß§ã§ä§â§å§Ü§ä§à§â

     *

     * @param _name - §Ú§Þ§ñ §ä§à§Ü§Ö§ß§Ñ

     * @param _symbol - §ã§Ú§Þ§Ó§à§Ý §ä§à§Ü§Ö§ß§Ñ

     * @param _totalSupply - §ã§à §ã§Ü§à§Ý§î§Ü§Ú§Þ§Ú §ä§à§Ü§Ö§ß§Ñ§Þ§Ú §Þ§í §ã§ä§Ñ§â§ä§å§Ö§Þ

     * @param _decimals - §Ü§à§Ý-§Ó§à §Ù§ß§Ñ§Ü§à§Ó §á§à§ã§Ý§Ö §Ù§Ñ§á§ñ§ä§à§Û

     */

    function ImpToken(string _name, string _symbol, uint _totalSupply, uint _decimals) {

        require(_totalSupply != 0);



        name = _name;

        symbol = _symbol;

        decimals = _decimals;



        totalSupply = _totalSupply;

    }



    /**

     * §£§Ý§Ñ§Õ§Ö§Ý§Ö§è §Õ§à§Ý§Ø§Ö§ß §Ó§í§Ù§Ó§Ñ§ä§î §ï§ä§å §æ§å§ß§Ü§è§Ú§ð, §é§ä§à§Ò§í §ã§Õ§Ö§Ý§Ñ§ä§î §ß§Ñ§é§Ñ§Ý§î§ß§à§Ö §â§Ñ§ã§á§â§Ö§Õ§Ö§Ý§Ö§ß§Ú§Ö §ä§à§Ü§Ö§ß§à§Ó

     */

    function distribute(address toAddress, uint tokenAmount) external onlyOwner {

        require(!isDistributed);



        balances[toAddress] = tokenAmount;



        distributedAmount = distributedAmount.add(tokenAmount);



        require(distributedAmount <= totalSupply);

    }



    function closeDistribution() external onlyOwner {

        require(!isDistributed);



        isDistributed = true;

    }



    /**

     * §£§Ý§Ñ§Õ§Ö§Ý§Ö§è §Þ§à§Ø§Ö§ä §à§Ò§ß§à§Ó§Ú§ä§î §Ú§ß§æ§å §á§à §ä§à§Ü§Ö§ß§å

     */

    function setTokenInformation(string newName, string newSymbol) external onlyOwner {

        name = newName;

        symbol = newSymbol;



        // §£§í§Ù§í§Ó§Ñ§Ö§Þ §ã§à§Ò§í§ä§Ú§Ö

        UpdatedTokenInformation(name, symbol);

    }



    /**

     * §£§Ý§Ñ§Õ§Ö§Ý§Ö§è §Þ§à§Ø§Ö§ä §á§à§Þ§Ö§ß§ñ§ä§î decimals

     */

    function setDecimals(uint newDecimals) external onlyOwner {

        decimals = newDecimals;

    }

}













contract ImpCore is Ownable, ValidationUtil {

    using SafeMath for uint;

    using ECRecovery for bytes32;



    /* §´§à§Ü§Ö§ß, §ã §Ü§à§ä§à§â§í§Þ §â§Ñ§Ò§à§ä§Ñ§Ö§Þ */

    ImpToken public token;



    /* §®§Ñ§á§Ñ §Ñ§Õ§â§Ö§ã §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ñ §ä§à§Ü§Ö§ß§à§Ó - nonce, §ß§å§Ø§ß§à §Õ§Ý§ñ §ä§à§Ô§à, §é§ä§à§Ò§í §ß§Ö§Ý§î§Ù§ñ §Ò§í§Ý§à §á§à§Ó§ä§à§â§ß§à §Ù§Ñ§á§â§à§ã§Ú§ä§î withdraw */

    mapping (address => uint) private withdrawalsNonce;



    event Withdraw(address receiver, uint tokenAmount);

    event WithdrawCanceled(address receiver);



    function ImpCore(address _token) {

        requireNotEmptyAddress(_token);



        token = ImpToken(_token);

    }



    function withdraw(uint tokenAmount, bytes signedData) external {

        uint256 nonce = withdrawalsNonce[msg.sender] + 1;



        bytes32 validatingHash = keccak256(msg.sender, tokenAmount, nonce);



        // §±§à§Õ§á§Ú§ã§í§Ó§Ñ§ä§î §Ó§ã§Ö §ä§â§Ñ§ß§Ù§Ñ§Ü§è§Ú§Ú §Õ§à§Ý§Ø§Ö§ß owner

        address addressRecovered = validatingHash.recover(signedData);



        require(addressRecovered == owner);



        // §¥§Ö§Ý§Ñ§Ö§Þ §á§Ö§â§Ö§Ó§à§Õ §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ð

        require(token.transfer(msg.sender, tokenAmount));



        withdrawalsNonce[msg.sender] = nonce;



        Withdraw(msg.sender, tokenAmount);

    }



    function cancelWithdraw() external {

        withdrawalsNonce[msg.sender]++;



        WithdrawCanceled(msg.sender);

    }





}