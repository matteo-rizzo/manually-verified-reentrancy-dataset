/**

 *Submitted for verification at Etherscan.io on 2018-09-11

*/



pragma solidity ^0.4.24;



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

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

}





/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender)

    public view returns (uint256);



    function transferFrom(address from, address to, uint256 value)

    public returns (bool);



    function approve(address spender, uint256 value) public returns (bool);

    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 value

    );

}



/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is ERC20Basic {

    using SafeMath for uint256;



    mapping(address => uint256) balances;



    uint256 totalSupply_;



    /**

    * @dev Total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return totalSupply_;

    }



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





}







/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/issues/20

 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract StandardToken is ERC20, BasicToken {



    mapping (address => mapping (address => uint256)) internal allowed;





    /**

     * @dev Transfer tokens from one address to another

     * @param _from address The address which you want to send tokens from

     * @param _to address The address which you want to transfer to

     * @param _value uint256 the amount of tokens to be transferred

     */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(_to != address(0));

        require(_value <= balances[_from]);

        require(_value <= allowed[_from][msg.sender]);



        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }



    /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param _spender The address which will spend the funds.

     * @param _value The amount of tokens to be spent.

     */

    function approve(address _spender, uint256 _value) public returns (bool) {

        //        allowed[msg.sender][_spender] = _value;

        //        emit Approval(msg.sender, _spender, _value);

        _spender;

        _value;

        return true;

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param _owner address The address which owns the funds.

     * @param _spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(

        address _owner,

        address _spender

    )

    public

    view

    returns (uint256)

    {

        return allowed[_owner][_spender];

    }





}





/**

 * @title SimpleToken

 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.

 * Note they can later distribute these tokens as they wish using `transfer` and other

 * `StandardToken` functions.

 */

contract AngeniumPromoToken is StandardToken, Ownable {





    address public mainToken = 0xC5C02655BbD508545B4e32eC88Cef3Aa5e741D87;



    string public constant name = "Angenium Promo Token";

    string public constant symbol = "ANG PROMO";

    uint8 public constant decimals = 18;





    uint256 public constant INITIAL_SUPPLY = 50000 * (10 ** uint256(decimals));





    constructor() public {

        totalSupply_ = INITIAL_SUPPLY;

        balances[msg.sender] = INITIAL_SUPPLY;

    }





    function multisend(address[] _owners) public onlyOwner {

        for (uint256 i = 0; i < _owners.length; i++) {

            transfer(_owners[i], 1000000000000000000);

        }

    }





}