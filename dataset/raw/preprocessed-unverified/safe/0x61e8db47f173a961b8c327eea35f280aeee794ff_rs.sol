pragma solidity ^0.4.24;








contract Minter {
  Minter_Database private database;

  constructor(address _database) public {
    database = Minter_Database(_database);
  }

  function cloneToken(string _uri, address _erc20Address) external returns (address asset) {
    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "CrowdsaleGeneratorERC20"))) ||
            msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "CrowdsaleGeneratorETH"))) ||
            msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "AssetGenerator"))) );
    Minter_MiniMeTokenFactory factory = Minter_MiniMeTokenFactory(database.addressStorage(keccak256(abi.encodePacked("platform.tokenFactory"))));
    asset = factory.createCloneToken(address(0), 0, _uri, uint8(18), _uri, true, _erc20Address);
    return asset;
  }

  function mintAssetTokens(address _assetAddress, address _receiver, uint256 _amount) external returns (bool){
    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "CrowdsaleERC20"))) ||
            msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "CrowdsaleETH"))) ||
            msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "AssetGenerator"))) );
    require(Minter_MiniMeToken(_assetAddress).generateTokens(_receiver, _amount));
    return true;
  }

  function changeTokenController(address _assetAddress, address _newController) external returns (bool){
    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "DAODeployer"))));
    Minter_MiniMeToken(_assetAddress).changeController(_newController);
  }
}