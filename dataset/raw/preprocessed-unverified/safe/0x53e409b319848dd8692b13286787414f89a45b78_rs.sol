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

    SPDX-License-Identifier: Apache License, Version 2.0
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


// Dependency file: @openzeppelin/contracts/utils/Address.sol

// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */


// Dependency file: @openzeppelin/contracts/GSN/Context.sol

// pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
// Dependency file: contracts/interfaces/external/IUniswapV2Router.sol

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


// Dependency file: contracts/interfaces/external/IUniswapV2Pair.sol

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
    limitations under the License
*/

// pragma solidity 0.6.10;



// Dependency file: contracts/interfaces/external/IStakingRewards.sol

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


// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol

// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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


// Dependency file: @openzeppelin/contracts/math/SignedSafeMath.sol

// pragma solidity ^0.6.0;

/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
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


// Dependency file: @openzeppelin/contracts/token/ERC20/ERC20.sol

// pragma solidity ^0.6.0;

// import "../../GSN/Context.sol";
// import "./IERC20.sol";
// import "../../math/SafeMath.sol";
// import "../../utils/Address.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

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

// import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { Math } from "@openzeppelin/contracts/math/Math.sol";
// import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import { SafeCast } from "@openzeppelin/contracts/utils/SafeCast.sol";
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
// import { SignedSafeMath } from "@openzeppelin/contracts/math/SignedSafeMath.sol";

// import { IController } from "../../interfaces/IController.sol";
// import { Invoke } from "../lib/Invoke.sol";
// import { ISetToken } from "../../interfaces/ISetToken.sol";
// import { IStakingRewards } from "../../interfaces/external/IStakingRewards.sol";
// import { IUniswapV2Pair } from "../../interfaces/external/IUniswapV2Pair.sol";
// import { IUniswapV2Router } from "../../interfaces/external/IUniswapV2Router.sol";
// import { ModuleBase } from "../lib/ModuleBase.sol";
// import { Position } from "../lib/Position.sol";
// import { PreciseUnitMath } from "../../lib/PreciseUnitMath.sol";


