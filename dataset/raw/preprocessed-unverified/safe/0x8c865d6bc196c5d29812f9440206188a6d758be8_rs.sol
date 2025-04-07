/**

 *Submitted for verification at Etherscan.io on 2018-10-14

*/



pragma solidity ^0.4.24;



/**

 * @title Helps contracts guard against reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>

 * @dev If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {



  /// @dev Constant for unlocked guard state - non-zero to prevent extra gas costs.

  /// See: https://github.com/OpenZeppelin/openzeppelin-solidity/issues/1056

  uint private constant REENTRANCY_GUARD_FREE = 1;



  /// @dev Constant for locked guard state

  uint private constant REENTRANCY_GUARD_LOCKED = 2;



  /**

   * @dev We use a single lock for the whole contract.

   */

  uint private reentrancyLock = REENTRANCY_GUARD_FREE;



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * If you mark a function `nonReentrant`, you should also

   * mark it `external`. Calling one `nonReentrant` function from

   * another is not supported. Instead, you can implement a

   * `private` function doing the actual work, and an `external`

   * wrapper marked as `nonReentrant`.

   */

  modifier nonReentrant() {

    require(reentrancyLock == REENTRANCY_GUARD_FREE);

    reentrancyLock = REENTRANCY_GUARD_LOCKED;

    _;

    reentrancyLock = REENTRANCY_GUARD_FREE;

  }



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









contract Indorser is Ownable, ReentrancyGuard {



    function multisend(address _tokenAddr, address[] _to, uint256[] _value) onlyOwner returns (bool _success) {

        assert(_to.length == _value.length);

		assert(_to.length <= 150);

        // loop through to addresses and send value

		for (uint8 i = 0; i < _to.length; i++) {

            assert((ERC20(_tokenAddr).transfer(_to[i], _value[i])) == true);

        }

        return true;

    }

}