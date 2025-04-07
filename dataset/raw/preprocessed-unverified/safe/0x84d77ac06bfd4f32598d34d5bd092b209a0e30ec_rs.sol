/**
 *Submitted for verification at Etherscan.io on 2021-03-06
*/

// Dependency file: @openzeppelin/contracts/utils/Address.sol



// pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
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


// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: contracts/interfaces/ISetToken.sol

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

// Dependency file: contracts/interfaces/IBaseManager.sol

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

// pragma solidity 0.6.10;


// import { ISetToken } from "contracts/interfaces/ISetToken.sol";



// Dependency file: contracts/lib/BaseAdapter.sol

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

// pragma solidity 0.6.10;

// import { AddressArrayUtils } from "contracts/lib/AddressArrayUtils.sol";
// import { IBaseManager } from "contracts/interfaces/IBaseManager.sol";

/**
 * @title BaseAdapter
 * @author Set Protocol
 *
 * Abstract class that houses common adapter-related state and functions.
 */
abstract contract BaseAdapter {
    using AddressArrayUtils for address[];

    /* ============ Events ============ */

    event CallerStatusUpdated(address indexed _caller, bool _status);
    event AnyoneCallableUpdated(bool indexed _status);

    /* ============ Modifiers ============ */

    /**
     * Throws if the sender is not the SetToken operator
     */
    modifier onlyOperator() {
        require(msg.sender == manager.operator(), "Must be operator");
        _;
    }

    /**
     * Throws if the sender is not the SetToken methodologist
     */
    modifier onlyMethodologist() {
        require(msg.sender == manager.methodologist(), "Must be methodologist");
        _;
    }

    /**
     * Throws if caller is a contract, can be used to stop flash loan and sandwich attacks
     */
    modifier onlyEOA() {
        require(msg.sender == tx.origin, "Caller must be EOA Address");
        _;
    }

    /**
     * Throws if not allowed caller
     */
    modifier onlyAllowedCaller(address _caller) {
        require(isAllowedCaller(_caller), "Address not permitted to call");
        _;
    }

    /* ============ State Variables ============ */

    // Instance of manager contract
    IBaseManager public manager;

    // Boolean indicating if anyone can call function
    bool public anyoneCallable;

    // Mapping of addresses allowed to call function
    mapping(address => bool) public callAllowList;

    /* ============ Constructor ============ */

    constructor(IBaseManager _manager) public { manager = _manager; }

    /* ============ External Functions ============ */

    /**
     * OPERATOR ONLY: Toggle ability for passed addresses to call only allowed caller functions
     *
     * @param _callers           Array of caller addresses to toggle status
     * @param _statuses          Array of statuses for each caller
     */
    function updateCallerStatus(address[] calldata _callers, bool[] calldata _statuses) external onlyOperator {
        require(_callers.length == _statuses.length, "Array length mismatch");
        require(_callers.length > 0, "Array length must be > 0");
        require(!_callers.hasDuplicate(), "Cannot duplicate callers");

        for (uint256 i = 0; i < _callers.length; i++) {
            address caller = _callers[i];
            bool status = _statuses[i];
            callAllowList[caller] = status;
            emit CallerStatusUpdated(caller, status);
        }
    }

    /**
     * OPERATOR ONLY: Toggle whether anyone can call function, bypassing the callAllowlist 
     *
     * @param _status           Boolean indicating whether to allow anyone call
     */
    function updateAnyoneCallable(bool _status) external onlyOperator {
        anyoneCallable = _status;
        emit AnyoneCallableUpdated(_status);
    }

    /* ============ Internal Functions ============ */
    
    /**
     * Invoke manager to transfer tokens from manager to other contract.
     *
     * @param _token           Token being transferred from manager contract
     * @param _amount          Amount of token being transferred
     */
    function invokeManagerTransfer(address _token, address _destination, uint256 _amount) internal {
        bytes memory callData = abi.encodeWithSignature("transfer(address,uint256)", _destination, _amount);
        invokeManager(_token, callData);
    }

    /**
     * Invoke call from manager
     *
     * @param _module           Module to interact with
     * @param _encoded          Encoded byte data
     */
    function invokeManager(address _module, bytes memory _encoded) internal {
        manager.interactManager(_module, _encoded);
    }

    /**
     * Determine if passed address is allowed to call function. If anyoneCallable set to true anyone can call otherwise needs to be approved.
     *
     * return bool              Boolean indicating if allowed caller
     */
    function isAllowedCaller(address _caller) internal view virtual returns (bool) {
        return anyoneCallable || callAllowList[_caller];
    }
}

