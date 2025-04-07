/**

 *Submitted for verification at Etherscan.io on 2018-11-21

*/



pragma solidity ^0.4.24;



/**

 * @title Interface for the Polymath Module Registry contract

 */





/**

 * @title Interface that every module factory contract should implement

 */





/**

 * @title Interface for the Polymath Security Token Registry contract

 */









/**

 * @title Interface for managing polymath feature switches

 */





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





/**

 * @title Helper library use to compare or validate the semantic versions

 */







contract EternalStorage {



    /// @notice Internal mappings used to store all kinds on data into the contract

    mapping(bytes32 => uint256) internal uintStorage;

    mapping(bytes32 => string) internal stringStorage;

    mapping(bytes32 => address) internal addressStorage;

    mapping(bytes32 => bytes) internal bytesStorage;

    mapping(bytes32 => bool) internal boolStorage;

    mapping(bytes32 => int256) internal intStorage;

    mapping(bytes32 => bytes32) internal bytes32Storage;



    /// @notice Internal mappings used to store arrays of different data types

    mapping(bytes32 => bytes32[]) internal bytes32ArrayStorage;

    mapping(bytes32 => uint256[]) internal uintArrayStorage;

    mapping(bytes32 => address[]) internal addressArrayStorage;

    mapping(bytes32 => string[]) internal stringArrayStorage;



    //////////////////

    //// set functions

    //////////////////

    /// @notice Set the key values using the Overloaded `set` functions

    /// Ex- string version = "0.0.1"; replace to

    /// set(keccak256(abi.encodePacked("version"), "0.0.1");

    /// same for the other variables as well some more example listed below

    /// ex1 - address securityTokenAddress = 0x123; replace to

    /// set(keccak256(abi.encodePacked("securityTokenAddress"), 0x123);

    /// ex2 - bytes32 tokenDetails = "I am ST20"; replace to

    /// set(keccak256(abi.encodePacked("tokenDetails"), "I am ST20");

    /// ex3 - mapping(string => address) ownedToken;

    /// set(keccak256(abi.encodePacked("ownedToken", "Chris")), 0x123);

    /// ex4 - mapping(string => uint) tokenIndex;

    /// tokenIndex["TOKEN"] = 1; replace to set(keccak256(abi.encodePacked("tokenIndex", "TOKEN"), 1);

    /// ex5 - mapping(string => SymbolDetails) registeredSymbols; where SymbolDetails is the structure having different type of values as

    /// {uint256 date, string name, address owner} etc.

    /// registeredSymbols["TOKEN"].name = "MyFristToken"; replace to set(keccak256(abi.encodePacked("registeredSymbols_name", "TOKEN"), "MyFirstToken");

    /// More generalized- set(keccak256(abi.encodePacked("registeredSymbols_<struct variable>", "keyname"), "value");



    function set(bytes32 _key, uint256 _value) internal {

        uintStorage[_key] = _value;

    }



    function set(bytes32 _key, address _value) internal {

        addressStorage[_key] = _value;

    }



    function set(bytes32 _key, bool _value) internal {

        boolStorage[_key] = _value;

    }



    function set(bytes32 _key, bytes32 _value) internal {

        bytes32Storage[_key] = _value;

    }



    function set(bytes32 _key, string _value) internal {

        stringStorage[_key] = _value;

    }



    ////////////////////

    /// get functions

    ////////////////////

    /// @notice Get function use to get the value of the singleton state variables

    /// Ex1- string public version = "0.0.1";

    /// string _version = getString(keccak256(abi.encodePacked("version"));

    /// Ex2 - assert(temp1 == temp2); replace to

    /// assert(getUint(keccak256(abi.encodePacked(temp1)) == getUint(keccak256(abi.encodePacked(temp2));

    /// Ex3 - mapping(string => SymbolDetails) registeredSymbols; where SymbolDetails is the structure having different type of values as

    /// {uint256 date, string name, address owner} etc.

    /// string _name = getString(keccak256(abi.encodePacked("registeredSymbols_name", "TOKEN"));



    function getBool(bytes32 _key) internal view returns (bool) {

        return boolStorage[_key];

    }



    function getUint(bytes32 _key) internal view returns (uint256) {

        return uintStorage[_key];

    }



    function getAddress(bytes32 _key) internal view returns (address) {

        return addressStorage[_key];

    }



    function getString(bytes32 _key) internal view returns (string) {

        return stringStorage[_key];

    }



    function getBytes32(bytes32 _key) internal view returns (bytes32) {

        return bytes32Storage[_key];

    }





    ////////////////////////////

    // deleteArray functions

    ////////////////////////////

    /// @notice Function used to delete the array element.

    /// Ex1- mapping(address => bytes32[]) tokensOwnedByOwner;

    /// For deleting the item from array developers needs to create a funtion for that similarly

    /// in this case we have the helper function deleteArrayBytes32() which will do it for us

    /// deleteArrayBytes32(keccak256(abi.encodePacked("tokensOwnedByOwner", 0x1), 3); -- it will delete the index 3





    //Deletes from mapping (bytes32 => array[]) at index _index

    function deleteArrayAddress(bytes32 _key, uint256 _index) internal {

        address[] storage array = addressArrayStorage[_key];

        require(_index < array.length, "Index should less than length of the array");

        array[_index] = array[array.length - 1];

        array.length = array.length - 1;

    }



    //Deletes from mapping (bytes32 => bytes32[]) at index _index

    function deleteArrayBytes32(bytes32 _key, uint256 _index) internal {

        bytes32[] storage array = bytes32ArrayStorage[_key];

        require(_index < array.length, "Index should less than length of the array");

        array[_index] = array[array.length - 1];

        array.length = array.length - 1;

    }



    //Deletes from mapping (bytes32 => uint[]) at index _index

    function deleteArrayUint(bytes32 _key, uint256 _index) internal {

        uint256[] storage array = uintArrayStorage[_key];

        require(_index < array.length, "Index should less than length of the array");

        array[_index] = array[array.length - 1];

        array.length = array.length - 1;

    }



    //Deletes from mapping (bytes32 => string[]) at index _index

    function deleteArrayString(bytes32 _key, uint256 _index) internal {

        string[] storage array = stringArrayStorage[_key];

        require(_index < array.length, "Index should less than length of the array");

        array[_index] = array[array.length - 1];

        array.length = array.length - 1;

    }



    ////////////////////////////

    //// pushArray functions

    ///////////////////////////

    /// @notice Below are the helper functions to facilitate storing arrays of different data types.

    /// Ex1- mapping(address => bytes32[]) tokensOwnedByTicker;

    /// tokensOwnedByTicker[owner] = tokensOwnedByTicker[owner].push("xyz"); replace with

    /// pushArray(keccak256(abi.encodePacked("tokensOwnedByTicker", owner), "xyz");



    /// @notice use to store the values for the array

    /// @param _key bytes32 type

    /// @param _value [uint256, string, bytes32, address] any of the data type in array

    function pushArray(bytes32 _key, address _value) internal {

        addressArrayStorage[_key].push(_value);

    }



    function pushArray(bytes32 _key, bytes32 _value) internal {

        bytes32ArrayStorage[_key].push(_value);

    }



    function pushArray(bytes32 _key, string _value) internal {

        stringArrayStorage[_key].push(_value);

    }



    function pushArray(bytes32 _key, uint256 _value) internal {

        uintArrayStorage[_key].push(_value);

    }



    /////////////////////////

    //// Set Array functions

    ////////////////////////

    /// @notice used to intialize the array

    /// Ex1- mapping (address => address[]) public reputation;

    /// reputation[0x1] = new address[](0); It can be replaced as

    /// setArray(hash('reputation', 0x1), new address[](0)); 

    

    function setArray(bytes32 _key, address[] _value) internal {

        addressArrayStorage[_key] = _value;

    }



    function setArray(bytes32 _key, uint256[] _value) internal {

        uintArrayStorage[_key] = _value;

    }



    function setArray(bytes32 _key, bytes32[] _value) internal {

        bytes32ArrayStorage[_key] = _value;

    }



    function setArray(bytes32 _key, string[] _value) internal {

        stringArrayStorage[_key] = _value;

    }



    /////////////////////////

    /// getArray functions

    /////////////////////////

    /// @notice Get functions to get the array of the required data type

    /// Ex1- mapping(address => bytes32[]) tokensOwnedByOwner;

    /// getArrayBytes32(keccak256(abi.encodePacked("tokensOwnedByOwner", 0x1)); It return the bytes32 array

    /// Ex2- uint256 _len =  tokensOwnedByOwner[0x1].length; replace with

    /// getArrayBytes32(keccak256(abi.encodePacked("tokensOwnedByOwner", 0x1)).length;



    function getArrayAddress(bytes32 _key) internal view returns(address[]) {

        return addressArrayStorage[_key];

    }



    function getArrayBytes32(bytes32 _key) internal view returns(bytes32[]) {

        return bytes32ArrayStorage[_key];

    }



    function getArrayString(bytes32 _key) internal view returns(string[]) {

        return stringArrayStorage[_key];

    }



    function getArrayUint(bytes32 _key) internal view returns(uint[]) {

        return uintArrayStorage[_key];

    }



    ///////////////////////////////////

    /// setArrayIndexValue() functions

    ///////////////////////////////////

    /// @notice set the value of particular index of the address array

    /// Ex1- mapping(bytes32 => address[]) moduleList;

    /// general way is -- moduleList[moduleType][index] = temp; 

    /// It can be re-write as -- setArrayIndexValue(keccak256(abi.encodePacked('moduleList', moduleType)), index, temp); 



    function setArrayIndexValue(bytes32 _key, uint256 _index, address _value) internal {

        addressArrayStorage[_key][_index] = _value;

    }



    function setArrayIndexValue(bytes32 _key, uint256 _index, uint256 _value) internal {

        uintArrayStorage[_key][_index] = _value;

    }



    function setArrayIndexValue(bytes32 _key, uint256 _index, bytes32 _value) internal {

        bytes32ArrayStorage[_key][_index] = _value;

    }



    function setArrayIndexValue(bytes32 _key, uint256 _index, string _value) internal {

        stringArrayStorage[_key][_index] = _value;

    }



        /////////////////////////////

        /// Public getters functions

        /////////////////////////////



    function getUintValues(bytes32 _variable) public view returns(uint256) {

        return uintStorage[_variable];

    }



    function getBoolValues(bytes32 _variable) public view returns(bool) {

        return boolStorage[_variable];

    }



    function getStringValues(bytes32 _variable) public view returns(string) {

        return stringStorage[_variable];

    }



    function getAddressValues(bytes32 _variable) public view returns(address) {

        return addressStorage[_variable];

    }



    function getBytes32Values(bytes32 _variable) public view returns(bytes32) {

        return bytes32Storage[_variable];

    }



    function getBytesValues(bytes32 _variable) public view returns(bytes) {

        return bytesStorage[_variable];

    }



}







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title Interface for all security tokens

 */





