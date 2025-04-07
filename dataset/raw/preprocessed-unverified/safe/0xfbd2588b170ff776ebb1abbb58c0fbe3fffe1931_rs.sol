/*

 Copyright 2018 RigoBlock, Rigo Investment Sagl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

/// @title Drago Interface - Allows interaction with the Drago contract.
/// @author Gabriele Rigo - <gab@rigoblock.com>
// solhint-disable-next-line


/// @title Drago Registry Interface - Allows external interaction with Drago Registry.
/// @author Gabriele Rigo - <gab@rigoblock.com>
// solhint-disable-next-line


/// @title Drago Data Helper - Allows to query multiple data of a drago at once.
/// @author Gabriele Rigo - <gab@rigoblock.com>
// solhint-disable-next-line
contract HGetDragoData {

    struct DragoData {
        string name;
        string symbol;
        uint256 sellPrice;
        uint256 buyPrice;
        address owner;
        address feeCollector;
        address dragoDao;
        uint256 ratio;
        uint256 transactionFee;
        uint256 totalSupply;
        uint256 ethBalance;
        uint32 minPeriod;
        uint256 id;
        address drago;
    }

    /*
     * CONSTANT PUBLIC FUNCTIONS
     */
    /// @dev Returns structs of infos on a drago from its ID.
    /// @param _dragoRegistry Address of the pools registry.
    /// @param _dragoId Number of the target drago ID.
    /// @return dragoData Structs of data.
    function queryDataFromId(
        address _dragoRegistry,
        uint256 _dragoId)
        external
        view
        returns (
            DragoData memory dragoData
        )
    {
        address drago;
        DragoRegistryFace dragoRegistryInstance = DragoRegistryFace(_dragoRegistry);
        (drago, , , , , ) = dragoRegistryInstance.fromId(_dragoId);
        (
            dragoData
        ) = queryDataInternal(drago);
        dragoData.id = _dragoId;
        dragoData.drago = drago;
    }

    /// @dev Returns structs of infos on a drago from its address.
    /// @param _dragoRegistry Address of the pools registry.
    /// @param _dragoAddress Array of addresses of the target drago.
    /// @return dragoData Arrays of structs of data.
    function queryDataFromAddress(
        address _dragoRegistry,
        address _dragoAddress)
        external
        view
        returns (
            DragoData memory dragoData
        )
    {
        uint256 dragoId;
        DragoRegistryFace dragoRegistryInstance = DragoRegistryFace(_dragoRegistry);
        (dragoId, , , , , ) = dragoRegistryInstance.fromAddress(_dragoAddress);
        (
            dragoData
        ) = queryDataInternal(_dragoAddress);
        dragoData.id = dragoId;
        dragoData.drago = _dragoAddress;
    }

    /// @dev Returns structs of infos on a drago from its ID.
    /// @param _dragoRegistry Address of the drago registry.
    /// @param _dragoIds Array of IDs of the target dragos.
    /// @return Arrays of structs of data and related address of a drago.
    function queryMultiDataFromId(
        address _dragoRegistry,
        uint256[] calldata _dragoIds)
        external
        view
        returns (
            DragoData[] memory
        )
    {
        uint256 length = _dragoIds.length;
        DragoData[] memory dragoData = new DragoData[](length);
        address[] memory dragos = new address[](length);
        address dragoRegistry = _dragoRegistry;
        DragoRegistryFace dragoRegistryInstance = DragoRegistryFace(dragoRegistry);
        for (uint256 i = 0; i < length; i++) {
            uint256 dragoId = _dragoIds[i];
            (dragos[i], , , , , ) = dragoRegistryInstance.fromId(dragoId);
            (
                dragoData[i]
            ) = queryDataInternal(dragos[i]);
            dragoData[i].id = dragoId;
            dragoData[i].drago = dragos[i];
        }
        return(dragoData);
    }

    /// @dev Returns structs of infos on a drago from its address.
    /// @param _dragoRegistry Address of the pools registry.
    /// @param _dragoAddresses Array of addresses of the target dragos.
    /// @return Arrays of structs of data and related address of a drago.
    function queryMultiDataFromAddress(
        address _dragoRegistry,
        address[] calldata _dragoAddresses)
        external
        view
        returns (
            DragoData[] memory
        )
    {
        uint256 length = _dragoAddresses.length;
        DragoData[] memory dragoData = new DragoData[](length);
        uint256[] memory dragoIds = new uint256[](length);
        address[] memory dragos = _dragoAddresses;
        address dragoRegistry = _dragoRegistry;
        DragoRegistryFace dragoRegistryInstance = DragoRegistryFace(dragoRegistry);
        for (uint256 i = 0; i < length; i++) {
            address dragoAddress = dragos[i];
            (dragoIds[i], , , , , ) = dragoRegistryInstance.fromAddress(dragoAddress);
            (
                dragoData[i]
            ) = queryDataInternal(dragos[i]);
            dragoData[i].id = dragoIds[i];
            dragoData[i].drago = dragos[i];
        }
        return(dragoData);
    }

    /*
     * INTERNAL FUNCTIONS
     */
    /// @dev Returns structs of infos on a drago.
    /// @param _drago Array of addresses of the target dragos.
    /// @return dragoData Structs of data.
    function queryDataInternal(
        address _drago)
        internal
        view
        returns (
            DragoData memory dragoData
        )
    {
        DragoFace dragoInstance = DragoFace(_drago);
        (
            dragoData.name,
            dragoData.symbol,
            dragoData.sellPrice,
            dragoData.buyPrice
        ) = dragoInstance.getData();
        (
            dragoData.owner,
            dragoData.feeCollector,
            dragoData.dragoDao,
            dragoData.ratio,
            dragoData.transactionFee,
            dragoData.minPeriod
        ) = dragoInstance.getAdminData();
        dragoData.totalSupply = dragoInstance.totalSupply();
        dragoData.ethBalance = address(_drago).balance;
    }
}