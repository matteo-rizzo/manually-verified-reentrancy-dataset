/**
 *Submitted for verification at Etherscan.io on 2021-02-17
*/

// Dependency file: @openzeppelin/contracts/utils/Address.sol



// pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: contracts/interfaces/ISetToken.sol

// pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";

// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ISetToken
 * @author Set Protocol
 *
 * Interface for operating with SetTokens.
 */
interface ISetToken is IERC20 {

    /* ============ Enums ============ */

    enum ModuleState {
        NONE,
        PENDING,
        INITIALIZED
    }

    /* ============ Structs ============ */
    /**
     * The base definition of a SetToken Position
     *
     * @param component           Address of token in the Position
     * @param module              If not in default state, the address of associated module
     * @param unit                Each unit is the # of components per 10^18 of a SetToken
     * @param positionState       Position ENUM. Default is 0; External is 1
     * @param data                Arbitrary data
     */
    struct Position {
        address component;
        address module;
        int256 unit;
        uint8 positionState;
        bytes data;
    }

    /**
     * A struct that stores a component's cash position details and external positions
     * This data structure allows O(1) access to a component's cash position units and 
     * virtual units.
     *
     * @param virtualUnit               Virtual value of a component's DEFAULT position. Stored as virtual for efficiency
     *                                  updating all units at once via the position multiplier. Virtual units are achieved
     *                                  by dividing a "real" value by the "positionMultiplier"
     * @param componentIndex            
     * @param externalPositionModules   List of external modules attached to each external position. Each module
     *                                  maps to an external position
     * @param externalPositions         Mapping of module => ExternalPosition struct for a given component
     */
    struct ComponentPosition {
      int256 virtualUnit;
      address[] externalPositionModules;
      mapping(address => ExternalPosition) externalPositions;
    }

    /**
     * A struct that stores a component's external position details including virtual unit and any
     * auxiliary data.
     *
     * @param virtualUnit       Virtual value of a component's EXTERNAL position.
     * @param data              Arbitrary data
     */
    struct ExternalPosition {
      int256 virtualUnit;
      bytes data;
    }


    /* ============ Functions ============ */
    
    function addComponent(address _component) external;
    function removeComponent(address _component) external;
    function editDefaultPositionUnit(address _component, int256 _realUnit) external;
    function addExternalPositionModule(address _component, address _positionModule) external;
    function removeExternalPositionModule(address _component, address _positionModule) external;
    function editExternalPositionUnit(address _component, address _positionModule, int256 _realUnit) external;
    function editExternalPositionData(address _component, address _positionModule, bytes calldata _data) external;

    function invoke(address _target, uint256 _value, bytes calldata _data) external returns(bytes memory);

    function editPositionMultiplier(int256 _newMultiplier) external;

    function mint(address _account, uint256 _quantity) external;
    function burn(address _account, uint256 _quantity) external;

    function lock() external;
    function unlock() external;

    function addModule(address _module) external;
    function removeModule(address _module) external;
    function initializeModule() external;

    function setManager(address _manager) external;

    function manager() external view returns (address);
    function moduleStates(address _module) external view returns (ModuleState);
    function getModules() external view returns (address[] memory);
    
    function getDefaultPositionRealUnit(address _component) external view returns(int256);
    function getExternalPositionRealUnit(address _component, address _positionModule) external view returns(int256);
    function getComponents() external view returns(address[] memory);
    function getExternalPositionModules(address _component) external view returns(address[] memory);
    function getExternalPositionData(address _component, address _positionModule) external view returns(bytes memory);
    function isExternalPositionModule(address _component, address _module) external view returns(bool);
    function isComponent(address _component) external view returns(bool);
    
    function positionMultiplier() external view returns (int256);
    function getPositions() external view returns (Position[] memory);
    function getTotalComponentRealUnits(address _component) external view returns(int256);

    function isInitializedModule(address _module) external view returns(bool);
    function isPendingModule(address _module) external view returns(bool);
    function isLocked() external view returns (bool);
}

// Dependency file: contracts/lib/AddressArrayUtils.sol

/*
    Copyright 2020 Set Labs Inc.

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

// pragma solidity 0.6.10;

/**
 * @title AddressArrayUtils
 * @author Set Protocol
 *
 * Utility functions to handle Address Arrays
 */


// Dependency file: contracts/lib/MutualUpgrade.sol

/*
    Copyright 2018 Set Labs Inc.

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

// pragma solidity 0.6.10;

/**
 * @title MutualUpgrade
 * @author Set Protocol
 *
 * The MutualUpgrade contract contains a modifier for handling mutual upgrades between two parties
 */
contract MutualUpgrade {
    /* ============ State Variables ============ */

    // Mapping of upgradable units and if upgrade has been initialized by other party
    mapping(bytes32 => bool) public mutualUpgrades;

    /* ============ Events ============ */

    event MutualUpgradeRegistered(
        bytes32 _upgradeHash
    );

    /* ============ Modifiers ============ */

    modifier mutualUpgrade(address _signerOne, address _signerTwo) {
        require(
            msg.sender == _signerOne || msg.sender == _signerTwo,
            "Must be authorized address"
        );

        address nonCaller = _getNonCaller(_signerOne, _signerTwo);

        // The upgrade hash is defined by the hash of the transaction call data and sender of msg,
        // which uniquely identifies the function, arguments, and sender.
        bytes32 expectedHash = keccak256(abi.encodePacked(msg.data, nonCaller));

        if (!mutualUpgrades[expectedHash]) {
            bytes32 newHash = keccak256(abi.encodePacked(msg.data, msg.sender));

            mutualUpgrades[newHash] = true;

            emit MutualUpgradeRegistered(newHash);

            return;
        }

        delete mutualUpgrades[expectedHash];

        // Run the rest of the upgrades
        _;
    }

    /* ============ Internal Functions ============ */

    function _getNonCaller(address _signerOne, address _signerTwo) internal view returns(address) {
        return msg.sender == _signerOne ? _signerTwo : _signerOne;
    }
}


