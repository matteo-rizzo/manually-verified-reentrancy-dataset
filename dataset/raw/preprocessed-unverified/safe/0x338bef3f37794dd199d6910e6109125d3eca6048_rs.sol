/**
 *Submitted for verification at Etherscan.io on 2021-03-06
*/

// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol



// pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// Dependency file: @openzeppelin/contracts/utils/SafeCast.sol


// pragma solidity >=0.6.0 <0.8.0;


/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */



// Dependency file: @openzeppelin/contracts/math/SafeMath.sol


// pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */



// Dependency file: @openzeppelin/contracts/math/SignedSafeMath.sol


// pragma solidity >=0.6.0 <0.8.0;

/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
 */



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


// Dependency file: contracts/interfaces/IController.sol

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



// Dependency file: contracts/interfaces/ISetToken.sol

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

// Dependency file: contracts/interfaces/IManagerIssuanceHook.sol

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

// import { ISetToken } from "contracts/interfaces/ISetToken.sol";



// Dependency file: contracts/interfaces/IModuleIssuanceHook.sol

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

// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import { ISetToken } from "contracts/interfaces/ISetToken.sol";


/**
 * CHANGELOG:
 *      - Added a module level issue hook that can be used to set state ahead of component level
 *        issue hooks
 */


// Dependency file: contracts/protocol/lib/Invoke.sol

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

// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";

// import { ISetToken } from "contracts/interfaces/ISetToken.sol";


/**
 * @title Invoke
 * @author Set Protocol
 *
 * A collection of common utility functions for interacting with the SetToken's invoke function
 */


// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


// pragma solidity >=0.6.0 <0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: contracts/lib/ExplicitERC20.sol

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

// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";

/**
 * @title ExplicitERC20
 * @author Set Protocol
 *
 * Utility functions for ERC20 transfers that require the explicit amount to be transferred.
 */



// Dependency file: contracts/interfaces/IModule.sol

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
 * @title IModule
 * @author Set Protocol
 *
 * Interface for interacting with Modules.
 */


// Dependency file: contracts/lib/PreciseUnitMath.sol

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
pragma experimental ABIEncoderV2;

// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
// import { SignedSafeMath } from "@openzeppelin/contracts/math/SignedSafeMath.sol";


/**
 * @title PreciseUnitMath
 * @author Set Protocol
 *
 * Arithmetic for fixed-point numbers with 18 decimals of precision. Some functions taken from
 * dYdX's BaseMath library.
 *
 * CHANGELOG:
 * - 9/21/20: Added safePower function
 */


// Dependency file: contracts/protocol/lib/Position.sol

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


// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { SafeCast } from "@openzeppelin/contracts/utils/SafeCast.sol";
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
// import { SignedSafeMath } from "@openzeppelin/contracts/math/SignedSafeMath.sol";

// import { ISetToken } from "contracts/interfaces/ISetToken.sol";
// import { PreciseUnitMath } from "contracts/lib/PreciseUnitMath.sol";


/**
 * @title Position
 * @author Set Protocol
 *
 * Collection of helper functions for handling and updating SetToken Positions
 *
 * CHANGELOG:
 *  - Updated editExternalPosition to work when no external position is associated with module
 */



// Dependency file: contracts/interfaces/IIntegrationRegistry.sol

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



// Dependency file: contracts/interfaces/IPriceOracle.sol

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
 * @title IPriceOracle
 * @author Set Protocol
 *
 * Interface for interacting with PriceOracle
 */


// Dependency file: contracts/interfaces/ISetValuer.sol

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

// import { ISetToken } from "contracts/interfaces/ISetToken.sol";



// Dependency file: contracts/protocol/lib/ResourceIdentifier.sol

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

// import { IController } from "contracts/interfaces/IController.sol";
// import { IIntegrationRegistry } from "contracts/interfaces/IIntegrationRegistry.sol";
// import { IPriceOracle } from "contracts/interfaces/IPriceOracle.sol";
// import { ISetValuer } from "contracts/interfaces/ISetValuer.sol";

/**
 * @title ResourceIdentifier
 * @author Set Protocol
 *
 * A collection of utility functions to fetch information related to Resource contracts in the system
 */


// Dependency file: contracts/protocol/lib/ModuleBase.sol

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

// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import { AddressArrayUtils } from "contracts/lib/AddressArrayUtils.sol";
// import { ExplicitERC20 } from "contracts/lib/ExplicitERC20.sol";
// import { IController } from "contracts/interfaces/IController.sol";
// import { IModule } from "contracts/interfaces/IModule.sol";
// import { ISetToken } from "contracts/interfaces/ISetToken.sol";
// import { Invoke } from "contracts/protocol/lib/Invoke.sol";
// import { Position } from "contracts/protocol/lib/Position.sol";
// import { PreciseUnitMath } from "contracts/lib/PreciseUnitMath.sol";
// import { ResourceIdentifier } from "contracts/protocol/lib/ResourceIdentifier.sol";
// import { SafeCast } from "@openzeppelin/contracts/utils/SafeCast.sol";
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
// import { SignedSafeMath } from "@openzeppelin/contracts/math/SignedSafeMath.sol";

/**
 * @title ModuleBase
 * @author Set Protocol
 *
 * Abstract class that houses common Module-related state and functions.
 */
abstract contract ModuleBase is IModule {
    using AddressArrayUtils for address[];
    using Invoke for ISetToken;
    using Position for ISetToken;
    using PreciseUnitMath for uint256;
    using ResourceIdentifier for IController;
    using SafeCast for int256;
    using SafeCast for uint256;
    using SafeMath for uint256;
    using SignedSafeMath for int256;

    /* ============ State Variables ============ */

    // Address of the controller
    IController public controller;

    /* ============ Modifiers ============ */

    modifier onlyManagerAndValidSet(ISetToken _setToken) { 
        require(isSetManager(_setToken, msg.sender), "Must be the SetToken manager");
        require(isSetValidAndInitialized(_setToken), "Must be a valid and initialized SetToken");
        _;
    }

    modifier onlySetManager(ISetToken _setToken, address _caller) {
        require(isSetManager(_setToken, _caller), "Must be the SetToken manager");
        _;
    }

    modifier onlyValidAndInitializedSet(ISetToken _setToken) {
        require(isSetValidAndInitialized(_setToken), "Must be a valid and initialized SetToken");
        _;
    }

    /**
     * Throws if the sender is not a SetToken's module or module not enabled
     */
    modifier onlyModule(ISetToken _setToken) {
        require(
            _setToken.moduleStates(msg.sender) == ISetToken.ModuleState.INITIALIZED,
            "Only the module can call"
        );

        require(
            controller.isModule(msg.sender),
            "Module must be enabled on controller"
        );
        _;
    }

    /**
     * Utilized during module initializations to check that the module is in pending state
     * and that the SetToken is valid
     */
    modifier onlyValidAndPendingSet(ISetToken _setToken) {
        require(controller.isSet(address(_setToken)), "Must be controller-enabled SetToken");
        require(isSetPendingInitialization(_setToken), "Must be pending initialization");        
        _;
    }

    /* ============ Constructor ============ */

    /**
     * Set state variables and map asset pairs to their oracles
     *
     * @param _controller             Address of controller contract
     */
    constructor(IController _controller) public {
        controller = _controller;
    }

    /* ============ Internal Functions ============ */

    /**
     * Transfers tokens from an address (that has set allowance on the module).
     *
     * @param  _token          The address of the ERC20 token
     * @param  _from           The address to transfer from
     * @param  _to             The address to transfer to
     * @param  _quantity       The number of tokens to transfer
     */
    function transferFrom(IERC20 _token, address _from, address _to, uint256 _quantity) internal {
        ExplicitERC20.transferFrom(_token, _from, _to, _quantity);
    }

    /**
     * Gets the integration for the module with the passed in name. Validates that the address is not empty
     */
    function getAndValidateAdapter(string memory _integrationName) internal view returns(address) { 
        bytes32 integrationHash = getNameHash(_integrationName);
        return getAndValidateAdapterWithHash(integrationHash);
    }

    /**
     * Gets the integration for the module with the passed in hash. Validates that the address is not empty
     */
    function getAndValidateAdapterWithHash(bytes32 _integrationHash) internal view returns(address) { 
        address adapter = controller.getIntegrationRegistry().getIntegrationAdapterWithHash(
            address(this),
            _integrationHash
        );

        require(adapter != address(0), "Must be valid adapter"); 
        return adapter;
    }

    /**
     * Gets the total fee for this module of the passed in index (fee % * quantity)
     */
    function getModuleFee(uint256 _feeIndex, uint256 _quantity) internal view returns(uint256) {
        uint256 feePercentage = controller.getModuleFee(address(this), _feeIndex);
        return _quantity.preciseMul(feePercentage);
    }

    /**
     * Pays the _feeQuantity from the _setToken denominated in _token to the protocol fee recipient
     */
    function payProtocolFeeFromSetToken(ISetToken _setToken, address _token, uint256 _feeQuantity) internal {
        if (_feeQuantity > 0) {
            _setToken.strictInvokeTransfer(_token, controller.feeRecipient(), _feeQuantity); 
        }
    }

    /**
     * Returns true if the module is in process of initialization on the SetToken
     */
    function isSetPendingInitialization(ISetToken _setToken) internal view returns(bool) {
        return _setToken.isPendingModule(address(this));
    }

    /**
     * Returns true if the address is the SetToken's manager
     */
    function isSetManager(ISetToken _setToken, address _toCheck) internal view returns(bool) {
        return _setToken.manager() == _toCheck;
    }

    /**
     * Returns true if SetToken must be enabled on the controller 
     * and module is registered on the SetToken
     */
    function isSetValidAndInitialized(ISetToken _setToken) internal view returns(bool) {
        return controller.isSet(address(_setToken)) &&
            _setToken.isInitializedModule(address(this));
    }

    /**
     * Hashes the string and returns a bytes32 value
     */
    function getNameHash(string memory _name) internal pure returns(bytes32) {
        return keccak256(bytes(_name));
    }
}

