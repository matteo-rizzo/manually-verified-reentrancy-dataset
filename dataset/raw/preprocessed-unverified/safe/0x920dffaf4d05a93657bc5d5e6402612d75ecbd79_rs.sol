pragma solidity ^0.4.24;



// File: contracts/registry/IDeployer.sol







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



// File: contracts/registry/MultiTokenRegistry.sol



contract MultiTokenRegistry is Pausable {



    address[] public multitokens;

    mapping(uint256 => IDeployer) public deployers;



    function allMultitokens() public view returns(address[]) {

        return multitokens;

    }



    function setDeployer(uint256 index, IDeployer deployer) public onlyOwner whenNotPaused {

        deployers[index] = deployer;

    }



    function deploy(uint256 index, bytes data) public whenNotPaused {

        multitokens.push(deployers[index].deploy(data));

    }

}