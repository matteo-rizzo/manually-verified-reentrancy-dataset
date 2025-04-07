/**

 *Submitted for verification at Etherscan.io on 2018-11-12

*/



pragma solidity ^0.4.24;



/**

 * @title Interface to be implemented by all permission manager modules

 */





/**

 * @title Interface that every module contract should implement

 */





/**

 * @title Interface for all security tokens

 */





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title Interface that any module contract should implement

 * @notice Contract is abstract

 */

contract Module is IModule {



    address public factory;



    address public securityToken;



    bytes32 public constant FEE_ADMIN = "FEE_ADMIN";



    IERC20 public polyToken;



    /**

     * @notice Constructor

     * @param _securityToken Address of the security token

     * @param _polyAddress Address of the polytoken

     */

    constructor (address _securityToken, address _polyAddress) public {

        securityToken = _securityToken;

        factory = msg.sender;

        polyToken = IERC20(_polyAddress);

    }



    //Allows owner, factory or permissioned delegate

    modifier withPerm(bytes32 _perm) {

        bool isOwner = msg.sender == Ownable(securityToken).owner();

        bool isFactory = msg.sender == factory;

        require(isOwner||isFactory||ISecurityToken(securityToken).checkPermission(msg.sender, address(this), _perm), "Permission check failed");

        _;

    }



    modifier onlyOwner {

        require(msg.sender == Ownable(securityToken).owner(), "Sender is not owner");

        _;

    }



    modifier onlyFactory {

        require(msg.sender == factory, "Sender is not factory");

        _;

    }



    modifier onlyFactoryOwner {

        require(msg.sender == Ownable(factory).owner(), "Sender is not factory owner");

        _;

    }



    modifier onlyFactoryOrOwner {

        require((msg.sender == Ownable(securityToken).owner()) || (msg.sender == factory), "Sender is not factory or owner");

        _;

    }



    /**

     * @notice used to withdraw the fee by the factory owner

     */

    function takeFee(uint256 _amount) public withPerm(FEE_ADMIN) returns(bool) {

        require(polyToken.transferFrom(securityToken, Ownable(factory).owner(), _amount), "Unable to take fee");

        return true;

    }

}



/**

 * @title Permission Manager module for core permissioning functionality

 */

