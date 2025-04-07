/**

 *Submitted for verification at Etherscan.io on 2019-02-26

*/



pragma solidity 0.5.4;







contract pDNADistributedRegistry is Ownable {

  mapping(string => address) private registry;



  event Profiled(string eGrid, address indexed property);

  event Unprofiled(string eGrid, address indexed property);



  /**

   * this function's abi should never change and always maintain backwards compatibility

   */

  function getProperty(string memory _eGrid) public view returns (address property) {

    property = registry[_eGrid];

  }



  function profileProperty(string memory _eGrid, address _property) public onlyOwner {

    require(bytes(_eGrid).length > 0, "eGrid must be non-empty string");

    require(_property != address(0), "property address must be non-null");

    require(registry[_eGrid] == address(0), "property must not already exist in land registry");



    registry[_eGrid] = _property;

    emit Profiled(_eGrid, _property);

  }



  function unprofileProperty(string memory _eGrid) public onlyOwner {

    address property = getProperty(_eGrid);

    require(property != address(0), "property must exist in land registry");



    registry[_eGrid] = address(0);

    emit Unprofiled(_eGrid, property);

  }

}