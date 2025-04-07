/**

 *Submitted for verification at Etherscan.io on 2018-09-30

*/



pragma solidity 0.4.24;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 * @dev Based on https://github.com/OpenZeppelin/zeppelin-soliditysettable

 */







/**

 * @title Truffle Migrations contract

 * @dev It violates standard naming convention for compatibility with Truffle suite

 * @dev It extends standard implementation with changeable owner.

 */

contract Migrations is Ownable {

    // solhint-disable-next-line var-name-mixedcase

    uint256 public last_completed_migration;



    function setCompleted(uint256 completed) public onlyOwner {

        last_completed_migration = completed;

    }



    // solhint-disable-next-line func-param-name-mixedcase

    function upgrade(address new_address) public onlyOwner {

        Migrations upgraded = Migrations(new_address);

        upgraded.setCompleted(last_completed_migration);

    }

}