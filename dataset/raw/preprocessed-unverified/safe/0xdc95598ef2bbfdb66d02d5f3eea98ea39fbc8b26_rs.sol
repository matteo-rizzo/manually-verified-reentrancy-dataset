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

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Transfer Manager module for core transfer validation functionality

 */

contract GeneralTransferManager is ITransferManager {



    using SafeMath for uint256;



    //Address from which issuances come

    address public issuanceAddress = address(0);



    //Address which can sign whitelist changes

    address public signingAddress = address(0);



    bytes32 public constant WHITELIST = "WHITELIST";

    bytes32 public constant FLAGS = "FLAGS";



    //from and to timestamps that an investor can send / receive tokens respectively

    struct TimeRestriction {

        uint256 fromTime;

        uint256 toTime;

        uint256 expiryTime;

        bool canBuyFromSTO;

    }



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



    // Emit when Issuance address get changed

    event ChangeIssuanceAddress(address _issuanceAddress);

    // Emit when there is change in the flag variable called allowAllTransfers

    event AllowAllTransfers(bool _allowAllTransfers);

    // Emit when there is change in the flag variable called allowAllWhitelistTransfers

    event AllowAllWhitelistTransfers(bool _allowAllWhitelistTransfers);

    // Emit when there is change in the flag variable called allowAllWhitelistIssuances

    event AllowAllWhitelistIssuances(bool _allowAllWhitelistIssuances);

    // Emit when there is change in the flag variable called allowAllBurnTransfers

    event AllowAllBurnTransfers(bool _allowAllBurnTransfers);

    // Emit when there is change in the flag variable called signingAddress

    event ChangeSigningAddress(address _signingAddress);

    // Emit when investor details get modified related to their whitelisting

    event ModifyWhitelist(

        address _investor,

        uint256 _dateAdded,

        address _addedBy,

        uint256 _fromTime,

        uint256 _toTime,

        uint256 _expiryTime,

        bool _canBuyFromSTO

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



    /**

     * @notice Used to change the Issuance Address

     * @param _issuanceAddress new address for the issuance

     */

    function changeIssuanceAddress(address _issuanceAddress) public withPerm(FLAGS) {

        issuanceAddress = _issuanceAddress;

        emit ChangeIssuanceAddress(_issuanceAddress);

    }



    /**

     * @notice Used to change the Sigining Address

     * @param _signingAddress new address for the signing

     */

    function changeSigningAddress(address _signingAddress) public withPerm(FLAGS) {

        signingAddress = _signingAddress;

        emit ChangeSigningAddress(_signingAddress);

    }



    /**

     * @notice Used to change the flag

            true - It refers there are no transfer restrictions, for any addresses

            false - It refers transfers are restricted for all addresses.

     * @param _allowAllTransfers flag value

     */

    function changeAllowAllTransfers(bool _allowAllTransfers) public withPerm(FLAGS) {

        allowAllTransfers = _allowAllTransfers;

        emit AllowAllTransfers(_allowAllTransfers);

    }



    /**

     * @notice Used to change the flag

            true - It refers that time lock is ignored for transfers (address must still be on whitelist)

            false - It refers transfers are restricted for all addresses.

     * @param _allowAllWhitelistTransfers flag value

     */

    function changeAllowAllWhitelistTransfers(bool _allowAllWhitelistTransfers) public withPerm(FLAGS) {

        allowAllWhitelistTransfers = _allowAllWhitelistTransfers;

        emit AllowAllWhitelistTransfers(_allowAllWhitelistTransfers);

    }



    /**

     * @notice Used to change the flag

            true - It refers that time lock is ignored for issuances (address must still be on whitelist)

            false - It refers transfers are restricted for all addresses.

     * @param _allowAllWhitelistIssuances flag value

     */

    function changeAllowAllWhitelistIssuances(bool _allowAllWhitelistIssuances) public withPerm(FLAGS) {

        allowAllWhitelistIssuances = _allowAllWhitelistIssuances;

        emit AllowAllWhitelistIssuances(_allowAllWhitelistIssuances);

    }



    /**

     * @notice Used to change the flag

            true - It allow to burn the tokens

            false - It deactivate the burning mechanism.

     * @param _allowAllBurnTransfers flag value

     */

    function changeAllowAllBurnTransfers(bool _allowAllBurnTransfers) public withPerm(FLAGS) {

        allowAllBurnTransfers = _allowAllBurnTransfers;

        emit AllowAllBurnTransfers(_allowAllBurnTransfers);

    }



    /**

     * @notice Default implementation of verifyTransfer used by SecurityToken

     * If the transfer request comes from the STO, it only checks that the investor is in the whitelist

     * If the transfer request comes from a token holder, it checks that:

     * a) Both are on the whitelist

     * b) Seller's sale lockup period is over

     * c) Buyer's purchase lockup is over

     * @param _from Address of the sender

     * @param _to Address of the receiver

    */

    function verifyTransfer(address _from, address _to, uint256 /*_amount*/, bytes /* _data */, bool /* _isTransfer */) public returns(Result) {

        if (!paused) {

            if (allowAllTransfers) {

                //All transfers allowed, regardless of whitelist

                return Result.VALID;

            }

            if (allowAllBurnTransfers && (_to == address(0))) {

                return Result.VALID;

            }

            if (allowAllWhitelistTransfers) {

                //Anyone on the whitelist can transfer, regardless of time

                return (_onWhitelist(_to) && _onWhitelist(_from)) ? Result.VALID : Result.NA;

            }

            if (allowAllWhitelistIssuances && _from == issuanceAddress) {

                if (!whitelist[_to].canBuyFromSTO && _isSTOAttached()) {

                    return Result.NA;

                }

                return _onWhitelist(_to) ? Result.VALID : Result.NA;

            }

            //Anyone on the whitelist can transfer provided the blocknumber is large enough

            /*solium-disable-next-line security/no-block-members*/

            return ((_onWhitelist(_from) && whitelist[_from].fromTime <= now) &&

                (_onWhitelist(_to) && whitelist[_to].toTime <= now)) ? Result.VALID : Result.NA; /*solium-disable-line security/no-block-members*/

        }

        return Result.NA;

    }



    /**

    * @notice Adds or removes addresses from the whitelist.

    * @param _investor is the address to whitelist

    * @param _fromTime is the moment when the sale lockup period ends and the investor can freely sell his tokens

    * @param _toTime is the moment when the purchase lockup period ends and the investor can freely purchase tokens from others

    * @param _expiryTime is the moment till investors KYC will be validated. After that investor need to do re-KYC

    * @param _canBuyFromSTO is used to know whether the investor is restricted investor or not.

    */

    function modifyWhitelist(

        address _investor,

        uint256 _fromTime,

        uint256 _toTime,

        uint256 _expiryTime,

        bool _canBuyFromSTO

    )

        public

        withPerm(WHITELIST)

    {

        //Passing a _time == 0 into this function, is equivalent to removing the _investor from the whitelist

        whitelist[_investor] = TimeRestriction(_fromTime, _toTime, _expiryTime, _canBuyFromSTO);

        /*solium-disable-next-line security/no-block-members*/

        emit ModifyWhitelist(_investor, now, msg.sender, _fromTime, _toTime, _expiryTime, _canBuyFromSTO);

    }



    /**

    * @notice Adds or removes addresses from the whitelist.

    * @param _investors List of the addresses to whitelist

    * @param _fromTimes An array of the moment when the sale lockup period ends and the investor can freely sell his tokens

    * @param _toTimes An array of the moment when the purchase lockup period ends and the investor can freely purchase tokens from others

    * @param _expiryTimes An array of the moment till investors KYC will be validated. After that investor need to do re-KYC

    * @param _canBuyFromSTO An array of boolean values

    */

    function modifyWhitelistMulti(

        address[] _investors,

        uint256[] _fromTimes,

        uint256[] _toTimes,

        uint256[] _expiryTimes,

        bool[] _canBuyFromSTO

    ) public withPerm(WHITELIST) {

        require(_investors.length == _fromTimes.length, "Mismatched input lengths");

        require(_fromTimes.length == _toTimes.length, "Mismatched input lengths");

        require(_toTimes.length == _expiryTimes.length, "Mismatched input lengths");

        require(_canBuyFromSTO.length == _toTimes.length, "Mismatched input length");

        for (uint256 i = 0; i < _investors.length; i++) {

            modifyWhitelist(_investors[i], _fromTimes[i], _toTimes[i], _expiryTimes[i], _canBuyFromSTO[i]);

        }

    }



    /**

    * @notice Adds or removes addresses from the whitelist - can be called by anyone with a valid signature

    * @param _investor is the address to whitelist

    * @param _fromTime is the moment when the sale lockup period ends and the investor can freely sell his tokens

    * @param _toTime is the moment when the purchase lockup period ends and the investor can freely purchase tokens from others

    * @param _expiryTime is the moment till investors KYC will be validated. After that investor need to do re-KYC

    * @param _canBuyFromSTO is used to know whether the investor is restricted investor or not.

    * @param _validFrom is the time that this signature is valid from

    * @param _validTo is the time that this signature is valid until

    * @param _nonce nonce of signature (avoid replay attack)

    * @param _v issuer signature

    * @param _r issuer signature

    * @param _s issuer signature

    */

    function modifyWhitelistSigned(

        address _investor,

        uint256 _fromTime,

        uint256 _toTime,

        uint256 _expiryTime,

        bool _canBuyFromSTO,

        uint256 _validFrom,

        uint256 _validTo,

        uint256 _nonce,

        uint8 _v,

        bytes32 _r,

        bytes32 _s

    ) public {

        /*solium-disable-next-line security/no-block-members*/

        require(_validFrom <= now, "ValidFrom is too early");

        /*solium-disable-next-line security/no-block-members*/

        require(_validTo >= now, "ValidTo is too late");

        require(!nonceMap[_investor][_nonce], "Already used signature");

        nonceMap[_investor][_nonce] = true;

        bytes32 hash = keccak256(

            abi.encodePacked(this, _investor, _fromTime, _toTime, _expiryTime, _canBuyFromSTO, _validFrom, _validTo, _nonce)

        );

        _checkSig(hash, _v, _r, _s);

        //Passing a _time == 0 into this function, is equivalent to removing the _investor from the whitelist

        whitelist[_investor] = TimeRestriction(_fromTime, _toTime, _expiryTime, _canBuyFromSTO);

        /*solium-disable-next-line security/no-block-members*/

        emit ModifyWhitelist(_investor, now, msg.sender, _fromTime, _toTime, _expiryTime, _canBuyFromSTO);

    }



    /**

     * @notice Used to verify the signature

     */

    function _checkSig(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) internal view {

        //Check that the signature is valid

        //sig should be signing - _investor, _fromTime, _toTime & _expiryTime and be signed by the issuer address

        address signer = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)), _v, _r, _s);

        require(signer == Ownable(securityToken).owner() || signer == signingAddress, "Incorrect signer");

    }



    /**

     * @notice Internal function used to check whether the investor is in the whitelist or not

            & also checks whether the KYC of investor get expired or not

     * @param _investor Address of the investor

     */

    function _onWhitelist(address _investor) internal view returns(bool) {

        return (((whitelist[_investor].fromTime != 0) || (whitelist[_investor].toTime != 0)) &&

            (whitelist[_investor].expiryTime >= now)); /*solium-disable-line security/no-block-members*/

    }



    /**

     * @notice Internal function use to know whether the STO is attached or not

     */

    function _isSTOAttached() internal view returns(bool) {

        bool attached = ISecurityToken(securityToken).getModulesByType(3).length > 0;

        return attached;

    }



    /**

     * @notice Return the permissions flag that are associated with general trnasfer manager

     */

    function getPermissions() public view returns(bytes32[]) {

        bytes32[] memory allPermissions = new bytes32[](2);

        allPermissions[0] = WHITELIST;

        allPermissions[1] = FLAGS;

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

 * @title Factory for deploying GeneralTransferManager module

 */

contract GeneralTransferManagerFactory is ModuleFactory {



    /**

     * @notice Constructor

     * @param _polyAddress Address of the polytoken

     */

    constructor (address _polyAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost) public

    ModuleFactory(_polyAddress, _setupCost, _usageCost, _subscriptionCost)

    {

        version = "1.0.0";

        name = "GeneralTransferManager";

        title = "General Transfer Manager";

        description = "Manage transfers using a time based whitelist";

        compatibleSTVersionRange["lowerBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));

        compatibleSTVersionRange["upperBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));

    }





     /**

     * @notice Used to launch the Module with the help of factory

     * @return address Contract address of the Module

     */

    function deploy(bytes /* _data */) external returns(address) {

        if (setupCost > 0)

            require(polyToken.transferFrom(msg.sender, owner, setupCost), "Failed transferFrom because of sufficent Allowance is not provided");

        address generalTransferManager = new GeneralTransferManager(msg.sender, address(polyToken));

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