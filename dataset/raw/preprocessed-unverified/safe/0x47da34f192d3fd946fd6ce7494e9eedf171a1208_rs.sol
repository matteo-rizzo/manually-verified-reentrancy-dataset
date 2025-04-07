/**

 *Submitted for verification at Etherscan.io on 2018-11-12

*/



pragma solidity ^0.4.24;



/**

 * @title Math

 * @dev Assorted math operations

 */





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





/**

 * @title Interface that every module contract should implement

 */





/**

 * @title Interface that every module factory contract should implement

 */





/**

 * @title Interface for the Polymath Module Registry contract

 */





/**

 * @title Interface for managing polymath feature switches

 */





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

 * @title Interface for all security tokens

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

 * @title Utility contract to allow owner to retreive any ERC20 sent to the contract

 */

contract ReclaimTokens is Ownable {



    /**

    * @notice Reclaim all ERC20Basic compatible tokens

    * @param _tokenContract The address of the token contract

    */

    function reclaimERC20(address _tokenContract) external onlyOwner {

        require(_tokenContract != address(0), "Invalid address");

        IERC20 token = IERC20(_tokenContract);

        uint256 balance = token.balanceOf(address(this));

        require(token.transfer(owner, balance), "Transfer failed");

    }

}



/**

 * @title Core functionality for registry upgradability

 */

contract PolymathRegistry is ReclaimTokens {



    mapping (bytes32 => address) public storedAddresses;



    event ChangeAddress(string _nameKey, address indexed _oldAddress, address indexed _newAddress);



    /**

     * @notice Gets the contract address

     * @param _nameKey is the key for the contract address mapping

     * @return address

     */

    function getAddress(string _nameKey) external view returns(address) {

        bytes32 key = keccak256(bytes(_nameKey));

        require(storedAddresses[key] != address(0), "Invalid address key");

        return storedAddresses[key];

    }



    /**

     * @notice Changes the contract address

     * @param _nameKey is the key for the contract address mapping

     * @param _newAddress is the new contract address

     */

    function changeAddress(string _nameKey, address _newAddress) external onlyOwner {

        bytes32 key = keccak256(bytes(_nameKey));

        emit ChangeAddress(_nameKey, storedAddresses[key], _newAddress);

        storedAddresses[key] = _newAddress;

    }





}



contract RegistryUpdater is Ownable {



    address public polymathRegistry;

    address public moduleRegistry;

    address public securityTokenRegistry;

    address public featureRegistry;

    address public polyToken;



    constructor (address _polymathRegistry) public {

        require(_polymathRegistry != address(0), "Invalid address");

        polymathRegistry = _polymathRegistry;

    }



    function updateFromRegistry() public onlyOwner {

        moduleRegistry = PolymathRegistry(polymathRegistry).getAddress("ModuleRegistry");

        securityTokenRegistry = PolymathRegistry(polymathRegistry).getAddress("SecurityTokenRegistry");

        featureRegistry = PolymathRegistry(polymathRegistry).getAddress("FeatureRegistry");

        polyToken = PolymathRegistry(polymathRegistry).getAddress("PolyToken");

    }



}



/**

 * @title Utility contract for reusable code

 */





