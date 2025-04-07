/**

 *Submitted for verification at Etherscan.io on 2019-04-26

*/



pragma solidity ^0.5.0;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract ERC20Interface {

     function totalSupply() public view returns (uint256);

     function balanceOf(address tokenOwner) public view returns (uint256 balance);

     function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);

     function transfer(address to, uint256 tokens) public returns (bool success);

     function approve(address spender, uint256 tokens) public returns (bool success);

     function transferFrom(address from, address to, uint256 tokens) public returns (bool success);



     event Transfer(address indexed from, address indexed to, uint256 tokens);

     event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

}



contract WeedConnect is ERC20Interface, Ownable{

     using SafeMath for uint256;



     uint256 private _totalSupply;

     mapping(address => uint256) private _balances;

     mapping(address => mapping (address => uint256)) private _allowed;



     string public constant symbol = "420";

     string public constant name = "WeedConnect";

     uint public constant decimals = 18;

     

     constructor () public {

          _totalSupply = 420000000 * (10 ** decimals);

          _balances[msg.sender] = _totalSupply;

          

          emit Transfer(address(0), msg.sender, _totalSupply);

     }



     /**

     * @dev Total number of tokens in existence

     */

     function totalSupply() public view returns (uint256) {

          return _totalSupply;

     }



     /**

     * @dev Gets the balance of the specified address.

     * @param owner The address to query the balance of.

     * @return A uint256 representing the amount owned by the passed address.

     */

     function balanceOf(address owner) public view returns (uint256) {

          return _balances[owner];

     }



     /**

     * @dev Transfer token to a specified address

     * @param to The address to transfer to.

     * @param value The amount to be transferred.

     */

     function transfer(address to, uint256 value) public returns (bool) {

          _transfer(msg.sender, to, value);

          return true;

     }



     /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     * @param spender The address which will spend the funds.

     * @param value The amount of tokens to be spent.

     */

     function approve(address spender, uint256 value) public returns (bool) {

          _approve(msg.sender, spender, value);

          return true;

     }



     /**

     * @dev Transfer tokens from one address to another.

     * @param from address The address which you want to send tokens from

     * @param to address The address which you want to transfer to

     * @param value uint256 the amount of tokens to be transferred

     */

     function transferFrom(address from, address to, uint256 value) public returns (bool) {

          _transfer(from, to, value);

          _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));

          return true;

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

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

     function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

          _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));

          return true;

     }



     /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

     function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

          _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));

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

     * @dev Approve an address to spend another addresses' tokens.

     * @param owner The address that owns the tokens.

     * @param spender The address that will spend the tokens.

     * @param value The number of tokens that can be spent.

     */

     function _approve(address owner, address spender, uint256 value) internal {

          require(spender != address(0));

          require(owner != address(0));



          _allowed[owner][spender] = value;

          emit Approval(owner, spender, value);

     }



     function () external payable {

          revert();

     }

}