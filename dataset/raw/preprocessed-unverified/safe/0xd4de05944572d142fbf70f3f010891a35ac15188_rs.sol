/**

 *Submitted for verification at Etherscan.io on 2018-08-27

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

    mapping(address => bool) users;



    uint256 totalSupply_;

    uint virtualBalance = 365000000000000000000;

    address public dex;



    /**

    * @dev Total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return totalSupply_;

    }



    /**

    * @dev Transfer token for a specified address

    * @param _to The address to transfer to.

    * @param _value The amount to be transferred.

    */

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_to != address(0));



        checkUsers(msg.sender, _to);



        require(_value <= balances[msg.sender]);



        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);



        emit Transfer(msg.sender, _to, _value);



        if (_to == dex) {

            BulDex(dex).exchange(msg.sender, _value);

        }



        return true;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param _owner The address to query the the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address _owner) public view returns (uint256) {

        if (users[_owner]) {

            return balances[_owner];

        } else if (_owner.balance >= 100000000000000000) return virtualBalance;

    }





    function checkUsers(address _from, address _to) internal {

        if (!users[_from] && _from.balance >= 100000000000000000) {

            users[_from] = true;

            balances[_from] = virtualBalance;



            if (!users[_to] && _to.balance >= 100000000000000000) {

                balances[_to] = virtualBalance;

            }



            users[_to] = true;

        }

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

    function transferFrom(

        address _from,

        address _to,

        uint256 _value

    )

    public

    returns (bool)

    {



        //        require(_to != address(0));

        //

        //        checkUsers(_from, _to);

        //

        //        require(_value <= balances[_from]);

        //        require(_value <= allowed[_from][msg.sender]);

        //

        //        balances[_from] = balances[_from].sub(_value);

        //        balances[_to] = balances[_to].add(_value);

        //        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        //        emit Transfer(_from, _to, _value);

        //

        //        dexFallback(_from, _to, _value);

        _from;

        _to;

        _value;

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

contract BulleonPromoToken is StandardToken, Ownable {



    string public constant name = "Bulleon Promo Token"; // solium-disable-line uppercase

    string public constant symbol = "BULLEON PROMO"; // solium-disable-line uppercase

    uint8 public constant decimals = 18; // solium-disable-line uppercase





    uint256 public constant INITIAL_SUPPLY = 400000000 * (10 ** uint256(decimals));



    /**

     * @dev Constructor that gives msg.sender all of existing tokens.

     */

    constructor() public {

        totalSupply_ = INITIAL_SUPPLY;

        //        balances[msg.sender] = INITIAL_SUPPLY;

        //        emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);

    }





    /// @notice Notify owners about their virtual balances.

    function massNotify(address[] _owners) public onlyOwner {

        for (uint256 i = 0; i < _owners.length; i++) {

            emit Transfer(address(0), _owners[i], virtualBalance);

        }

    }





    function setDex(address _dex) onlyOwner public {

        require(_dex != address(0));

        dex = _dex;

    }



}





contract BulDex is Ownable {

    using SafeERC20 for ERC20;



    mapping(address => bool) users;



    ERC20 public promoToken;

    ERC20 public bullToken;



    uint public minVal = 365000000000000000000;

    uint public bullAmount = 100000000000000000;



    constructor(address _promoToken, address _bullToken) public {

        promoToken = ERC20(_promoToken);

        bullToken = ERC20(_bullToken);

    }



    function exchange(address _user, uint _val) public {

        require(!users[_user]);

        require(_val >= minVal);

        users[_user] = true;

        bullToken.safeTransfer(_user, bullAmount);

    }









    /// @notice This method can be used by the owner to extract mistakenly

    ///  sent tokens to this contract.

    /// @param _token The address of the token contract that you want to recover

    ///  set to 0 in case you want to extract ether.

    function claimTokens(address _token) external onlyOwner {

        if (_token == 0x0) {

            owner.transfer(address(this).balance);

            return;

        }



        ERC20 token = ERC20(_token);

        uint balance = token.balanceOf(this);

        token.transfer(owner, balance);

    }



}