/**
 *Submitted for verification at Etherscan.io on 2021-02-07
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

contract Governed {
    event NewGov(address oldGov, address newGov);
    event NewPendingGov(address oldPendingGov, address newPendingGov);

    address public gov;
    address public pendingGov;

    modifier onlyGov {
        require(msg.sender == gov, "!gov");
        _;
    }

    function _setPendingGov(address who)
        public
        onlyGov
    {
        address old = pendingGov;
        pendingGov = who;
        emit NewPendingGov(old, who);
    }

    function _acceptGov()
        public
    {
        require(msg.sender == pendingGov, "!pendingGov");
        address oldgov = gov;
        gov = pendingGov;
        pendingGov = address(0);
        emit NewGov(oldgov, gov);
    }
}

contract SubGoverned is Governed {
    /**
     * @notice Event emitted when a sub gov is enabled/disabled
     */
    event SubGovModified(
        address account,
        bool isSubGov
    );
    /// @notice sub governors
    mapping(address => bool) public isSubGov;

    modifier onlyGovOrSubGov() {
        require(msg.sender == gov || isSubGov[msg.sender]);
        _;
    }

    function setIsSubGov(address subGov, bool _isSubGov)
        public
        onlyGov
    {
        isSubGov[subGov] = _isSubGov;
        emit SubGovModified(subGov, _isSubGov);
    }
}

/**
 * @dev Collection of functions related to the address type
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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
    function getTotalComponentRealUnits(address _component) external view returns(int256);

    function isInitializedModule(address _module) external view returns(bool);
    function isPendingModule(address _module) external view returns(bool);
    function isLocked() external view returns (bool);
}

contract TreasuryManager is SubGoverned {
    using Address for address;

    /* ============ Modifiers ============ */

    /** @notice Throws if the sender is not allowed for this module */
    modifier onlyAllowedForModule(address _user, address _module) {
        require(
            moduleAllowlist[_user][_module] || _user == gov,
            "TreasuryManager::onlyAllowedForModule: User is not allowed for module"
        );
        _;
    }

    /* ============ State Variables ============ */

    /** @notice  Set token this contract manages                     */
    ISetToken public immutable setToken;

    /** @notice  mapping of modules a caller is allowed to use       */
    mapping(address => mapping(address => bool)) public moduleAllowlist;

    /** @notice  mapping of allowed tokens                           */
    mapping(address => bool) public allowedTokens;

    /* ============ Events ============ */

    event TokensAdded(address[] tokens);
    event TokensRemoved(address[] tokens);
    event ModulePermissionsUpdated(
        address indexed user,
        address indexed module,
        bool allowed
    );

    constructor(
        ISetToken _setToken,
        address _gov,
        address[] memory _allowedTokens
    ) public {
        setToken = _setToken;
        gov = _gov;
        addTokens(_allowedTokens);
    }

    /* ============ External Functions ============ */

    /**
     * @dev Gov ONLY
     *
     * @param _newManager       Manager to set on the set token
     */
    function setManager(address _newManager) external onlyGov {
        setToken.setManager(_newManager);
    }

    /**
     * @dev Gov ONLY
     *
     * @param _module           Module to add to the set token
     */
    function addModule(address _module) external onlyGov {
        setToken.addModule(_module);
    }

    /**
     * @dev Gov
     *
     * @param _module           Module to remove
     */
    function removeModule(address _module) external onlyGov {
        setToken.removeModule(_module);
    }

    /**
     * @dev Only allowed for module
     *
     * @param _module           Module to interact with
     * @param _data             Byte data of function to call in module
     */
    function interactModule(address _module, bytes calldata _data)
        external
        onlyAllowedForModule(msg.sender, _module)
    {
        // Invoke call to module, assume value will always be 0
        _module.functionCallWithValue(_data, 0);
    }

    /**
     * @dev Gov ONLY. Updates whether a module + adapter combo are allowed
     *
     * @param _module                    The module to allow this adapter with
     * @param _caller                    The caller to allow to use this module
     */
    function setModuleAllowed(
        address _caller,
        address _module,
        bool allowed
    ) external onlyGov {
        moduleAllowlist[_caller][_module] = allowed;
        emit ModulePermissionsUpdated(_caller, _module, allowed);
    }

    /**
     * @dev Gov ONLY. Enables a list of tokens for trading/wrapping to
     *
     * @param _tokens                    The list of tokens to add
     */
    function addTokens(address[] memory _tokens) public onlyGov {
        for (uint256 index = 0; index < _tokens.length; index++) {
            allowedTokens[_tokens[index]] = true;
        }
        emit TokensAdded(_tokens);
    }

    /**
     * @dev Gov ONLY. Disables a list of tokens from trading/wrapping to
     *
     * @param _tokens                    The list of tokens to remove
     */
    function removeTokens(address[] memory _tokens) external onlyGov {
        for (uint256 index = 0; index < _tokens.length; index++) {
            allowedTokens[_tokens[index]] = false;
        }
        emit TokensRemoved(_tokens);
    }

    /**
     * @dev Returns whether a token is allowed
     *
     * @param _token                    The token to check if it is allowed
     */
    function isTokenAllowed(address _token)
        external
        view
        returns (bool allowed)
    {
        return allowedTokens[_token];
    }
}