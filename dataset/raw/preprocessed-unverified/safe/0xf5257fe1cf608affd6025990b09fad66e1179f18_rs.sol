/**
 *Submitted for verification at Etherscan.io on 2020-10-30
*/

// Dependency file: @openzeppelin/contracts/utils/Address.sol



// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
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

// import { ISetToken } from "../interfaces/ISetToken.sol";


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


// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol



// pragma solidity ^0.6.0;

// import "./IERC20.sol";
// import "../../math/SafeMath.sol";
// import "../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// Dependency file: @openzeppelin/contracts/math/SignedSafeMath.sol



// pragma solidity ^0.6.0;

/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
 */


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

// import { IController } from "../../interfaces/IController.sol";
// import { IIntegrationRegistry } from "../../interfaces/IIntegrationRegistry.sol";
// import { IPriceOracle } from "../../interfaces/IPriceOracle.sol";
// import { ISetValuer } from "../../interfaces/ISetValuer.sol";

/**
 * @title ResourceIdentifier
 * @author Set Protocol
 *
 * A collection of utility functions to fetch information related to Resource contracts in the system
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


// Dependency file: contracts/lib/Uint256ArrayUtils.sol

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
 * @title Uint256ArrayUtils
 * @author Set Protocol
 *
 * Utility functions to handle Uint256 Arrays
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
// pragma experimental ABIEncoderV2;

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
// pragma experimental "ABIEncoderV2";

// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { SafeCast } from "@openzeppelin/contracts/utils/SafeCast.sol";
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
// import { SignedSafeMath } from "@openzeppelin/contracts/math/SignedSafeMath.sol";

// import { ISetToken } from "../../interfaces/ISetToken.sol";
// import { PreciseUnitMath } from "../../lib/PreciseUnitMath.sol";


/**
 * @title Position
 * @author Set Protocol
 *
 * Collection of helper functions for handling and updating SetToken Positions
 *
 * CHANGELOG:
 *  - Updated editExternalPosition to work when no external position is associated with module
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

// import { ExplicitERC20 } from "../../lib/ExplicitERC20.sol";
// import { IController } from "../../interfaces/IController.sol";
// import { IModule } from "../../interfaces/IModule.sol";
// import { ISetToken } from "../../interfaces/ISetToken.sol";
// import { Invoke } from "./Invoke.sol";
// import { PreciseUnitMath } from "../../lib/PreciseUnitMath.sol";
// import { ResourceIdentifier } from "./ResourceIdentifier.sol";

/**
 * @title ModuleBase
 * @author Set Protocol
 *
 * Abstract class that houses common Module-related state and functions.
 */
