/**

 *Submitted for verification at Etherscan.io on 2018-11-10

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

 * @title MedianizerProxy

 * @dev Points to `Medianizer`, enabling it to be upgraded if absolutely necessary.

 *

 * `TokenSale` references `this.medianizer` to locate `Medianizer`.

 * This contract is never intended to be upgraded.

 */

contract MedianizerProxy is Claimable {

  address public medianizer;



  event Set(address medianizer);



  function set(address _medianizer) public onlyOwner {

    medianizer = _medianizer;

    emit Set(medianizer);

  }

}