/**

 *Submitted for verification at Etherscan.io on 2019-06-06

*/



pragma solidity ^0.4.25;



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

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

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







/**

 * @title TokenVesting

 * @dev A token holder contract that can release its token balance gradually like a

 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the

 * owner.

 */

contract TokenVesting is Ownable {

  using SafeMath for uint256;

  using SafeERC20 for ERC20Basic;



  event Released(uint256 amount);

  event Revoked();



  // beneficiary of tokens after they are released

  address public beneficiary;

  uint256 public releaseTime;

  bool public revocable;



  mapping (address => uint256) public released;

  mapping (address => bool) public revoked;

  mapping (address => bool) public completed;



  constructor(

    address _beneficiary,

    uint256 _releaseTime,

    bool _revocable

  )

    public

  {

    require(_beneficiary != address(0));



    beneficiary = _beneficiary;

    releaseTime = _releaseTime;

    revocable = _revocable;

  }



  /**

   * @notice Transfers vested tokens to beneficiary.

   * @param token ERC20 token which is being vested

   */

  function release(ERC20Basic token) public {

    uint256 toRelease = releasableAmount(token);

    require(toRelease > 0);

    require(!completed[token]);

    released[token] = released[token].add(toRelease);

    completed[token] = true;

    token.safeTransfer(beneficiary, toRelease);

    emit Released(toRelease);

  }



  /**

   * @notice Allows the owner to revoke the vesting. Tokens already vested

   * remain in the contract, the rest are returned to the owner.

   * @param token ERC20 token which is being vested

   */

  function revoke(ERC20Basic token) public onlyOwner {

    require(revocable);

    require(!revoked[token]);

    uint256 refund = token.balanceOf(this);

    revoked[token] = true;

    token.safeTransfer(owner, refund);

    emit Revoked();

  }



  /**

   * @dev Calculates the amount that has already vested.

   * @param token ERC20 token which is being vested

   */

  function releasableAmount(ERC20Basic token) public view returns (uint256) {

    uint256 currentBalance = token.balanceOf(this);

    uint256 _now = now;

    require(currentBalance>0);

    uint256 canReleaseToken = 0;

    if(_now > releaseTime){

      canReleaseToken = currentBalance;

    }

    return canReleaseToken;

  }

}