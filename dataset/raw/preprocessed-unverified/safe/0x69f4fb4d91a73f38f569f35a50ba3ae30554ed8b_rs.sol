/**

 *Submitted for verification at Etherscan.io on 2018-08-31

*/



pragma solidity ^0.4.23;



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



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

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title Helps contracts guard agains reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>

 * @notice If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {



  /**

   * @dev We use a single lock for the whole contract.

   */

  bool private reentrancyLock = false;



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * @notice If you mark a function `nonReentrant`, you should also

   * mark it `external`. Calling one nonReentrant function from

   * another is not supported. Instead, you can implement a

   * `private` function doing the actual work, and a `external`

   * wrapper marked as `nonReentrant`.

   */

  modifier nonReentrant() {

    require(!reentrancyLock);

    reentrancyLock = true;

    _;

    reentrancyLock = false;

  }



}



contract DividendInterface {

  function putProfit() public payable;

  function dividendBalanceOf(address _account) public view returns (uint256);

  function hasDividends() public view returns (bool);

  function claimDividends() public returns (uint256);

  function claimedDividendsOf(address _account) public view returns (uint256);

  function saveUnclaimedDividends(address _account) public;

}



contract BasicDividend is DividendInterface, ReentrancyGuard, Ownable {

  using SafeMath for uint256;



  event Dividends(uint256 amount);

  event DividendsClaimed(address claimer, uint256 amount);



  uint256 public totalDividends;

  mapping (address => uint256) public lastDividends;

  mapping (address => uint256) public unclaimedDividends;

  mapping (address => uint256) public claimedDividends;

  ERC20 public token;



  modifier onlyToken() {

    require(msg.sender == address(token));

    _;

  }



  constructor(ERC20 _token) public {

    token = _token;

  }



  /**

   * @dev fallback payment function

   */

  function () external payable {

    putProfit();

  }



  /**

   * @dev on every ether transaction totalDividends is incremented by amount

   */

  function putProfit() public nonReentrant onlyOwner payable {

    totalDividends = totalDividends.add(msg.value);

    emit Dividends(msg.value);

  }



  /**

  * @dev Gets the unclaimed dividends balance of the specified address.

  * @param _account The address to query the the dividends balance of.

  * @return An uint256 representing the amount of dividends owned by the passed address.

  */

  function dividendBalanceOf(address _account) public view returns (uint256) {

    uint256 accountBalance = token.balanceOf(_account);

    uint256 totalSupply = token.totalSupply();

    uint256 newDividends = totalDividends.sub(lastDividends[_account]);

    uint256 product = accountBalance.mul(newDividends);

    return product.div(totalSupply) + unclaimedDividends[_account];

  }



  function claimedDividendsOf(address _account) public view returns (uint256) {

    return claimedDividends[_account];

  }



  function hasDividends() public view returns (bool) {

    return totalDividends > 0 && address(this).balance > 0;

  }



  /**

  * @dev claim dividends

  */

  function claimDividends() public nonReentrant returns (uint256) {

    require(address(this).balance > 0);

    uint256 dividends = dividendBalanceOf(msg.sender);

    require(dividends > 0);

    lastDividends[msg.sender] = totalDividends;

    unclaimedDividends[msg.sender] = 0;

    claimedDividends[msg.sender] = claimedDividends[msg.sender].add(dividends);

    msg.sender.transfer(dividends);

    emit DividendsClaimed(msg.sender, dividends);

    return dividends;

  }



  function saveUnclaimedDividends(address _account) public onlyToken {

    if (totalDividends > lastDividends[_account]) {

      unclaimedDividends[_account] = dividendBalanceOf(_account);

      lastDividends[_account] = totalDividends;

    }

  }

}



contract BablosDividend is BasicDividend {



  constructor(ERC20 _token) public BasicDividend(_token) {



  }



}