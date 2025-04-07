// "SPDX-License-Identifier: UNLICENSED"
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

// solhint-disable

enum Operation {Call, Delegatecall}

enum DataFlow {None, In, Out, InAndOut}



struct Condition {
    IGelatoCondition inst; // can be AddressZero for self-conditional Actions
    bytes data; // can be bytes32(0) for self-conditional Actions
}

struct Action {
    address addr;
    bytes data;
    Operation operation;
    DataFlow dataFlow;
    uint256 value;
    bool termsOkCheck;
}

struct Task {
    Condition[] conditions; // optional
    Action[] actions;
    uint256 selfProviderGasLimit; // optional: 0 defaults to gelatoMaxGas
    uint256 selfProviderGasPriceCeil; // optional: 0 defaults to NO_CEIL
}



abstract contract GelatoProviderModuleStandard is IGelatoProviderModule {
    string internal constant OK = "OK";

    function isProvided(
        address,
        address,
        Task calldata
    ) external view virtual override returns (string memory) {
        return OK;
    }

    /// @dev Overriding fns should revert with the revertMsg they detected on the userProxy
    function execRevertCheck(bytes calldata) external pure virtual override {
        // By default no reverts detected => do nothing
    }
}

/// @dev InstaDapp Index


/// @dev InstaDapp List


/// @dev InstaDapp Connectors


/// @dev InstaDapp Defi Smart Account wallet


contract ProviderModuleDSA is GelatoProviderModuleStandard {
    IndexInterface public immutable index;
    address public immutable gelatoCore;

    constructor(IndexInterface _index, address _gelatoCore) {
        index = _index;
        gelatoCore = _gelatoCore;
    }

    // ================= GELATO PROVIDER MODULE STANDARD ================
    function isProvided(
        address _userProxy,
        address,
        Task calldata
    ) external view override returns (string memory) {
        // Verify InstaDapp account identity
        if (ListInterface(index.list()).accountID(_userProxy) == 0)
            return "ProviderModuleDSA.isProvided:InvalidUserProxy";

        // Is GelatoCore authorized
        if (!AccountInterface(_userProxy).isAuth(gelatoCore))
            return "ProviderModuleDSA.isProvided:GelatoCoreNotAuth";

        // @dev commented out for gas savings

        // // Is connector valid
        // ConnectorsInterface connectors = ConnectorsInterface(index.connectors(
        //     AccountInterface(_userProxy).version()
        // ));

        // address[] memory targets = new address[](_task.actions.length);
        // for (uint i = 0; i < _task.actions.length; i++)
        //     targets[i] = _task.actions[i].addr;

        // bool isShield = AccountInterface(_userProxy).shield();
        // if (isShield)
        //     if (!connectors.isStaticConnector(targets))
        //         return "ProviderModuleDSA.isProvided:not-static-connector";
        // else
        //     if (!connectors.isConnector(targets))
        //         return "ProviderModuleDSA.isProvided:not-connector";

        return OK;
    }

    /// @dev DS PROXY ONLY ALLOWS DELEGATE CALL for single actions, that's why we also use multisend
    function execPayload(
        uint256,
        address,
        address,
        Task calldata _task,
        uint256
    ) external view override returns (bytes memory payload, bool) {
        address[] memory targets = new address[](_task.actions.length);
        for (uint256 i = 0; i < _task.actions.length; i++)
            targets[i] = _task.actions[i].addr;

        bytes[] memory datas = new bytes[](_task.actions.length);
        for (uint256 i = 0; i < _task.actions.length; i++)
            datas[i] = _task.actions[i].data;

        payload = abi.encodeWithSelector(
            AccountInterface.cast.selector,
            targets,
            datas,
            gelatoCore
        );
    }
}