// Root file: contracts/manager/ICManagerV2.sol

/*
    Copyright 2021 Set Labs Inc.

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

pragma solidity 0.6.10;

// import { Address } from "@openzeppelin/contracts/utils/Address.sol";
// import { ISetToken } from "contracts/interfaces/ISetToken.sol";
// import { AddressArrayUtils } from "contracts/lib/AddressArrayUtils.sol";
// import { MutualUpgrade } from "contracts/lib/MutualUpgrade.sol";

/**
 * @title ICManagerV2
 * @author Set Protocol
 *
 * Smart contract manager that contains permissions and admin functionality
 */
contract ICManagerV2 is MutualUpgrade {
    using Address for address;
    using AddressArrayUtils for address[];

    /* ============ Events ============ */

    event AdapterAdded(
        address _adapter
    );

    event AdapterRemoved(
        address _adapter
    );

    event MethodologistChanged(
        address _oldMethodologist,
        address _newMethodologist
    );

    event OperatorChanged(
        address _oldOperator,
        address _newOperator
    );

    /* ============ Modifiers ============ */

    /**
     * Throws if the sender is not the SetToken operator
     */
    modifier onlyOperator() {
        require(msg.sender == operator, "Must be operator");
        _;
    }

    /**
     * Throws if the sender is not the SetToken methodologist
     */
    modifier onlyMethodologist() {
        require(msg.sender == methodologist, "Must be methodologist");
        _;
    }

    /**
     * Throws if the sender is not a listed adapter
     */
    modifier onlyAdapter() {
        require(isAdapter[msg.sender], "Must be adapter");
        _;
    }

    /* ============ State Variables ============ */

    // Instance of SetToken
    ISetToken public setToken;

    // Array of listed adapters
    address[] adapters;

    // Mapping to check if adapter is added
    mapping(address => bool) public isAdapter;

    // Address of operator
    address public operator;

    // Address of methodologist
    address public methodologist;

    /* ============ Constructor ============ */

    constructor(
        ISetToken _setToken,
        address _operator,
        address _methodologist,
        address[] memory _adapters
    )
        public
    {
        setToken = _setToken;
        operator = _operator;
        methodologist = _methodologist;

        for (uint256 i = 0; i < _adapters.length; i++) {
            require(!isAdapter[_adapters[i]], "Adapter already exists");

            isAdapter[_adapters[i]] = true;
        }
        adapters = _adapters;
    }

    /* ============ External Functions ============ */

    /**
     * MUTUAL UPGRADE: Update the SetToken manager address. Operator and Methodologist must each call
     * this function to execute the update.
     *
     * @param _newManager           New manager address
     */
    function setManager(address _newManager) external mutualUpgrade(operator, methodologist) {
        setToken.setManager(_newManager);
    }

    /**
     * MUTUAL UPGRADE: Add a new adapter that the ICManagerV2 can call.
     *
     * @param _adapter           New adapter to add
     */
    function addAdapter(address _adapter) external mutualUpgrade(operator, methodologist) {
        require(!isAdapter[_adapter], "Adapter already exists");

        adapters.push(_adapter);

        isAdapter[_adapter] = true;

        emit AdapterAdded(_adapter);
    }

    /**
     * MUTUAL UPGRADE: Remove an existing adapter tracked by the ICManagerV2.
     *
     * @param _adapter           Old adapter to remove
     */
    function removeAdapter(address _adapter) external mutualUpgrade(operator, methodologist) {
        require(isAdapter[_adapter], "Adapter does not exist");

        adapters = adapters.remove(_adapter);

        isAdapter[_adapter] = false;

        emit AdapterRemoved(_adapter);
    }

    /**
     * ADAPTER ONLY: Interact with a module registered on the SetToken.
     *
     * @param _module           Module to interact with
     * @param _data             Byte data of function to call in module
     */
    function interactModule(address _module, bytes calldata _data) external onlyAdapter {
        // Invoke call to module, assume value will always be 0
        _module.functionCallWithValue(_data, 0);
    }

    /**
     * OPERATOR ONLY: Add a new module to the SetToken.
     *
     * @param _module           New module to add
     */
    function addModule(address _module) external onlyOperator {
        setToken.addModule(_module);
    }

    /**
     * OPERATOR ONLY: Remove a new module from the SetToken.
     *
     * @param _module           Module to remove
     */
    function removeModule(address _module) external onlyOperator {
        setToken.removeModule(_module);
    }

    /**
     * METHODOLOGIST ONLY: Update the methodologist address
     *
     * @param _newMethodologist           New methodologist address
     */
    function setMethodologist(address _newMethodologist) external onlyMethodologist {
        emit MethodologistChanged(methodologist, _newMethodologist);

        methodologist = _newMethodologist;
    }

    /**
     * OPERATOR ONLY: Update the operator address
     *
     * @param _newOperator           New operator address
     */
    function setOperator(address _newOperator) external onlyOperator {
        emit OperatorChanged(operator, _newOperator);

        operator = _newOperator;
    }

    function getAdapters() external view returns(address[] memory) {
        return adapters;
    }
}