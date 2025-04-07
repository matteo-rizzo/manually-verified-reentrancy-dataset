/**

 *Submitted for verification at Etherscan.io on 2018-10-04

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



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: contracts/ZCDistribution.sol



/**

 * @title ZCDistribution

 * 

 * Used to distribute rewards to consumers

 *

 * (c) Philip Louw / Zero Carbon Project 2018. The MIT Licence.

 */

contract ZCDistribution is Claimable {



    // Total amount of airdrops that happend

    uint256 public numDrops;

    // Total amount of tokens dropped

    uint256 public dropAmount;

    // Address of the Token

    address public tokenAddress;



    /**

     * @param _tokenAddr The Address of the Token

     */

    constructor(address _tokenAddr) public {

        assert(_tokenAddr != address(0));

        tokenAddress = _tokenAddr;

    }



    /**

    * @dev Event when reward is distributed to consumer

    * @param receiver Consumer address

    * @param amount Amount of tokens distributed

    */

    event RewardDistributed(address receiver, uint amount);



    /**

    * @dev Distributes the rewards to the consumers. Returns the amount of customers that received tokens. Can only be called by Owner

    * @param dests Array of cosumer addresses

    * @param values Array of token amounts to distribute to each client

    */

    function multisend(address[] dests, uint256[] values) public onlyOwner returns (uint256) {

        assert(dests.length == values.length);

        uint256 i = 0;

        while (i < dests.length) {

            assert(ERC20Basic(tokenAddress).transfer(dests[i], values[i]));

            emit RewardDistributed(dests[i], values[i]);

            dropAmount += values[i];

            i += 1;

        }

        numDrops += dests.length;

        return i;

    }



    /**

     * @dev Returns the Amount of tokens issued to consumers 

     */

    function getSentAmount() external view returns (uint256) {

        return dropAmount;

    }

}