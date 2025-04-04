/**

 *Submitted for verification at Etherscan.io on 2018-09-03

*/



pragma solidity ^0.4.21;

/** ----------------------------------------------------------------------------------------------

 * Zeniex x Genesis Fund Token.

 * An ERC20 standard

 *

 * author: To be issued under Genesis's Cayman entity

 */



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error.

 */







contract ERC20 {



    uint256 public totalSupply;



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);



    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);



    function allowance(address owner, address spender) public view returns (uint256);

    function approve(address spender, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);



}

















contract TokenERC20 is ERC20, Ownable{

    // Public variables of the token

    string public name;

    string public symbol;

    uint8  public decimals = 18;

    // 18 decimals is the strongly suggested default, avoid changing it

    using SafeMath for uint256;

    // Balances

    mapping (address => uint256) balances;

    // Allowances

    mapping (address => mapping (address => uint256)) allowances;





    // ----- Events -----

    event Burn(address indexed from, uint256 value);





    /**

     * Constructor function

     */

    function TokenERC20(uint256 _initialSupply, string _tokenName, string _tokenSymbol, uint8 _decimals) public {

        name = _tokenName;                                   // Set the name for display purposes

        symbol = _tokenSymbol;                               // Set the symbol for display purposes

        decimals = _decimals;



        totalSupply = _initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount

        balances[msg.sender] = totalSupply;                // Give the creator all initial tokens

    }



        /**

     * @dev Fix for the ERC20 short address attack.

     */

    modifier onlyPayloadSize(uint size) {

      if(msg.data.length < size.add(4)) {

        revert();

      }

      _;

    }

    



    function balanceOf(address _owner) public view returns(uint256) {

        return balances[_owner];

    }



    function allowance(address _owner, address _spender) public view returns (uint256) {

        return allowances[_owner][_spender];

    }



    /**

     * Internal transfer, only can be called by this contract

     */

    function _transfer(address _from, address _to, uint _value) internal returns(bool) {

        // Prevent transfer to 0x0 address. Use burn() instead

        require(_to != 0x0);

        // Check if the sender has enough

        require(balances[_from] >= _value);

        // Check for overflows

        require(balances[_to].add(_value) > balances[_to]);



        require(_value >= 0);

        // Save this for an assertion in the future

        uint previousBalances = balances[_from].add(balances[_to]);

         // SafeMath.sub will throw if there is not enough balance.

        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        // Asserts are used to use static analysis to find bugs in your code. They should never fail

        assert(balances[_from].add(balances[_to]) == previousBalances);



        return true;

    }



    /**

     * Transfer tokens

     *

     * Send `_value` tokens to `_to` from your account

     *

     * @param _to The address of the recipient

     * @param _value the amount to send

     */

    function transfer(address _to, uint256 _value) public returns(bool) {

        return _transfer(msg.sender, _to, _value);

    }



    /**

     * Transfer tokens from other address

     *

     * Send `_value` tokens to `_to` in behalf of `_from`

     *

     * @param _from The address of the sender

     * @param _to The address of the recipient

     * @param _value the amount to send

     */

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {

        require(_to != address(0));

        require(_value <= balances[_from]);

        require(_value > 0);



        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }



    /**

     * Set allowance for other address

     *

     * Allows `_spender` to spend no more than `_value` tokens in your behalf

     *

     * @param _spender The address authorized to spend

     * @param _value the max amount they can spend

     */

    function approve(address _spender, uint256 _value) public returns(bool) {

        require((_value == 0) || (allowances[msg.sender][_spender] == 0));

        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    /**

     * Set allowance for other address and notify

     *

     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it

     *

     * @param _spender The address authorized to spend

     * @param _value the max amount they can spend

     * @param _extraData some extra information to send to the approved contract

     */

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns(bool) {

        if (approve(_spender, _value)) {

            TokenRecipient spender = TokenRecipient(_spender);

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

        return false;

    }





  /**

   * @dev Transfer tokens to multiple addresses

   * @param _addresses The addresses that will receieve tokens

   * @param _amounts The quantity of tokens that will be transferred

   * @return True if the tokens are transferred correctly

   */

  function transferForMultiAddresses(address[] _addresses, uint256[] _amounts)  public returns (bool) {

    for (uint256 i = 0; i < _addresses.length; i++) {

      require(_addresses[i] != address(0));

      require(_amounts[i] <= balances[msg.sender]);

      require(_amounts[i] > 0);



      // SafeMath.sub will throw if there is not enough balance.

      balances[msg.sender] = balances[msg.sender].sub(_amounts[i]);

      balances[_addresses[i]] = balances[_addresses[i]].add(_amounts[i]);

      emit Transfer(msg.sender, _addresses[i], _amounts[i]);

    }

    return true;

  }



    /**

     * Destroy tokens

     *

     * Remove `_value` tokens from the system irreversibly

     *

     * @param _value the amount of money to burn

     */

    function burn(uint256 _value) public returns(bool) {

        require(balances[msg.sender] >= _value);   // Check if the sender has enough

        balances[msg.sender] = balances[msg.sender].sub(_value);            // Subtract from the sender

        totalSupply = totalSupply.sub(_value);                      // Updates totalSupply

        emit Burn(msg.sender, _value);

        return true;

    }



        /**

     * Destroy tokens from other account

     *

     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.

     *

     * @param _from the address of the sender

     * @param _value the amount of money to burn

     */

    function burnFrom(address _from, uint256 _value) public returns(bool) {

        require(balances[_from] >= _value);                // Check if the targeted balance is enough

        require(_value <= allowances[_from][msg.sender]);    // Check allowance

        balances[_from] = balances[_from].sub(_value);                         // Subtract from the targeted balance

        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);             // Subtract from the sender's allowance

        totalSupply = totalSupply.sub(_value);                                 // Update totalSupply

        emit Burn(_from, _value);

        return true;

    }





    /**

     * approve should be called when allowances[_spender] == 0. To increment

     * allowances value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     */

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

        // Check for overflows

        require(allowances[msg.sender][_spender].add(_addedValue) > allowances[msg.sender][_spender]);



        allowances[msg.sender][_spender] =allowances[msg.sender][_spender].add(_addedValue);

        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);

        return true;

    }



    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

        uint oldValue = allowances[msg.sender][_spender];

        if (_subtractedValue > oldValue) {

            allowances[msg.sender][_spender] = 0;

        } else {

            allowances[msg.sender][_spender] = oldValue.sub(_subtractedValue);

        }

        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);

        return true;

    }





}





contract ZXGToken is TokenERC20 {



    function ZXGToken() TokenERC20(20000000, "Zeniex x Genesis Fund Token", "ZXG", 18) public {



    }

    

    function () payable public {

      //if ether is sent to this address, send it back.

      //throw;

      require(false);

    }

}