// Dependency file: contracts/interfaces/IIssuanceModule.sol

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
// pragma solidity 0.6.10;

// import { ISetToken } from "contracts/interfaces/ISetToken.sol";

/**
 * @title IDebtIssuanceModule
 * @author Set Protocol
 *
 * Interface for interacting with Debt Issuance module interface.
 */


// Dependency file: contracts/interfaces/IStreamingFeeModule.sol

// pragma solidity 0.6.10;


// import { ISetToken } from "contracts/interfaces/ISetToken.sol";



// Dependency file: @openzeppelin/contracts/math/SignedSafeMath.sol


// pragma solidity >=0.6.0 <0.8.0;

/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
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


// Dependency file: @openzeppelin/contracts/GSN/Context.sol


// pragma solidity >=0.6.0 <0.8.0;

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


// Dependency file: @openzeppelin/contracts/access/Ownable.sol


// pragma solidity >=0.6.0 <0.8.0;

// import "@openzeppelin/contracts/GSN/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// Dependency file: contracts/lib/TimeLockUpgrade.sol

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

// import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";

/**
 * @title TimeLockUpgrade
 * @author Set Protocol
 *
 * The TimeLockUpgrade contract contains a modifier for handling minimum time period updates
 */
contract TimeLockUpgrade is
    Ownable
{
    using SafeMath for uint256;

    /* ============ State Variables ============ */

    // Timelock Upgrade Period in seconds
    uint256 public timeLockPeriod;

    // Mapping of upgradable units and initialized timelock
    mapping(bytes32 => uint256) public timeLockedUpgrades;

    /* ============ Events ============ */

    event UpgradeRegistered(
        bytes32 _upgradeHash,
        uint256 _timestamp
    );

    /* ============ Modifiers ============ */

    modifier timeLockUpgrade() {
        // If the time lock period is 0, then allow non-timebound upgrades.
        // This is useful for initialization of the protocol and for testing.
        if (timeLockPeriod == 0) {
            _;

            return;
        }

        // The upgrade hash is defined by the hash of the transaction call data,
        // which uniquely identifies the function as well as the passed in arguments.
        bytes32 upgradeHash = keccak256(
            abi.encodePacked(
                msg.data
            )
        );

        uint256 registrationTime = timeLockedUpgrades[upgradeHash];

        // If the upgrade hasn't been registered, register with the current time.
        if (registrationTime == 0) {
            timeLockedUpgrades[upgradeHash] = block.timestamp;

            emit UpgradeRegistered(
                upgradeHash,
                block.timestamp
            );

            return;
        }

        require(
            block.timestamp >= registrationTime.add(timeLockPeriod),
            "TimeLockUpgrade: Time lock period must have elapsed."
        );

        // Reset the timestamp to 0
        timeLockedUpgrades[upgradeHash] = 0;

        // Run the rest of the upgrades
        _;
    }

    /* ============ Function ============ */

    /**
     * Change timeLockPeriod period. Generally called after initially settings have been set up.
     *
     * @param  _timeLockPeriod   Time in seconds that upgrades need to be evaluated before execution
     */
    function setTimeLockPeriod(
        uint256 _timeLockPeriod
    )
        virtual
        external
        onlyOwner
    {
        // Only allow setting of the timeLockPeriod if the period is greater than the existing
        require(
            _timeLockPeriod > timeLockPeriod,
            "TimeLockUpgrade: New period must be greater than existing"
        );

        timeLockPeriod = _timeLockPeriod;
    }
}


// Root file: contracts/adapters/FeeSplitAdapter.sol

/*
    Copyright 2021 IndexCooperative

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
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";

// import { BaseAdapter } from "contracts/lib/BaseAdapter.sol";
// import { IIssuanceModule } from "contracts/interfaces/IIssuanceModule.sol";
// import { IBaseManager } from "contracts/interfaces/IBaseManager.sol";
// import { ISetToken } from "contracts/interfaces/ISetToken.sol";
// import { IStreamingFeeModule } from "contracts/interfaces/IStreamingFeeModule.sol";
// import { PreciseUnitMath } from "contracts/lib/PreciseUnitMath.sol";
// import { TimeLockUpgrade } from "contracts/lib/TimeLockUpgrade.sol";


/**
 * @title FeeSplitAdapter
 * @author Set Protocol
 *
 * Smart contract adapter that allows for splitting and setting streaming and mint/redeem fees. 
 */