contract GeneralPermissionManager is IPermissionManager, Module {



    // Mapping used to hold the permissions on the modules provided to delegate, module add => delegate add => permission bytes32 => bool 

    mapping (address => mapping (address => mapping (bytes32 => bool))) public perms;

    // Mapping hold the delagate details

    mapping (address => bytes32) public delegateDetails;

    // Array to track all delegates

    address[] public allDelegates;





    // Permission flag

    bytes32 public constant CHANGE_PERMISSION = "CHANGE_PERMISSION";



    /// Event emitted after any permission get changed for the delegate

    event ChangePermission(address indexed _delegate, address _module, bytes32 _perm, bool _valid, uint256 _timestamp);

    /// Used to notify when delegate is added in permission manager contract

    event AddDelegate(address indexed _delegate, bytes32 _details, uint256 _timestamp);





    /// @notice constructor

    constructor (address _securityToken, address _polyAddress) public

    Module(_securityToken, _polyAddress)

    {

    }



    /**

     * @notice Init function i.e generalise function to maintain the structure of the module contract

     * @return bytes4

     */

    function getInitFunction() public pure returns (bytes4) {

        return bytes4(0);

    }



    /**

     * @notice Used to check the permission on delegate corresponds to module contract address

     * @param _delegate Ethereum address of the delegate

     * @param _module Ethereum contract address of the module

     * @param _perm Permission flag

     * @return bool

     */

    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns(bool) {

        if (delegateDetails[_delegate] != bytes32(0)) {

            return perms[_module][_delegate][_perm];

        } else

            return false;

    }



    /**

     * @notice Used to add a delegate

     * @param _delegate Ethereum address of the delegate

     * @param _details Details about the delegate i.e `Belongs to financial firm`

     */

    function addDelegate(address _delegate, bytes32 _details) external withPerm(CHANGE_PERMISSION) {

        require(_delegate != address(0), "Invalid address");

        require(_details != bytes32(0), "0 value not allowed");

        require(delegateDetails[_delegate] == bytes32(0), "Already present");

        delegateDetails[_delegate] = _details;

        allDelegates.push(_delegate);

        /*solium-disable-next-line security/no-block-members*/

        emit AddDelegate(_delegate, _details, now);

    }



    /**

     * @notice Used to delete a delegate

     * @param _delegate Ethereum address of the delegate

     */

    function deleteDelegate(address _delegate) external withPerm(CHANGE_PERMISSION) {

        require(delegateDetails[_delegate] != bytes32(0), "delegate does not exist");

        for (uint256 i = 0; i < allDelegates.length; i++) {

            if (allDelegates[i] == _delegate) {

                allDelegates[i] = allDelegates[allDelegates.length - 1];

                allDelegates.length = allDelegates.length - 1;

            }

        }

        delete delegateDetails[_delegate];

    }



    /**

     * @notice Used to check if an address is a delegate or not

     * @param _potentialDelegate the address of potential delegate

     * @return bool

     */

    function checkDelegate(address _potentialDelegate) external view returns(bool) {

        require(_potentialDelegate != address(0), "Invalid address");



        if (delegateDetails[_potentialDelegate] != bytes32(0)) {

            return true;

        } else

            return false;

    }



    /**

     * @notice Used to provide/change the permission to the delegate corresponds to the module contract

     * @param _delegate Ethereum address of the delegate

     * @param _module Ethereum contract address of the module

     * @param _perm Permission flag

     * @param _valid Bool flag use to switch on/off the permission

     * @return bool

     */

    function changePermission(

        address _delegate,

        address _module,

        bytes32 _perm,

        bool _valid

    )

    public

    withPerm(CHANGE_PERMISSION)

    {

        require(_delegate != address(0), "invalid address");

        _changePermission(_delegate, _module, _perm, _valid);

    }



    /**

     * @notice Used to change one or more permissions for a single delegate at once

     * @param _delegate Ethereum address of the delegate

     * @param _modules Multiple module matching the multiperms, needs to be same length

     * @param _perms Multiple permission flag needs to be changed

     * @param _valids Bool array consist the flag to switch on/off the permission

     * @return nothing

     */

    function changePermissionMulti(

        address _delegate,

        address[] _modules,

        bytes32[] _perms,

        bool[] _valids

    )

    external

    withPerm(CHANGE_PERMISSION)

    {

        require(_delegate != address(0), "invalid address");

        require(_modules.length > 0, "0 length is not allowed");

        require(_modules.length == _perms.length, "Array length mismatch");

        require(_valids.length == _perms.length, "Array length mismatch");

        for(uint256 i = 0; i < _perms.length; i++) {

            _changePermission(_delegate, _modules[i], _perms[i], _valids[i]);

        }

    }



    /**

     * @notice Used to return all delegates with a given permission and module

     * @param _module Ethereum contract address of the module

     * @param _perm Permission flag

     * @return address[]

     */

    function getAllDelegatesWithPerm(address _module, bytes32 _perm) external view returns(address[]) {

        uint256 counter = 0;

        uint256 i = 0;

        for (i = 0; i < allDelegates.length; i++) {

            if (perms[_module][allDelegates[i]][_perm]) {

                counter++;

            }

        }

        address[] memory allDelegatesWithPerm = new address[](counter);

        counter = 0;

        for (i = 0; i < allDelegates.length; i++) {

            if (perms[_module][allDelegates[i]][_perm]){

                allDelegatesWithPerm[counter] = allDelegates[i];

                counter++;

            }

        }

        return allDelegatesWithPerm;

    }



    /**

     * @notice Used to return all permission of a single or multiple module

     * @dev possible that function get out of gas is there are lot of modules and perm related to them

     * @param _delegate Ethereum address of the delegate

     * @param _types uint8[] of types

     * @return address[] the address array of Modules this delegate has permission

     * @return bytes32[] the permission array of the corresponding Modules

     */

    function getAllModulesAndPermsFromTypes(address _delegate, uint8[] _types) external view returns(address[], bytes32[]) {

        uint256 counter = 0;

        // loop through _types and get their modules from securityToken->getModulesByType

        for (uint256 i = 0; i < _types.length; i++) {

            address[] memory _currentTypeModules = ISecurityToken(securityToken).getModulesByType(_types[i]);

            // loop through each modules to get their perms from IModule->getPermissions

            for (uint256 j = 0; j < _currentTypeModules.length; j++){

                bytes32[] memory _allModulePerms = IModule(_currentTypeModules[j]).getPermissions();

                // loop through each perm, if it is true, push results into arrays

                for (uint256 k = 0; k < _allModulePerms.length; k++) {

                    if (perms[_currentTypeModules[j]][_delegate][_allModulePerms[k]]) {

                        counter ++;

                    }

                }

            }

        }



        address[] memory _allModules = new address[](counter);

        bytes32[] memory _allPerms = new bytes32[](counter);

        counter = 0;



        for (i = 0; i < _types.length; i++){

            _currentTypeModules = ISecurityToken(securityToken).getModulesByType(_types[i]);

            for (j = 0; j < _currentTypeModules.length; j++) {

                _allModulePerms = IModule(_currentTypeModules[j]).getPermissions();

                for (k = 0; k < _allModulePerms.length; k++) {

                    if (perms[_currentTypeModules[j]][_delegate][_allModulePerms[k]]) {

                        _allModules[counter] = _currentTypeModules[j];

                        _allPerms[counter] = _allModulePerms[k];

                        counter++;

                    }

                }

            }

        }



        return(_allModules, _allPerms);

    }



    /**

     * @notice Used to provide/change the permission to the delegate corresponds to the module contract

     * @param _delegate Ethereum address of the delegate

     * @param _module Ethereum contract address of the module

     * @param _perm Permission flag

     * @param _valid Bool flag use to switch on/off the permission

     * @return bool

     */

    function _changePermission(

        address _delegate,

        address _module,

        bytes32 _perm,

        bool _valid

    )

     internal

    {

        perms[_module][_delegate][_perm] = _valid;

        /*solium-disable-next-line security/no-block-members*/

        emit ChangePermission(_delegate, _module, _perm, _valid, now);

    }



    /**

     * @notice Used to get all delegates

     * @return address[]

     */

    function getAllDelegates() external view returns(address[]) {

        return allDelegates;

    }

    

    /**

    * @notice Returns the Permission flag related the `this` contract

    * @return Array of permission flags

    */

    function getPermissions() public view returns(bytes32[]) {

        bytes32[] memory allPermissions = new bytes32[](1);

        allPermissions[0] = CHANGE_PERMISSION;

        return allPermissions;

    }



}