/**

 * @title Helps contracts guard agains reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>

 * @notice If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {



  /**

   * @dev We use a single lock for the whole contract.

   */

  bool private reentrancyLock = false;



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * @notice If you mark a function `nonReentrant`, you should also

   * mark it `external`. Calling one nonReentrant function from

   * another is not supported. Instead, you can implement a

   * `private` function doing the actual work, and a `external`

   * wrapper marked as `nonReentrant`.

   */

  modifier nonReentrant() {

    require(!reentrancyLock);

    reentrancyLock = true;

    _;

    reentrancyLock = false;

  }



}



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



  uint256 totalSupply_;



  /**

  * @dev total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  /**

  * @dev transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[msg.sender]);



    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];

  }



}



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * @dev https://github.com/ethereum/EIPs/issues/20

 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) internal allowed;





  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

  function transferFrom(

    address _from,

    address _to,

    uint256 _value

  )

    public

    returns (bool)

  {

    require(_to != address(0));

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);

    return true;

  }



  /**

   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

   *

   * Beware that changing an allowance with this method brings the risk that someone may use both the old

   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

   * @param _spender The address which will spend the funds.

   * @param _value The amount of tokens to be spent.

   */

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);

    return true;

  }



  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param _owner address The address which owns the funds.

   * @param _spender address The address which will spend the funds.

   * @return A uint256 specifying the amount of tokens still available for the spender.

   */

  function allowance(

    address _owner,

    address _spender

   )

    public

    view

    returns (uint256)

  {

    return allowed[_owner][_spender];

  }



  /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   *

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _addedValue The amount of tokens to increase the allowance by.

   */

  function increaseApproval(

    address _spender,

    uint _addedValue

  )

    public

    returns (bool)

  {

    allowed[msg.sender][_spender] = (

      allowed[msg.sender][_spender].add(_addedValue));

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



  /**

   * @dev Decrease the amount of tokens that an owner allowed to a spender.

   *

   * approve should be called when allowed[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseApproval(

    address _spender,

    uint _subtractedValue

  )

    public

    returns (bool)

  {

    uint oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}



/**

 * @title DetailedERC20 token

 * @dev The decimals are only for visualization purposes.

 * All the operations are done using the smallest and indivisible token unit,

 * just as on Ethereum all the operations are done in wei.

 */

contract DetailedERC20 is ERC20 {

  string public name;

  string public symbol;

  uint8 public decimals;



  constructor(string _name, string _symbol, uint8 _decimals) public {

    name = _name;

    symbol = _symbol;

    decimals = _decimals;

  }

}



/**

 * @title Interface to be implemented by all permission manager modules

 */









/**

* @title Security Token contract

* @notice SecurityToken is an ERC20 token with added capabilities:

* @notice - Implements the ST-20 Interface

* @notice - Transfers are restricted

* @notice - Modules can be attached to it to control its behaviour

* @notice - ST should not be deployed directly, but rather the SecurityTokenRegistry should be used

* @notice - ST does not inherit from ISecurityToken due to:

* @notice - https://github.com/ethereum/solidity/issues/4847

*/

contract SecurityToken is StandardToken, DetailedERC20, ReentrancyGuard, RegistryUpdater {

    using SafeMath for uint256;



    TokenLib.InvestorDataStorage investorData;



    // Used to hold the semantic version data

    struct SemanticVersion {

        uint8 major;

        uint8 minor;

        uint8 patch;

    }



    SemanticVersion securityTokenVersion;



    // off-chain data

    string public tokenDetails;



    uint8 constant PERMISSION_KEY = 1;

    uint8 constant TRANSFER_KEY = 2;

    uint8 constant MINT_KEY = 3;

    uint8 constant CHECKPOINT_KEY = 4;

    uint8 constant BURN_KEY = 5;



    uint256 public granularity;



    // Value of current checkpoint

    uint256 public currentCheckpointId;



    // Used to temporarily halt all transactions

    bool public transfersFrozen;



    // Used to permanently halt all minting

    bool public mintingFrozen;



    // Used to permanently halt controller actions

    bool public controllerDisabled;



    // Address whitelisted by issuer as controller

    address public controller;



    // Records added modules - module list should be order agnostic!

    mapping (uint8 => address[]) modules;



    // Records information about the module

    mapping (address => TokenLib.ModuleData) modulesToData;



    // Records added module names - module list should be order agnostic!

    mapping (bytes32 => address[]) names;



    // Map each investor to a series of checkpoints

    mapping (address => TokenLib.Checkpoint[]) checkpointBalances;



    // List of checkpoints that relate to total supply

    TokenLib.Checkpoint[] checkpointTotalSupply;



    // Times at which each checkpoint was created

    uint256[] checkpointTimes;



    // Emit at the time when module get added

    event ModuleAdded(

        uint8[] _types,

        bytes32 _name,

        address _moduleFactory,

        address _module,

        uint256 _moduleCost,

        uint256 _budget,

        uint256 _timestamp

    );



    // Emit when the token details get updated

    event UpdateTokenDetails(string _oldDetails, string _newDetails);

    // Emit when the granularity get changed

    event GranularityChanged(uint256 _oldGranularity, uint256 _newGranularity);

    // Emit when Module get archived from the securityToken

    event ModuleArchived(uint8[] _types, address _module, uint256 _timestamp);

    // Emit when Module get unarchived from the securityToken

    event ModuleUnarchived(uint8[] _types, address _module, uint256 _timestamp);

    // Emit when Module get removed from the securityToken

    event ModuleRemoved(uint8[] _types, address _module, uint256 _timestamp);

    // Emit when the budget allocated to a module is changed

    event ModuleBudgetChanged(uint8[] _moduleTypes, address _module, uint256 _oldBudget, uint256 _budget);

    // Emit when transfers are frozen or unfrozen

    event FreezeTransfers(bool _status, uint256 _timestamp);

    // Emit when new checkpoint created

    event CheckpointCreated(uint256 indexed _checkpointId, uint256 _timestamp);

    // Emit when is permanently frozen by the issuer

    event FreezeMinting(uint256 _timestamp);

    // Events to log minting and burning

    event Minted(address indexed _to, uint256 _value);

    event Burnt(address indexed _from, uint256 _value);



    // Events to log controller actions

    event SetController(address indexed _oldController, address indexed _newController);

    event ForceTransfer(

        address indexed _controller,

        address indexed _from,

        address indexed _to,

        uint256 _value,

        bool _verifyTransfer,

        bytes _data

    );

    event ForceBurn(

        address indexed _controller,

        address indexed _from,

        uint256 _value,

        bool _verifyTransfer,

        bytes _data

    );

    event DisableController(uint256 _timestamp);



    function _isModule(address _module, uint8 _type) internal view returns (bool) {

        require(modulesToData[_module].module == _module, "Wrong address");

        require(!modulesToData[_module].isArchived, "Module archived");

        for (uint256 i = 0; i < modulesToData[_module].moduleTypes.length; i++) {

            if (modulesToData[_module].moduleTypes[i] == _type) {

                return true;

            }

        }

        return false;

    }



    // Require msg.sender to be the specified module type

    modifier onlyModule(uint8 _type) {

        require(_isModule(msg.sender, _type));

        _;

    }



    // Require msg.sender to be the specified module type or the owner of the token

    modifier onlyModuleOrOwner(uint8 _type) {

        if (msg.sender == owner) {

            _;

        } else {

            require(_isModule(msg.sender, _type));

            _;

        }

    }



    modifier checkGranularity(uint256 _value) {

        require(_value % granularity == 0, "Invalid granularity");

        _;

    }



    modifier isMintingAllowed() {

        require(!mintingFrozen, "Minting frozen");

        _;

    }



    modifier isEnabled(string _nameKey) {

        require(IFeatureRegistry(featureRegistry).getFeatureStatus(_nameKey));

        _;

    }



    /**

     * @notice Revert if called by an account which is not a controller

     */

    modifier onlyController() {

        require(msg.sender == controller, "Not controller");

        require(!controllerDisabled, "Controller disabled");

        _;

    }



    /**

     * @notice Constructor

     * @param _name Name of the SecurityToken

     * @param _symbol Symbol of the Token

     * @param _decimals Decimals for the securityToken

     * @param _granularity granular level of the token

     * @param _tokenDetails Details of the token that are stored off-chain

     * @param _polymathRegistry Contract address of the polymath registry

     */

    constructor (

        string _name,

        string _symbol,

        uint8 _decimals,

        uint256 _granularity,

        string _tokenDetails,

        address _polymathRegistry

    )

    public

    DetailedERC20(_name, _symbol, _decimals)

    RegistryUpdater(_polymathRegistry)

    {

        //When it is created, the owner is the STR

        updateFromRegistry();

        tokenDetails = _tokenDetails;

        granularity = _granularity;

        securityTokenVersion = SemanticVersion(2,0,0);

    }



    /**

     * @notice Attachs a module to the SecurityToken

     * @dev  E.G.: On deployment (through the STR) ST gets a TransferManager module attached to it

     * @dev to control restrictions on transfers.

     * @param _moduleFactory is the address of the module factory to be added

     * @param _data is data packed into bytes used to further configure the module (See STO usage)

     * @param _maxCost max amount of POLY willing to pay to the module.

     * @param _budget max amount of ongoing POLY willing to assign to the module.

     */

    function addModule(

        address _moduleFactory,

        bytes _data,

        uint256 _maxCost,

        uint256 _budget

    ) external onlyOwner nonReentrant {

        //Check that the module factory exists in the ModuleRegistry - will throw otherwise

        IModuleRegistry(moduleRegistry).useModule(_moduleFactory);

        IModuleFactory moduleFactory = IModuleFactory(_moduleFactory);

        uint8[] memory moduleTypes = moduleFactory.getTypes();

        uint256 moduleCost = moduleFactory.getSetupCost();

        require(moduleCost <= _maxCost, "Invalid cost");

        //Approve fee for module

        ERC20(polyToken).approve(_moduleFactory, moduleCost);

        //Creates instance of module from factory

        address module = moduleFactory.deploy(_data);

        require(modulesToData[module].module == address(0), "Module exists");

        //Approve ongoing budget

        ERC20(polyToken).approve(module, _budget);

        //Add to SecurityToken module map

        bytes32 moduleName = moduleFactory.getName();

        uint256[] memory moduleIndexes = new uint256[](moduleTypes.length);

        uint256 i;

        for (i = 0; i < moduleTypes.length; i++) {

            moduleIndexes[i] = modules[moduleTypes[i]].length;

            modules[moduleTypes[i]].push(module);

        }

        modulesToData[module] = TokenLib.ModuleData(

            moduleName, module, _moduleFactory, false, moduleTypes, moduleIndexes, names[moduleName].length

        );

        names[moduleName].push(module);

        //Emit log event

        /*solium-disable-next-line security/no-block-members*/

        emit ModuleAdded(moduleTypes, moduleName, _moduleFactory, module, moduleCost, _budget, now);

    }



    /**

    * @notice Archives a module attached to the SecurityToken

    * @param _module address of module to archive

    */

    function archiveModule(address _module) external onlyOwner {

        TokenLib.archiveModule(modulesToData[_module], _module);

    }



    /**

    * @notice Unarchives a module attached to the SecurityToken

    * @param _module address of module to unarchive

    */

    function unarchiveModule(address _module) external onlyOwner {

        TokenLib.unarchiveModule(modulesToData[_module], _module);

    }



    /**

    * @notice Removes a module attached to the SecurityToken

    * @param _module address of module to unarchive

    */

    function removeModule(address _module) external onlyOwner {

        require(modulesToData[_module].isArchived, "Not archived");

        require(modulesToData[_module].module != address(0), "Module missing");

        /*solium-disable-next-line security/no-block-members*/

        emit ModuleRemoved(modulesToData[_module].moduleTypes, _module, now);

        // Remove from module type list

        uint8[] memory moduleTypes = modulesToData[_module].moduleTypes;

        for (uint256 i = 0; i < moduleTypes.length; i++) {

            _removeModuleWithIndex(moduleTypes[i], modulesToData[_module].moduleIndexes[i]);

            /* modulesToData[_module].moduleType[moduleTypes[i]] = false; */

        }

        // Remove from module names list

        uint256 index = modulesToData[_module].nameIndex;

        bytes32 name = modulesToData[_module].name;

        uint256 length = names[name].length;

        names[name][index] = names[name][length - 1];

        names[name].length = length - 1;

        if ((length - 1) != index) {

            modulesToData[names[name][index]].nameIndex = index;

        }

        // Remove from modulesToData

        delete modulesToData[_module];

    }



    /**

    * @notice Internal - Removes a module attached to the SecurityToken by index

    */

    function _removeModuleWithIndex(uint8 _type, uint256 _index) internal {

        uint256 length = modules[_type].length;

        modules[_type][_index] = modules[_type][length - 1];

        modules[_type].length = length - 1;



        if ((length - 1) != _index) {

            //Need to find index of _type in moduleTypes of module we are moving

            uint8[] memory newTypes = modulesToData[modules[_type][_index]].moduleTypes;

            for (uint256 i = 0; i < newTypes.length; i++) {

                if (newTypes[i] == _type) {

                    modulesToData[modules[_type][_index]].moduleIndexes[i] = _index;

                }

            }

        }

    }



    /**

     * @notice Returns the data associated to a module

     * @param _module address of the module

     * @return bytes32 name

     * @return address module address

     * @return address module factory address

     * @return bool module archived

     * @return uint8 module type

     */

    function getModule(address _module) external view returns (bytes32, address, address, bool, uint8[]) {

        return (modulesToData[_module].name,

        modulesToData[_module].module,

        modulesToData[_module].moduleFactory,

        modulesToData[_module].isArchived,

        modulesToData[_module].moduleTypes);

    }



    /**

     * @notice Returns a list of modules that match the provided name

     * @param _name name of the module

     * @return address[] list of modules with this name

     */

    function getModulesByName(bytes32 _name) external view returns (address[]) {

        return names[_name];

    }



    /**

     * @notice Returns a list of modules that match the provided module type

     * @param _type type of the module

     * @return address[] list of modules with this type

     */

    function getModulesByType(uint8 _type) external view returns (address[]) {

        return modules[_type];

    }



   /**

    * @notice Allows the owner to withdraw unspent POLY stored by them on the ST or any ERC20 token.

    * @dev Owner can transfer POLY to the ST which will be used to pay for modules that require a POLY fee.

    * @param _tokenContract Address of the ERC20Basic compliance token

    * @param _value amount of POLY to withdraw

    */

    function withdrawERC20(address _tokenContract, uint256 _value) external onlyOwner {

        require(_tokenContract != address(0));

        IERC20 token = IERC20(_tokenContract);

        require(token.transfer(owner, _value));

    }



    /**



    * @notice allows owner to increase/decrease POLY approval of one of the modules

    * @param _module module address

    * @param _change change in allowance

    * @param _increase true if budget has to be increased, false if decrease

    */

    function changeModuleBudget(address _module, uint256 _change, bool _increase) external onlyOwner {

        require(modulesToData[_module].module != address(0), "Module missing");

        uint256 currentAllowance = IERC20(polyToken).allowance(address(this), _module);

        uint256 newAllowance;

        if (_increase) {

            require(IERC20(polyToken).increaseApproval(_module, _change), "IncreaseApproval fail");

            newAllowance = currentAllowance.add(_change);

        } else {

            require(IERC20(polyToken).decreaseApproval(_module, _change), "Insufficient allowance");

            newAllowance = currentAllowance.sub(_change);

        }

        emit ModuleBudgetChanged(modulesToData[_module].moduleTypes, _module, currentAllowance, newAllowance);

    }



    /**

     * @notice updates the tokenDetails associated with the token

     * @param _newTokenDetails New token details

     */

    function updateTokenDetails(string _newTokenDetails) external onlyOwner {

        emit UpdateTokenDetails(tokenDetails, _newTokenDetails);

        tokenDetails = _newTokenDetails;

    }



    /**

    * @notice Allows owner to change token granularity

    * @param _granularity granularity level of the token

    */

    function changeGranularity(uint256 _granularity) external onlyOwner {

        require(_granularity != 0, "Invalid granularity");

        emit GranularityChanged(granularity, _granularity);

        granularity = _granularity;

    }



    /**

    * @notice Keeps track of the number of non-zero token holders

    * @param _from sender of transfer

    * @param _to receiver of transfer

    * @param _value value of transfer

    */

    function _adjustInvestorCount(address _from, address _to, uint256 _value) internal {

        TokenLib.adjustInvestorCount(investorData, _from, _to, _value, balanceOf(_to), balanceOf(_from));

    }



    /**

     * @notice returns an array of investors

     * NB - this length may differ from investorCount as it contains all investors that ever held tokens

     * @return list of addresses

     */

    function getInvestors() external view returns(address[]) {

        return investorData.investors;

    }



    /**

     * @notice returns an array of investors at a given checkpoint

     * NB - this length may differ from investorCount as it contains all investors that ever held tokens

     * @param _checkpointId Checkpoint id at which investor list is to be populated

     * @return list of investors

     */

    function getInvestorsAt(uint256 _checkpointId) external view returns(address[]) {

        uint256 count = 0;

        uint256 i;

        for (i = 0; i < investorData.investors.length; i++) {

            if (balanceOfAt(investorData.investors[i], _checkpointId) > 0) {

                count++;

            }

        }

        address[] memory investors = new address[](count);

        count = 0;

        for (i = 0; i < investorData.investors.length; i++) {

            if (balanceOfAt(investorData.investors[i], _checkpointId) > 0) {

                investors[count] = investorData.investors[i];

                count++;

            }

        }

        return investors;

    }



    /**

     * @notice generates subset of investors

     * NB - can be used in batches if investor list is large

     * @param _start Position of investor to start iteration from

     * @param _end Position of investor to stop iteration at

     * @return list of investors

     */

    function iterateInvestors(uint256 _start, uint256 _end) external view returns(address[]) {

        require(_end <= investorData.investors.length, "Invalid end");

        address[] memory investors = new address[](_end.sub(_start));

        uint256 index = 0;

        for (uint256 i = _start; i < _end; i++) {

            investors[index] = investorData.investors[i];

            index++;

        }

        return investors;

    }



    /**

     * @notice Returns the investor count

     * @return Investor count

     */

    function getInvestorCount() external view returns(uint256) {

        return investorData.investorCount;

    }



    /**

     * @notice freezes transfers

     */

    function freezeTransfers() external onlyOwner {

        require(!transfersFrozen, "Already frozen");

        transfersFrozen = true;

        /*solium-disable-next-line security/no-block-members*/

        emit FreezeTransfers(true, now);

    }



    /**

     * @notice Unfreeze transfers

     */

    function unfreezeTransfers() external onlyOwner {

        require(transfersFrozen, "Not frozen");

        transfersFrozen = false;

        /*solium-disable-next-line security/no-block-members*/

        emit FreezeTransfers(false, now);

    }



    /**

     * @notice Internal - adjusts totalSupply at checkpoint after minting or burning tokens

     */

    function _adjustTotalSupplyCheckpoints() internal {

        TokenLib.adjustCheckpoints(checkpointTotalSupply, totalSupply(), currentCheckpointId);

    }



    /**

     * @notice Internal - adjusts token holder balance at checkpoint after a token transfer

     * @param _investor address of the token holder affected

     */

    function _adjustBalanceCheckpoints(address _investor) internal {

        TokenLib.adjustCheckpoints(checkpointBalances[_investor], balanceOf(_investor), currentCheckpointId);

    }



    /**

     * @notice Overloaded version of the transfer function

     * @param _to receiver of transfer

     * @param _value value of transfer

     * @return bool success

     */

    function transfer(address _to, uint256 _value) public returns (bool success) {

        return transferWithData(_to, _value, "");

    }



    /**

     * @notice Overloaded version of the transfer function

     * @param _to receiver of transfer

     * @param _value value of transfer

     * @param _data data to indicate validation

     * @return bool success

     */

    function transferWithData(address _to, uint256 _value, bytes _data) public returns (bool success) {

        require(_updateTransfer(msg.sender, _to, _value, _data), "Transfer invalid");

        require(super.transfer(_to, _value));

        return true;

    }



    /**

     * @notice Overloaded version of the transferFrom function

     * @param _from sender of transfer

     * @param _to receiver of transfer

     * @param _value value of transfer

     * @return bool success

     */

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {

        return transferFromWithData(_from, _to, _value, "");

    }



    /**

     * @notice Overloaded version of the transferFrom function

     * @param _from sender of transfer

     * @param _to receiver of transfer

     * @param _value value of transfer

     * @param _data data to indicate validation

     * @return bool success

     */

    function transferFromWithData(address _from, address _to, uint256 _value, bytes _data) public returns(bool) {

        require(_updateTransfer(_from, _to, _value, _data), "Transfer invalid");

        require(super.transferFrom(_from, _to, _value));

        return true;

    }



    /**

     * @notice Updates internal variables when performing a transfer

     * @param _from sender of transfer

     * @param _to receiver of transfer

     * @param _value value of transfer

     * @param _data data to indicate validation

     * @return bool success

     */

    function _updateTransfer(address _from, address _to, uint256 _value, bytes _data) internal nonReentrant returns(bool) {

        // NB - the ordering in this function implies the following:

        //  - investor counts are updated before transfer managers are called - i.e. transfer managers will see

        //investor counts including the current transfer.

        //  - checkpoints are updated after the transfer managers are called. This allows TMs to create

        //checkpoints as though they have been created before the current transactions,

        //  - to avoid the situation where a transfer manager transfers tokens, and this function is called recursively,

        //the function is marked as nonReentrant. This means that no TM can transfer (or mint / burn) tokens.

        _adjustInvestorCount(_from, _to, _value);

        bool verified = _verifyTransfer(_from, _to, _value, _data, true);

        _adjustBalanceCheckpoints(_from);

        _adjustBalanceCheckpoints(_to);

        return verified;

    }



    /**

     * @notice Validate transfer with TransferManager module if it exists

     * @dev TransferManager module has a key of 2

     * @dev _isTransfer boolean flag is the deciding factor for whether the

     * state variables gets modified or not within the different modules. i.e isTransfer = true

     * leads to change in the modules environment otherwise _verifyTransfer() works as a read-only

     * function (no change in the state).

     * @param _from sender of transfer

     * @param _to receiver of transfer

     * @param _value value of transfer

     * @param _data data to indicate validation

     * @param _isTransfer whether transfer is being executed

     * @return bool

     */

    function _verifyTransfer(

        address _from,

        address _to,

        uint256 _value,

        bytes _data,

        bool _isTransfer

    ) internal checkGranularity(_value) returns (bool) {

        if (!transfersFrozen) {

            bool isInvalid = false;

            bool isValid = false;

            bool isForceValid = false;

            bool unarchived = false;

            address module;

            for (uint256 i = 0; i < modules[TRANSFER_KEY].length; i++) {

                module = modules[TRANSFER_KEY][i];

                if (!modulesToData[module].isArchived) {

                    unarchived = true;

                    ITransferManager.Result valid = ITransferManager(module).verifyTransfer(_from, _to, _value, _data, _isTransfer);

                    if (valid == ITransferManager.Result.INVALID) {

                        isInvalid = true;

                    } else if (valid == ITransferManager.Result.VALID) {

                        isValid = true;

                    } else if (valid == ITransferManager.Result.FORCE_VALID) {

                        isForceValid = true;

                    }

                }

            }

            // If no unarchived modules, return true by default

            return unarchived ? (isForceValid ? true : (isInvalid ? false : isValid)) : true;

        }

        return false;

    }



    /**

     * @notice Validates a transfer with a TransferManager module if it exists

     * @dev TransferManager module has a key of 2

     * @param _from sender of transfer

     * @param _to receiver of transfer

     * @param _value value of transfer

     * @param _data data to indicate validation

     * @return bool

     */

    function verifyTransfer(address _from, address _to, uint256 _value, bytes _data) public returns (bool) {

        return _verifyTransfer(_from, _to, _value, _data, false);

    }



    /**

     * @notice Permanently freeze minting of this security token.

     * @dev It MUST NOT be possible to increase `totalSuppy` after this function is called.

     */

    function freezeMinting() external isMintingAllowed() isEnabled("freezeMintingAllowed") onlyOwner {

        mintingFrozen = true;

        /*solium-disable-next-line security/no-block-members*/

        emit FreezeMinting(now);

    }



    /**

     * @notice Mints new tokens and assigns them to the target _investor.

     * @dev Can only be called by the issuer or STO attached to the token

     * @param _investor Address where the minted tokens will be delivered

     * @param _value Number of tokens be minted

     * @return success

     */

    function mint(address _investor, uint256 _value) public returns (bool success) {

        return mintWithData(_investor, _value, "");

    }



    /**

     * @notice mints new tokens and assigns them to the target _investor.

     * @dev Can only be called by the issuer or STO attached to the token

     * @param _investor Address where the minted tokens will be delivered

     * @param _value Number of tokens be minted

     * @param _data data to indicate validation

     * @return success

     */

    function mintWithData(

        address _investor,

        uint256 _value,

        bytes _data

        ) public onlyModuleOrOwner(MINT_KEY) isMintingAllowed() returns (bool success) {

        require(_investor != address(0), "Investor is 0");

        require(_updateTransfer(address(0), _investor, _value, _data), "Transfer invalid");

        _adjustTotalSupplyCheckpoints();

        totalSupply_ = totalSupply_.add(_value);

        balances[_investor] = balances[_investor].add(_value);

        emit Minted(_investor, _value);

        emit Transfer(address(0), _investor, _value);

        return true;

    }



    /**

     * @notice Mints new tokens and assigns them to the target _investor.

     * @dev Can only be called by the issuer or STO attached to the token.

     * @param _investors A list of addresses to whom the minted tokens will be dilivered

     * @param _values A list of number of tokens get minted and transfer to corresponding address of the investor from _investor[] list

     * @return success

     */

    function mintMulti(address[] _investors, uint256[] _values) external returns (bool success) {

        require(_investors.length == _values.length, "Incorrect inputs");

        for (uint256 i = 0; i < _investors.length; i++) {

            mint(_investors[i], _values[i]);

        }

        return true;

    }



    /**

     * @notice Validate permissions with PermissionManager if it exists, If no Permission return false

     * @dev Note that IModule withPerm will allow ST owner all permissions anyway

     * @dev this allows individual modules to override this logic if needed (to not allow ST owner all permissions)

     * @param _delegate address of delegate

     * @param _module address of PermissionManager module

     * @param _perm the permissions

     * @return success

     */

    function checkPermission(address _delegate, address _module, bytes32 _perm) public view returns(bool) {

        for (uint256 i = 0; i < modules[PERMISSION_KEY].length; i++) {

            if (!modulesToData[modules[PERMISSION_KEY][i]].isArchived)

                return TokenLib.checkPermission(modules[PERMISSION_KEY], _delegate, _module, _perm);

        }

        return false;

    }



    function _burn(address _from, uint256 _value, bytes _data) internal returns(bool) {

        require(_value <= balances[_from], "Value too high");

        bool verified = _updateTransfer(_from, address(0), _value, _data);

        _adjustTotalSupplyCheckpoints();

        balances[_from] = balances[_from].sub(_value);

        totalSupply_ = totalSupply_.sub(_value);

        emit Burnt(_from, _value);

        emit Transfer(_from, address(0), _value);

        return verified;

    }



    /**

     * @notice Burn function used to burn the securityToken

     * @param _value No. of tokens that get burned

     * @param _data data to indicate validation

     */

    function burnWithData(uint256 _value, bytes _data) public onlyModule(BURN_KEY) {

        require(_burn(msg.sender, _value, _data), "Burn invalid");

    }



    /**

     * @notice Burn function used to burn the securityToken on behalf of someone else

     * @param _from Address for whom to burn tokens

     * @param _value No. of tokens that get burned

     * @param _data data to indicate validation

     */

    function burnFromWithData(address _from, uint256 _value, bytes _data) public onlyModule(BURN_KEY) {

        require(_value <= allowed[_from][msg.sender], "Value too high");

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        require(_burn(_from, _value, _data), "Burn invalid");

    }



    /**

     * @notice Creates a checkpoint that can be used to query historical balances / totalSuppy

     * @return uint256

     */

    function createCheckpoint() external onlyModuleOrOwner(CHECKPOINT_KEY) returns(uint256) {

        require(currentCheckpointId < 2**256 - 1);

        currentCheckpointId = currentCheckpointId + 1;

        /*solium-disable-next-line security/no-block-members*/

        checkpointTimes.push(now);

        /*solium-disable-next-line security/no-block-members*/

        emit CheckpointCreated(currentCheckpointId, now);

        return currentCheckpointId;

    }



    /**

     * @notice Gets list of times that checkpoints were created

     * @return List of checkpoint times

     */

    function getCheckpointTimes() external view returns(uint256[]) {

        return checkpointTimes;

    }



    /**

     * @notice Queries totalSupply as of a defined checkpoint

     * @param _checkpointId Checkpoint ID to query

     * @return uint256

     */

    function totalSupplyAt(uint256 _checkpointId) external view returns(uint256) {

        require(_checkpointId <= currentCheckpointId);

        return TokenLib.getValueAt(checkpointTotalSupply, _checkpointId, totalSupply());

    }



    /**

     * @notice Queries balances as of a defined checkpoint

     * @param _investor Investor to query balance for

     * @param _checkpointId Checkpoint ID to query as of

     */

    function balanceOfAt(address _investor, uint256 _checkpointId) public view returns(uint256) {

        require(_checkpointId <= currentCheckpointId);

        return TokenLib.getValueAt(checkpointBalances[_investor], _checkpointId, balanceOf(_investor));

    }



    /**

     * @notice Used by the issuer to set the controller addresses

     * @param _controller address of the controller

     */

    function setController(address _controller) public onlyOwner {

        require(!controllerDisabled);

        emit SetController(controller, _controller);

        controller = _controller;

    }



    /**

     * @notice Used by the issuer to permanently disable controller functionality

     * @dev enabled via feature switch "disableControllerAllowed"

     */

    function disableController() external isEnabled("disableControllerAllowed") onlyOwner {

        require(!controllerDisabled);

        controllerDisabled = true;

        delete controller;

        /*solium-disable-next-line security/no-block-members*/

        emit DisableController(now);

    }



    /**

     * @notice Used by a controller to execute a forced transfer

     * @param _from address from which to take tokens

     * @param _to address where to send tokens

     * @param _value amount of tokens to transfer

     * @param _data data to indicate validation

     * @param _log data attached to the transfer by controller to emit in event

     */

    function forceTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _log) public onlyController {

        require(_to != address(0));

        require(_value <= balances[_from]);

        bool verified = _updateTransfer(_from, _to, _value, _data);

        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit ForceTransfer(msg.sender, _from, _to, _value, verified, _log);

        emit Transfer(_from, _to, _value);

    }



    /**

     * @notice Used by a controller to execute a forced burn

     * @param _from address from which to take tokens

     * @param _value amount of tokens to transfer

     * @param _data data to indicate validation

     * @param _log data attached to the transfer by controller to emit in event

     */

    function forceBurn(address _from, uint256 _value, bytes _data, bytes _log) public onlyController {

        bool verified = _burn(_from, _value, _data);

        emit ForceBurn(msg.sender, _from, _value, verified, _log);

    }



    /**

     * @notice Returns the version of the SecurityToken

     */

    function getVersion() external view returns(uint8[]) {

        uint8[] memory _version = new uint8[](3);

        _version[0] = securityTokenVersion.major;

        _version[1] = securityTokenVersion.minor;

        _version[2] = securityTokenVersion.patch;

        return _version;

    }



}



/**

 * @title Interface for security token proxy deployment

 */





/**

 * @title Proxy for deploying SecurityToken instances

 */

contract STFactory is ISTFactory {



    address public transferManagerFactory;



    constructor (address _transferManagerFactory) public {

        transferManagerFactory = _transferManagerFactory;

    }



    /**

     * @notice deploys the token and adds default modules like the GeneralTransferManager.

     * Future versions of the proxy can attach different modules or pass different parameters.

     */

    function deployToken(

        string _name,

        string _symbol,

        uint8 _decimals,

        string _tokenDetails,

        address _issuer,

        bool _divisible,

        address _polymathRegistry

        ) external returns (address) {

        address newSecurityTokenAddress = new SecurityToken(

            _name,

            _symbol,

            _decimals,

            _divisible ? 1 : uint256(10)**_decimals,

            _tokenDetails,

            _polymathRegistry

        );

        SecurityToken(newSecurityTokenAddress).addModule(transferManagerFactory, "", 0, 0);

        SecurityToken(newSecurityTokenAddress).transferOwnership(_issuer);

        return newSecurityTokenAddress;

    }

}