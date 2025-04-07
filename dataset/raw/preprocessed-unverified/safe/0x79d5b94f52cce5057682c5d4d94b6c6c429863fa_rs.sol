/**
 *Submitted for verification at Etherscan.io on 2019-10-31
*/

pragma solidity 0.5.11;








contract SetUserSigningKeyActionIDHelper {
  function getSetUserSigningKeyActionID(
    DharmaSmartWalletImplementationV0Interface smartWallet,
    address userSigningKey,
    uint256 minimumActionGas
  ) external view returns (bytes32 actionID) {
    uint256 version = smartWallet.getVersion();
    DharmaKeyRegistryInterface keyRegistry;
    if (version == 2) {
      keyRegistry = DharmaKeyRegistryInterface(
        0x000000005D7065eB9716a410070Ee62d51092C98
      );
    } else {
      keyRegistry = DharmaKeyRegistryInterface(
        0x000000000D38df53b45C5733c7b34000dE0BDF52
      );
    }
      
    actionID = keccak256(
      abi.encodePacked(
        address(smartWallet),
        version,
        smartWallet.getUserSigningKey(),
        keyRegistry.getKeyForUser(address(smartWallet)),
        smartWallet.getNonce(),
        minimumActionGas,
        DharmaSmartWalletImplementationV0Interface.ActionType.SetUserSigningKey,
        abi.encode(userSigningKey)
      )
    );
  }
}