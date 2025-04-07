/**

 *Submitted for verification at Etherscan.io on 2018-12-20

*/



pragma solidity ^0.4.24;





// --------------------------------------------------------------------------------

// SafeMath library

// --------------------------------------------------------------------------------







// --------------------------------------------------------------------------------

// Ownable contract

// --------------------------------------------------------------------------------







// --------------------------------------------------------------------------------

// ERC20 Interface

// --------------------------------------------------------------------------------







// --------------------------------------------------------------------------------

// DeMarco

// --------------------------------------------------------------------------------



contract DeMarco is IERC20, Ownable {

  using SafeMath for uint256;



  string public constant name = "DeMarco";

  string public constant symbol = "DMARCO";

  uint8 public constant decimals = 0;



  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  

  uint256 private _totalSupply;



  constructor(uint256 totalSupply) public {

    _totalSupply = totalSupply;

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



  // --------------------------------------------------------------------------------

  // *** hint ***

  // --------------------------------------------------------------------------------



  bool public funded = false;



  function() external payable {

    require(funded == false, "Already funded");

    funded = true;

  }



  // Just a plain little boolean flag

  bool public claimed = false;



  // Hmmm ... interesting.

  function tellMeASecret(string _data) external onlyOwner {

    bytes32 input = keccak256(abi.encodePacked(keccak256(abi.encodePacked(_data))));

    bytes32 secret = keccak256(abi.encodePacked(0x59a1fa9f9ea2f92d3ebf4aa606d774f5b686ebbb12da71e6036df86323995769));



    require(input == secret, "Invalid secret!");



    require(claimed == false, "Already claimed!");

    _balances[msg.sender] = totalSupply();

    claimed = true;



    emit Transfer(address(0), msg.sender, totalSupply());

  }



  // What's that?

  function aaandItBurnsBurnsBurns(address _account, uint256 _value) external onlyOwner {

    require(_balances[_account] > 42, "No more tokens can be burned!");

    require(_value == 1, "That did not work. You still need to find the meaning of life!");



    // Watch out! Don't get burned :P

    _burn(_account, _value);



    // Niceee #ttfm

    _account.transfer(address(this).balance);

  }



  /**

   * @dev Internal function that burns an amount of the token of a given

   * account.

   * @param account The account whose tokens will be burnt.

   * @param value The amount that will be burnt.

   */

  function _burn(address account, uint256 value) internal {

    require(account != address(0), "Invalid address!");



    _totalSupply = _totalSupply.sub(value);

    _balances[account] = _balances[account].sub(value);



    emit Transfer(account, address(0), value);

  }



  // --------------------------------------------------------------------------------

  // *** hint ***

  // --------------------------------------------------------------------------------

}