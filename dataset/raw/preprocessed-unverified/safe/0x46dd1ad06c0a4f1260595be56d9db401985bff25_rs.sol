/**

 *Submitted for verification at Etherscan.io on 2018-11-14

*/



pragma solidity 0.4.24;



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

  event Pause();

  event Unpause();



  bool public paused = false;





  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() onlyOwner whenNotPaused public {

    paused = true;

    emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() onlyOwner whenPaused public {

    paused = false;

    emit Unpause();

  }

}



// File: contracts/Whitelist.sol



contract Whitelist is Pausable {

  uint8 public constant version = 1;



  mapping (address => bool) private whitelistedMap;



  event Whitelisted(address indexed account, bool isWhitelisted);



  function whitelisted(address _address)

    public

    view

    returns(bool)

  {

    if (paused) {

      return false;

    }



    return whitelistedMap[_address];

  }



  function addAddress(address _address)

    public

    onlyOwner

  {

    require(whitelistedMap[_address] != true);

    whitelistedMap[_address] = true;

    emit Whitelisted(_address, true);

  }



  function removeAddress(address _address)

    public

    onlyOwner

  {

    require(whitelistedMap[_address] != false);

    whitelistedMap[_address] = false;

    emit Whitelisted(_address, false);

  }

}