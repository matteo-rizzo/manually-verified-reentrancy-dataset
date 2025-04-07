/**

 *Submitted for verification at Etherscan.io on 2018-10-11

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





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



// File: contracts/AllowanceSheet.sol



// A wrapper around the allowanceOf mapping.

contract AllowanceSheet is Claimable {

    using SafeMath for uint256;



    mapping(address => mapping(address => uint256)) public allowanceOf;



    function addAllowance(address _tokenHolder, address _spender, uint256 _value) public onlyOwner {

        allowanceOf[_tokenHolder][_spender] = allowanceOf[_tokenHolder][_spender].add(_value);

    }



    function subAllowance(address _tokenHolder, address _spender, uint256 _value) public onlyOwner {

        allowanceOf[_tokenHolder][_spender] = allowanceOf[_tokenHolder][_spender].sub(_value);

    }



    function setAllowance(address _tokenHolder, address _spender, uint256 _value) public onlyOwner {

        allowanceOf[_tokenHolder][_spender] = _value;

    }

}