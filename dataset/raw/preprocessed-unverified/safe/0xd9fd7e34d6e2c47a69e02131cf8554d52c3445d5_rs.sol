/**

 *Submitted for verification at Etherscan.io on 2018-11-12

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

 * @title Transfer Manager for limiting maximum number of token holders

 */

contract CountTransferManager is ITransferManager {



    // The maximum number of concurrent token holders

    uint256 public maxHolderCount;



    bytes32 public constant ADMIN = "ADMIN";



    event ModifyHolderCount(uint256 _oldHolderCount, uint256 _newHolderCount);



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



    /** @notice Used to verify the transfer transaction and prevent a transfer if it passes the allowed amount of token holders

     * @param _to Address of the receiver

     */

    function verifyTransfer(

        address /* _from */,

        address _to,

        uint256 /* _amount */,

        bytes /* _data */,

        bool /* _isTransfer */

    )

        public

        returns(Result)

    {

        if (!paused) {

            if (maxHolderCount < ISecurityToken(securityToken).getInvestorCount()) {

                // Allow transfers to existing maxHolders

                if (ISecurityToken(securityToken).balanceOf(_to) != 0) {

                    return Result.NA;

                }

                return Result.INVALID;

            }

            return Result.NA;

        }

        return Result.NA;

    }



    /**

     * @notice Used to initialize the variables of the contract

     * @param _maxHolderCount Maximum no. of holders this module allows the SecurityToken to have

     */

    function configure(uint256 _maxHolderCount) public onlyFactory {

        maxHolderCount = _maxHolderCount;

    }



    /**

    * @notice Sets the cap for the amount of token holders there can be

    * @param _maxHolderCount is the new maximum amount of token holders

    */

    function changeHolderCount(uint256 _maxHolderCount) public withPerm(ADMIN) {

        emit ModifyHolderCount(maxHolderCount, _maxHolderCount);

        maxHolderCount = _maxHolderCount;

    }



    /**

     * @notice This function returns the signature of configure function

     */

    function getInitFunction() public pure returns (bytes4) {

        return bytes4(keccak256("configure(uint256)"));

    }



    /**

     * @notice Returns the permissions flag that are associated with CountTransferManager

     */

    function getPermissions() public view returns(bytes32[]) {

        bytes32[] memory allPermissions = new bytes32[](1);

        allPermissions[0] = ADMIN;

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

 * @title Utility contract for reusable code

 */





/**

 * @title Factory for deploying CountTransferManager module

 */

contract CountTransferManagerFactory is ModuleFactory {



    /**

     * @notice Constructor

     * @param _polyAddress Address of the polytoken

     */

    constructor (address _polyAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost) public

    ModuleFactory(_polyAddress, _setupCost, _usageCost, _subscriptionCost)

    {

        version = "1.0.0";

        name = "CountTransferManager";

        title = "Count Transfer Manager";

        description = "Restrict the number of investors";

        compatibleSTVersionRange["lowerBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));

        compatibleSTVersionRange["upperBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));

    }



    /**

     * @notice Used to launch the Module with the help of factory

     * @param _data Data used for the intialization of the module factory variables

     * @return address Contract address of the Module

     */

    function deploy(bytes _data) external returns(address) {

        if(setupCost > 0)

            require(polyToken.transferFrom(msg.sender, owner, setupCost), "Failed transferFrom due to insufficent Allowance provided");

        CountTransferManager countTransferManager = new CountTransferManager(msg.sender, address(polyToken));

        require(Util.getSig(_data) == countTransferManager.getInitFunction(), "Provided data is not valid");

        /*solium-disable-next-line security/no-low-level-calls*/

        require(address(countTransferManager).call(_data), "Unsuccessful call");

        /*solium-disable-next-line security/no-block-members*/

        emit GenerateModuleFromFactory(address(countTransferManager), getName(), address(this), msg.sender, setupCost, now);

        return address(countTransferManager);



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

        return "Allows an issuer to restrict the total number of non-zero token holders";

    }



    /**

     * @notice Get the tags related to the module factory

     */

    function getTags() external view returns(bytes32[]) {

        bytes32[] memory availableTags = new bytes32[](2);

        availableTags[0] = "Count";

        availableTags[1] = "Transfer Restriction";

        return availableTags;

    }

}