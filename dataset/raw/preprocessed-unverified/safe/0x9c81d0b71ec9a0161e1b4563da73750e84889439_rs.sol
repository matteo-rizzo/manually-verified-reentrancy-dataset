/**
 *Submitted for verification at Etherscan.io on 2020-11-20
*/

pragma solidity ^0.6.12;












/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



contract GetBancorData is Ownable{
  using stringToBytes32 for string;
  IBancorPoolParser public BancorPoolParser;
  IContractRegistry public bancorRegistry;

  constructor(address _bancorRegistry)public{
    bancorRegistry = IContractRegistry(_bancorRegistry);
  }

  // return contract address from Bancor registry by name
  function getBancorContractAddresByName(string memory _name) public view returns (address result){
     bytes32 name = stringToBytes32.convert(_name);
     result = bancorRegistry.addressOf(name);
  }

  /**
  * @dev get ratio between Bancor assets
  *
  * @param _from  address or Relay
  * @param _to  address or Relay
  * @param _amount  amount for _from
  */
  function getBancorRatioForAssets(address _from, address _to, uint256 _amount) public view returns(uint256 result){
    if(_amount > 0){
      try BancorPoolParser.parseConnectorsByPool(_from, _to, _amount)
        returns(uint256 totalValue)
       {
         result = totalValue;
       }
       catch{
         result = getRatioByPath(_from, _to, _amount);
       }
    }
    else{
      result = 0;
    }
  }


  // Works for Bancor assets and old bancor pools
  function getRatioByPath(address _from, address _to, uint256 _amount) public view returns(uint256) {
    BancorNetworkInterface bancorNetwork = BancorNetworkInterface(
      getBancorContractAddresByName("BancorNetwork")
    );
    // get Bancor path array
    address[] memory path = bancorNetwork.conversionPath(_from, _to);
    // get Ratio
    return bancorNetwork.rateByPath(path, _amount);
  }



  // get addresses array of token path
  function getBancorPathForAssets(address _from, address _to) public view returns(address[] memory){
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

  // update BancorPoolParser
  function changeBancorPoolParser(address _BancorPoolParser) public onlyOwner{
    BancorPoolParser = IBancorPoolParser(_BancorPoolParser);
  }
}