/**

 * @title Interface that every module factory contract should implement

 */





/**

 * @title Helper library use to compare or validate the semantic versions

 */







/**

 * @title Interface that any module factory contract should implement

 * @notice Contract is abstract

 */

contract ModuleFactory is IModuleFactory, Ownable {



    IERC20 public polyToken;

    uint256 public usageCost;

    uint256 public monthlySubscriptionCost;



    uint256 public setupCost;

    string public description;

    string public version;

    bytes32 public name;

    string public title;



    // @notice Allow only two variables to be stored

    // 1. lowerBound 

    // 2. upperBound

    // @dev (0.0.0 will act as the wildcard) 

    // @dev uint24 consists packed value of uint8 _major, uint8 _minor, uint8 _patch

    mapping(string => uint24) compatibleSTVersionRange;



    event ChangeFactorySetupFee(uint256 _oldSetupCost, uint256 _newSetupCost, address _moduleFactory);

    event ChangeFactoryUsageFee(uint256 _oldUsageCost, uint256 _newUsageCost, address _moduleFactory);

    event ChangeFactorySubscriptionFee(uint256 _oldSubscriptionCost, uint256 _newMonthlySubscriptionCost, address _moduleFactory);

    event GenerateModuleFromFactory(

        address _module,

        bytes32 indexed _moduleName,

        address indexed _moduleFactory,

        address _creator,

        uint256 _timestamp

    );

    event ChangeSTVersionBound(string _boundType, uint8 _major, uint8 _minor, uint8 _patch);



    /**

     * @notice Constructor

     * @param _polyAddress Address of the polytoken

     */

    constructor (address _polyAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost) public {

        polyToken = IERC20(_polyAddress);

        setupCost = _setupCost;

        usageCost = _usageCost;

        monthlySubscriptionCost = _subscriptionCost;

    }



    /**

     * @notice Used to change the fee of the setup cost

     * @param _newSetupCost new setup cost

     */

    function changeFactorySetupFee(uint256 _newSetupCost) public onlyOwner {

        emit ChangeFactorySetupFee(setupCost, _newSetupCost, address(this));

        setupCost = _newSetupCost;

    }



    /**

     * @notice Used to change the fee of the usage cost

     * @param _newUsageCost new usage cost

     */

    function changeFactoryUsageFee(uint256 _newUsageCost) public onlyOwner {

        emit ChangeFactoryUsageFee(usageCost, _newUsageCost, address(this));

        usageCost = _newUsageCost;

    }



    /**

     * @notice Used to change the fee of the subscription cost

     * @param _newSubscriptionCost new subscription cost

     */

    function changeFactorySubscriptionFee(uint256 _newSubscriptionCost) public onlyOwner {

        emit ChangeFactorySubscriptionFee(monthlySubscriptionCost, _newSubscriptionCost, address(this));

        monthlySubscriptionCost = _newSubscriptionCost;



    }



    /**

     * @notice Updates the title of the ModuleFactory

     * @param _newTitle New Title that will replace the old one.

     */

    function changeTitle(string _newTitle) public onlyOwner {

        require(bytes(_newTitle).length > 0, "Invalid title");

        title = _newTitle;

    }



    /**

     * @notice Updates the description of the ModuleFactory

     * @param _newDesc New description that will replace the old one.

     */

    function changeDescription(string _newDesc) public onlyOwner {

        require(bytes(_newDesc).length > 0, "Invalid description");

        description = _newDesc;

    }



    /**

     * @notice Updates the name of the ModuleFactory

     * @param _newName New name that will replace the old one.

     */

    function changeName(bytes32 _newName) public onlyOwner {

        require(_newName != bytes32(0),"Invalid name");

        name = _newName;

    }



    /**

     * @notice Updates the version of the ModuleFactory

     * @param _newVersion New name that will replace the old one.

     */

    function changeVersion(string _newVersion) public onlyOwner {

        require(bytes(_newVersion).length > 0, "Invalid version");

        version = _newVersion;

    }



    /**

     * @notice Function use to change the lower and upper bound of the compatible version st

     * @param _boundType Type of bound

     * @param _newVersion new version array

     */

    function changeSTVersionBounds(string _boundType, uint8[] _newVersion) external onlyOwner {

        require(

            keccak256(abi.encodePacked(_boundType)) == keccak256(abi.encodePacked("lowerBound")) ||

            keccak256(abi.encodePacked(_boundType)) == keccak256(abi.encodePacked("upperBound")),

            "Must be a valid bound type"

        );

        require(_newVersion.length == 3);

        if (compatibleSTVersionRange[_boundType] != uint24(0)) { 

            uint8[] memory _currentVersion = VersionUtils.unpack(compatibleSTVersionRange[_boundType]);

            require(VersionUtils.isValidVersion(_currentVersion, _newVersion), "Failed because of in-valid version");

        }

        compatibleSTVersionRange[_boundType] = VersionUtils.pack(_newVersion[0], _newVersion[1], _newVersion[2]);

        emit ChangeSTVersionBound(_boundType, _newVersion[0], _newVersion[1], _newVersion[2]);

    }



    /**

     * @notice Used to get the lower bound

     * @return lower bound

     */

    function getLowerSTVersionBounds() external view returns(uint8[]) {

        return VersionUtils.unpack(compatibleSTVersionRange["lowerBound"]);

    }



    /**

     * @notice Used to get the upper bound

     * @return upper bound

     */

    function getUpperSTVersionBounds() external view returns(uint8[]) {

        return VersionUtils.unpack(compatibleSTVersionRange["upperBound"]);

    }



    /**

     * @notice Get the setup cost of the module

     */

    function getSetupCost() external view returns (uint256) {

        return setupCost;

    }



   /**

    * @notice Get the name of the Module

    */

    function getName() public view returns(bytes32) {

        return name;

    }



}