/**

* @title Registry contract to store registered modules

* @notice Only Polymath can register and verify module factories to make them available for issuers to attach.

*/

contract ModuleRegistry is IModuleRegistry, EternalStorage {

    /*

        // Mapping used to hold the type of module factory corresponds to the address of the Module factory contract

        mapping (address => uint8) public registry;



        // Mapping used to hold the reputation of the factory

        mapping (address => address[]) public reputation;



        // Mapping containing the list of addresses of Module Factories of a particular type

        mapping (uint8 => address[]) public moduleList;



        // Mapping to store the index of the Module Factory in the moduleList

        mapping(address => uint8) private moduleListIndex;



        // contains the list of verified modules

        mapping (address => bool) public verified;



    */



    ///////////

    // Events

    //////////



    // Emit when network becomes paused

    event Pause(uint256 _timestammp);

     // Emit when network becomes unpaused

    event Unpause(uint256 _timestamp);

    // Emit when Module is used by the SecurityToken

    event ModuleUsed(address indexed _moduleFactory, address indexed _securityToken);

    // Emit when the Module Factory gets registered on the ModuleRegistry contract

    event ModuleRegistered(address indexed _moduleFactory, address indexed _owner);

    // Emit when the module gets verified by Polymath

    event ModuleVerified(address indexed _moduleFactory, bool _verified);

    // Emit when a ModuleFactory is removed by Polymath

    event ModuleRemoved(address indexed _moduleFactory, address indexed _decisionMaker);

    // Emit when ownership gets transferred

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    ///////////////

    //// Modifiers

    ///////////////



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(msg.sender == owner(),"sender must be owner");

        _;

    }



    /**

     * @notice Modifier to make a function callable only when the contract is not paused.

     */

    modifier whenNotPausedOrOwner() {

        if (msg.sender == owner())

            _;

        else {

            require(!isPaused(), "Already paused");

            _;

        }

    }



    /**

     * @notice Modifier to make a function callable only when the contract is not paused and ignore is msg.sender is owner.

     */

    modifier whenNotPaused() {

        require(!isPaused(), "Already paused");

        _;

    }



    /**

     * @notice Modifier to make a function callable only when the contract is paused.

     */

    modifier whenPaused() {

        require(isPaused(), "Should not be paused");

        _;

    }



    /////////////////////////////

    // Initialization

    /////////////////////////////



    // Constructor

    constructor () public

    {



    }



    function initialize(address _polymathRegistry, address _owner) external payable {

        require(!getBool(Encoder.getKey("initialised")),"already initialized");

        require(_owner != address(0) && _polymathRegistry != address(0), "0x address is invalid");

        set(Encoder.getKey("polymathRegistry"), _polymathRegistry);

        set(Encoder.getKey("owner"), _owner);

        set(Encoder.getKey("paused"), false);

        set(Encoder.getKey("initialised"), true);

    }



    /**

     * @notice Called by a SecurityToken to check if the ModuleFactory is verified or appropriate custom module

     * @dev ModuleFactory reputation increases by one every time it is deployed(used) by a ST.

     * @dev Any module can be added during token creation without being registered if it is defined in the token proxy deployment contract

     * @dev The feature switch for custom modules is labelled "customModulesAllowed"

     * @param _moduleFactory is the address of the relevant module factory

     */

    function useModule(address _moduleFactory) external {

        // This if statement is required to be able to add modules from the token proxy contract during deployment

        if (ISecurityTokenRegistry(getAddress(Encoder.getKey("securityTokenRegistry"))).isSecurityToken(msg.sender)) {

            if (IFeatureRegistry(getAddress(Encoder.getKey("featureRegistry"))).getFeatureStatus("customModulesAllowed")) {

                require(getBool(Encoder.getKey("verified", _moduleFactory)) || IOwnable(_moduleFactory).owner() == IOwnable(msg.sender).owner(),"ModuleFactory must be verified or SecurityToken owner must be ModuleFactory owner");

            } else {

                require(getBool(Encoder.getKey("verified", _moduleFactory)), "ModuleFactory must be verified");

            }

            require(_isCompatibleModule(_moduleFactory, msg.sender), "Version should within the compatible range of ST");

            pushArray(Encoder.getKey("reputation", _moduleFactory), msg.sender);

            emit ModuleUsed(_moduleFactory, msg.sender);

        }

    }



    function _isCompatibleModule(address _moduleFactory, address _securityToken) internal view returns(bool) {

        uint8[] memory _latestVersion = ISecurityToken(_securityToken).getVersion();

        uint8[] memory _lowerBound = IModuleFactory(_moduleFactory).getLowerSTVersionBounds();

        uint8[] memory _upperBound = IModuleFactory(_moduleFactory).getUpperSTVersionBounds();

        bool _isLowerAllowed = VersionUtils.compareLowerBound(_lowerBound, _latestVersion);

        bool _isUpperAllowed = VersionUtils.compareUpperBound(_upperBound, _latestVersion);

        return (_isLowerAllowed && _isUpperAllowed);

    }



    /**

     * @notice Called by the ModuleFactory owner to register new modules for SecurityTokens to use

     * @param _moduleFactory is the address of the module factory to be registered

     */

    function registerModule(address _moduleFactory) external whenNotPausedOrOwner {

        if (IFeatureRegistry(getAddress(Encoder.getKey("featureRegistry"))).getFeatureStatus("customModulesAllowed")) {

            require(msg.sender == IOwnable(_moduleFactory).owner() || msg.sender == owner(),"msg.sender must be the Module Factory owner or registry curator");

        } else {

            require(msg.sender == owner(), "Only owner allowed to register modules");

        }

        require(getUint(Encoder.getKey("registry", _moduleFactory)) == 0, "Module factory should not be pre-registered");

        IModuleFactory moduleFactory = IModuleFactory(_moduleFactory);

        //Enforce type uniqueness

        uint256 i;

        uint256 j;

        uint8[] memory moduleTypes = moduleFactory.getTypes();

        for (i = 1; i < moduleTypes.length; i++) {

            for (j = 0; j < i; j++) {

                require(moduleTypes[i] != moduleTypes[j], "Type mismatch");

            }

        }

        require(moduleTypes.length != 0, "Factory must have type");

        // NB - here we index by the first type of the module.

        uint8 moduleType = moduleFactory.getTypes()[0];

        set(Encoder.getKey("registry", _moduleFactory), uint256(moduleType));

        set(

            Encoder.getKey("moduleListIndex", _moduleFactory),

            uint256(getArrayAddress(Encoder.getKey("moduleList", uint256(moduleType))).length)

        );

        pushArray(Encoder.getKey("moduleList", uint256(moduleType)), _moduleFactory);

        emit ModuleRegistered (_moduleFactory, IOwnable(_moduleFactory).owner());

    }



    /**

     * @notice Called by the ModuleFactory owner or registry curator to delete a ModuleFactory from the registry

     * @param _moduleFactory is the address of the module factory to be deleted from the registry

     */

    function removeModule(address _moduleFactory) external whenNotPausedOrOwner {

        uint256 moduleType = getUint(Encoder.getKey("registry", _moduleFactory));



        require(moduleType != 0, "Module factory should be registered");

        require(

            msg.sender == IOwnable(_moduleFactory).owner() || msg.sender == owner(),

            "msg.sender must be the Module Factory owner or registry curator"

        );

        uint256 index = getUint(Encoder.getKey("moduleListIndex", _moduleFactory));

        uint256 last = getArrayAddress(Encoder.getKey("moduleList", moduleType)).length - 1;

        address temp = getArrayAddress(Encoder.getKey("moduleList", moduleType))[last];



        // pop from array and re-order

        if (index != last) {

            // moduleList[moduleType][index] = temp;

            setArrayIndexValue(Encoder.getKey("moduleList", moduleType), index, temp);

            set(Encoder.getKey("moduleListIndex", temp), index);

        }

        deleteArrayAddress(Encoder.getKey("moduleList", moduleType), last);



        // delete registry[_moduleFactory];

        set(Encoder.getKey("registry", _moduleFactory), uint256(0));

        // delete reputation[_moduleFactory];

        setArray(Encoder.getKey("reputation", _moduleFactory), new address[](0));

        // delete verified[_moduleFactory];

        set(Encoder.getKey("verified", _moduleFactory), false);

        // delete moduleListIndex[_moduleFactory];

        set(Encoder.getKey("moduleListIndex", _moduleFactory), uint256(0));

        emit ModuleRemoved(_moduleFactory, msg.sender);

    }



    /**

    * @notice Called by Polymath to verify Module Factories for SecurityTokens to use.

    * @notice A module can not be used by an ST unless first approved/verified by Polymath

    * @notice (The only exception to this is that the author of the module is the owner of the ST)

    * @notice -> Only if Polymath enabled the feature.

    * @param _moduleFactory is the address of the module factory to be verified

    * @return bool

    */

    function verifyModule(address _moduleFactory, bool _verified) external onlyOwner {

        require(getUint(Encoder.getKey("registry", _moduleFactory)) != uint256(0), "Module factory must be registered");

        set(Encoder.getKey("verified", _moduleFactory), _verified);

        emit ModuleVerified(_moduleFactory, _verified);

    }



    /**

     * @notice Returns all the tags related to the a module type which are valid for the given token

     * @param _moduleType is the module type

     * @param _securityToken is the token

     * @return list of tags

     * @return corresponding list of module factories

     */

    function getTagsByTypeAndToken(uint8 _moduleType, address _securityToken) external view returns(bytes32[], address[]) {

        address[] memory modules = getModulesByTypeAndToken(_moduleType, _securityToken);

        return _tagsByModules(modules);

    }



    /**

     * @notice Returns all the tags related to the a module type which are valid for the given token

     * @param _moduleType is the module type

     * @return list of tags

     * @return corresponding list of module factories

     */

    function getTagsByType(uint8 _moduleType) external view returns(bytes32[], address[]) {

        address[] memory modules = getModulesByType(_moduleType);

        return _tagsByModules(modules);

    }



    /**

     * @notice Returns all the tags related to the modules provided

     * @param _modules modules to return tags for

     * @return list of tags

     * @return corresponding list of module factories

     */

    function _tagsByModules(address[] _modules) internal view returns(bytes32[], address[]) {

        uint256 counter = 0;

        uint256 i;

        uint256 j;

        for (i = 0; i < _modules.length; i++) {

            counter = counter + IModuleFactory(_modules[i]).getTags().length;

        }

        bytes32[] memory tags = new bytes32[](counter);

        address[] memory modules = new address[](counter);

        bytes32[] memory tempTags;

        counter = 0;

        for (i = 0; i < _modules.length; i++) {

            tempTags = IModuleFactory(_modules[i]).getTags();

            for (j = 0; j < tempTags.length; j++) {

                tags[counter] = tempTags[j];

                modules[counter] = _modules[i];

                counter++;

            }

        }

        return (tags, modules);

    }



    /**

     * @notice Returns the reputation of the entered Module Factory

     * @param _factoryAddress is the address of the module factory

     * @return address array which contains the list of securityTokens that use that module factory

     */

    function getReputationByFactory(address _factoryAddress) external view returns(address[]) {

        return getArrayAddress(Encoder.getKey("reputation", _factoryAddress));

    }



    /**

     * @notice Returns the list of addresses of Module Factory of a particular type

     * @param _moduleType Type of Module

     * @return address array that contains the list of addresses of module factory contracts.

     */

    function getModulesByType(uint8 _moduleType) public view returns(address[]) {

        return getArrayAddress(Encoder.getKey("moduleList", uint256(_moduleType)));

    }



    /**

     * @notice Returns the list of available Module factory addresses of a particular type for a given token.

     * @param _moduleType is the module type to look for

     * @param _securityToken is the address of SecurityToken

     * @return address array that contains the list of available addresses of module factory contracts.

     */

    function getModulesByTypeAndToken(uint8 _moduleType, address _securityToken) public view returns (address[]) {

        uint256 _len = getArrayAddress(Encoder.getKey("moduleList", uint256(_moduleType))).length;

        address[] memory _addressList = getArrayAddress(Encoder.getKey("moduleList", uint256(_moduleType)));

        bool _isCustomModuleAllowed = IFeatureRegistry(getAddress(Encoder.getKey("featureRegistry"))).getFeatureStatus("customModulesAllowed");

        uint256 counter = 0;

        for (uint256 i = 0; i < _len; i++) {

            if (_isCustomModuleAllowed) {

                if (IOwnable(_addressList[i]).owner() == IOwnable(_securityToken).owner() || getBool(Encoder.getKey("verified", _addressList[i])))

                    if(_isCompatibleModule(_addressList[i], _securityToken))

                        counter++;

            }

            else if (getBool(Encoder.getKey("verified", _addressList[i]))) {

                if(_isCompatibleModule(_addressList[i], _securityToken))

                    counter++;

            }

        }

        address[] memory _tempArray = new address[](counter);

        counter = 0;

        for (uint256 j = 0; j < _len; j++) {

            if (_isCustomModuleAllowed) {

                if (IOwnable(_addressList[j]).owner() == IOwnable(_securityToken).owner() || getBool(Encoder.getKey("verified", _addressList[j]))) {

                    if(_isCompatibleModule(_addressList[j], _securityToken)) {

                        _tempArray[counter] = _addressList[j];

                        counter ++;

                    }

                }

            }

            else if (getBool(Encoder.getKey("verified", _addressList[j]))) {

                if(_isCompatibleModule(_addressList[j], _securityToken)) {

                    _tempArray[counter] = _addressList[j];

                    counter ++;

                }

            }

        }

        return _tempArray;

    }



    /**

    * @notice Reclaims all ERC20Basic compatible tokens

    * @param _tokenContract The address of the token contract

    */

    function reclaimERC20(address _tokenContract) external onlyOwner {

        require(_tokenContract != address(0), "0x address is invalid");

        IERC20 token = IERC20(_tokenContract);

        uint256 balance = token.balanceOf(address(this));

        require(token.transfer(owner(), balance),"token transfer failed");

    }



    /**

     * @notice Called by the owner to pause, triggers stopped state

     */

    function pause() external whenNotPaused onlyOwner {

        set(Encoder.getKey("paused"), true);

        /*solium-disable-next-line security/no-block-members*/

        emit Pause(now);

    }



    /**

     * @notice Called by the owner to unpause, returns to normal state

     */

    function unpause() external whenPaused onlyOwner {

        set(Encoder.getKey("paused"), false);

        /*solium-disable-next-line security/no-block-members*/

        emit Unpause(now);

    }



    /**

     * @notice Stores the contract addresses of other key contracts from the PolymathRegistry

     */

    function updateFromRegistry() external onlyOwner {

        address _polymathRegistry = getAddress(Encoder.getKey("polymathRegistry"));

        set(Encoder.getKey("securityTokenRegistry"), IPolymathRegistry(_polymathRegistry).getAddress("SecurityTokenRegistry"));

        set(Encoder.getKey("featureRegistry"), IPolymathRegistry(_polymathRegistry).getAddress("FeatureRegistry"));

        set(Encoder.getKey("polyToken"), IPolymathRegistry(_polymathRegistry).getAddress("PolyToken"));

    }



    /**

    * @dev Allows the current owner to transfer control of the contract to a newOwner.

    * @param _newOwner The address to transfer ownership to.

    */

    function transferOwnership(address _newOwner) external onlyOwner {

        require(_newOwner != address(0), "Invalid address");

        emit OwnershipTransferred(owner(), _newOwner);

        set(Encoder.getKey("owner"), _newOwner);

    }



    /**

     * @notice Gets the owner of the contract

     * @return address owner

     */

    function owner() public view returns(address) {

        return getAddress(Encoder.getKey("owner"));

    }



    /**

     * @notice Checks whether the contract operations is paused or not

     * @return bool

     */

    function isPaused() public view returns(bool) {

        return getBool(Encoder.getKey("paused"));

    }

}