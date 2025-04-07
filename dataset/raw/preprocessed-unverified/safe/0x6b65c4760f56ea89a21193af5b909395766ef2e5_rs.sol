// Dependency file: @openzeppelin/contracts/utils/Address.sol



// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
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

/**
 * @title ModuleBase
 * @author Set Protocol
 *
 * Abstract class that houses common Module-related state and functions.
 */
abstract contract ModuleBase is IModule {

    /* ============ State Variables ============ */

    // Address of the controller
    IController public controller;

    /* ============ Modifiers ============ */

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
}
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

// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol



// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Dependency file: contracts/protocol/modules/StreamingFeeModule.sol

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

// import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import { SafeCast } from "@openzeppelin/contracts/utils/SafeCast.sol";
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
// import { SignedSafeMath } from "@openzeppelin/contracts/math/SignedSafeMath.sol";

// import { IController } from "../../interfaces/IController.sol";
// import { ISetToken } from "../../interfaces/ISetToken.sol";
// import { ModuleBase } from "../lib/ModuleBase.sol";
// import { PreciseUnitMath } from "../../lib/PreciseUnitMath.sol";


/**
 * @title StreamingFeeModule
 * @author Set Protocol
 *
 * Smart contract that accrues streaming fees for Set managers. Streaming fees are denominated as percent
 * per year and realized as Set inflation rewarded to the manager.
 */
