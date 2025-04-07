/**

 *Submitted for verification at Etherscan.io on 2019-04-01

*/



pragma solidity ^0.4.24;



/**

 * @title Transfer Manager module for core transfer validation functionality

 */

contract GeneralTransferManagerStorage {



    //Address from which issuances come

    address public issuanceAddress = address(0);



    //Address which can sign whitelist changes

    address public signingAddress = address(0);



    bytes32 public constant WHITELIST = "WHITELIST";

    bytes32 public constant FLAGS = "FLAGS";



    //from and to timestamps that an investor can send / receive tokens respectively

    struct TimeRestriction {

        //the moment when the sale lockup period ends and the investor can freely sell or transfer away their tokens

        uint64 canSendAfter;

        //the moment when the purchase lockup period ends and the investor can freely purchase or receive from others

        uint64 canReceiveAfter;

        uint64 expiryTime;

        uint8 canBuyFromSTO;

        uint8 added;

    }



    // Allows all TimeRestrictions to be offset

    struct Defaults {

        uint64 canSendAfter;

        uint64 canReceiveAfter;

    }



    // Offset to be applied to all timings (except KYC expiry)

    Defaults public defaults;



    // List of all addresses that have been added to the GTM at some point

    address[] public investors;



    // An address can only send / receive tokens once their corresponding uint256 > block.number

    // (unless allowAllTransfers == true or allowAllWhitelistTransfers == true)

    mapping (address => TimeRestriction) public whitelist;

    // Map of used nonces by customer

    mapping(address => mapping(uint256 => bool)) public nonceMap;



    //If true, there are no transfer restrictions, for any addresses

    bool public allowAllTransfers = false;

    //If true, time lock is ignored for transfers (address must still be on whitelist)

    bool public allowAllWhitelistTransfers = false;

    //If true, time lock is ignored for issuances (address must still be on whitelist)

    bool public allowAllWhitelistIssuances = true;

    //If true, time lock is ignored for burn transactions

    bool public allowAllBurnTransfers = false;



}



/**

 * @title Proxy

 * @dev Gives the possibility to delegate any call to a foreign implementation.

 */

contract Proxy {



    /**

    * @dev Tells the address of the implementation where every call will be delegated.

    * @return address of the implementation to which it will be delegated

    */

    function _implementation() internal view returns (address);



    /**

    * @dev Fallback function.

    * Implemented entirely in `_fallback`.

    */

    function _fallback() internal {

        _delegate(_implementation());

    }



    /**

    * @dev Fallback function allowing to perform a delegatecall to the given implementation.

    * This function will return whatever the implementation call returns

    */

    function _delegate(address implementation) internal {

        /*solium-disable-next-line security/no-inline-assembly*/

        assembly {

            // Copy msg.data. We take full control of memory in this inline assembly

            // block because it will not return to Solidity code. We overwrite the

            // Solidity scratch pad at memory position 0.

            calldatacopy(0, 0, calldatasize)



            // Call the implementation.

            // out and outsize are 0 because we don't know the size yet.

            let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)



            // Copy the returned data.

            returndatacopy(0, 0, returndatasize)



            switch result

            // delegatecall returns 0 on error.

            case 0 { revert(0, returndatasize) }

            default { return(0, returndatasize) }

        }

    }



    function () public payable {

        _fallback();

    }

}



/**

 * @title OwnedProxy

 * @dev This contract combines an upgradeability proxy with basic authorization control functionalities

 */

contract OwnedProxy is Proxy {



    // Owner of the contract

    address private __owner;



    // Address of the current implementation

    address internal __implementation;



    /**

    * @dev Event to show ownership has been transferred

    * @param _previousOwner representing the address of the previous owner

    * @param _newOwner representing the address of the new owner

    */

    event ProxyOwnershipTransferred(address _previousOwner, address _newOwner);



    /**

    * @dev Throws if called by any account other than the owner.

    */

    modifier ifOwner() {

        if (msg.sender == _owner()) {

            _;

        } else {

            _fallback();

        }

    }



    /**

    * @dev the constructor sets the original owner of the contract to the sender account.

    */

    constructor() public {

        _setOwner(msg.sender);

    }



    /**

    * @dev Tells the address of the owner

    * @return the address of the owner

    */

    function _owner() internal view returns (address) {

        return __owner;

    }



    /**

    * @dev Sets the address of the owner

    */

    function _setOwner(address _newOwner) internal {

        require(_newOwner != address(0), "Address should not be 0x");

        __owner = _newOwner;

    }



    /**

    * @notice Internal function to provide the address of the implementation contract

    */

    function _implementation() internal view returns (address) {

        return __implementation;

    }



    /**

    * @dev Tells the address of the proxy owner

    * @return the address of the proxy owner

    */

    function proxyOwner() external ifOwner returns (address) {

        return _owner();

    }



    /**

    * @dev Tells the address of the current implementation

    * @return address of the current implementation

    */

    function implementation() external ifOwner returns (address) {

        return _implementation();

    }



    /**

    * @dev Allows the current owner to transfer control of the contract to a newOwner.

    * @param _newOwner The address to transfer ownership to.

    */

    function transferProxyOwnership(address _newOwner) external ifOwner {

        require(_newOwner != address(0), "Address should not be 0x");

        emit ProxyOwnershipTransferred(_owner(), _newOwner);

        _setOwner(_newOwner);

    }



}