// Root file: contracts/protocol/modules/DebtIssuanceModule.sol

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


// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import { SafeCast } from "@openzeppelin/contracts/utils/SafeCast.sol";
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
// import { SignedSafeMath } from "@openzeppelin/contracts/math/SignedSafeMath.sol";

// import { AddressArrayUtils } from "contracts/lib/AddressArrayUtils.sol";
// import { IController } from "contracts/interfaces/IController.sol";
// import { IManagerIssuanceHook } from "contracts/interfaces/IManagerIssuanceHook.sol";
// import { IModuleIssuanceHook } from "contracts/interfaces/IModuleIssuanceHook.sol";
// import { Invoke } from "contracts/protocol/lib/Invoke.sol";
// import { ISetToken } from "contracts/interfaces/ISetToken.sol";
// import { ModuleBase } from "contracts/protocol/lib/ModuleBase.sol";
// import { Position } from "contracts/protocol/lib/Position.sol";
// import { PreciseUnitMath } from "contracts/lib/PreciseUnitMath.sol";


/**
 * @title DebtIssuanceModule
 * @author Set Protocol
 *
 * The DebtIssuanceModule is a module that enables users to issue and redeem SetTokens that contain default and all
 * external positions, including debt positions. Module hooks are added to allow for syncing of positions, and component
 * level hooks are added to ensure positions are replicated correctly. The manager can define arbitrary issuance logic
 * in the manager hook, as well as specify issue and redeem fees.
 */
