pragma solidity ^0.4.21;







/**

 * @title Owned Interface

 * @dev Owned is interface for owner contract

 */







/**

 * @title InitialTestMT Interface

 * @dev InitialTestMT is a token ERC20 contract for TestMT (TestMT.com)

 */



contract ITestMTInterface is Owned {



    /** total amount of tokens **/

    uint256 public totalSupply;



    /** 

     * @param _owner The address from which the balance will be retrieved

     * @return The balance

    **/

    

    function balanceOf(address _owner) public view returns (uint256 balance);





    

    /** @notice send `_value` token to `_to` from `msg.sender`

     * @param _to The address of the recipient

     * @param _value The amount of token to be transferred

     * @return Whether the transfer was successful or not

    **/

     

    function transfer(address _to, uint256 _value) public returns (bool success);



    /** 

     * @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`

     * @param _from The address of the sender

     * @param _to The address of the recipient

     * @param _value The amount of token to be transferred

     * @return Whether the transfer was successful or not

     **/

     

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);



    /**

     * @notice `msg.sender` approves `_spender` to spend `_value` tokens

     * @param _spender The address of the account able to transfer the tokens

     * @param _value The amount of tokens to be approved for transfer

     * @return Whether the approval was successful or not

     **/

     

    function approve(address _spender, uint256 _value) public returns (bool success);



    /** @param _owner The address of the account owning tokens

     * @param _spender The address of the account able to transfer the tokens

     * @return Amount of remaining tokens allowed to spent

     **/

 

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    

    // solhint-disable-next-line no-simple-event-func-name  

    event Transfer(address indexed _from, address indexed _to, uint256 _value); 

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

   

}



/**

 * @title InitialTestMT

 * @dev InitialTestMT is a token ERC20 contract for TestMT (TestMT.com)

 */

contract InitialTestMT is ITestMTInterface {

    

    using SafeMath for uint256;

    

    mapping (address => uint256) public balances;

    mapping (address => mapping (address => uint256)) public allowed;







    //specific events

    event Burn(address indexed burner, uint256 value);



    

    string public name;                   //Initial Money Token

    uint8 public decimals;                //18

    string public symbol;                 //IMT

    

    constructor (

        uint256 _initialAmount,

        string _tokenName,

        uint8 _decimalUnits,

        string _tokenSymbol

    ) public {



        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens

        totalSupply = _initialAmount;                        // Update total supply

        name = _tokenName;                                   // Set the name for display purposes

        decimals = _decimalUnits;                            // Amount of decimals for display purposes

        symbol = _tokenSymbol;                               // Set the symbol for display purposes    

    }

    

    

    function transfer(address _to, uint256 _value)  public returns (bool success) {

        _transfer(msg.sender, _to, _value);

        return true;

    }

    

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        _transferFrom(msg.sender, _from, _to, _value);

        return true;

    }



    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];

    }

    

    

    function burn(uint256 _value) public onlyOwner returns (bool success) {

       _burn(msg.sender, _value);

       return true;      

    }



    function approve(address _spender, uint256 _value) public returns (bool success) {

        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }   



     /** 

       * Specific functins for contract

     **/

        

    //resend any tokens

    function transferAnyERC20Token(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success){

        return ITestMTInterface(tokenAddress).transfer(owner, tokens);

    }



    /** 

      * internal functions

    **/

    

    

    //burn function

    function _burn(address _who, uint256 _value) internal returns (bool success) {

     

        balances[_who] = balances[_who].sub(_value);

        totalSupply = totalSupply.sub(_value);

        emit Burn(_who, _value);

        emit Transfer(_who, address(0), _value);



        return true;

    }



    function _transfer(address _from, address _to, uint256 _value) internal  returns (bool success) {

         

        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        

        return true;

    }



    function _transferFrom(address _who, address _from, address _to, uint256 _value) internal returns (bool success) {

        

        uint256 allow = allowed[_from][_who];

        require(balances[_from] >= _value && allow >= _value);



        balances[_to] = balances[_to].add(_value);

        balances[_from] = balances[_from].sub(_value);

        allowed[_from][_who] = allowed[_from][_who].sub(_value);

        

        emit Transfer(_from, _to, _value);

        

        return true;

    }

}