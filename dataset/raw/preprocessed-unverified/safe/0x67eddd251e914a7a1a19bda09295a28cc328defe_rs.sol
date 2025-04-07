/**
 *Submitted for verification at Etherscan.io on 2020-10-16
*/

/**
 *Submitted for verification at Etherscan.io on 2020-10-16
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
// Dependency file: contracts/interfaces/IWrapAdapter.sol

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
 * @title IWrapAdapter
 * @author Set Protocol
 *
 */

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
// import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import { SafeCast } from "@openzeppelin/contracts/utils/SafeCast.sol";
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";

// import { IController } from "../../interfaces/IController.sol";
// import { IIntegrationRegistry } from "../../interfaces/IIntegrationRegistry.sol";
// import { Invoke } from "../lib/Invoke.sol";
// import { ISetToken } from "../../interfaces/ISetToken.sol";
// import { IWETH } from "../../interfaces/external/IWETH.sol";
// import { IWrapAdapter } from "../../interfaces/IWrapAdapter.sol";
// import { ModuleBase } from "../lib/ModuleBase.sol";
// import { Position } from "../lib/Position.sol";
// import { PreciseUnitMath } from "../../lib/PreciseUnitMath.sol";

/**
 * @title WrapModule
 * @author Set Protocol
 *
 * Module that enables the wrapping of ERC20 and Ether positions via third party protocols. The WrapModule
 * works in conjunction with WrapAdapters, in which the wrapAdapterID / integrationNames are stored on the
 * integration registry.
 *
 * Some examples of wrap actions include wrapping, DAI to cDAI (Compound) or Dai to aDai (AAVE).
 */