contract UniswapYieldStrategy is ModuleBase, ReentrancyGuard {
    using Position for ISetToken;
    using Invoke for ISetToken;
    using SafeMath for uint256;
    using SafeCast for uint256;
    using SafeCast for int256;

    /* ============ State Variables ============ */

    IUniswapV2Router public uniswapRouter;
    IUniswapV2Pair public lpToken;
    IERC20 public assetOne;
    IERC20 public assetTwo;
    IERC20 public uni;
    address public feeRecipient;
    IStakingRewards public rewarder;
    ISetToken public setToken;
    uint256 public reservePercentage;        // Precise percentage (e.g. 10^16 = 1%)
    uint256 public slippageTolerance;        // Precise percentage
    uint256 public rewardFee;                // Precise percentage
    uint256 public withdrawalFee;            // Precise percentage
    uint256 public assetOneBaseUnit;
    uint256 public assetTwoBaseUnit;
    uint256 public lpTokenBaseUnit;

    /* ============ Constructor ============ */

    constructor(
        IController _controller,
        IUniswapV2Router _uniswapRouter,
        IUniswapV2Pair _lpToken,
        IERC20 _assetOne,
        IERC20 _assetTwo,
        IERC20 _uni,
        IStakingRewards _rewarder,
        address _feeRecipient
    )
        public
        ModuleBase(_controller)
    {
        controller = _controller;
        uniswapRouter = _uniswapRouter;
        lpToken = _lpToken;
        assetOne = _assetOne;
        assetTwo = _assetTwo;
        uni = _uni;
        rewarder = _rewarder;
        feeRecipient = _feeRecipient;

        uint256 tokenOneDecimals = ERC20(address(_assetOne)).decimals();
        assetOneBaseUnit = 10 ** tokenOneDecimals;
        uint256 tokenTwoDecimals = ERC20(address(_assetTwo)).decimals();
        assetTwoBaseUnit = 10 ** tokenTwoDecimals;
        uint256 lpTokenDecimals = ERC20(address(_lpToken)).decimals();
        lpTokenBaseUnit = 10 ** lpTokenDecimals;
    }

    /* ============ External Functions ============ */

    function engage() external nonReentrant {
        _engage();
    }

    function disengage() external nonReentrant {
        _rebalance(0);

        uint256 lpTokenQuantity = _calculateDisengageLPQuantity();

        _unstake(lpTokenQuantity);

        _approveAndRemoveLiquidity(lpTokenQuantity);

        _updatePositions();
    }

    function reap() external nonReentrant {
        _handleReward();

        _engage();
    }

    function rebalance() external nonReentrant {
        _rebalance(0);

        _updatePositions();
    }

    function rebalanceSome(uint256 _sellTokenQuantity) external nonReentrant {
        _rebalance(_sellTokenQuantity);

        _updatePositions();        
    }

    function unstakeAndRedeem(uint256 _setTokenQuantity) external nonReentrant {
        require(setToken.balanceOf(msg.sender) >= _setTokenQuantity, "User must have sufficient SetToken");

        setToken.burn(msg.sender, _setTokenQuantity);

        uint256 lpTokenUnit = setToken.getExternalPositionRealUnit(address(lpToken), address(this)).toUint256();

        uint256 userLPBalance = lpTokenUnit.preciseMul(_setTokenQuantity);

        _unstake(userLPBalance);

        uint256 lpFees = userLPBalance.preciseMul(withdrawalFee);
        setToken.invokeTransfer(address(lpToken), msg.sender, userLPBalance.sub(lpFees));
        setToken.invokeTransfer(address(lpToken), feeRecipient, lpFees);

        uint256 assetOneUnit = setToken.getDefaultPositionRealUnit(address(assetOne)).toUint256();
        uint256 assetOneNotional = assetOneUnit.preciseMul(_setTokenQuantity);
        uint256 assetOneFee = assetOneNotional.preciseMul(withdrawalFee);
        setToken.invokeTransfer(address(assetOne), msg.sender, assetOneNotional.sub(assetOneFee));
        setToken.invokeTransfer(address(assetOne), feeRecipient, assetOneFee);

        uint256 assetTwoUnit = setToken.getDefaultPositionRealUnit(address(assetTwo)).toUint256();
        uint256 assetTwoNotional = assetTwoUnit.preciseMul(_setTokenQuantity);
        uint256 assetTwoFee = assetTwoNotional.preciseMul(withdrawalFee);
        setToken.invokeTransfer(address(assetTwo), msg.sender, assetTwoNotional.sub(assetTwoFee));
        setToken.invokeTransfer(address(assetTwo), feeRecipient, assetTwoFee);
    }

    function initialize(
        ISetToken _setToken,
        uint256 _reservePercentage,
        uint256 _slippageTolerance,
        uint256 _rewardFee,
        uint256 _withdrawalFee
    )
        external
        onlySetManager(_setToken, msg.sender)
    {
        require(address(setToken) == address(0), "May only be called once");

        setToken = _setToken;
        reservePercentage = _reservePercentage;
        slippageTolerance = _slippageTolerance;
        rewardFee = _rewardFee;
        withdrawalFee = _withdrawalFee;

        _setToken.initializeModule();
    }

    function removeModule() external override {
        require(msg.sender == address(setToken), "Caller must be SetToken");

        uint256 lpBalance = rewarder.balanceOf(address(setToken));

        _unstake(lpBalance);

        _approveAndRemoveLiquidity(lpBalance);

        _updatePositions();
    }

    /* ============ Internal Functions ============ */

    function _engage() internal {
        _rebalance(0);

        (uint256 assetOneQuantity, uint256 assetTwoQuantity) = _calculateEngageQuantities();

        uint256 lpBalance = _approveAndAddLiquidity(assetOneQuantity, assetTwoQuantity);

        _approveAndStake(lpBalance);

        _updatePositions();
    }  

    // Rebalances reserve assets to achieve a 50/50 value split
    // If a sellTokenQuantity is provided, then use this value
    function _rebalance(uint256 _sellTokenQuantity) internal {
        address assetToSell;
        address assetToBuy;
        uint256 quantityToSell;
        uint256 minimumBuyToken;

        uint256 assetOneToTwoPrice = controller.getPriceOracle().getPrice(address(assetOne), address(assetTwo));

        uint256 balanceAssetOne = assetOne.balanceOf(address(setToken));
        uint256 balanceAssetTwo = assetTwo.balanceOf(address(setToken));

        // Convert Asset Two to One adjust for decimal differences
        uint256 valueAssetTwoDenomOne = balanceAssetTwo.preciseDiv(assetOneToTwoPrice).mul(assetOneBaseUnit).div(assetTwoBaseUnit);

        if (balanceAssetOne > valueAssetTwoDenomOne) {
            assetToSell = address(assetOne);
            assetToBuy = address(assetTwo);
            quantityToSell = balanceAssetOne.sub(valueAssetTwoDenomOne).div(2);

            // Base unit calculations are to normalize the values for different decimals
            minimumBuyToken = quantityToSell.preciseMul(assetOneToTwoPrice).mul(assetTwoBaseUnit).div(assetOneBaseUnit);
        } else {
            assetToSell = address(assetTwo);
            assetToBuy = address(assetOne);
            quantityToSell = valueAssetTwoDenomOne
                                .sub(balanceAssetOne).div(2).preciseMul(assetOneToTwoPrice)
                                .mul(assetTwoBaseUnit).div(assetOneBaseUnit);
            minimumBuyToken = quantityToSell.preciseDiv(assetOneToTwoPrice).mul(assetOneBaseUnit).div(assetTwoBaseUnit);
        }

        if (_sellTokenQuantity > 0) {
            require(_sellTokenQuantity <= quantityToSell, "Delta must be less than max");
            minimumBuyToken = minimumBuyToken.preciseMul(_sellTokenQuantity).preciseDiv(quantityToSell);
            quantityToSell = _sellTokenQuantity;
        }

        // Reduce the expected receive quantity 
        minimumBuyToken = minimumBuyToken
            .preciseMul(PreciseUnitMath.preciseUnit().sub(slippageTolerance));

        setToken.invokeApprove(assetToSell, address(uniswapRouter), quantityToSell);
        if (quantityToSell > 0) {
            _invokeUniswapTrade(assetToSell, assetToBuy, quantityToSell, minimumBuyToken);
        }
    }

    function _approveAndAddLiquidity(uint256 _assetOneQuantity, uint256 _assetTwoQuantity) internal returns (uint256) {
        setToken.invokeApprove(address(assetOne), address(uniswapRouter), _assetOneQuantity);
        setToken.invokeApprove(address(assetTwo), address(uniswapRouter), _assetTwoQuantity);

        bytes memory addLiquidityBytes = abi.encodeWithSignature(
            "addLiquidity(address,address,uint256,uint256,uint256,uint256,address,uint256)",
            assetOne,
            assetTwo,
            _assetOneQuantity,
            _assetTwoQuantity,
            1,
            1,
            address(setToken),
            now.add(60) // Valid for one minute
        );

        setToken.invoke(address(uniswapRouter), 0, addLiquidityBytes);

        return lpToken.balanceOf(address(setToken));
    }

    function _approveAndRemoveLiquidity(uint256 _liquidityQuantity) internal {
        setToken.invokeApprove(address(lpToken), address(uniswapRouter), _liquidityQuantity);

        bytes memory removeLiquidityBytes = abi.encodeWithSignature(
            "removeLiquidity(address,address,uint256,uint256,uint256,address,uint256)",
            assetOne,
            assetTwo,
            _liquidityQuantity,
            1,
            1,
            address(setToken),
            now.add(60) // Valid for one minute
        );

        setToken.invoke(address(uniswapRouter), 0, removeLiquidityBytes);
    }

    function _approveAndStake(uint256 _lpTokenQuantity) internal {
        setToken.invokeApprove(address(lpToken), address(rewarder), _lpTokenQuantity);
        bytes memory stakeBytes = abi.encodeWithSignature("stake(uint256)", _lpTokenQuantity);

        setToken.invoke(address(rewarder), 0, stakeBytes);
    }

    function _unstake(uint256 _lpTokenQuantity) internal {
        bytes memory unstakeBytes = abi.encodeWithSignature("withdraw(uint256)", _lpTokenQuantity);

        setToken.invoke(address(rewarder), 0, unstakeBytes);
    }

    function _handleReward() internal {
        setToken.invoke(address(rewarder), 0, abi.encodeWithSignature("getReward()"));

        uint256 uniBalance = uni.balanceOf(address(setToken));
        uint256 assetOneBalance = assetOne.balanceOf(address(setToken));

        setToken.invokeApprove(address(uni), address(uniswapRouter), uniBalance);
        _invokeUniswapTrade(address(uni), address(assetOne), uniBalance, 1);

        uint256 postTradeAssetOneBalance = assetOne.balanceOf(address(setToken));
        uint256 fee = postTradeAssetOneBalance.sub(assetOneBalance).preciseMul(rewardFee);

        setToken.strictInvokeTransfer(address(assetOne), feeRecipient, fee);
    }

    function _invokeUniswapTrade(
        address _sellToken,
        address _buyToken,
        uint256 _amountIn,
        uint256 _amountOutMin
    )
        internal
    {
        address[] memory path = new address[](2);
        path[0] = _sellToken;
        path[1] = _buyToken;

        bytes memory tradeBytes = abi.encodeWithSignature(
            "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)",
            _amountIn,
            _amountOutMin,
            path,
            address(setToken),
            now.add(180)
        );

        setToken.invoke(address(uniswapRouter), 0, tradeBytes);
    }

    function _calculateEngageQuantities() internal view returns(uint256 tokenAQuantity, uint256 tokenBQuantity) {
        (
            uint256 desiredAssetOne,
            uint256 desiredAssetTwo,
            uint256 assetOneOnSetToken,
            uint256 assetTwoOnSetToken
        ) = _getDesiredSingleAssetReserve();

        require(assetOneOnSetToken > desiredAssetOne && assetTwoOnSetToken > desiredAssetTwo, "SetToken assets must be > desired");

        return (
            assetOneOnSetToken.sub(desiredAssetOne),
            assetTwoOnSetToken.sub(desiredAssetTwo)
        );
    }

    function _calculateDisengageLPQuantity() internal view returns(uint256 _lpTokenQuantity) {
        (uint256 assetOneToLPRate, uint256 assetTwoToLPRate) = _getLPReserveExchangeRate();

        (
            uint256 desiredOne,
            uint256 desiredTwo,
            uint256 assetOneOnSetToken,
            uint256 assetTwoOnSetToken
        ) = _getDesiredSingleAssetReserve();    

        require(assetOneOnSetToken < desiredOne && assetTwoOnSetToken < desiredTwo, "SetToken assets must be < desired");

        // LP Rates already account for decimals
        uint256 minLPForOneToRedeem = desiredOne.sub(assetOneOnSetToken).preciseDiv(assetOneToLPRate);
        uint256 minLPForTwoToRedeem = desiredTwo.sub(assetTwoOnSetToken).preciseDiv(assetTwoToLPRate);

        return Math.max(minLPForOneToRedeem, minLPForTwoToRedeem);
    }

    // Returns desiredOneReserve, desiredTwoReserve, tokenOne and tokenTwo balances
    function _getDesiredSingleAssetReserve()
        internal
        view
        returns(uint256, uint256, uint256, uint256)
    {
        (uint256 assetOneReserve, uint256 assetTwoReserve) = _getTotalLPReserves();
        uint256 balanceAssetOne = assetOne.balanceOf(address(setToken));
        uint256 balanceAssetTwo = assetTwo.balanceOf(address(setToken));

        uint256 desiredOneReserve = assetOneReserve.add(balanceAssetOne).preciseMul(reservePercentage);
        uint256 desiredTwoReserve = assetTwoReserve.add(balanceAssetTwo).preciseMul(reservePercentage);

        return(desiredOneReserve, desiredTwoReserve, balanceAssetOne, balanceAssetTwo);
    }

    // Returns assetAToLPRate and assetBToLPRate
    function _getLPReserveExchangeRate() internal view returns (uint256, uint256) {
        (uint reserve0, uint reserve1) = _getReservesSafe();
        uint256 totalSupply = lpToken.totalSupply();
        return(
            reserve0.preciseDiv(totalSupply),
            reserve1.preciseDiv(totalSupply)
        );
    }

    // Returns assetOneReserve and assetTwoReserve
    function _getTotalLPReserves() internal view returns (uint256, uint256) {
        (uint reserve0, uint reserve1) = _getReservesSafe();
        uint256 totalSupply = lpToken.totalSupply();
        uint256 lpTokenBalance = rewarder.balanceOf(address(setToken));
        return(
            reserve0.mul(lpTokenBalance).div(totalSupply),
            reserve1.mul(lpTokenBalance).div(totalSupply)
        );
    }

    function _updatePositions() internal {
        uint256 totalSupply = setToken.totalSupply();
        uint256 assetOneBalance = assetOne.balanceOf(address(setToken));
        uint256 assetTwoBalance = assetTwo.balanceOf(address(setToken));
        uint256 lpBalance = rewarder.balanceOf(address(setToken));

        // Doesn't check to make sure unit is different, and no check for any LP token on Set
        setToken.editDefaultPosition(address(assetOne), Position.getDefaultPositionUnit(totalSupply, assetOneBalance));
        setToken.editDefaultPosition(address(assetTwo), Position.getDefaultPositionUnit(totalSupply, assetTwoBalance));
        setToken.editExternalPosition(
            address(lpToken),
            address(this),
            Position.getDefaultPositionUnit(totalSupply, lpBalance).toInt256(),
            ""
        );
    }

    // Code pulled to sort from UniswapV2Library
    // https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/libraries/UniswapV2Library.sol
    function _getReservesSafe() internal view returns(uint256, uint256) {
        address firstAsset = address(assetOne) < address(assetTwo) ? address(assetOne) : address(assetTwo);
        (uint reserve0, uint reserve1,) = lpToken.getReserves();
        return address(assetOne) == firstAsset ? (reserve0, reserve1) : (reserve1, reserve0);
    }
}