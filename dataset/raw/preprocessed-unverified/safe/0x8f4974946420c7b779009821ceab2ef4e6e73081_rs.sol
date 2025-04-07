/**

 *Submitted for verification at Etherscan.io on 2018-11-13

*/



pragma solidity ^0.4.24;







/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */









/** 

 * @title IndexConsumer

 * @dev This contract adds an autoincrementing index to contracts. 

 */

contract IndexConsumer {



    using SafeMath for uint256;



    /** The index */

    uint256 private freshIndex = 0;



    /** Fetch the next index */

    function nextIndex() internal returns (uint256) {

        uint256 theIndex = freshIndex;

        freshIndex = freshIndex.add(1);

        return theIndex;

    }



}





/**

 * @title CapTables

 * @dev The sole purpose of this contract is to store the cap tables of securities

 * created by the OFN system.  We take the position that a security is defined

 * by its cap table and not by its transfer rules.  So a security is

 * represented by a unique integer index.  A security has a fixed amount and we

 * preserve this invariant by allowing no other cap table updates beside

 * transfers.

 */

contract CapTables is IndexConsumer {

    using SafeMath for uint256;



    /** Address of security */

    mapping(uint256 => address) public addresses;

    mapping(address => uint) private indexes;



    /** `capTable(security, user) == userBalance` */

    mapping(uint256 => mapping(address => uint256)) public capTable;



    /** Total token supplies */

    mapping(uint256 => uint256) public totalSupply;



    /* EVENTS */



    



    event NewSecurity(uint256 security);

    event SecurityMigration(uint256 security, address newAddress);



    modifier onlySecurity(uint256 security) {  

        require(

            msg.sender == addresses[security], 

            "this method MUST be called by the security's control account"

        );

        _;

    }



    /** @dev retrieve the balance at a given address */

    function balanceOf(uint256 security, address user) public view returns (uint256) {

        return capTable[security][user];

    }



    /** @dev Add a security to the contract. */

    function initialize(uint256 supply, address manager) public returns (uint256) {

        uint256 index = nextIndex();

        addresses[index] = manager;

        capTable[index][manager] = supply;

        totalSupply[index] = supply;

        indexes[manager] = index;

        emit NewSecurity(index);

        return index;

    }





    /** @dev Migrate a security to a new address, if its transfer restriction rules change. */

    function migrate(uint256 security, address newAddress) public onlySecurity(security) {

        addresses[security] = newAddress;

        emit SecurityMigration(security, newAddress);

    }



    /** @dev Transfer an amount of security. */

    function transfer(uint256 security, address src, address dest, uint256 amount) 

        public 

        onlySecurity(security) 

    {

        capTable[security][src] = capTable[security][src].sub(amount);

        capTable[security][dest] = capTable[security][dest].add(amount);

    }

}