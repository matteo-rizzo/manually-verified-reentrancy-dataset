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





// File: node_modules/zos-lib/contracts/application/versioning/Package.sol



/**

 * @title Package

 * @dev Collection of contracts grouped into versions.

 * Contracts with the same name can have different implementation addresses in different versions.

 */

contract Package is Ownable {

  /**

   * @dev Emitted when a version is added to the package.

   * XXX The version is not indexed due to truffle testing constraints.

   * @param version Name of the added version.

   * @param provider ImplementationProvider associated with the version.

   */

  event VersionAdded(string version, ImplementationProvider provider);



  /*

   * @dev Mapping associating versions and their implementation providers.

   */

  mapping (string => ImplementationProvider) internal versions;



  /**

   * @dev Returns the implementation provider of a version.

   * @param version Name of the version.

   * @return The implementation provider of the version.

   */

  function getVersion(string version) public view returns (ImplementationProvider) {

    ImplementationProvider provider = versions[version];

    return provider;

  }



  /**

   * @dev Adds the implementation provider of a new version to the package.

   * @param version Name of the version.

   * @param provider ImplementationProvider associated with the version.

   */

  function addVersion(string version, ImplementationProvider provider) public onlyOwner {

    require(!hasVersion(version), "Given version is already registered in package");

    versions[version] = provider;

    emit VersionAdded(version, provider);

  }



  /**

   * @dev Checks whether a version is present in the package.

   * @param version Name of the version.

   * @return true if the version is already in the package, false otherwise.

   */

  function hasVersion(string version) public view returns (bool) {

    return address(versions[version]) != address(0);

  }



  /**

   * @dev Returns the implementation address for a given version and contract name.

   * @param version Name of the version.

   * @param contractName Name of the contract.

   * @return Address where the contract is implemented.

   */

  function getImplementation(string version, string contractName) public view returns (address) {

    ImplementationProvider provider = getVersion(version);

    return provider.getImplementation(contractName);

  }

}