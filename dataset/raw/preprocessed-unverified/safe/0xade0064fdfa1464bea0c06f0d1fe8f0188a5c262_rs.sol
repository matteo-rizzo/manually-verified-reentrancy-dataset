/**

 *Submitted for verification at Etherscan.io on 2018-09-07

*/



pragma solidity ^0.4.22;



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

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





/**

 * @title Contracts that should be able to recover tokens

 * @author SylTi

 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.

 * This will prevent any accidental loss of tokens.

 */

contract CanReclaimToken is Ownable {

  using SafeERC20 for ERC20Basic;



  /**

   * @dev Reclaim all ERC20Basic compatible tokens

   * @param _token ERC20Basic The address of the token contract

   */

  function reclaimToken(ERC20Basic _token) external onlyOwner {

    uint256 balance = _token.balanceOf(this);

    _token.safeTransfer(owner, balance);

  }



}



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

  event Pause();

  event Unpause();



  bool public paused = false;





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

  function pause() public onlyOwner whenNotPaused {

    paused = true;

    emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyOwner whenPaused {

    paused = false;

    emit Unpause();

  }

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





contract KindAdsReward is Ownable, CanReclaimToken, Pausable{



  // Use SafeMath for all uint256

  using SafeMath for uint256;

   // The KIND address

  address tokenAddress;

  // The KIND Token Instance

  ERC20 public KIND;

  // PayAndDistribute Event

  event PaidAndDistributed(address indexed publisher, uint256 pricePaid, string campaignId);



  constructor(address _tokenAddress) public {

    KIND = ERC20(_tokenAddress);

    tokenAddress = _tokenAddress;

  }



  function payAndDistribute(

    address _publisher,

    uint256 _priceToPay,

    uint256 _toPublisher,

    uint256 _toReward,

    string _campaignId) public whenNotPaused returns (bool) {



    require(msg.sender != address(0));

    require(_priceToPay <= KIND.balanceOf(msg.sender));

    require(_priceToPay <= KIND.allowance(msg.sender, this));

    require(_toPublisher.add(_toReward) == _priceToPay);

    // First move the reward share tokens for this contract

    KIND.transferFrom(msg.sender, this, _toReward);

    // Transfer the real payment to the publisher

    KIND.transferFrom(msg.sender, _publisher, _toPublisher);



    emit PaidAndDistributed(_publisher, _priceToPay, _campaignId);

    return true;

  }



   /**

  * @dev Returns the publisher address

  */

  function getKindAddress() public view returns (address kindAddress) {

    return tokenAddress;

  }



   /**

  * @dev Returns the full amount of KIND in this contract

  */

  function getTokenBalance() public view returns(uint256 balance) {

    return KIND.balanceOf(this);

  }



}