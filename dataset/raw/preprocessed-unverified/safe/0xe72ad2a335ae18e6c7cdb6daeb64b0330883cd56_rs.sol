/**

 *Submitted for verification at Etherscan.io on 2018-09-20

*/



/**

 * Copyright (c) 2018 blockimmo AG [emailÂ protected]

 * Non-Profit Open Software License 3.0 (NPOSL-3.0)

 * https://opensource.org/licenses/NPOSL-3.0

 */





pragma solidity 0.4.25;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







/**

 * @title Claimable

 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.

 * This allows the new owner to accept the transfer.

 */

contract Claimable is Ownable {

  address public pendingOwner;



  /**

   * @dev Modifier throws if called by any account other than the pendingOwner.

   */

  modifier onlyPendingOwner() {

    require(msg.sender == pendingOwner);

    _;

  }



  /**

   * @dev Allows the current owner to set the pendingOwner address.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public onlyOwner {

    pendingOwner = newOwner;

  }



  /**

   * @dev Allows the pendingOwner address to finalize the transfer.

   */

  function claimOwnership() public onlyPendingOwner {

    emit OwnershipTransferred(owner, pendingOwner);

    owner = pendingOwner;

    pendingOwner = address(0);

  }

}



/**

 * @title LandRegistryProxy

 * @dev Points to `LandRegistry`, enabling it to be upgraded if absolutely necessary.

 *

 * Contracts reference `this.landRegistry` to locate `LandRegistry`.

 * They also reference `owner` to identify blockimmo's 'administrator' (currently blockimmo but ownership may be transferred to a

 * contract / DAO in the near-future, or even rescinded).

 *

 * `TokenizedProperty` references `this` to enforce the `LandRegistry` and route blockimmo's 1% transaction fee on dividend payouts.

 * `ShareholderDAO` references `this` to allow blockimmo's 'administrator' to extend proposals for any `TokenizedProperty`.

 * `TokenSale` references `this` to route blockimmo's 1% transaction fee on sales.

 *

 * For now this centralized 'administrator' provides an extra layer of control / security until our contracts are time and battle tested.

 *

 * This contract is never intended to be upgraded.

 */

contract LandRegistryProxy is Claimable {

  address public landRegistry;



  event Set(address indexed landRegistry);



  function set(address _landRegistry) public onlyOwner {

    landRegistry = _landRegistry;

    emit Set(landRegistry);

  }

}