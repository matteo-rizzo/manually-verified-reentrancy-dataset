/**

 *Submitted for verification at Etherscan.io on 2018-08-30

*/



pragma solidity ^0.4.24;



// File: node_modules/zos-lib/contracts/application/versioning/ImplementationProvider.sol



/**

 * @title ImplementationProvider

 * @dev Interface for providing implementation addresses for other contracts by name.

 */





// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: openzeppelin-solidity/contracts/AddressUtils.sol



/**

 * Utility library of inline functions on addresses

 */





// File: node_modules/zos-lib/contracts/application/versioning/ImplementationDirectory.sol



/**

 * @title ImplementationDirectory

 * @dev Implementation provider that stores contract implementations in a mapping.

 */

contract ImplementationDirectory is ImplementationProvider, Ownable {

  /**

   * @dev Emitted when the implementation of a contract is changed.

   * @param contractName Name of the contract.

   * @param implementation Address of the added implementation.

   */

  event ImplementationChanged(string contractName, address implementation);



  /// @dev Mapping where the addresses of the implementations are stored.

  mapping (string => address) internal implementations;



  /**

   * @dev Returns the implementation address of a contract.

   * @param contractName Name of the contract.

   * @return Address of the implementation.

   */

  function getImplementation(string contractName) public view returns (address) {

    return implementations[contractName];

  }



  /**

   * @dev Sets the address of the implementation of a contract in the directory.

   * @param contractName Name of the contract.

   * @param implementation Address of the implementation.

   */

  function setImplementation(string contractName, address implementation) public onlyOwner {

    require(AddressUtils.isContract(implementation), "Cannot set implementation in directory with a non-contract address");

    implementations[contractName] = implementation;

    emit ImplementationChanged(contractName, implementation);

  }



  /**

   * @dev Removes the address of a contract implementation from the directory.

   * @param contractName Name of the contract.

   */

  function unsetImplementation(string contractName) public onlyOwner {

    implementations[contractName] = address(0);

    emit ImplementationChanged(contractName, address(0));

  }

}



// File: node_modules/zos-lib/contracts/application/AppDirectory.sol



/**

 * @title AppDirectory

 * @dev Implementation directory with a standard library as a fallback provider.

 * If the implementation is not found in the directory, it will search in the

 * standard library.

 */

contract AppDirectory is ImplementationDirectory {

  /**

   * @dev Emitted when the standard library is changed.

   * @param newStdlib Address of the new standard library.

   */

  event StdlibChanged(address newStdlib);



  /**

   * @dev Provider for standard library implementations.

   */

  ImplementationProvider public stdlib;



  /**

   * @dev Constructor function.

   * @param _stdlib Provider for standard library implementations.

   */

  constructor(ImplementationProvider _stdlib) public {

    stdlib = _stdlib;

  }



  /**

   * @dev Returns the implementation address for a given contract name.

   * If the implementation is not found in the directory, it will search in the

   * standard library.

   * @param contractName Name of the contract.

   * @return Address where the contract is implemented, or 0 if it is not

   * found.

   */

  function getImplementation(string contractName) public view returns (address) {

    address implementation = super.getImplementation(contractName);

    if(implementation != address(0)) return implementation;

    if(stdlib != address(0)) return stdlib.getImplementation(contractName);

    return address(0);

  }



  /**

   * @dev Sets a new implementation provider for standard library contracts.

   * @param _stdlib Standard library implementation provider.

   */

  function setStdlib(ImplementationProvider _stdlib) public onlyOwner {

    stdlib = _stdlib;

    emit StdlibChanged(_stdlib);

  }

}