abstract contract ModuleBase is IModule {
    using PreciseUnitMath for uint256;
    using Invoke for ISetToken;
    using ResourceIdentifier for IController;

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
// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol



// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

// Dependency file: contracts/interfaces/external/IWETH.sol

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

// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IWETH
 * @author Set Protocol
 *
 * Interface for Wrapped Ether. This interface allows for interaction for wrapped ether's deposit and withdrawal
 * functionality.
 */
interface IWETH is IERC20{
    function deposit()
        external
        payable;

    function withdraw(
        uint256 wad
    )
        external;
}
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
// pragma experimental "ABIEncoderV2";

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

// import { ISetToken } from "../../interfaces/ISetToken.sol";


/**
 * @title Invoke
 * @author Set Protocol
 *
 * A collection of common utility functions for interacting with the SetToken's invoke function
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

// Dependency file: @openzeppelin/contracts/math/SafeMath.sol



// pragma solidity ^0.6.0;

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


// Dependency file: @openzeppelin/contracts/utils/SafeCast.sol



// pragma solidity ^0.6.0;


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


// Dependency file: @openzeppelin/contracts/utils/ReentrancyGuard.sol



// pragma solidity ^0.6.0;

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
contract ReentrancyGuard {
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

// Dependency file: @openzeppelin/contracts/math/Math.sol



// pragma solidity ^0.6.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */




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

pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";

// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { Math } from "@openzeppelin/contracts/math/Math.sol";
// import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import { SafeCast } from "@openzeppelin/contracts/utils/SafeCast.sol";
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";

// import { AddressArrayUtils } from "../../lib/AddressArrayUtils.sol";
// import { IController } from "../../interfaces/IController.sol";
// import { Invoke } from "../lib/Invoke.sol";
// import { ISetToken } from "../../interfaces/ISetToken.sol";
// import { IWETH } from "../../interfaces/external/IWETH.sol";
// import { ModuleBase } from "../lib/ModuleBase.sol";
// import { Position } from "../lib/Position.sol";
// import { PreciseUnitMath } from "../../lib/PreciseUnitMath.sol";
// import { Uint256ArrayUtils } from "../../lib/Uint256ArrayUtils.sol";


/**
 * @title SingleIndexModule
 * @author Set Protocol
 *
 * Smart contract that facilitates rebalances for indices. Manager can set target unit amounts, max trade sizes, the
 * exchange to trade on, and the cool down period between trades (on a per asset basis). As currently constructed
 * the module only works for one Set at a time.
 *
 * SECURITY ASSUMPTION:
 *  - Works with following modules: StreamingFeeModule, BasicIssuanceModule (any other module additions to Sets using
      this module need to be examined separately)
 */
contract SingleIndexModule is ModuleBase, ReentrancyGuard {
    using SafeCast for int256;
    using SafeCast for uint256;
    using SafeMath for uint256;
    using Position for uint256;
    using Math for uint256;
    using Position for ISetToken;
    using Invoke for ISetToken;
    using AddressArrayUtils for address[];
    using Uint256ArrayUtils for uint256[];

    /* ============ Structs ============ */

    struct AssetTradeInfo {
        uint256 targetUnit;              // Target unit for the asset during current rebalance period
        uint256 maxSize;                 // Max trade size in precise units
        uint256 coolOffPeriod;           // Required time between trades for the asset
        uint256 lastTradeTimestamp;      // Timestamp of last trade
        uint256 exchange;                // Integer representing ID of exchange to use
    }

    /* ============ Enums ============ */

    // Enum of exchange Ids
    enum ExchangeId {
        None,
        Uniswap,
        Sushiswap,
        Balancer,
        Last
    }

    /* ============ Events ============ */

    event TargetUnitsUpdated(address indexed _component, uint256 _newUnit, uint256 _positionMultiplier);
    event TradeMaximumUpdated(address indexed _component, uint256 _newMaximum);
    event AssetExchangeUpdated(address indexed _component, uint256 _newExchange);
    event CoolOffPeriodUpdated(address indexed _component, uint256 _newCoolOffPeriod);
    event TraderStatusUpdated(address indexed _trader, bool _status);
    event AnyoneTradeUpdated(bool indexed _status);
    event TradeExecuted(
        address indexed _executor,
        address indexed _sellComponent,
        address indexed _buyComponent,
        uint256 _amountSold,
        uint256 _amountBought
    );

    /* ============ Constants ============ */

    uint256 private constant TARGET_RAISE_DIVISOR = 1.0025e18;       // Raise targets 25 bps
    uint256 private constant BALANCER_POOL_LIMIT = 3;                // Amount of pools examined when fetching quote

    string private constant UNISWAP_OUT = "swapTokensForExactTokens(uint256,uint256,address[],address,uint256)";
    string private constant UNISWAP_IN = "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)";
    string private constant BALANCER_OUT = "smartSwapExactOut(address,address,uint256,uint256,uint256)";
    string private constant BALANCER_IN = "smartSwapExactIn(address,address,uint256,uint256,uint256)";

    /* ============ State Variables ============ */

    mapping(address => AssetTradeInfo) public assetInfo;    // Mapping of component to component restrictions
    address[] public rebalanceComponents;                   // Components having units updated during current rebalance
    uint256 public positionMultiplier;                      // Position multiplier when current rebalance units were devised
    mapping(address => bool) public tradeAllowList;         // Mapping of addresses allowed to call trade()
    bool public anyoneTrade;                                // Toggles on or off skipping the tradeAllowList
    ISetToken public index;                                 // Index being managed with contract
    IWETH public weth;                                      // Weth contract address
    address public uniswapRouter;                           // Uniswap router address
    address public sushiswapRouter;                         // Sushiswap router address
    address public balancerProxy;                           // Balancer exchange proxy address

    /* ============ Modifiers ============ */

    modifier onlyAllowedTrader(address _caller) {
        require(_isAllowedTrader(_caller), "Address not permitted to trade");
        _;
    }

    modifier onlyEOA() {
        require(msg.sender == tx.origin, "Caller must be EOA Address");
        _;
    }

    /* ============ Constructor ============ */

    constructor(
        IController _controller,
        IWETH _weth,
        address _uniswapRouter,
        address _sushiswapRouter,
        address _balancerProxy
    )
        public
        ModuleBase(_controller)
    {
        weth = _weth;
        uniswapRouter = _uniswapRouter;
        sushiswapRouter = _sushiswapRouter;
        balancerProxy = _balancerProxy;
    }

    /**
     * MANAGER ONLY: Set new target units, zeroing out any units for components being removed from index. Log position multiplier to
     * adjust target units in case fees are accrued. Validate that weth is not a part of the new allocation and that all components
     * in current allocation are in _components array.
     *
     * @param _newComponents                    Array of new components to add to allocation
     * @param _newComponentsTargetUnits         Array of target units at end of rebalance for new components, maps to same index of component
     * @param _oldComponentsTargetUnits         Array of target units at end of rebalance for old component, maps to same index of component,
     *                                               if component being removed set to 0.
     * @param _positionMultiplier               Position multiplier when target units were calculated, needed in order to adjust target units
     *                                               if fees accrued
     */
    function startRebalance(
        address[] calldata _newComponents,
        uint256[] calldata _newComponentsTargetUnits,
        uint256[] calldata _oldComponentsTargetUnits,
        uint256 _positionMultiplier
    )
        external
        onlyManagerAndValidSet(index)
    {   
        // Don't use validate arrays because empty arrays are valid
        require(_newComponents.length == _newComponentsTargetUnits.length, "Array length mismatch");

        address[] memory currentComponents = index.getComponents();
        require(currentComponents.length == _oldComponentsTargetUnits.length, "New allocation must have target for all old components");

        address[] memory aggregateComponents = currentComponents.extend(_newComponents);
        uint256[] memory aggregateTargetUnits = _oldComponentsTargetUnits.extend(_newComponentsTargetUnits);

        require(!aggregateComponents.hasDuplicate(), "Cannot duplicate components");

        for (uint256 i = 0; i < aggregateComponents.length; i++) {
            address component = aggregateComponents[i];
            uint256 targetUnit = aggregateTargetUnits[i];

            require(address(component) != address(weth), "WETH cannot be an index component");
            assetInfo[component].targetUnit = targetUnit;

            emit TargetUnitsUpdated(component, targetUnit, _positionMultiplier);
        }

        rebalanceComponents = aggregateComponents;
        positionMultiplier = _positionMultiplier;
    }

    /**
     * ACCESS LIMITED: Only approved addresses can call if anyoneTrade is false. Determines trade size
     * and direction and swaps into or out of WETH on exchange specified by manager.
     *
     * @param _component            Component to trade
     */
    function trade(address _component) external nonReentrant onlyAllowedTrader(msg.sender) onlyEOA() virtual {

        _validateTradeParameters(_component);

        (
            bool isBuy,
            uint256 tradeAmount
        ) = _calculateTradeSizeAndDirection(_component);

        if (isBuy) {
            _buyUnderweight(_component, tradeAmount);
        } else {
            _sellOverweight(_component, tradeAmount);
        }

        assetInfo[_component].lastTradeTimestamp = block.timestamp;
    }

    /**
     * ACCESS LIMITED: Only approved addresses can call if anyoneTrade is false. Only callable when 1) there are no
     * more components to be sold and, 2) entire remaining WETH amount can be traded such that resulting inflows won't
     * exceed components maxTradeSize nor overshoot the target unit. To be used near the end of rebalances when a
     * component's calculated trade size is greater in value than remaining WETH.
     *
     * @param _component            Component to trade
     */
    function tradeRemainingWETH(address _component) external nonReentrant onlyAllowedTrader(msg.sender) onlyEOA() virtual {
        require(_noTokensToSell(), "Must sell all sellable tokens before can be called");

        _validateTradeParameters(_component);

        (, uint256 tradeLimit) = _calculateTradeSizeAndDirection(_component);

        uint256 preTradeComponentAmount = IERC20(_component).balanceOf(address(index));
        uint256 preTradeWethAmount = weth.balanceOf(address(index));

        _executeTrade(address(weth), _component, true, preTradeWethAmount, assetInfo[_component].exchange);

        (,
            uint256 componentTradeSize
        ) = _updatePositionState(address(weth), _component, preTradeWethAmount, preTradeComponentAmount);

        require(componentTradeSize < tradeLimit, "Trade size exceeds trade size limit");

        assetInfo[_component].lastTradeTimestamp = block.timestamp;
    }

    /**
     * ACCESS LIMITED: For situation where all target units met and remaining WETH, uniformly raise targets by same
     * percentage in order to allow further trading. Can be called multiple times if necessary, increase should be
     * small in order to reduce tracking error.
     */
    function raiseAssetTargets() external nonReentrant onlyAllowedTrader(msg.sender) virtual {
        require(
            _allTargetsMet() && index.getDefaultPositionRealUnit(address(weth)) > 0,
            "Targets must be met and ETH remaining in order to raise target"
        );

        positionMultiplier = positionMultiplier.preciseDiv(TARGET_RAISE_DIVISOR);
    }

    /**
     * MANAGER ONLY: Set trade maximums for passed components
     *
     * @param _components            Array of components
     * @param _tradeMaximums         Array of trade maximums mapping to correct component
     */
    function setTradeMaximums(
        address[] calldata _components,
        uint256[] calldata _tradeMaximums
    )
        external
        onlyManagerAndValidSet(index)
    {
        _validateArrays(_components, _tradeMaximums);

        for (uint256 i = 0; i < _components.length; i++) {
            assetInfo[_components[i]].maxSize = _tradeMaximums[i];
            emit TradeMaximumUpdated(_components[i], _tradeMaximums[i]);
        }
    }

    /**
     * MANAGER ONLY: Set exchange for passed components
     *
     * @param _components        Array of components
     * @param _exchanges         Array of exchanges mapping to correct component, uint256 used to signify exchange
     */
    function setExchanges(
        address[] calldata _components,
        uint256[] calldata _exchanges
    )
        external
        onlyManagerAndValidSet(index)
    {
        _validateArrays(_components, _exchanges);

        for (uint256 i = 0; i < _components.length; i++) {
            uint256 exchange = _exchanges[i];
            require(exchange < uint256(ExchangeId.Last), "Unrecognized exchange identifier");
            assetInfo[_components[i]].exchange = _exchanges[i];

            emit AssetExchangeUpdated(_components[i], exchange);
        }
    }

    /**
     * MANAGER ONLY: Set exchange for passed components
     *
     * @param _components           Array of components
     * @param _coolOffPeriods       Array of cool off periods to correct component
     */
    function setCoolOffPeriods(
        address[] calldata _components,
        uint256[] calldata _coolOffPeriods
    )
        external
        onlyManagerAndValidSet(index)
    {
        _validateArrays(_components, _coolOffPeriods);

        for (uint256 i = 0; i < _components.length; i++) {
            assetInfo[_components[i]].coolOffPeriod = _coolOffPeriods[i];
            emit CoolOffPeriodUpdated(_components[i], _coolOffPeriods[i]);
        }
    }

    /**
     * MANAGER ONLY: Toggle ability for passed addresses to trade from current state 
     *
     * @param _traders           Array trader addresses to toggle status
     * @param _statuses          Booleans indicating if matching trader can trade
     */
    function updateTraderStatus(address[] calldata _traders, bool[] calldata _statuses) external onlyManagerAndValidSet(index) {
        require(_traders.length == _statuses.length, "Array length mismatch");
        require(_traders.length > 0, "Array length must be > 0");
        require(!_traders.hasDuplicate(), "Cannot duplicate traders");

        for (uint256 i = 0; i < _traders.length; i++) {
            address trader = _traders[i];
            bool status = _statuses[i];
            tradeAllowList[trader] = status;
            emit TraderStatusUpdated(trader, status);
        }
    }

    /**
     * MANAGER ONLY: Toggle whether anyone can trade, bypassing the traderAllowList
     *
     * @param _status           Boolean indicating if anyone can trade
     */
    function updateAnyoneTrade(bool _status) external onlyManagerAndValidSet(index) {
        anyoneTrade = _status;
        emit AnyoneTradeUpdated(_status);
    }

    /**
     * MANAGER ONLY: Set target units to current units and last trade to zero. Initialize module.
     *
     * @param _index            Address of index being used for this Set
     */
    function initialize(ISetToken _index)
        external
        onlySetManager(_index, msg.sender)
        onlyValidAndPendingSet(_index)
    {
        require(address(index) == address(0), "Module already in use");

        ISetToken.Position[] memory positions = _index.getPositions();

        for (uint256 i = 0; i < positions.length; i++) {
            ISetToken.Position memory position = positions[i];
            assetInfo[position.component].targetUnit = position.unit.toUint256();
            assetInfo[position.component].lastTradeTimestamp = 0;
        }

        index = _index;
        _index.initializeModule();
    }

    function removeModule() external override {}

    /* ============ Getter Functions ============ */

    /**
     * Get target units for passed components, normalized to current positionMultiplier.
     *
     * @param _components           Array of components to get target units for
     * @return                      Array of targetUnits mapping to passed components
     */
    function getTargetUnits(address[] calldata _components) external view returns(uint256[] memory) {
        uint256 currentPositionMultiplier = index.positionMultiplier().toUint256();
        
        uint256[] memory targetUnits = new uint256[](_components.length);
        for (uint256 i = 0; i < _components.length; i++) {
            targetUnits[i] = _normalizeTargetUnit(_components[i], currentPositionMultiplier);
        }

        return targetUnits;
    }

    function getRebalanceComponents() external view returns(address[] memory) {
        return rebalanceComponents;
    }

    /* ============ Internal Functions ============ */

    /**
     * Validate that enough time has elapsed since component's last trade and component isn't WETH.
     */
    function _validateTradeParameters(address _component) internal view virtual {
        require(rebalanceComponents.contains(_component), "Passed component not included in rebalance");

        AssetTradeInfo memory componentInfo = assetInfo[_component];
        require(componentInfo.exchange != uint256(ExchangeId.None), "Exchange must be specified");
        require(
            componentInfo.lastTradeTimestamp.add(componentInfo.coolOffPeriod) <= block.timestamp,
            "Cool off period has not elapsed."
        );
    }

    /**
     * Calculate trade size and whether trade is buy. Trade size is the minimum of the max size and components left to trade.
     * Reverts if target quantity is already met. Target unit is adjusted based on ratio of position multiplier when target was defined
     * and the current positionMultiplier.
     */
    function _calculateTradeSizeAndDirection(address _component) internal view returns (bool isBuy, uint256) {
        uint256 totalSupply = index.totalSupply();

        uint256 componentMaxSize = assetInfo[_component].maxSize;
        uint256 currentPositionMultiplier = index.positionMultiplier().toUint256();

        uint256 currentNotional = totalSupply.getDefaultTotalNotional(
            index.getDefaultPositionRealUnit(_component).toUint256()
        );
        uint256 targetNotional = totalSupply.getDefaultTotalNotional(_normalizeTargetUnit(_component, currentPositionMultiplier));

        require(targetNotional != currentNotional, "Target already met");

        return targetNotional > currentNotional ? (true, componentMaxSize.min(targetNotional.sub(currentNotional))) :
            (false, componentMaxSize.min(currentNotional.sub(targetNotional)));
    }

    /**
     * Buy an underweight asset by selling an unfixed amount of WETH for a fixed amount of the component.
     */
    function _buyUnderweight(address _component, uint256 _amount) internal {
        uint256 preTradeBuyComponentAmount = IERC20(_component).balanceOf(address(index));
        uint256 preTradeSellComponentAmount = weth.balanceOf(address(index));

        _executeTrade(address(weth), _component, false, _amount, assetInfo[_component].exchange);

        _updatePositionState(address(weth), _component, preTradeSellComponentAmount, preTradeBuyComponentAmount);
    }

    /**
     * Sell an overweight asset by selling a fixed amount of component for an unfixed amount of WETH.
     */
    function _sellOverweight(address _component, uint256 _amount) internal {
        uint256 preTradeBuyComponentAmount = weth.balanceOf(address(index));
        uint256 preTradeSellComponentAmount = IERC20(_component).balanceOf(address(index));

        _executeTrade(_component, address(weth), true, _amount, assetInfo[_component].exchange);

        _updatePositionState(_component, address(weth), preTradeSellComponentAmount, preTradeBuyComponentAmount);
    }

    /**
     * Determine parameters for trade and invoke trade on index using correct exchange.
     */
    function _executeTrade(
        address _sellComponent,
        address _buyComponent,
        bool _fixIn,
        uint256 _amount,
        uint256 _exchange
    )
        internal
        virtual
    {
        uint256 wethBalance = weth.balanceOf(address(index));
        
        (
            address exchangeAddress,
            bytes memory tradeCallData
        ) = _exchange == uint256(ExchangeId.Balancer) ? _getBalancerTradeData(_sellComponent, _buyComponent, _fixIn, _amount, wethBalance) :
            _getUniswapLikeTradeData(_sellComponent, _buyComponent, _fixIn, _amount, _exchange);

        uint256 approveAmount = _sellComponent == address(weth) ? wethBalance : _amount;
        index.invokeApprove(_sellComponent, exchangeAddress, approveAmount);
        index.invoke(exchangeAddress, 0, tradeCallData);
    }

    /**
     * Update position units on index. Emit event.
     */
    function _updatePositionState(
        address _sellComponent,
        address _buyComponent,
        uint256 _preTradeSellComponentAmount,
        uint256 _preTradeBuyComponentAmount
    )
        internal
        returns (uint256 sellAmount, uint256 buyAmount)
    {
        uint256 totalSupply = index.totalSupply();

        (uint256 postTradeSellComponentAmount,,) = index.calculateAndEditDefaultPosition(
            _sellComponent,
            totalSupply,
            _preTradeSellComponentAmount
        );
        (uint256 postTradeBuyComponentAmount,,) = index.calculateAndEditDefaultPosition(
            _buyComponent,
            totalSupply,
            _preTradeBuyComponentAmount
        );

        sellAmount = _preTradeSellComponentAmount.sub(postTradeSellComponentAmount);
        buyAmount = postTradeBuyComponentAmount.sub(_preTradeBuyComponentAmount);

        emit TradeExecuted(
            msg.sender,
            _sellComponent,
            _buyComponent,
            sellAmount,
            buyAmount
        );
    }

    /**
     * Create Balancer trade call data
     */
    function _getBalancerTradeData(
        address _sellComponent,
        address _buyComponent,
        bool _fixIn,
        uint256 _amount,
        uint256 _maxOut
    )
        internal
        view
        returns(address, bytes memory)
    {
        address exchangeAddress = balancerProxy;
        (
            string memory functionSignature,
            uint256 limit
        ) = _fixIn ? (BALANCER_IN, 1) : (BALANCER_OUT, _maxOut);

        bytes memory tradeCallData = abi.encodeWithSignature(
            functionSignature,
            _sellComponent,
            _buyComponent,
            _amount,
            limit,
            BALANCER_POOL_LIMIT
        );

        return (exchangeAddress, tradeCallData);       
    }

    /**
     * Determine whether exchange to call is Uniswap or Sushiswap and generate necessary call data.
     */
    function _getUniswapLikeTradeData(
        address _sellComponent,
        address _buyComponent,
        bool _fixIn,
        uint256 _amount,
        uint256 _exchange
    )
        internal
        view
        returns(address, bytes memory)
    {
        address exchangeAddress = _exchange == uint256(ExchangeId.Uniswap) ? uniswapRouter : sushiswapRouter;
        
        string memory functionSignature;
        address[] memory path = new address[](2);
        uint256 limit;
        if (_fixIn) {
            functionSignature = UNISWAP_IN;
            limit = 1;
        } else {
            functionSignature = UNISWAP_OUT;
            limit = PreciseUnitMath.maxUint256();
        }
        path[0] = _sellComponent;
        path[1] = _buyComponent;
        
        bytes memory tradeCallData = abi.encodeWithSignature(
            functionSignature,
            _amount,
            limit,
            path,
            address(index),
            now.add(180)
        );

        return (exchangeAddress, tradeCallData);
    }

    /**
     * Check if there are any more tokens to sell.
     */
    function _noTokensToSell() internal view returns (bool) {
        uint256 currentPositionMultiplier = index.positionMultiplier().toUint256();
        for (uint256 i = 0; i < rebalanceComponents.length; i++) {
            address component = rebalanceComponents[i];
            bool canSell = _normalizeTargetUnit(component, currentPositionMultiplier) < index.getDefaultPositionRealUnit(
                component
            ).toUint256();
            if (canSell) { return false; }
        }
        return true;
    }

    /**
     * Check if all targets are met
     */
    function _allTargetsMet() internal view returns (bool) {
        uint256 currentPositionMultiplier = index.positionMultiplier().toUint256();
        for (uint256 i = 0; i < rebalanceComponents.length; i++) {
            address component = rebalanceComponents[i];
            bool targetUnmet = _normalizeTargetUnit(component, currentPositionMultiplier) != index.getDefaultPositionRealUnit(
                component
            ).toUint256();
            if (targetUnmet) { return false; }
        }
        return true;
    }

    /**
     * Normalize target unit to current position multiplier in case fees have been accrued.
     */
    function _normalizeTargetUnit(address _component, uint256 _currentPositionMultiplier) internal view returns(uint256) {
        return assetInfo[_component].targetUnit.mul(_currentPositionMultiplier).div(positionMultiplier);
    }

    /**
     * Determine if passed address is allowed to call trade. If anyoneTrade set to true anyone can call otherwise needs to be approved.
     */
    function _isAllowedTrader(address _caller) internal view virtual returns (bool) {
        return anyoneTrade || tradeAllowList[_caller];
    }

    /**
     * Validate arrays are of equal length and not empty.
     */
    function _validateArrays(address[] calldata _components, uint256[] calldata _data) internal pure {
        require(_components.length == _data.length, "Array length mismatch");
        require(_components.length > 0, "Array length must be > 0");
        require(!_components.hasDuplicate(), "Cannot duplicate components");
    }
}