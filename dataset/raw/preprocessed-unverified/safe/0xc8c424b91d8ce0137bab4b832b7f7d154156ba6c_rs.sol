/**

 *Submitted for verification at Etherscan.io on 2019-04-15

*/



pragma solidity ^0.5.7;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood:

 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 *

 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for

 * all accounts just by listening to said events. Note that this isn't required by the specification, and other

 * compliant implementations may not do it.

 */

contract ERC20 is IERC20 {

    using SafeMath for uint256;



    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowed;



    uint256 private _totalSupply;



    /**

    * @dev Total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param owner The address to query the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param owner address The address which owns the funds.

     * @param spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];

    }



    /**

    * @dev Transfer token for a specified address

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

    }



    /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param spender The address which will spend the funds.

     * @param value The amount of tokens to be spent.

     */

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



    /**

     * @dev Transfer tokens from one address to another.

     * Note that while this function emits an Approval event, this is not required as per the specification,

     * and other compliant implementations may not emit the event.

     * @param from address The address which you want to send tokens from

     * @param to address The address which you want to transfer to

     * @param value uint256 the amount of tokens to be transferred

     */

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        emit Approval(from, msg.sender, _allowed[from][msg.sender]);

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

    * @dev Transfer token for a specified addresses

    * @param from The address to transfer from.

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }



    /**

     * @dev Internal function that mints an amount of the token and assigns it to

     * an account. This encapsulates the modification of balances such that the

     * proper events are emitted.

     * @param account The account that will receive the created tokens.

     * @param value The amount that will be created.

     */

    function _mint(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.add(value);

        _balances[account] = _balances[account].add(value);

        emit Transfer(address(0), account, value);

    }



    function _burn(address account, uint256 value) internal {

      _totalSupply = _totalSupply.sub(value);

      _balances[account] = _balances[account].sub(value);

      emit Transfer(account, address(0), value);

    }



}



contract Pausable is Ownable{

    event Paused();

    event Unpaused();



    bool private _paused;



    function paused() public view returns (bool) {

        return _paused;

    }



    modifier whenNotPaused() {

       require(!_paused);

       _;

   }



   modifier whenPaused() {

       require(_paused);

       _;

   }



   function pause() public onlyOwner whenNotPaused {

        _paused = true;

        emit Paused();

    }



    function unpause() public onlyOwner whenPaused {

        _paused = false;

        emit Unpaused();

    }



}



contract Apmcoin is ERC20, Ownable, Pausable{



    string public constant name = "APM Coin";

    string public constant symbol = "APM";

    uint8 public constant decimals = 18;



    event ClaimedTokens(address indexed owner, address indexed _token, uint256 claimedBalance);

    event RegisterBlacklist(address indexed account);

    event UnregisterBlacklist(address indexed account);



    mapping (address => bool) private blacklist;



    constructor (uint256 initialBalance) public {

        uint256 _initialBalance = initialBalance;

        _mint(msg.sender, _initialBalance);

    }



    function _transfer(address from, address to, uint256 value) whenNotPaused internal {

        require(!isBlacklist(from) && !isBlacklist(to));

        return super._transfer(from, to, value);

    }



    function mint(address account, uint256 amount) onlyOwner public {

        _mint(account, amount);

    }



    function burn(uint256 amount) onlyOwner public {

        _burn(msg.sender, amount);

    }



    function isBlacklist(address account) public view returns (bool) {

        return blacklist[account];

    }



    function registerBlacklist(address account) onlyOwner public {

        blacklist[account] = true;

        emit RegisterBlacklist(account);

    }



    function unregisterBlacklist(address account) onlyOwner public {

        blacklist[account] = false;

        emit UnregisterBlacklist(account);

    }



    function claimTokens(address _token, uint256 _claimedBalance) public onlyOwner {

        IERC20 token = IERC20(_token);

        address thisAddress = address(this);

        uint256 tokenBalance = token.balanceOf(thisAddress);

        require(tokenBalance >= _claimedBalance);



        address owner = msg.sender;

        token.transfer(owner, _claimedBalance);

        emit ClaimedTokens(owner, _token, _claimedBalance);

    }

}