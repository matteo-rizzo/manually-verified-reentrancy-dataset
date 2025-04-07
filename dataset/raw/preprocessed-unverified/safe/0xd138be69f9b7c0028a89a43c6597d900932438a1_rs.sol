/**

 *Submitted for verification at Etherscan.io on 2019-01-01

*/



pragma solidity ^0.4.23;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title DealsRootStorage

 * @dev Storage for precalculated merkle roots.

 */

contract DealsRootStorage is Ownable {

  mapping(uint256 => bytes32) roots;

  uint256 public lastTimestamp = 0;



  /**

   * @dev Sets merkle root at the specified timestamp.

   */

  function setRoot(uint256 _timestamp, bytes32 _root) onlyOwner public returns (bool) {

    require(_timestamp > 0);

    require(roots[_timestamp] == 0);



    roots[_timestamp] = _root;

    lastTimestamp = _timestamp;



    return true;

  }



  /**

   * @dev Gets last available merkle root.

   */

  function lastRoot() public view returns (bytes32) {

    return roots[lastTimestamp];

  }



  /**

   * @dev Gets merkle root by the specified timestamp.

   */

  function getRoot(uint256 _timestamp) public view returns (bytes32) {

    return roots[_timestamp];

  }

}