contract FeeSplitAdapter is BaseAdapter, TimeLockUpgrade {
    using Address for address;
    using PreciseUnitMath for uint256;
    using SafeMath for uint256;

    /* ============ Events ============ */

    event FeesAccrued(address indexed _operator, address indexed _methodologist, uint256 _operatorTake, uint256 _methodologistTake);
    
    /* ============ State Variables ============ */

    ISetToken public setToken;
    IStreamingFeeModule public streamingFeeModule;
    IIssuanceModule public issuanceModule;

    // Percent of fees in precise units (10^16 = 1%) sent to operator, rest to methodologist
    uint256 public operatorFeeSplit;

    /* ============ Constructor ============ */

    constructor(
        IBaseManager _manager,
        IStreamingFeeModule _streamingFeeModule,
        IIssuanceModule _issuanceModule,
        uint256 _operatorFeeSplit
    )
        public
        BaseAdapter(_manager)
    {
        streamingFeeModule = _streamingFeeModule;
        issuanceModule = _issuanceModule;
        operatorFeeSplit = _operatorFeeSplit;
        setToken = manager.setToken();
    }

    /* ============ External Functions ============ */

    /**
     * ANYONE CALLABLE: Accrues fees from streaming fee module. Gets resulting balance after fee accrual, calculates fees for
     * operator and methodologist, and sends to each. NOTE: mint/redeem fees will automatically be sent to this address so reading
     * the balance of the SetToken in the contract after accrual is sufficient for accounting for all collected fees.
     */
    function accrueFeesAndDistribute() public {
        streamingFeeModule.accrueFee(setToken);
        
        uint256 totalFees = setToken.balanceOf(address(manager));
        
        address operator = manager.operator();
        address methodologist = manager.methodologist();

        uint256 operatorTake = totalFees.preciseMul(operatorFeeSplit);
        uint256 methodologistTake = totalFees.sub(operatorTake);

        if (operatorTake > 0) {
            invokeManagerTransfer(address(setToken), operator, operatorTake);
        }

        if (methodologistTake > 0) {
            invokeManagerTransfer(address(setToken), methodologist, methodologistTake);
        }

        emit FeesAccrued(operator, methodologist, operatorTake, methodologistTake);
    }

    /**
     * ONLY OPERATOR: Updates streaming fee on StreamingFeeModule. NOTE: This will accrue streaming fees though not send to operator
     * and methodologist.
     */
    function updateStreamingFee(uint256 _newFee) external onlyOperator timeLockUpgrade {
        bytes memory callData = abi.encodeWithSignature("updateStreamingFee(address,uint256)", manager.setToken(), _newFee);
        invokeManager(address(streamingFeeModule), callData);
    }

    /**
     * ONLY OPERATOR: Updates issue fee on IssuanceModule. Only is executed once time lock has passed.
     */
    function updateIssueFee(uint256 _newFee) external onlyOperator timeLockUpgrade {
        bytes memory callData = abi.encodeWithSignature("updateIssueFee(address,uint256)", manager.setToken(), _newFee);
        invokeManager(address(issuanceModule), callData);
    }

    /**
     * ONLY OPERATOR: Updates redeem fee on IssuanceModule. Only is executed once time lock has passed.
     */
    function updateRedeemFee(uint256 _newFee) external onlyOperator timeLockUpgrade {
        bytes memory callData = abi.encodeWithSignature("updateRedeemFee(address,uint256)", manager.setToken(), _newFee);
        invokeManager(address(issuanceModule), callData);
    }

    /**
     * ONLY OPERATOR: Updates fee recipient on both streaming fee and issuance modules.
     */
    function updateFeeRecipient(address _newFeeRecipient) external onlyOperator {
        bytes memory callData = abi.encodeWithSignature("updateFeeRecipient(address,address)", manager.setToken(), _newFeeRecipient);
        invokeManager(address(streamingFeeModule), callData);
        invokeManager(address(issuanceModule), callData);
    }

    /**
     * ONLY OPERATOR: Updates fee split between operator and methodologist. Split defined in precise units (1% = 10^16).
     */
    function updateFeeSplit(uint256 _newFeeSplit) external onlyOperator {
        require(_newFeeSplit <= PreciseUnitMath.preciseUnit(), "Fee must be less than 100%");
        accrueFeesAndDistribute();
        operatorFeeSplit = _newFeeSplit;
    }
}