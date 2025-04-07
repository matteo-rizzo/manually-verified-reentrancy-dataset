/**

 *Submitted for verification at Etherscan.io on 2018-09-04

*/



pragma solidity ^0.4.24;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

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

 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract ERC20 is IERC20, Ownable {

  using SafeMath for uint256;



  mapping (address => uint256) private balances_;



  mapping (address => mapping (address => uint256)) private allowed_;

  

  uint256 private totalSupply_;

  uint256 public tokensSold;

  

  address public fundsWallet = 0x1defDc87eF32479928eeB933891907Fb56818821;

  

  constructor() public {

      totalSupply_ = 10000000000e18;

      balances_[address(this)] = 10000000000e18;

      emit Transfer(address(0), address(this), totalSupply_);

      tokensSold = 0;

  }





  /**

  * @dev Total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) public view returns (uint256) {

    return balances_[_owner];

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

    return allowed_[_owner][_spender];

  }



  /**

  * @dev Transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_value <= balances_[msg.sender]);

    require(_to != address(0));



    balances_[msg.sender] = balances_[msg.sender].sub(_value);

    balances_[_to] = balances_[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;

  }

  

  

  /**

   * Allows the owner to withdraw XPI tokens from the contract

   * @param _value The total amount of tokens to be withdrawn

   * @return true if function executes successfully, false otherwise

   * */

  function withdrawXPI(uint256 _value) public onlyOwner returns(bool){

    require(_value <= balances_[address(this)]);

    balances_[owner] = balances_[owner].add(_value);

    balances_[address(this)] = balances_[address(this)].sub(_value);

    emit Transfer(address(this), owner, _value);

    return true;

  }

  

  

  /**

   * Enables investors to purchase XPI tokens by simply sending ETH 

   * to the contract address.

   * */

  function() public payable {

      buyTokens(msg.sender);

  }

  



  function buyTokens(address _investor) public payable returns(bool) {

    require(_investor != address(0));

    require(msg.value >= 5e15 && msg.value <= 5e18);

    require(tokensSold < 6000000000e18);

    uint256 XPiToTransfer = msg.value.mul(20000000);

    if(msg.value < 5e16) {

        dispatchTokens(_investor, XPiToTransfer);

        return true;

    } else if(msg.value < 1e17) {

        XPiToTransfer = XPiToTransfer.add((XPiToTransfer.mul(20)).div(100));

        dispatchTokens(_investor, XPiToTransfer);

        return true;

    } else if(msg.value < 5e17) {

        XPiToTransfer = XPiToTransfer.add((XPiToTransfer.mul(30)).div(100));

        dispatchTokens(_investor, XPiToTransfer);

        return true;

    } else if(msg.value < 1e18) {

        XPiToTransfer = XPiToTransfer.add((XPiToTransfer.mul(50)).div(100));

        dispatchTokens(_investor, XPiToTransfer);

        return true;

    } else if(msg.value >= 1e18) {

        XPiToTransfer = XPiToTransfer.mul(2);

        dispatchTokens(_investor, XPiToTransfer);

        return true;

    }

  }

  

  function dispatchTokens(address _investor, uint256 _XPiToTransfer) internal {

      balances_[address(this)] = balances_[address(this)].sub(_XPiToTransfer);

      balances_[_investor] = balances_[_investor].add(_XPiToTransfer);

      emit Transfer(address(this), _investor, _XPiToTransfer);

      tokensSold = tokensSold.add(_XPiToTransfer);

      fundsWallet.transfer(msg.value);

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

    allowed_[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);

    return true;

  }



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

    require(_value <= balances_[_from]);

    require(_value <= allowed_[_from][msg.sender]);

    require(_to != address(0));



    balances_[_from] = balances_[_from].sub(_value);

    balances_[_to] = balances_[_to].add(_value);

    allowed_[_from][msg.sender] = allowed_[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);

    return true;

  }



  /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed_[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _addedValue The amount of tokens to increase the allowance by.

   */

  function increaseApproval(

    address _spender,

    uint256 _addedValue

  )

    public

    returns (bool)

  {

    allowed_[msg.sender][_spender] = (

      allowed_[msg.sender][_spender].add(_addedValue));

    emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);

    return true;

  }



  /**

   * @dev Decrease the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed_[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseApproval(

    address _spender,

    uint256 _subtractedValue

  )

    public

    returns (bool)

  {

    uint256 oldValue = allowed_[msg.sender][_spender];

    if (_subtractedValue >= oldValue) {

      allowed_[msg.sender][_spender] = 0;

    } else {

      allowed_[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);

    return true;

  }





  /**

   * @dev Internal function that burns an amount of the token of a given

   * account.

   * @param _account The account whose tokens will be burnt.

   * @param _amount The amount that will be burnt.

   */

  function _burn(address _account, uint256 _amount) internal {

    require(_account != 0);

    require(_amount <= balances_[_account]);



    totalSupply_ = totalSupply_.sub(_amount);

    balances_[_account] = balances_[_account].sub(_amount);

    emit Transfer(_account, address(0), _amount);

  }



  /**

   * @dev Internal function that burns an amount of the token of a given

   * account, deducting from the sender's allowance for said account. Uses the

   * internal _burn function.

   * @param _account The account whose tokens will be burnt.

   * @param _amount The amount that will be burnt.

   */

  function _burnFrom(address _account, uint256 _amount) internal {

    require(_amount <= allowed_[_account][msg.sender]);



    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,

    // this function needs to emit an event with the updated approval.

    allowed_[_account][msg.sender] = allowed_[_account][msg.sender].sub(

      _amount);

    _burn(_account, _amount);

  }

}







/**

 * @title Burnable Token

 * @dev Token that can be irreversibly burned (destroyed).

 */

contract ERC20Burnable is ERC20 {



  event TokensBurned(address indexed burner, uint256 value);



  /**

   * @dev Burns a specific amount of tokens.

   * @param _value The amount of token to be burned.

   */

  function burn(uint256 _value) public {

    _burn(msg.sender, _value);

  }



  /**

   * @dev Burns a specific amount of tokens from the target address and decrements allowance

   * @param _from address The address which you want to send tokens from

   * @param _value uint256 The amount of token to be burned

   */

  function burnFrom(address _from, uint256 _value) public {

    _burnFrom(_from, _value);

  }



  /**

   * @dev Overrides ERC20._burn in order for burn and burnFrom to emit

   * an additional Burn event.

   */

  function _burn(address _who, uint256 _value) internal {

    super._burn(_who, _value);

    emit TokensBurned(_who, _value);

  }

}





contract XPiBlock is ERC20Burnable {

    

    string public name;

    string public symbol;

    uint8 public decimals;

    

    constructor() public {

        name = "XPiBlock";

        symbol = "XPI";

        decimals = 18;

    }

}