contract DebtIssuanceModule is ModuleBase, ReentrancyGuard {

    /* ============ Structs ============ */

    // NOTE: moduleIssuanceHooks uses address[] for compatibility with AddressArrayUtils library
    struct IssuanceSettings {
        uint256 maxManagerFee;                          // Max issue/redeem fee defined on instantiation
        uint256 managerIssueFee;                        // Current manager issuance fees in precise units (10^16 = 1%)
        uint256 managerRedeemFee;                       // Current manager redeem fees in precise units (10^16 = 1%)
        address feeRecipient;                           // Address that receives all manager issue and redeem fees
        IManagerIssuanceHook managerIssuanceHook;       // Instance of manager defined hook, can hold arbitrary logic
        address[] moduleIssuanceHooks;                  // Array of modules that are registered with this module
        mapping(address => bool) isModuleHook;          // Mapping of modules to if they've registered a hook
    }

    /* ============ Events ============ */

    event SetTokenIssued(
        ISetToken indexed _setToken,
        address indexed _issuer,
        address indexed _to,
        address _hookContract,
        uint256 _quantity,
        uint256 _managerFee,
        uint256 _protocolFee
    );
    event SetTokenRedeemed(
        ISetToken indexed _setToken,
        address indexed _redeemer,
        address indexed _to,
        uint256 _quantity,
        uint256 _managerFee,
        uint256 _protocolFee
    );
    event FeeRecipientUpdated(ISetToken indexed _setToken, address _newFeeRecipient);
    event IssueFeeUpdated(ISetToken indexed _setToken, uint256 _newIssueFee);
    event RedeemFeeUpdated(ISetToken indexed _setToken, uint256 _newRedeemFee);

    /* ============ Constants ============ */

    uint256 private constant ISSUANCE_MODULE_PROTOCOL_FEE_SPLIT_INDEX = 0;

    /* ============ State ============ */

    mapping(ISetToken => IssuanceSettings) public issuanceSettings;

    /* ============ Constructor ============ */

    constructor(IController _controller) public ModuleBase(_controller) {}

    /* ============ External Functions ============ */

    /**
     * Deposits components to the SetToken, replicates any external module component positions and mints 
     * the SetToken. If the token has a debt position all collateral will be transferred in first then debt
     * will be returned to the minting address. If specified, a fee will be charged on issuance.
     *
     * @param _setToken         Instance of the SetToken to issue
     * @param _quantity         Quantity of SetToken to issue
     * @param _to               Address to mint SetToken to
     */
    function issue(
        ISetToken _setToken,
        uint256 _quantity,
        address _to
    )
        external
        nonReentrant
        onlyValidAndInitializedSet(_setToken)
    {
        require(_quantity > 0, "Issue quantity must be > 0");

        address hookContract = _callManagerPreIssueHooks(_setToken, _quantity, msg.sender, _to);

        _callModulePreIssueHooks(_setToken, _quantity);

        (
            uint256 quantityWithFees,
            uint256 managerFee,
            uint256 protocolFee
        ) = calculateTotalFees(_setToken, _quantity, true);

        (
            address[] memory components,
            uint256[] memory equityUnits,
            uint256[] memory debtUnits
        ) = _calculateRequiredComponentIssuanceUnits(_setToken, quantityWithFees, true);

        _resolveEquityPositions(_setToken, quantityWithFees, _to, true, components, equityUnits);
        _resolveDebtPositions(_setToken, quantityWithFees, true, components, debtUnits);
        _resolveFees(_setToken, managerFee, protocolFee);

        _setToken.mint(_to, _quantity);

        emit SetTokenIssued(
            _setToken,
            msg.sender,
            _to,
            hookContract,
            _quantity,
            managerFee,
            protocolFee
        );
    }

    /**
     * Returns components from the SetToken, unwinds any external module component positions and burns 
     * the SetToken. If the token has a debt position all debt will be paid down first then equity positions
     * will be returned to the minting address. If specified, a fee will be charged on redeem.
     *
     * @param _setToken         Instance of the SetToken to redeem
     * @param _quantity         Quantity of SetToken to redeem
     * @param _to               Address to send collateral to
     */
    function redeem(
        ISetToken _setToken,
        uint256 _quantity,
        address _to
    )
        external
        nonReentrant
        onlyValidAndInitializedSet(_setToken)
    {
        require(_quantity > 0, "Redeem quantity must be > 0");

        _callModulePreRedeemHooks(_setToken, _quantity);

        // Place burn after pre-redeem hooks because burning tokens may lead to false accounting of synced positions
        _setToken.burn(msg.sender, _quantity);

        (
            uint256 quantityNetFees,
            uint256 managerFee,
            uint256 protocolFee
        ) = calculateTotalFees(_setToken, _quantity, false);

        (
            address[] memory components,
            uint256[] memory equityUnits,
            uint256[] memory debtUnits
        ) = _calculateRequiredComponentIssuanceUnits(_setToken, quantityNetFees, false);

        _resolveDebtPositions(_setToken, quantityNetFees, false, components, debtUnits);
        _resolveEquityPositions(_setToken, quantityNetFees, _to, false, components, equityUnits);
        _resolveFees(_setToken, managerFee, protocolFee);

        emit SetTokenRedeemed(
            _setToken,
            msg.sender,
            _to,
            _quantity,
            managerFee,
            protocolFee
        );
    }

    /**
     * MANAGER ONLY: Updates address receiving issue/redeem fees for a given SetToken.
     *
     * @param _setToken             Instance of the SetToken to update fee recipient
     * @param _newFeeRecipient      New fee recipient address
     */
    function updateFeeRecipient(
        ISetToken _setToken,
        address _newFeeRecipient
    )
        external
        onlyManagerAndValidSet(_setToken)
    {
        require(_newFeeRecipient != address(0), "Fee Recipient must be non-zero address.");
        require(_newFeeRecipient != issuanceSettings[_setToken].feeRecipient, "Same fee recipient passed");

        issuanceSettings[_setToken].feeRecipient = _newFeeRecipient;

        emit FeeRecipientUpdated(_setToken, _newFeeRecipient);
    }

    /**
     * MANAGER ONLY: Updates issue fee for passed SetToken
     *
     * @param _setToken             Instance of the SetToken to update issue fee
     * @param _newIssueFee          New fee amount in preciseUnits (1% = 10^16)
     */
    function updateIssueFee(
        ISetToken _setToken,
        uint256 _newIssueFee
    )
        external
        onlyManagerAndValidSet(_setToken)
    {
        require(_newIssueFee <= issuanceSettings[_setToken].maxManagerFee, "Issue fee can't exceed maximum");
        require(_newIssueFee != issuanceSettings[_setToken].managerIssueFee, "Same issue fee passed");

        issuanceSettings[_setToken].managerIssueFee = _newIssueFee;

        emit IssueFeeUpdated(_setToken, _newIssueFee);
    }

    /**
     * MANAGER ONLY: Updates redeem fee for passed SetToken
     *
     * @param _setToken             Instance of the SetToken to update redeem fee
     * @param _newRedeemFee         New fee amount in preciseUnits (1% = 10^16)
     */
    function updateRedeemFee(
        ISetToken _setToken,
        uint256 _newRedeemFee
    )
        external
        onlyManagerAndValidSet(_setToken)
    {
        require(_newRedeemFee <= issuanceSettings[_setToken].maxManagerFee, "Redeem fee can't exceed maximum");
        require(_newRedeemFee != issuanceSettings[_setToken].managerRedeemFee, "Same redeem fee passed");

        issuanceSettings[_setToken].managerRedeemFee = _newRedeemFee;

        emit RedeemFeeUpdated(_setToken, _newRedeemFee);
    }

    /**
     * MODULE ONLY: Adds calling module to array of modules that require they be called before component hooks are
     * called. Can be used to sync debt positions before issuance.
     *
     * @param _setToken             Instance of the SetToken to issue
     */
    function registerToIssuanceModule(ISetToken _setToken) external onlyModule(_setToken) onlyValidAndInitializedSet(_setToken) {
        require(!issuanceSettings[_setToken].isModuleHook[msg.sender], "Module already registered.");
        issuanceSettings[_setToken].moduleIssuanceHooks.push(msg.sender);
        issuanceSettings[_setToken].isModuleHook[msg.sender] = true;
    }

    /**
     * MODULE ONLY: Removes calling module from array of modules that require they be called before component hooks are
     * called.
     *
     * @param _setToken             Instance of the SetToken to issue
     */
    function unregisterFromIssuanceModule(ISetToken _setToken) external onlyModule(_setToken) onlyValidAndInitializedSet(_setToken) {
        require(issuanceSettings[_setToken].isModuleHook[msg.sender], "Module not registered.");
        issuanceSettings[_setToken].moduleIssuanceHooks.removeStorage(msg.sender);
        issuanceSettings[_setToken].isModuleHook[msg.sender] = false;
    }

    /**
     * MANAGER ONLY: Initializes this module to the SetToken with issuance-related hooks and fee information. Only callable
     * by the SetToken's manager. Hook addresses are optional. Address(0) means that no hook will be called
     *
     * @param _setToken                     Instance of the SetToken to issue
     * @param _maxManagerFee                Maximum fee that can be charged on issue and redeem
     * @param _managerIssueFee              Fee to charge on issuance
     * @param _managerRedeemFee             Fee to charge on redemption
     * @param _feeRecipient                 Address to send fees to
     * @param _managerIssuanceHook          Instance of the Manager Contract with the Pre-Issuance Hook function
     */
    function initialize(
        ISetToken _setToken,
        uint256 _maxManagerFee,
        uint256 _managerIssueFee,
        uint256 _managerRedeemFee,
        address _feeRecipient,
        IManagerIssuanceHook _managerIssuanceHook
    )
        external
        onlySetManager(_setToken, msg.sender)
        onlyValidAndPendingSet(_setToken)
    {
        require(_managerIssueFee <= _maxManagerFee, "Issue fee can't exceed maximum fee");
        require(_managerRedeemFee <= _maxManagerFee, "Redeem fee can't exceed maximum fee");

        issuanceSettings[_setToken] = IssuanceSettings({
            maxManagerFee: _maxManagerFee,
            managerIssueFee: _managerIssueFee,
            managerRedeemFee: _managerRedeemFee,
            feeRecipient: _feeRecipient,
            managerIssuanceHook: _managerIssuanceHook,
            moduleIssuanceHooks: new address[](0)
        });

        _setToken.initializeModule();
    }

    /**
     * SET TOKEN ONLY: Allows removal of module (and deletion of state) if no other modules are registered.
     */
    function removeModule() external override {
        require(issuanceSettings[ISetToken(msg.sender)].moduleIssuanceHooks.length == 0, "Registered modules must be removed.");
        delete issuanceSettings[ISetToken(msg.sender)];
    }

    /* ============ External View Functions ============ */

    /**
     * Calculates the manager fee, protocol fee and resulting totalQuantity to use when calculating unit amounts. If fees are charged they
     * are added to the total issue quantity, for example 1% fee on 100 Sets means 101 Sets are minted by caller, the _to address receives
     * 100 and the feeRecipient receives 1. Conversely, on redemption the redeemer will only receive the collateral that collateralizes 99
     * Sets, while the additional Set is given to the feeRecipient.
     *
     * @param _setToken                 Instance of the SetToken to issue
     * @param _quantity                 Amount of SetToken issuer wants to receive/redeem
     * @param _isIssue                  If issuing or redeeming
     *
     * @return totalQuantity           Total amount of Sets to be issued/redeemed with fee adjustment
     * @return managerFee              Sets minted to the manager
     * @return protocolFee             Sets minted to the protocol
     */
    function calculateTotalFees(
        ISetToken _setToken,
        uint256 _quantity,
        bool _isIssue
    )
        public
        view
        returns (uint256 totalQuantity, uint256 managerFee, uint256 protocolFee)
    {
        IssuanceSettings memory setIssuanceSettings = issuanceSettings[_setToken];
        uint256 protocolFeeSplit = controller.getModuleFee(address(this), ISSUANCE_MODULE_PROTOCOL_FEE_SPLIT_INDEX);
        uint256 totalFeeRate = _isIssue ? setIssuanceSettings.managerIssueFee : setIssuanceSettings.managerRedeemFee;
        
        uint256 totalFee = totalFeeRate.preciseMul(_quantity);
        protocolFee = totalFee.preciseMul(protocolFeeSplit);
        managerFee = totalFee.sub(protocolFee);

        totalQuantity = _isIssue ? _quantity.add(totalFee) : _quantity.sub(totalFee);
    }

    /**
     * Calculates the amount of each component needed to collateralize passed issue quantity plus fees of Sets as well as amount of debt
     * that will be returned to caller. Values DO NOT take into account any updates from pre action manager or module hooks.
     *
     * @param _setToken         Instance of the SetToken to issue
     * @param _quantity         Amount of Sets to be issued
     *
     * @return address[]        Array of component addresses making up the Set
     * @return uint256[]        Array of equity notional amounts of each component, respectively, represented as uint256
     * @return uint256[]        Array of debt notional amounts of each component, respectively, represented as uint256
     */
    function getRequiredComponentIssuanceUnits(
        ISetToken _setToken,
        uint256 _quantity
    )
        external
        view
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {
        (
            uint256 totalQuantity,,
        ) = calculateTotalFees(_setToken, _quantity, true);

        return _calculateRequiredComponentIssuanceUnits(_setToken, totalQuantity, true);
    }

    /**
     * Calculates the amount of each component will be returned on redemption net of fees as well as how much debt needs to be paid down to.
     * redeem. Values DO NOT take into account any updates from pre action manager or module hooks.
     *
     * @param _setToken         Instance of the SetToken to issue
     * @param _quantity         Amount of Sets to be redeemed
     *
     * @return address[]        Array of component addresses making up the Set
     * @return uint256[]        Array of equity notional amounts of each component, respectively, represented as uint256
     * @return uint256[]        Array of debt notional amounts of each component, respectively, represented as uint256
     */
    function getRequiredComponentRedemptionUnits(
        ISetToken _setToken,
        uint256 _quantity
    )
        external
        view
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {
        (
            uint256 totalQuantity,,
        ) = calculateTotalFees(_setToken, _quantity, false);

        return _calculateRequiredComponentIssuanceUnits(_setToken, totalQuantity, false);
    }

    function getModuleIssuanceHooks(ISetToken _setToken) external view returns(address[] memory) {
        return issuanceSettings[_setToken].moduleIssuanceHooks;
    }

    function isModuleIssuanceHook(ISetToken _setToken, address _hook) external view returns(bool) {
        return issuanceSettings[_setToken].isModuleHook[_hook];
    }

    /* ============ Internal Functions ============ */

    /**
     * Calculates the amount of each component needed to collateralize passed issue quantity of Sets as well as amount of debt that will
     * be returned to caller. Can also be used to determine how much collateral will be returned on redemption as well as how much debt
     * needs to be paid down to redeem.
     *
     * @param _setToken         Instance of the SetToken to issue
     * @param _quantity         Amount of Sets to be issued/redeemed
     * @param _isIssue          Whether Sets are being issued or redeemed
     *
     * @return address[]        Array of component addresses making up the Set
     * @return uint256[]        Array of equity notional amounts of each component, respectively, represented as uint256
     * @return uint256[]        Array of debt notional amounts of each component, respectively, represented as uint256
     */
    function _calculateRequiredComponentIssuanceUnits(
        ISetToken _setToken,
        uint256 _quantity,
        bool _isIssue
    )
        internal
        view
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {
        (
            address[] memory components,
            uint256[] memory equityUnits,
            uint256[] memory debtUnits
        ) = _getTotalIssuanceUnits(_setToken);

        uint256 componentsLength = components.length;
        uint256[] memory totalEquityUnits = new uint256[](componentsLength);
        uint256[] memory totalDebtUnits = new uint256[](componentsLength);
        for (uint256 i = 0; i < components.length; i++) {
            // Use preciseMulCeil to round up to ensure overcollateration when small issue quantities are provided
            // and preciseMul to round down to ensure overcollateration when small redeem quantities are provided
            totalEquityUnits[i] = _isIssue ?
                equityUnits[i].preciseMulCeil(_quantity) :
                equityUnits[i].preciseMul(_quantity);

            totalDebtUnits[i] = _isIssue ?
                debtUnits[i].preciseMul(_quantity) :
                debtUnits[i].preciseMulCeil(_quantity);
        }

        return (components, totalEquityUnits, totalDebtUnits);
    }

    /**
     * Sums total debt and equity units for each component, taking into account default and external positions.
     *
     * @param _setToken         Instance of the SetToken to issue
     *
     * @return address[]        Array of component addresses making up the Set
     * @return uint256[]        Array of equity unit amounts of each component, respectively, represented as uint256
     * @return uint256[]        Array of debt unit amounts of each component, respectively, represented as uint256
     */
    function _getTotalIssuanceUnits(
        ISetToken _setToken
    )
        internal
        view
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {
        address[] memory components = _setToken.getComponents();
        uint256 componentsLength = components.length;

        uint256[] memory equityUnits = new uint256[](componentsLength);
        uint256[] memory debtUnits = new uint256[](componentsLength);

        for (uint256 i = 0; i < components.length; i++) {
            address component = components[i];
            int256 cumulativeEquity = _setToken.getDefaultPositionRealUnit(component);
            int256 cumulativeDebt = 0;
            address[] memory externalPositions = _setToken.getExternalPositionModules(component);

            if (externalPositions.length > 0) {
                for (uint256 j = 0; j < externalPositions.length; j++) { 
                    int256 externalPositionUnit = _setToken.getExternalPositionRealUnit(component, externalPositions[j]);

                    // If positionUnit <= 0 it will be "added" to debt position
                    if (externalPositionUnit > 0) {
                        cumulativeEquity = cumulativeEquity.add(externalPositionUnit);
                    } else {
                        cumulativeDebt = cumulativeDebt.add(externalPositionUnit);
                    }
                }
            }

            equityUnits[i] = cumulativeEquity.toUint256();
            debtUnits[i] = cumulativeDebt.mul(-1).toUint256();
        }

        return (components, equityUnits, debtUnits);
    }

    /**
     * Resolve equity positions associated with SetToken. On issuance, the total equity position for an asset (including default and external
     * positions) is transferred in. Then any external position hooks are called to transfer the external positions to their necessary place.
     * On redemption all external positions are recalled by the external position hook, then those position plus any default position are
     * transferred back to the _to address.
     */
    function _resolveEquityPositions(
        ISetToken _setToken,
        uint256 _quantity,
        address _to,
        bool _isIssue,
        address[] memory _components,
        uint256[] memory _componentEquityQuantities
    )
        internal
    {
        for (uint256 i = 0; i < _components.length; i++) {
            address component = _components[i];
            uint256 componentQuantity = _componentEquityQuantities[i];
            if (componentQuantity > 0) {
                if (_isIssue) {
                    transferFrom(
                        IERC20(component),
                        msg.sender,
                        address(_setToken),
                        componentQuantity
                    );

                    _executeExternalPositionHooks(_setToken, _quantity, IERC20(component), true, true);
                } else {
                    _executeExternalPositionHooks(_setToken, _quantity, IERC20(component), false, true);

                    _setToken.strictInvokeTransfer(
                        component,
                        _to,
                        componentQuantity
                    );
                }
            }
        }
    }

    /**
     * Resolve debt positions associated with SetToken. On issuance, debt positions are entered into by calling the external position hook. The
     * resulting debt is then returned to the calling address. On redemption, the module transfers in the required debt amount from the caller
     * and uses those funds to repay the debt on behalf of the SetToken.
     */
    function _resolveDebtPositions(
        ISetToken _setToken,
        uint256 _quantity,
        bool _isIssue,
        address[] memory _components,
        uint256[] memory _componentDebtQuantities
    )
        internal
    {
        for (uint256 i = 0; i < _components.length; i++) {
            address component = _components[i];
            uint256 componentQuantity = _componentDebtQuantities[i];
            if (componentQuantity > 0) {
                if (_isIssue) {
                    _executeExternalPositionHooks(_setToken, _quantity, IERC20(component), true, false);
                    _setToken.strictInvokeTransfer(
                        component,
                        msg.sender,
                        componentQuantity
                    );
                } else {
                    transferFrom(
                        IERC20(component),
                        msg.sender,
                        address(_setToken),
                        componentQuantity
                    );
                    _executeExternalPositionHooks(_setToken, _quantity, IERC20(component), false, false);
                }
            }
        }
    }

    /**
     * If any manager fees mints Sets to the defined feeRecipient. If protocol fee is enabled mints Sets to protocol
     * feeRecipient. 
     */
    function _resolveFees(ISetToken _setToken, uint256 managerFee, uint256 protocolFee) internal {
        if (managerFee > 0) {
            _setToken.mint(issuanceSettings[_setToken].feeRecipient, managerFee);

            // Protocol fee check is inside manager fee check because protocol fees are only collected on manager fees
            if (protocolFee > 0) {
                _setToken.mint(controller.feeRecipient(), protocolFee);
            }
        }
    }

    /**
     * If a pre-issue hook has been configured, call the external-protocol contract. Pre-issue hook logic
     * can contain arbitrary logic including validations, external function calls, etc.
     */
    function _callManagerPreIssueHooks(
        ISetToken _setToken,
        uint256 _quantity,
        address _caller,
        address _to
    )
        internal
        returns(address)
    {
        IManagerIssuanceHook preIssueHook = issuanceSettings[_setToken].managerIssuanceHook;
        if (address(preIssueHook) != address(0)) {
            preIssueHook.invokePreIssueHook(_setToken, _quantity, _caller, _to);
            return address(preIssueHook);
        }

        return address(0);
    }
    
    /**
     * Calls all modules that have registered with the DebtIssuanceModule that have a moduleIssueHook.
     */
    function _callModulePreIssueHooks(ISetToken _setToken, uint256 _quantity) internal {
        address[] memory issuanceHooks = issuanceSettings[_setToken].moduleIssuanceHooks;
        for (uint256 i = 0; i < issuanceHooks.length; i++) {
            IModuleIssuanceHook(issuanceHooks[i]).moduleIssueHook(_setToken, _quantity);
        }
    }

    /**
     * Calls all modules that have registered with the DebtIssuanceModule that have a moduleRedeemHook.
     */
    function _callModulePreRedeemHooks(ISetToken _setToken, uint256 _quantity) internal {
        address[] memory issuanceHooks = issuanceSettings[_setToken].moduleIssuanceHooks;
        for (uint256 i = 0; i < issuanceHooks.length; i++) {
            IModuleIssuanceHook(issuanceHooks[i]).moduleRedeemHook(_setToken, _quantity);
        }
    }

    /**
     * For each component's external module positions, calculate the total notional quantity, and 
     * call the module's issue hook or redeem hook.
     * Note: It is possible that these hooks can cause the states of other modules to change.
     * It can be problematic if the hook called an external function that called back into a module, resulting in state inconsistencies.
     */
    function _executeExternalPositionHooks(
        ISetToken _setToken,
        uint256 _setTokenQuantity,
        IERC20 _component,
        bool _isIssue,
        bool _isEquity
    )
        internal
    {
        address[] memory externalPositionModules = _setToken.getExternalPositionModules(address(_component));
        uint256 modulesLength = externalPositionModules.length;
        if (_isIssue) {
            for (uint256 i = 0; i < modulesLength; i++) {
                IModuleIssuanceHook(externalPositionModules[i]).componentIssueHook(_setToken, _setTokenQuantity, _component, _isEquity);
            }
        } else {
            for (uint256 i = 0; i < modulesLength; i++) {
                IModuleIssuanceHook(externalPositionModules[i]).componentRedeemHook(_setToken, _setTokenQuantity, _component, _isEquity);
            }
        }
    }
}