/**

 *Submitted for verification at Etherscan.io on 2019-01-01

*/



pragma solidity ^0.4.24;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract Token is Ownable {

  event UpgradedTo(address indexed implementation);



  address internal _implementation;



  function implementation() public view returns (address) {

    return _implementation;

  }



  function upgradeTo(address impl) public onlyOwner {

    require(_implementation != impl);

    _implementation = impl;

    emit UpgradedTo(impl);

  }



  function () payable public {

    address _impl = implementation();

    require(_impl != address(0));

    bytes memory data = msg.data;



    assembly {

      let result := delegatecall(gas, _impl, add(data, 0x20), mload(data), 0, 0)

      let size := returndatasize

      let ptr := mload(0x40)

      returndatacopy(ptr, 0, size)

      switch result

      case 0 { revert(ptr, size) }

      default { return(ptr, size) }

    }

  }

}