/**

 *Submitted for verification at Etherscan.io on 2018-10-11

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: openzeppelin-solidity/contracts/ownership/Claimable.sol



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

    function transferOwnership(address newOwner) onlyOwner public {

        pendingOwner = newOwner;

    }



    /**

     * @dev Allows the pendingOwner address to finalize the transfer.

     */

    function claimOwnership() onlyPendingOwner public {

        emit OwnershipTransferred(owner, pendingOwner);

        owner = pendingOwner;

        pendingOwner = address(0);

    }

}



// File: contracts/AddressList.sol



contract AddressList is Claimable {

    string public name;

    mapping(address => bool) public onList;



    constructor(string _name, bool nullValue) public {

        name = _name;

        onList[0x0] = nullValue;

    }



    event ChangeWhiteList(address indexed to, bool onList);



    // Set whether _to is on the list or not. Whether 0x0 is on the list

    // or not cannot be set here - it is set once and for all by the constructor.

    function changeList(address _to, bool _onList) onlyOwner public {

        require(_to != 0x0);

        if (onList[_to] != _onList) {

            onList[_to] = _onList;

            emit ChangeWhiteList(_to, _onList);

        }

    }

}



// File: contracts/NamableAddressList.sol



contract NamableAddressList is AddressList {

    constructor(string _name, bool nullValue)

    AddressList(_name, nullValue) public {}



    function changeName(string _name) onlyOwner public {

        name = _name;

    }

}