contract WrapModule is ModuleBase, ReentrancyGuard {
    using SafeCast for int256;
    using PreciseUnitMath for uint256;
    using Position for uint256;
    using SafeMath for uint256;

    using Invoke for ISetToken;
    using Position for ISetToken.Position;
    using Position for ISetToken;

    /* ============ Events ============ */

    event ComponentWrapped(
        ISetToken indexed _setToken,
        address indexed _underlyingToken,
        address indexed _wrappedToken,
        uint256 _underlyingQuantity,
        uint256 _wrappedQuantity,
        string _integrationName
    );

    event ComponentUnwrapped(
        ISetToken indexed _setToken,
        address indexed _underlyingToken,
        address indexed _wrappedToken,
        uint256 _underlyingQuantity,
        uint256 _wrappedQuantity,
        string _integrationName
    );

    /* ============ State Variables ============ */

    // Wrapped ETH address
    IWETH public weth;

    /* ============ Constructor ============ */

    /**
     * @param _controller               Address of controller contract
     * @param _weth                     Address of wrapped eth
     */
    constructor(IController _controller, IWETH _weth) public ModuleBase(_controller) {
        weth = _weth;
    }

    /* ============ External Functions ============ */
    
    /**
     * MANAGER-ONLY: Instructs the SetToken to wrap an underlying asset into a wrappedToken via a specified adapter.
     *
     * @param _setToken             Instance of the SetToken
     * @param _underlyingToken      Address of the component to be wrapped
     * @param _wrappedToken         Address of the desired wrapped token
     * @param _underlyingUnits      Quantity of underlying units in Position units
     * @param _integrationName      Name of wrap module integration (mapping on integration registry)
     */
    function wrap(
        ISetToken _setToken,
        address _underlyingToken,
        address _wrappedToken,
        uint256 _underlyingUnits,
        string calldata _integrationName
    ) 
        external
        nonReentrant
        onlyManagerAndValidSet(_setToken)
    {
        (
            uint256 notionalUnderlyingWrapped,
            uint256 notionalWrapped
        ) = _validateWrapAndUpdate(
            _integrationName,
            _setToken,
            _underlyingToken,
            _wrappedToken,
            _underlyingUnits,
            false // does not use Ether
        );

        emit ComponentWrapped(
            _setToken,
            _underlyingToken,
            _wrappedToken,
            notionalUnderlyingWrapped,
            notionalWrapped,
            _integrationName
        );
    }

    /**
     * MANAGER-ONLY: Instructs the SetToken to wrap Ether into a wrappedToken via a specified adapter. Since SetTokens
     * only hold WETH, in order to support protocols that collateralize with Ether the SetToken's WETH must be unwrapped
     * first before sending to the external protocol.
     *
     * @param _setToken             Instance of the SetToken
     * @param _wrappedToken         Address of the desired wrapped token
     * @param _underlyingUnits      Quantity of underlying units in Position units
     * @param _integrationName      Name of wrap module integration (mapping on integration registry)
     */
    function wrapWithEther(
        ISetToken _setToken,
        address _wrappedToken,
        uint256 _underlyingUnits,
        string calldata _integrationName
    ) 
        external
        nonReentrant
        onlyManagerAndValidSet(_setToken)
    {
        (
            uint256 notionalUnderlyingWrapped,
            uint256 notionalWrapped
        ) = _validateWrapAndUpdate(
            _integrationName,
            _setToken,
            address(weth),
            _wrappedToken,
            _underlyingUnits,
            true // uses Ether
        );

        emit ComponentWrapped(
            _setToken,
            address(weth),
            _wrappedToken,
            notionalUnderlyingWrapped,
            notionalWrapped,
            _integrationName
        );
    }

    /**
     * MANAGER-ONLY: Instructs the SetToken to unwrap a wrapped asset into its underlying via a specified adapter.
     *
     * @param _setToken             Instance of the SetToken
     * @param _underlyingToken      Address of the underlying asset
     * @param _wrappedToken         Address of the component to be unwrapped
     * @param _wrappedUnits         Quantity of wrapped tokens in Position units
     * @param _integrationName      ID of wrap module integration (mapping on integration registry)
     */
    function unwrap(
        ISetToken _setToken,
        address _underlyingToken,
        address _wrappedToken,
        uint256 _wrappedUnits,
        string calldata _integrationName
    )
        external
        nonReentrant
        onlyManagerAndValidSet(_setToken)
    {
        (
            uint256 notionalUnderlyingUnwrapped,
            uint256 notionalUnwrapped
        ) = _validateUnwrapAndUpdate(
            _integrationName,
            _setToken,
            _underlyingToken,
            _wrappedToken,
            _wrappedUnits,
            false // uses Ether
        );

        emit ComponentUnwrapped(
            _setToken,
            _underlyingToken,
            _wrappedToken,
            notionalUnderlyingUnwrapped,
            notionalUnwrapped,
            _integrationName
        );
    }

    /**
     * MANAGER-ONLY: Instructs the SetToken to unwrap a wrapped asset collateralized by Ether into Wrapped Ether. Since
     * external protocol will send back Ether that Ether must be Wrapped into WETH in order to be accounted for by SetToken.
     *
     * @param _setToken                 Instance of the SetToken
     * @param _wrappedToken             Address of the component to be unwrapped
     * @param _wrappedUnits             Quantity of wrapped tokens in Position units
     * @param _integrationName          ID of wrap module integration (mapping on integration registry)
     */
    function unwrapWithEther(
        ISetToken _setToken,
        address _wrappedToken,
        uint256 _wrappedUnits,
        string calldata _integrationName
    )
        external
        nonReentrant
        onlyManagerAndValidSet(_setToken)
    {
        (
            uint256 notionalUnderlyingUnwrapped,
            uint256 notionalUnwrapped
        ) = _validateUnwrapAndUpdate(
            _integrationName,
            _setToken,
            address(weth),
            _wrappedToken,
            _wrappedUnits,
            true // uses Ether
        );

        emit ComponentUnwrapped(
            _setToken,
            address(weth),
            _wrappedToken,
            notionalUnderlyingUnwrapped,
            notionalUnwrapped,
            _integrationName
        );
    }

    /**
     * Initializes this module to the SetToken. Only callable by the SetToken's manager.
     *
     * @param _setToken             Instance of the SetToken to issue
     */
    function initialize(ISetToken _setToken) external onlySetManager(_setToken, msg.sender) {
        require(controller.isSet(address(_setToken)), "Must be controller-enabled SetToken");
        require(isSetPendingInitialization(_setToken), "Must be pending initialization");
        _setToken.initializeModule();
    }

    /**
     * Removes this module from the SetToken, via call by the SetToken.
     */
    function removeModule() external override {}


    /* ============ Internal Functions ============ */

    /**
     * Validates the wrap operation is valid. In particular, the following checks are made:
     * - The position is Default
     * - The position has sufficient units given the transact quantity
     * - The transact quantity > 0
     *
     * It is expected that the adapter will check if wrappedToken/underlyingToken are a valid pair for the given
     * integration.
     */
    function _validateInputs(
        ISetToken _setToken,
        address _transactPosition,
        uint256 _transactPositionUnits
    ) 
        internal
        view
    {
        require(_transactPositionUnits > 0, "Target position units must be > 0");
        require(_setToken.hasDefaultPosition(_transactPosition), "Target default position must be component");
        require(
            _setToken.hasSufficientDefaultUnits(_transactPosition, _transactPositionUnits),
            "Unit cant be greater than existing"
        );
    }

    /**
     * The WrapModule calculates the total notional underlying to wrap, approves the underlying to the 3rd party 
     * integration contract, then invokes the SetToken to call wrap by passing its calldata along. When raw ETH
     * is being used (_usesEther = true) WETH position must first be unwrapped and underlyingAddress sent to 
     * adapter must be external protocol's ETH representative address.
     *
     * Returns notional amount of underlying tokens and wrapped tokens that were wrapped.
     */
    function _validateWrapAndUpdate(
        string calldata _integrationName,
        ISetToken _setToken,
        address _underlyingToken,
        address _wrappedToken,
        uint256 _underlyingUnits,
        bool _usesEther
    ) 
        internal
        returns (uint256, uint256)
    {
        _validateInputs(_setToken, _underlyingToken, _underlyingUnits);

        // Snapshot pre wrap balances
        (
            uint256 preActionUnderlyingNotional,
            uint256 preActionWrapNotional
        ) = _snapshotTargetAssetsBalance(_setToken, _underlyingToken, _wrappedToken);

        uint256 notionalUnderlying = _setToken.totalSupply().getDefaultTotalNotional(_underlyingUnits);
        IWrapAdapter wrapAdapter = IWrapAdapter(getAndValidateAdapter(_integrationName));

        // Execute any pre-wrap actions depending on if using raw ETH or not
        if (_usesEther) {
            _setToken.invokeUnwrapWETH(address(weth), notionalUnderlying);
        } else {
            address spender = wrapAdapter.getSpenderAddress(_underlyingToken, _wrappedToken);

            _setToken.invokeApprove(_underlyingToken, spender, notionalUnderlying);
        }

        // Get function call data and invoke on SetToken
        _createWrapDataAndInvoke(
            _setToken,
            wrapAdapter,
            _usesEther ? wrapAdapter.ETH_TOKEN_ADDRESS() : _underlyingToken,
            _wrappedToken,
            notionalUnderlying
        );

        // Snapshot post wrap balances
        (
            uint256 postActionUnderlyingNotional,
            uint256 postActionWrapNotional
        ) = _snapshotTargetAssetsBalance(_setToken, _underlyingToken, _wrappedToken);

        _updatePosition(_setToken, _underlyingToken, preActionUnderlyingNotional, postActionUnderlyingNotional);
        _updatePosition(_setToken, _wrappedToken, preActionWrapNotional, postActionWrapNotional);

        return (
            preActionUnderlyingNotional.sub(postActionUnderlyingNotional),
            postActionWrapNotional.sub(preActionWrapNotional)
        );
    }

    /**
     * The WrapModule calculates the total notional wrap token to unwrap, then invokes the SetToken to call
     * unwrap by passing its calldata along. When raw ETH is being used (_usesEther = true) underlyingAddress
     * sent to adapter must be set to external protocol's ETH representative address and ETH returned from
     * external protocol is wrapped.
     *
     * Returns notional amount of underlying tokens and wrapped tokens unwrapped.
     */
    function _validateUnwrapAndUpdate(
        string calldata _integrationName,
        ISetToken _setToken,
        address _underlyingToken,
        address _wrappedToken,
        uint256 _wrappedTokenUnits,
        bool _usesEther
    )
        internal
        returns (uint256, uint256)
    {
        _validateInputs(_setToken, _wrappedToken, _wrappedTokenUnits);

        (
            uint256 preActionUnderlyingNotional,
            uint256 preActionWrapNotional
        ) = _snapshotTargetAssetsBalance(_setToken, _underlyingToken, _wrappedToken);

        uint256 notionalWrappedToken = _setToken.totalSupply().getDefaultTotalNotional(_wrappedTokenUnits);
        IWrapAdapter wrapAdapter = IWrapAdapter(getAndValidateAdapter(_integrationName));

        // Get function call data and invoke on SetToken
        _createUnwrapDataAndInvoke(
            _setToken,
            wrapAdapter,
            _usesEther ? wrapAdapter.ETH_TOKEN_ADDRESS() : _underlyingToken,
            _wrappedToken,
            notionalWrappedToken
        );

        if (_usesEther) {
            _setToken.invokeWrapWETH(address(weth), address(_setToken).balance);
        }

        (
            uint256 postActionUnderlyingNotional,
            uint256 postActionWrapNotional
        ) = _snapshotTargetAssetsBalance(_setToken, _underlyingToken, _wrappedToken);

        _updatePosition(_setToken, _underlyingToken, preActionUnderlyingNotional, postActionUnderlyingNotional);
        _updatePosition(_setToken, _wrappedToken, preActionWrapNotional, postActionWrapNotional);

        return (
            postActionUnderlyingNotional.sub(preActionUnderlyingNotional),
            preActionWrapNotional.sub(postActionWrapNotional)
        );
    }

    /**
     * Create the calldata for wrap and then invoke the call on the SetToken.
     */
    function _createWrapDataAndInvoke(
        ISetToken _setToken,
        IWrapAdapter _wrapAdapter,
        address _underlyingToken,
        address _wrappedToken,
        uint256 _notionalUnderlying
    ) internal {
        (
            address callTarget,
            uint256 callValue,
            bytes memory callByteData
        ) = _wrapAdapter.getWrapCallData(
            _underlyingToken,
            _wrappedToken,
            _notionalUnderlying
        );

        _setToken.invoke(callTarget, callValue, callByteData);
    }

    /**
     * Create the calldata for unwrap and then invoke the call on the SetToken.
     */
    function _createUnwrapDataAndInvoke(
        ISetToken _setToken,
        IWrapAdapter _wrapAdapter,
        address _underlyingToken,
        address _wrappedToken,
        uint256 _notionalUnderlying
    ) internal {
        (
            address callTarget,
            uint256 callValue,
            bytes memory callByteData
        ) = _wrapAdapter.getUnwrapCallData(
            _underlyingToken,
            _wrappedToken,
            _notionalUnderlying
        );

        _setToken.invoke(callTarget, callValue, callByteData);
    }

    /**
     * After a wrap/unwrap operation, check the underlying and wrap token quantities and recalculate
     * the units ((total tokens - airdrop)/ total supply). Then update the position on the SetToken.
     */
    function _updatePosition(
        ISetToken _setToken,
        address _token,
        uint256 _preActionTokenBalance,
        uint256 _postActionTokenBalance
    ) internal {
        uint256 newUnit = _setToken.totalSupply().calculateDefaultEditPositionUnit(
            _preActionTokenBalance,
            _postActionTokenBalance,
            _setToken.getDefaultPositionRealUnit(_token).toUint256()
        );

        _setToken.editDefaultPosition(_token, newUnit);
    }

    /**
     * Take snapshot of SetToken's balance of underlying and wrapped tokens.
     */
    function _snapshotTargetAssetsBalance(
        ISetToken _setToken,
        address _underlyingToken,
        address _wrappedToken
    ) internal view returns(uint256, uint256) {
        uint256 underlyingTokenBalance = IERC20(_underlyingToken).balanceOf(address(_setToken));
        uint256 wrapTokenBalance = IERC20(_wrappedToken).balanceOf(address(_setToken));

        return (
            underlyingTokenBalance,
            wrapTokenBalance            
        );
    }
}