contract StreamingFeeModule is ModuleBase, ReentrancyGuard {
    using SafeMath for uint256;
    using PreciseUnitMath for uint256;
    using SafeCast for uint256;

    using SignedSafeMath for int256;
    using PreciseUnitMath for int256;
    using SafeCast for int256;


    /* ============ Structs ============ */

    struct FeeState {
        address feeRecipient;                   // Address to accrue fees to
        uint256 maxStreamingFeePercentage;      // Max streaming fee maanager commits to using (1% = 1e16, 100% = 1e18)
        uint256 streamingFeePercentage;         // Percent of Set accruing to manager annually (1% = 1e16, 100% = 1e18)
        uint256 lastStreamingFeeTimestamp;      // Timestamp last streaming fee was accrued
    }

    /* ============ Events ============ */

    event FeeActualized(address indexed _setToken, uint256 _managerFee, uint256 _protocolFee);
    event StreamingFeeUpdated(address indexed _setToken, uint256 _newStreamingFee);
    event FeeRecipientUpdated(address indexed _setToken, address _newFeeRecipient);

    /* ============ Constants ============ */

    uint256 private constant ONE_YEAR_IN_SECONDS = 365.25 days;
    uint256 private constant PROTOCOL_STREAMING_FEE_INDEX = 0;

    /* ============ State Variables ============ */

    mapping(ISetToken => FeeState) public feeStates;

    /* ============ Constructor ============ */

    constructor(IController _controller) public ModuleBase(_controller) {}

    /* ============ External Functions ============ */

    /*
     * Calculates total inflation percentage then mints new Sets to the fee recipient. Position units are
     * then adjusted down (in magnitude) in order to ensure full collateralization. Callable by anyone.
     *
     * @param _setToken       Address of SetToken
     */
    function accrueFee(ISetToken _setToken) public nonReentrant onlyValidAndInitializedSet(_setToken) {
        uint256 managerFee;
        uint256 protocolFee;

        if (_streamingFeePercentage(_setToken) > 0) {
            uint256 inflationFeePercentage = _calculateStreamingFee(_setToken);

            // Calculate incentiveFee inflation
            uint256 feeQuantity = _calculateStreamingFeeInflation(_setToken, inflationFeePercentage);

            // Mint new Sets to manager and protocol
            (
                managerFee,
                protocolFee
            ) = _mintManagerAndProtocolFee(_setToken, feeQuantity);

            _editPositionMultiplier(_setToken, inflationFeePercentage);
        }

        feeStates[_setToken].lastStreamingFeeTimestamp = block.timestamp;

        emit FeeActualized(address(_setToken), managerFee, protocolFee);
    }

    /**
     * SET MANAGER ONLY. Initialize module with SetToken and set the fee state for the SetToken. Passed
     * _settings will have lastStreamingFeeTimestamp over-written.
     *
     * @param _setToken                 Address of SetToken
     * @param _settings                 FeeState struct defining fee parameters
     */
    function initialize(
        ISetToken _setToken,
        FeeState memory _settings
    )
        external
        onlySetManager(_setToken, msg.sender)
        onlyValidAndPendingSet(_setToken)
    {
        require(_settings.feeRecipient != address(0), "Fee Recipient must be non-zero address.");
        require(_settings.maxStreamingFeePercentage < PreciseUnitMath.preciseUnit(), "Max fee must be < 100%.");
        require(_settings.streamingFeePercentage <= _settings.maxStreamingFeePercentage, "Fee must be <= max.");

        _settings.lastStreamingFeeTimestamp = block.timestamp;

        feeStates[_setToken] = _settings;
        _setToken.initializeModule();
    }

    /**
     * Removes this module from the SetToken, via call by the SetToken. Manager's feeState is deleted. Fees
     * are not accrued in case reason for removing module is related to fee accrual.
     */
    function removeModule() external override {
        delete feeStates[ISetToken(msg.sender)];
    }

    /*
     * Set new streaming fee. Fees accrue at current rate then new rate is set.
     * Fees are accrued to prevent the manager from unfairly accruing a larger percentage.
     *
     * @param _setToken       Address of SetToken
     * @param _newFee         New streaming fee 18 decimal precision
     */
    function updateStreamingFee(
        ISetToken _setToken,
        uint256 _newFee
    )
        external
        onlySetManager(_setToken, msg.sender)
        onlyValidAndInitializedSet(_setToken)
    {
        require(_newFee < _maxStreamingFeePercentage(_setToken), "Fee must be less than max");
        accrueFee(_setToken);

        feeStates[_setToken].streamingFeePercentage = _newFee;

        emit StreamingFeeUpdated(address(_setToken), _newFee);
    }

    /*
     * Set new fee recipient.
     *
     * @param _setToken             Address of SetToken
     * @param _newFeeRecipient      New fee recipient
     */
    function updateFeeRecipient(ISetToken _setToken, address _newFeeRecipient)
        external
        onlySetManager(_setToken, msg.sender)
        onlyValidAndInitializedSet(_setToken)
    {
        require(_newFeeRecipient != address(0), "Fee Recipient must be non-zero address.");

        feeStates[_setToken].feeRecipient = _newFeeRecipient;

        emit FeeRecipientUpdated(address(_setToken), _newFeeRecipient);
    }

    /*
     * Calculates total inflation percentage in order to accrue fees to manager.
     *
     * @param _setToken       Address of SetToken
     * @return  uint256       Percent inflation of supply
     */
    function getFee(ISetToken _setToken) external view returns (uint256) {
        return _calculateStreamingFee(_setToken);
    }

    /* ============ Internal Functions ============ */

    /**
     * Calculates streaming fee by multiplying streamingFeePercentage by the elapsed amount of time since the last fee
     * was collected divided by one year in seconds, since the fee is a yearly fee.
     *
     * @param  _setToken          Address of Set to have feeState updated
     * @return uint256            Streaming fee denominated in percentage of totalSupply
     */
    function _calculateStreamingFee(ISetToken _setToken) internal view returns(uint256) {
        uint256 timeSinceLastFee = block.timestamp.sub(_lastStreamingFeeTimestamp(_setToken));

        // Streaming fee is streaming fee times years since last fee
        return timeSinceLastFee.mul(_streamingFeePercentage(_setToken)).div(ONE_YEAR_IN_SECONDS);
    }

    /**
     * Returns the new incentive fee denominated in the number of SetTokens to mint. The calculation for the fee involves
     * implying mint quantity so that the feeRecipient owns the fee percentage of the entire supply of the Set.
     *
     * The formula to solve for fee is:
     * (feeQuantity / feeQuantity) + totalSupply = fee / scaleFactor
     *
     * The simplified formula utilized below is:
     * feeQuantity = fee * totalSupply / (scaleFactor - fee)
     *
     * @param   _setToken               SetToken instance
     * @param   _feePercentage          Fee levied to feeRecipient
     * @return  uint256                 New RebalancingSet issue quantity
     */
    function _calculateStreamingFeeInflation(
        ISetToken _setToken,
        uint256 _feePercentage
    )
        internal
        view
        returns (uint256)
    {
        uint256 totalSupply = _setToken.totalSupply();

        // fee * totalSupply
        uint256 a = _feePercentage.mul(totalSupply);

        // ScaleFactor (10e18) - fee
        uint256 b = PreciseUnitMath.preciseUnit().sub(_feePercentage);

        return a.div(b);
    }

    /**
     * Mints sets to both the manager and the protocol. Protocol takes a percentage fee of the total amount of Sets
     * minted to manager.
     *
     * @param   _setToken               SetToken instance
     * @param   _feeQuantity            Amount of Sets to be minted as fees
     * @return  uint256                 Amount of Sets accrued to manager as fee
     * @return  uint256                 Amount of Sets accrued to protocol as fee
     */
    function _mintManagerAndProtocolFee(ISetToken _setToken, uint256 _feeQuantity) internal returns (uint256, uint256) {
        address protocolFeeRecipient = controller.feeRecipient();
        uint256 protocolFee = controller.getModuleFee(address(this), PROTOCOL_STREAMING_FEE_INDEX);

        uint256 protocolFeeAmount = _feeQuantity.preciseMul(protocolFee);
        uint256 managerFeeAmount = _feeQuantity.sub(protocolFeeAmount);

        _setToken.mint(_feeRecipient(_setToken), managerFeeAmount);

        if (protocolFeeAmount > 0) {
            _setToken.mint(protocolFeeRecipient, protocolFeeAmount);
        }

        return (managerFeeAmount, protocolFeeAmount);
    }

    /**
     * Calculates new position multiplier according to following formula:
     *
     * newMultiplier = oldMultiplier * (1-inflationFee)
     *
     * This reduces position sizes to offset increase in supply due to fee collection.
     *
     * @param   _setToken               SetToken instance
     * @param   _inflationFee           Fee inflation rate
     */
    function _editPositionMultiplier(ISetToken _setToken, uint256 _inflationFee) internal {
        int256 currentMultipler = _setToken.positionMultiplier();
        int256 newMultiplier = currentMultipler.preciseMul(PreciseUnitMath.preciseUnit().sub(_inflationFee).toInt256());

        _setToken.editPositionMultiplier(newMultiplier);
    }

    function _feeRecipient(ISetToken _set) internal view returns (address) {
        return feeStates[_set].feeRecipient;
    }

    function _lastStreamingFeeTimestamp(ISetToken _set) internal view returns (uint256) {
        return feeStates[_set].lastStreamingFeeTimestamp;
    }

    function _maxStreamingFeePercentage(ISetToken _set) internal view returns (uint256) {
        return feeStates[_set].maxStreamingFeePercentage;
    }

    function _streamingFeePercentage(ISetToken _set) internal view returns (uint256) {
        return feeStates[_set].streamingFeePercentage;
    }
}
// Dependency file: contracts/interfaces/IStreamingFeeModule.sol

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

