/**

 *Submitted for verification at Etherscan.io on 2018-09-13

*/



pragma solidity ^0.4.24;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */







/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */













contract Mortal is Owned {

    // This contract inherits the `onlyOwner` modifier from

    // `owned` and applies it to the `close` function, which

    // causes that calls to `close` only have an effect if

    // they are made by the stored owner.

    function close() public onlyOwner {

        selfdestruct(owner);

    }

}





contract Angelium is IERC20, Mortal {

    using SafeMath for uint256;

    

    mapping (address => uint256) private _balances;

    

    mapping (address => mapping (address => uint256)) private _allowed;

    

    uint256 private _totalSupply;

    string public symbol;

    string public  name;

    uint8 public decimals;

    

    constructor() public {

        symbol = "ANL";

        name = "ANGELIUM";

        decimals = 8;

        _totalSupply = 8400000000 * 10**uint(decimals);

        _balances[owner] = _totalSupply;

        emit Transfer(address(0), owner, _totalSupply);

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

    function allowance(address owner, address spender) public view returns (uint256)

    {

        return _allowed[owner][spender];

    }

    

    /**

    * @dev Transfer token for a specified address

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function transfer(address to, uint256 value) public returns (bool) {

        require(value <= _balances[msg.sender]);

        require(to != address(0));

        

        _balances[msg.sender] = _balances[msg.sender].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(msg.sender, to, value);

        return true;

    }

    

    /**

    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

    * Beware that changing an allowance with this method brings the risk that someone may use both the old

    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards

    * @param spender The address which will spend the funds.

    * @param value The amount of tokens to be spent.

    */

    function approve(address spender, uint256 value) public returns (bool) {

        require(value <= _balances[msg.sender]);

        require(spender != address(0));

        

        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }

    

    /**

    * @dev Transfer tokens from one address to another

    * @param from address The address which you want to send tokens from

    * @param to address The address which you want to transfer to

    * @param value uint256 the amount of tokens to be transferred

    */

    function transferFrom(address from, address to, uint256 value) public returns (bool)

    {

        require(value <= _balances[from]);

        require(value <= _allowed[from][msg.sender]);

        require(to != address(0));

        

        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        emit Transfer(from, to, value);

        return true;

    }

  

    // ------------------------------------------------------------------------

    // Don't accept ETH

    // ------------------------------------------------------------------------

    function () public payable {

        revert();

    }



    // ------------------------------------------------------------------------

    // Owner can transfer out any accidentally sent ERC20 tokens

    // ------------------------------------------------------------------------

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return IERC20(tokenAddress).transfer(owner, tokens);

    }

}