/**

 * @title Factory for deploying GeneralPermissionManager module

 */

contract GeneralPermissionManagerFactory is ModuleFactory {



    /**

     * @notice Constructor

     * @param _polyAddress Address of the polytoken

     */

    constructor (address _polyAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost) public

    ModuleFactory(_polyAddress, _setupCost, _usageCost, _subscriptionCost)

    {

        version = "1.0.0";

        name = "GeneralPermissionManager";

        title = "General Permission Manager";

        description = "Manage permissions within the Security Token and attached modules";

        compatibleSTVersionRange["lowerBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));

        compatibleSTVersionRange["upperBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));

    }



    /**

     * @notice Used to launch the Module with the help of factory

     * @return address Contract address of the Module

     */

    function deploy(bytes /* _data */) external returns(address) {

        if(setupCost > 0)

            require(polyToken.transferFrom(msg.sender, owner, setupCost), "Failed transferFrom due to insufficent Allowance provided");

        address permissionManager = new GeneralPermissionManager(msg.sender, address(polyToken));

        /*solium-disable-next-line security/no-block-members*/

        emit GenerateModuleFromFactory(address(permissionManager), getName(), address(this), msg.sender, setupCost, now);

        return permissionManager;

    }



    /**

     * @notice Type of the Module factory

     */

    function getTypes() external view returns(uint8[]) {

        uint8[] memory res = new uint8[](1);

        res[0] = 1;

        return res;

    }



    /**

     * @notice Returns the instructions associated with the module

     */

    function getInstructions() external view returns(string) {

        /*solium-disable-next-line max-len*/

        return "Add and remove permissions for the SecurityToken and associated modules. Permission types should be encoded as bytes32 values and attached using withPerm modifier to relevant functions. No initFunction required.";

    }



    /**

     * @notice Get the tags related to the module factory

     */

    function getTags() external view returns(bytes32[]) {

        bytes32[] memory availableTags = new bytes32[](0);

        return availableTags;

    }

}