/**

 * @title Utility contract to allow pausing and unpausing of certain functions

 */

contract Pausable {



    event Pause(uint256 _timestammp);

    event Unpause(uint256 _timestamp);



    bool public paused = false;



    /**

    * @notice Modifier to make a function callable only when the contract is not paused.

    */

    modifier whenNotPaused() {

        require(!paused, "Contract is paused");

        _;

    }



    /**

    * @notice Modifier to make a function callable only when the contract is paused.

    */

    modifier whenPaused() {

        require(paused, "Contract is not paused");

        _;

    }



   /**

    * @notice Called by the owner to pause, triggers stopped state

    */

    function _pause() internal whenNotPaused {

        paused = true;

        /*solium-disable-next-line security/no-block-members*/

        emit Pause(now);

    }



    /**

    * @notice Called by the owner to unpause, returns to normal state

    */

    function _unpause() internal whenPaused {

        paused = false;

        /*solium-disable-next-line security/no-block-members*/

        emit Unpause(now);

    }



}



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





/**

 * @title Storage for Module contract

 * @notice Contract is abstract

 */

contract ModuleStorage {



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

    

    address public factory;



    address public securityToken;



    bytes32 public constant FEE_ADMIN = "FEE_ADMIN";



    IERC20 public polyToken;



}



/**

 * @title Transfer Manager module for core transfer validation functionality

 */

contract GeneralTransferManagerProxy is GeneralTransferManagerStorage, ModuleStorage, Pausable, OwnedProxy {



    /**

    * @notice Constructor

    * @param _securityToken Address of the security token

    * @param _polyAddress Address of the polytoken

    * @param _implementation representing the address of the new implementation to be set

    */

    constructor (address _securityToken, address _polyAddress, address _implementation)

    public

    ModuleStorage(_securityToken, _polyAddress)

    {

        require(

            _implementation != address(0),

            "Implementation address should not be 0x"

        );

        __implementation = _implementation;

    }



}



/**

 * @title Interface that every module factory contract should implement

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

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

 * @title Factory for deploying GeneralTransferManager module

 */

contract GeneralTransferManagerFactory is ModuleFactory {



    address public logicContract;



    /**

     * @notice Constructor

     * @param _polyAddress Address of the polytoken

     * @param _setupCost Setup cost of the module

     * @param _usageCost Usage cost of the module

     * @param _subscriptionCost Subscription cost of the module

     * @param _logicContract Contract address that contains the logic related to `description`

     */

    constructor (address _polyAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost, address _logicContract) public

    ModuleFactory(_polyAddress, _setupCost, _usageCost, _subscriptionCost)

    {

        require(_logicContract != address(0), "Invalid logic contract");

        version = "2.1.0";

        name = "GeneralTransferManager";

        title = "General Transfer Manager";

        description = "Manage transfers using a time based whitelist";

        compatibleSTVersionRange["lowerBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));

        compatibleSTVersionRange["upperBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));

        logicContract = _logicContract;

    }





     /**

     * @notice Used to launch the Module with the help of factory

     * @return address Contract address of the Module

     */

    function deploy(bytes /* _data */) external returns(address) {

        if (setupCost > 0)

            require(polyToken.transferFrom(msg.sender, owner, setupCost), "Failed transferFrom because of sufficent Allowance is not provided");

        address generalTransferManager = new GeneralTransferManagerProxy(msg.sender, address(polyToken), logicContract);

        /*solium-disable-next-line security/no-block-members*/

        emit GenerateModuleFromFactory(address(generalTransferManager), getName(), address(this), msg.sender, setupCost, now);

        return address(generalTransferManager);

    }





    /**

     * @notice Type of the Module factory

     */

    function getTypes() external view returns(uint8[]) {

        uint8[] memory res = new uint8[](1);

        res[0] = 2;

        return res;

    }



    /**

     * @notice Returns the instructions associated with the module

     */

    function getInstructions() external view returns(string) {

        /*solium-disable-next-line max-len*/

        return "Allows an issuer to maintain a time based whitelist of authorised token holders.Addresses are added via modifyWhitelist and take a fromTime (the time from which they can send tokens) and a toTime (the time from which they can receive tokens). There are additional flags, allowAllWhitelistIssuances, allowAllWhitelistTransfers & allowAllTransfers which allow you to set corresponding contract level behaviour. Init function takes no parameters.";

    }



    /**

     * @notice Get the tags related to the module factory

     */

    function getTags() public view returns(bytes32[]) {

        bytes32[] memory availableTags = new bytes32[](2);

        availableTags[0] = "General";

        availableTags[1] = "Transfer Restriction";

        return availableTags;

    }





}