// import { ISetToken } from "./ISetToken.sol";
// import { StreamingFeeModule } from "../protocol/modules/StreamingFeeModule.sol";


// Dependency file: @nomiclabs/buidler/console.sol


// pragma solidity >= 0.4.22 <0.7.0;



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
// Dependency file: contracts/protocol-viewers/StreamingFeeModuleViewer.sol

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


// import { ISetToken } from "../interfaces/ISetToken.sol";
// import { IStreamingFeeModule } from "../interfaces/IStreamingFeeModule.sol";
// import { StreamingFeeModule } from "../protocol/modules/StreamingFeeModule.sol";


/**
 * @title StreamingFeeModuleViewer
 * @author Set Protocol
 *
 * StreamingFeeModuleViewer enables batch queries of StreamingFeeModule state.
 */
contract StreamingFeeModuleViewer {

    struct StreamingFeeInfo {
        address feeRecipient;
        uint256 streamingFeePercentage;
        uint256 unaccruedFees;
    }

    function batchFetchStreamingFeeInfo(
        IStreamingFeeModule _streamingFeeModule,
        ISetToken[] memory _setTokens
    )
        external
        view
        returns (StreamingFeeInfo[] memory)
    {
        StreamingFeeInfo[] memory feeInfo = new StreamingFeeInfo[](_setTokens.length);

        for (uint256 i = 0; i < _setTokens.length; i++) {
            StreamingFeeModule.FeeState memory feeState = _streamingFeeModule.feeStates(_setTokens[i]);
            uint256 unaccruedFees = _streamingFeeModule.getFee(_setTokens[i]);

            feeInfo[i] = StreamingFeeInfo({
                feeRecipient: feeState.feeRecipient,
                streamingFeePercentage: feeState.streamingFeePercentage,
                unaccruedFees: unaccruedFees
            });
        }

        return feeInfo;
    }
}
// Dependency file: contracts/protocol-viewers/SetTokenViewer.sol

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


// import { ISetToken } from "../interfaces/ISetToken.sol";
// import "@nomiclabs/buidler/console.sol";


/**
 * @title SetTokenViewer
 * @author Set Protocol
 *
 * SetTokenViewer enables batch queries of SetToken state.
 */
contract SetTokenViewer {

    function batchFetchManagers(ISetToken[] memory _setTokens) external view returns (address[] memory) {
        address[] memory managers = new address[](_setTokens.length);

        for (uint256 i = 0; i < _setTokens.length; i++) {
            managers[i] = _setTokens[i].manager();
        }
        return managers;
    }

    function batchFetchModuleStates(
        ISetToken[] calldata _setTokens,
        address[] calldata _modules
    )
        external
        view
        returns (ISetToken.ModuleState[][] memory)
    {
        ISetToken.ModuleState[][] memory states = new ISetToken.ModuleState[][](_setTokens.length);
        for (uint256 i = 0; i < _setTokens.length; i++) {
            ISetToken.ModuleState[] memory moduleStates = new ISetToken.ModuleState[](_modules.length);
            for (uint256 j = 0; j < _modules.length; j++) {
                moduleStates[j] = _setTokens[i].moduleStates(_modules[j]);
            }
            states[i] = moduleStates;
        }
        return states;
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


// import { SetTokenViewer } from "./SetTokenViewer.sol";
// import { StreamingFeeModuleViewer } from "./StreamingFeeModuleViewer.sol";


/**
 * @title StreamingFeeModuleViewer
 * @author Set Protocol
 *
 * ProtocolViewer enables atch queries of various protocol state.
 */
contract ProtocolViewer is
    SetTokenViewer,
    StreamingFeeModuleViewer
{
    constructor() public {}
}