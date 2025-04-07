/**

 *Submitted for verification at Etherscan.io on 2019-02-02

*/



pragma solidity ^0.4.25;



// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





// File: openzeppelin-solidity/contracts/token/ERC20/TokenTimelock.sol



/**

 * @title TokenTimelock

 * @dev TokenTimelock is a token holder contract that will allow a

 * beneficiary to extract the tokens after a given release time

 */

contract TokenTimelock {

  using SafeERC20 for IERC20;



  // ERC20 basic token contract being held

  IERC20 private _token;



  // beneficiary of tokens after they are released

  address private _beneficiary;



  // timestamp when token release is enabled

  uint256 private _releaseTime;



  constructor(

    IERC20 token,

    address beneficiary,

    uint256 releaseTime

  )

    public

  {

    // solium-disable-next-line security/no-block-members

    require(releaseTime > block.timestamp);

    _token = token;

    _beneficiary = beneficiary;

    _releaseTime = releaseTime;

  }



  /**

   * @return the token being held.

   */

  function token() public view returns(IERC20) {

    return _token;

  }



  /**

   * @return the beneficiary of the tokens.

   */

  function beneficiary() public view returns(address) {

    return _beneficiary;

  }



  /**

   * @return the time when the tokens are released.

   */

  function releaseTime() public view returns(uint256) {

    return _releaseTime;

  }



  /**

   * @notice Transfers tokens held by timelock to beneficiary.

   */

  function release() public {

    // solium-disable-next-line security/no-block-members

    require(block.timestamp >= _releaseTime);



    uint256 amount = _token.balanceOf(address(this));

    require(amount > 0);



    _token.safeTransfer(_beneficiary, amount);

  }

}



// File: contracts/token/BaseTimelock.sol



/**

 * @title BaseTimelock

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Extends from TokenTimelock which is a token holder contract that will allow a

 *  beneficiary to extract the tokens after a given release time

 */

contract BaseTimelock is TokenTimelock {



  /**

   * @param token Address of the token being distributed

   * @param beneficiary Who will receive the tokens after they are released

   * @param releaseTime Timestamp when token release is enabled

   */

  constructor(

    IERC20 token,

    address beneficiary,

    uint256 releaseTime

  )

    public

    TokenTimelock(token, beneficiary, releaseTime)

  {}

}