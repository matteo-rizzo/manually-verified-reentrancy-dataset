pragma solidity ^0.4.24;








/*
    Bancor Network interface
*/



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



contract GetBancorData is Ownable{
  using stringToBytes32 for string;

  IContractRegistry public bancorRegistry;

  constructor(address _bancorRegistry)public{
    bancorRegistry = IContractRegistry(_bancorRegistry);
  }

  // return contract address from Bancor registry by name
  function getBancorContractAddresByName(string _name) public view returns (address result){
     bytes32 name = stringToBytes32.convert(_name);
     result = bancorRegistry.addressOf(name);
  }

  /**
  * @dev get ratio between Bancor assets
  *
  * @param _from  ERC20 or Relay
  * @param _to  ERC20 or Relay
  * @param _amount  amount for _from
  */
  function getBancorRatioForAssets(ERC20 _from, ERC20 _to, uint256 _amount) public view returns(uint256 result){
    if(_amount > 0){
      BancorNetworkInterface bancorNetwork = BancorNetworkInterface(
        getBancorContractAddresByName("BancorNetwork")
      );

      // get Bancor path array
      address[] memory path = bancorNetwork.conversionPath(_from, _to);

      // get Ratio
      return bancorNetwork.rateByPath(path, _amount);
    }
    else{
      result = 0;
    }
  }

  // get addresses array of token path
  function getBancorPathForAssets(ERC20 _from, ERC20 _to) public view returns(address[] memory){
    BancorNetworkInterface bancorNetwork = BancorNetworkInterface(
      getBancorContractAddresByName("BancorNetwork")
    );

    address[] memory path = bancorNetwork.conversionPath(_from, _to);

    return path;
  }

  // update bancor registry
  function changeRegistryAddress(address _bancorRegistry) public onlyOwner{
    bancorRegistry = IContractRegistry(_bancorRegistry);
  }
}