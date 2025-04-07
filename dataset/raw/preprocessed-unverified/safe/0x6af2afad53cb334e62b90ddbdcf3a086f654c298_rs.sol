/**

 *Submitted for verification at Etherscan.io on 2018-11-26

*/



pragma solidity ^0.4.24;



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

 * @title Interface to be implemented by all Transfer Manager modules

 * @dev abstract contract

 */

contract ITransferManager is Module, Pausable {



    //If verifyTransfer returns:

    //  FORCE_VALID, the transaction will always be valid, regardless of other TM results

    //  INVALID, then the transfer should not be allowed regardless of other TM results

    //  VALID, then the transfer is valid for this TM

    //  NA, then the result from this TM is ignored

    enum Result {INVALID, NA, VALID, FORCE_VALID}



    function verifyTransfer(address _from, address _to, uint256 _amount, bytes _data, bool _isTransfer) public returns(Result);



    function unpause() public onlyOwner {

        super._unpause();

    }



    function pause() public onlyOwner {

        super._pause();

    }

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Transfer Manager module for manually approving or blocking transactions between accounts

 */

contract ManualApprovalTransferManager is ITransferManager {

    using SafeMath for uint256;



    //Address from which issuances come

    address public issuanceAddress = address(0);



    //Address which can sign whitelist changes

    address public signingAddress = address(0);



    bytes32 public constant TRANSFER_APPROVAL = "TRANSFER_APPROVAL";



    //Manual approval is an allowance (that has been approved) with an expiry time

    struct ManualApproval {

        uint256 allowance;

        uint256 expiryTime;

    }



    //Manual blocking allows you to specify a list of blocked address pairs with an associated expiry time for the block

    struct ManualBlocking {

        uint256 expiryTime;

    }



    //Store mappings of address => address with ManualApprovals

    mapping (address => mapping (address => ManualApproval)) public manualApprovals;



    //Store mappings of address => address with ManualBlockings

    mapping (address => mapping (address => ManualBlocking)) public manualBlockings;



    event AddManualApproval(

        address indexed _from,

        address indexed _to,

        uint256 _allowance,

        uint256 _expiryTime,

        address indexed _addedBy

    );



    event AddManualBlocking(

        address indexed _from,

        address indexed _to,

        uint256 _expiryTime,

        address indexed _addedBy

    );



    event RevokeManualApproval(

        address indexed _from,

        address indexed _to,

        address indexed _addedBy

    );



    event RevokeManualBlocking(

        address indexed _from,

        address indexed _to,

        address indexed _addedBy

    );



    /**

     * @notice Constructor

     * @param _securityToken Address of the security token

     * @param _polyAddress Address of the polytoken

     */

    constructor (address _securityToken, address _polyAddress)

    public

    Module(_securityToken, _polyAddress)

    {

    }



    /**

     * @notice This function returns the signature of configure function

     */

    function getInitFunction() public pure returns (bytes4) {

        return bytes4(0);

    }



    /** @notice Used to verify the transfer transaction and allow a manually approved transqaction to bypass other restrictions

     * @param _from Address of the sender

     * @param _to Address of the receiver

     * @param _amount The amount of tokens to transfer

     * @param _isTransfer Whether or not this is an actual transfer or just a test to see if the tokens would be transferrable

     */

    function verifyTransfer(address _from, address _to, uint256 _amount, bytes /* _data */, bool _isTransfer) public returns(Result) {

        // function must only be called by the associated security token if _isTransfer == true

        require(_isTransfer == false || msg.sender == securityToken, "Sender is not the owner");

        // manual blocking takes precidence over manual approval

        if (!paused) {

            /*solium-disable-next-line security/no-block-members*/

            if (manualBlockings[_from][_to].expiryTime >= now) {

                return Result.INVALID;

            }

            /*solium-disable-next-line security/no-block-members*/

            if ((manualApprovals[_from][_to].expiryTime >= now) && (manualApprovals[_from][_to].allowance >= _amount)) {

                if (_isTransfer) {

                    manualApprovals[_from][_to].allowance = manualApprovals[_from][_to].allowance.sub(_amount);

                }

                return Result.VALID;

            }

        }

        return Result.NA;

    }



    /**

    * @notice Adds a pair of addresses to manual approvals

    * @param _from is the address from which transfers are approved

    * @param _to is the address to which transfers are approved

    * @param _allowance is the approved amount of tokens

    * @param _expiryTime is the time until which the transfer is allowed

    */

    function addManualApproval(address _from, address _to, uint256 _allowance, uint256 _expiryTime) public withPerm(TRANSFER_APPROVAL) {

        require(_to != address(0), "Invalid to address");

        /*solium-disable-next-line security/no-block-members*/

        require(_expiryTime > now, "Invalid expiry time");

        require(manualApprovals[_from][_to].allowance == 0, "Approval already exists");

        manualApprovals[_from][_to] = ManualApproval(_allowance, _expiryTime);

        emit AddManualApproval(_from, _to, _allowance, _expiryTime, msg.sender);

    }



    /**

    * @notice Adds a pair of addresses to manual blockings

    * @param _from is the address from which transfers are blocked

    * @param _to is the address to which transfers are blocked

    * @param _expiryTime is the time until which the transfer is blocked

    */

    function addManualBlocking(address _from, address _to, uint256 _expiryTime) public withPerm(TRANSFER_APPROVAL) {

        require(_to != address(0), "Invalid to address");

        /*solium-disable-next-line security/no-block-members*/

        require(_expiryTime > now, "Invalid expiry time");

        require(manualBlockings[_from][_to].expiryTime == 0, "Blocking already exists");

        manualBlockings[_from][_to] = ManualBlocking(_expiryTime);

        emit AddManualBlocking(_from, _to, _expiryTime, msg.sender);

    }



    /**

    * @notice Removes a pairs of addresses from manual approvals

    * @param _from is the address from which transfers are approved

    * @param _to is the address to which transfers are approved

    */

    function revokeManualApproval(address _from, address _to) public withPerm(TRANSFER_APPROVAL) {

        require(_to != address(0), "Invalid to address");

        delete manualApprovals[_from][_to];

        emit RevokeManualApproval(_from, _to, msg.sender);

    }



    /**

    * @notice Removes a pairs of addresses from manual approvals

    * @param _from is the address from which transfers are approved

    * @param _to is the address to which transfers are approved

    */

    function revokeManualBlocking(address _from, address _to) public withPerm(TRANSFER_APPROVAL) {

        require(_to != address(0), "Invalid to address");

        delete manualBlockings[_from][_to];

        emit RevokeManualBlocking(_from, _to, msg.sender);

    }



    /**

     * @notice Returns the permissions flag that are associated with ManualApproval transfer manager

     */

    function getPermissions() public view returns(bytes32[]) {

        bytes32[] memory allPermissions = new bytes32[](1);

        allPermissions[0] = TRANSFER_APPROVAL;

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

 * @title Factory for deploying ManualApprovalTransferManager module

 */

contract ManualApprovalTransferManagerFactory is ModuleFactory {



    /**

     * @notice Constructor

     * @param _polyAddress Address of the polytoken

     * @param _setupCost Setup cost of the module

     * @param _usageCost Usage cost of the module

     * @param _subscriptionCost Subscription cost of the module

     */

    constructor (address _polyAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost) public

    ModuleFactory(_polyAddress, _setupCost, _usageCost, _subscriptionCost)

    {

        version = "2.0.1";

        name = "ManualApprovalTransferManager";

        title = "Manual Approval Transfer Manager";

        description = "Manage transfers using single approvals / blocking";

        compatibleSTVersionRange["lowerBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));

        compatibleSTVersionRange["upperBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));

    }



     /**

     * @notice used to launch the Module with the help of factory

     * @return address Contract address of the Module

     */

    function deploy(bytes /* _data */) external returns(address) {

        if (setupCost > 0)

            require(polyToken.transferFrom(msg.sender, owner, setupCost), "Failed transferFrom because of sufficent Allowance is not provided");

        address manualTransferManager = new ManualApprovalTransferManager(msg.sender, address(polyToken));

        /*solium-disable-next-line security/no-block-members*/

        emit GenerateModuleFromFactory(address(manualTransferManager), getName(), address(this), msg.sender, setupCost, now);

        return address(manualTransferManager);

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

        return "Allows an issuer to set manual approvals or blocks for specific pairs of addresses and amounts. Init function takes no parameters.";

    }



    /**

     * @notice Get the tags related to the module factory

     */

    function getTags() external view returns(bytes32[]) {

        bytes32[] memory availableTags = new bytes32[](2);

        availableTags[0] = "ManualApproval";

        availableTags[1] = "Transfer Restriction";

        return availableTags;

    }





}