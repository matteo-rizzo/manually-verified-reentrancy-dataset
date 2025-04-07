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

        keyRegistry = DharmaKeyRegistryInterface(
            0x00000000006c7f32F0cD1eA4C1383558eb68802D
        );

        actionID = keccak256(
            abi.encodePacked(
                address(smartWallet),
                version,
                smartWallet.getUserSigningKey(),
                keyRegistry.getGlobalKey(),
                smartWallet.getNonce(),
                minimumActionGas,
                DharmaSmartWalletImplementationV0Interface.ActionType.SetUserSigningKey,
                abi.encode(userSigningKey)
            )
        );
    }
}