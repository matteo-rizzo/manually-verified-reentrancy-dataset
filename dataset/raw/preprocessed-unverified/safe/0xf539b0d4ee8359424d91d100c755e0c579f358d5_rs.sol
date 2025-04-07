pragma solidity ^0.4.22;







/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





contract DBXCContract {

    // Public variables of the token

    string public name;

    string public symbol;

    uint8 public decimals = 18;

    // 18 decimals is the strongly suggested default, avoid changing it

    uint256 public totalSupply;



    // This creates an array with all balances

    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowed;



    // This generates a public event on the blockchain that will notify clients

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);



    /**

     * Constructor function

     *

     * Initializes contract with initial supply tokens to the creator of the contract

     */

    constructor(

        uint256 initialSupply,

        string tokenName,

        string tokenSymbol

    ) public {

        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount

        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens

        name = tokenName;                                   // Set the name for display purposes

        symbol = tokenSymbol;                               // Set the symbol for display purposes

    }



    /**

     * Internal transfer, only can be called by this contract

     */

    function _transfer(address _from, address _to, uint256 _value) internal {

        // Prevent transfer to 0x0 address. Use burn() instead

        require(_to != address(0x0));

        // Check if the sender has enough

        require(balanceOf[_from] >= _value);

        // Check for overflows

        require(balanceOf[_to] + _value >= balanceOf[_to]);

        // Save this for an assertion in the future

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        // Subtract from the sender

        balanceOf[_from] -= _value;

        // Add the same to the recipient

        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);

        // Asserts are used to use static analysis to find bugs in your code. They should never fail

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }



    /**

     * Transfer tokens

     *

     * Send `_value` tokens to `_to` from your account

     *

     * @param _to The address of the recipient

     * @param _value the amount to send

     */

    function transfer(address _to, uint256 _value) public returns (bool success) {

        _transfer(msg.sender, _to, _value);

        return true;

    }



    /**

     * Transfer tokens from other address

     *

     * Send `_value` tokens to `_to` on behalf of `_from`

     *

     * @param _from The address of the sender

     * @param _to The address of the recipient

     * @param _value the amount to send

     */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= allowed[_from][msg.sender]);     // Check allowance

        allowed[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;

    }



    /**

     * IncreaseApproval

     *

     * @param _spender The address authorized to spend

     * @param _addedValue the added amount

     */

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

        allowed[msg.sender][_spender] = SafeMath.add(allowed[msg.sender][_spender],_addedValue);

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }



    /**

     * DecreaseApproval

     *

     * @param _spender The address authorized to spend

     * @param _subtractedValue the subtracted amount

     */

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

        uint oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {

            allowed[msg.sender][_spender] = 0;

        } else {

            allowed[msg.sender][_spender] = SafeMath.sub(oldValue, _subtractedValue);

        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }



    /**

     * Get allowance 

     *

     */

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }



    /* Allow another contract to spend some tokens in your behalf */

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;     

        tokenRecipient spender = tokenRecipient(_spender);

        spender.receiveApproval(msg.sender, _value, this, _extraData); 

        return true; 

    }

}