/**

 *Submitted for verification at Etherscan.io on 2018-10-05

*/



pragma solidity 0.4.24;



// File: contracts/lib/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/Whitelist.sol



/**

 * @title Whitelist - crowdsale whitelist contract

 * @author Gustavo Guimaraes - <[emailÂ protected]>

 */

contract Whitelist is Ownable {

    mapping(address => bool) public allowedAddresses;



    event WhitelistUpdated(uint256 timestamp, string operation, address indexed member);



    /**

    * @dev Adds single address to whitelist.

    * @param _address Address to be added to the whitelist

    */

    function addToWhitelist(address _address) external onlyOwner {

        allowedAddresses[_address] = true;

        emit WhitelistUpdated(now, "Added", _address);

    }



    /**

     * @dev add various whitelist addresses

     * @param _addresses Array of ethereum addresses

     */

    function addManyToWhitelist(address[] _addresses) external onlyOwner {

        for (uint256 i = 0; i < _addresses.length; i++) {

            allowedAddresses[_addresses[i]] = true;

            emit WhitelistUpdated(now, "Added", _addresses[i]);

        }

    }



    /**

     * @dev remove whitelist addresses

     * @param _addresses Array of ethereum addresses

     */

    function removeManyFromWhitelist(address[] _addresses) public onlyOwner {

        for (uint256 i = 0; i < _addresses.length; i++) {

            allowedAddresses[_addresses[i]] = false;

            emit WhitelistUpdated(now, "Removed", _addresses[i]);

        }

    }

}