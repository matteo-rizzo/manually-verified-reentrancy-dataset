/**

 *Submitted for verification at Etherscan.io on 2018-09-13

*/



pragma solidity 0.4.24;



/**

* @title SafeMath

* @dev Math operations with safety checks that throw on error

*/





/**

* @title Owned

* @dev The owned contract has an owner address, and provides basic authorization control

* functions, this simplifies the implementation of "user permissions".

*/





/**

* @title Pausable

* @dev Base contract which allows children to implement an emergency stop mechanism.

*/

contract Pausable is Owned {

    bool public paused = false;



    event Pause();

    event Unpause();



    /**

    * @dev Modifier to make a function callable only when the contract is not paused.

    */

    modifier whenNotPaused() {

        require(!paused);

        _;

    }



    /**

    * @dev Modifier to make a function callable only when the contract is paused.

    */

    modifier whenPaused() {

        require(paused);

        _;

    }



    /**

    * @dev called by the owner to pause, triggers stopped state

    */

    function pause() onlyOwner whenNotPaused public {

        paused = true;

        emit Pause();

    }



    /**

    * @dev called by the owner to unpause, returns to normal state

    */

    function unpause() onlyOwner whenPaused public {

        paused = false;

        emit Unpause();

    }

}







/******************************************/

/*       CSCToken STARTS HERE       */

/******************************************/



contract CXToken is Pausable {

    using SafeMath for uint; // use the library for uint type



    string public symbol;

    string public  name;

    uint8 public decimals = 18;

    // 18 decimals is the strongly suggested default, avoid changing it

    uint public totalSupply;



    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;

    mapping (address => bool) public frozenAccount;

    mapping (address => uint256) public frozenAmount;



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    event Burn(address indexed from, uint256 value);



    event FrozenFunds(address target, bool frozen);

    event FrozenAmt(address target, uint256 value);

    event UnfrozenAmt(address target);



    constructor(

    uint256 initialSupply,

    string tokenName,

    string tokenSymbol

    ) public {

        // Update total supply with the decimal amount

        totalSupply = initialSupply * 10 ** uint256(decimals);

        // Give the creator all initial tokens

        balanceOf[msg.sender] = totalSupply;

        // Set the name for display purposes

        name = tokenName;

        // Set the symbol for display purposes

        symbol = tokenSymbol;

    }



    /* Internal transfer, only can be called by this contract */

    function _transfer(address _from, address _to, uint _value) whenNotPaused internal {

        require (_to != 0x0);

        require(!frozenAccount[_from]);

        require(!frozenAccount[_to]);

        uint256 amount = balanceOf[_from].sub(_value);

        require(frozenAmount[_from] == 0 || amount >= frozenAmount[_from]);

        balanceOf[_from] = amount;

        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(_from, _to, _value);

    }



    /**

    * Transfer tokens

    *

    * Send `_value` tokens to `_to` from your account

    *

    * @param _to The address of the recipient

    * @param _value the amount to send

    */

    function transfer(address _to, uint256 _value)

    public

    returns (bool success) {

        _transfer(msg.sender, _to, _value);

        return true;

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

    function transferFrom(address _from, address _to, uint256 _value)

    public

    returns (bool success) {

        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

        _transfer(_from, _to, _value);

        return true;

    }



    /**

    * Set allowance for other address

    *

    * Allows `_spender` to spend no more than `_value` tokens in your behalf

    * Limited usage in case of front running attack, see: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve

    *

    * @param _spender The address authorized to spend

    * @param _value the max amount they can spend

    */

    function approve(address _spender, uint256 _value) onlyOwner

    public

    returns (bool success) {

        allowance[msg.sender][_spender] = _value;

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

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) onlyOwner

    public

    returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

    }



    /**

    * Destroy tokens

    *

    * Remove `_value` tokens from the system irreversibly

    *

    * @param _value the amount of money to burn

    */

    function burn(uint256 _value)

    public

    returns (bool success) {

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);

        totalSupply = totalSupply.sub(_value);

        emit Burn(msg.sender, _value);

        return true;

    }





    /**

    * @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens

    *

    * @param target Address to be frozen

    * @param freeze either to freeze it or not

    */

    function freezeAccount(address target, bool freeze) onlyOwner public {

        frozenAccount[target] = freeze;

        emit FrozenFunds(target, freeze);

    }



    /**

    * @notice Freeze `_value` of `target` balance

    *

    * @param target Address to be frozen amount

    * @param _value freeze amount

    */

    function freezeAmount(address target, uint256 _value) onlyOwner public {

        require(_value > 0);

        frozenAmount[target] = _value;

        emit FrozenAmt(target, _value);

    }



    /**

    * @notice Unfreeze `target` balance.

    *

    * @param target Address to be unfrozen

    */

    function unfreezeAmount(address target) onlyOwner public {

        frozenAmount[target] = 0;

        emit UnfrozenAmt(target);

    }

}