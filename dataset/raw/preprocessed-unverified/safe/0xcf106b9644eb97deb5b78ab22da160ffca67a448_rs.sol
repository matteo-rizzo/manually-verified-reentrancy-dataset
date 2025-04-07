/**

 *Submitted for verification at Etherscan.io on 2019-02-04

*/



pragma solidity ^0.4.24;



/**

 * @title Owned

 * @dev Basic contract to define an owner.

 * @author Julien Niset - <[email protected]>

 */





/**

 * @title Managed

 * @dev Basic contract that defines a set of managers. Only the owner can add/remove managers.

 * @author Julien Niset - <[email protected]>

 */

contract Managed is Owned {



    // The managers

    mapping (address => bool) public managers;



    /**

     * @dev Throws if the sender is not a manager.

     */

    modifier onlyManager {

        require(managers[msg.sender] == true, "M: Must be manager");

        _;

    }



    event ManagerAdded(address indexed _manager);

    event ManagerRevoked(address indexed _manager);



    /**

    * @dev Adds a manager. 

    * @param _manager The address of the manager.

    */

    function addManager(address _manager) external onlyOwner {

        require(_manager != address(0), "M: Address must not be null");

        if(managers[_manager] == false) {

            managers[_manager] = true;

            emit ManagerAdded(_manager);

        }        

    }



    /**

    * @dev Revokes a manager.

    * @param _manager The address of the manager.

    */

    function revokeManager(address _manager) external onlyOwner {

        require(managers[_manager] == true, "M: Target must be an existing manager");

        delete managers[_manager];

        emit ManagerRevoked(_manager);

    }

}



/**

 * ENS Registry interface.

 */

contract ENSRegistry {

    function owner(bytes32 _node) public view returns (address);

    function resolver(bytes32 _node) public view returns (address);

    function ttl(bytes32 _node) public view returns (uint64);

    function setOwner(bytes32 _node, address _owner) public;

    function setSubnodeOwner(bytes32 _node, bytes32 _label, address _owner) public;

    function setResolver(bytes32 _node, address _resolver) public;

    function setTTL(bytes32 _node, uint64 _ttl) public;

}



/**

 * ENS Resolver interface.

 */

contract ENSResolver {

    function addr(bytes32 _node) public view returns (address);

    function setAddr(bytes32 _node, address _addr) public;

    function name(bytes32 _node) public view returns (string);

    function setName(bytes32 _node, string _name) public;

}



/**

 * ENS Reverse Registrar interface.

 */

contract ENSReverseRegistrar {

    function claim(address _owner) public returns (bytes32 _node);

    function claimWithResolver(address _owner, address _resolver) public returns (bytes32);

    function setName(string _name) public returns (bytes32);

    function node(address _addr) public view returns (bytes32);

}



/*

 * @title String & slice utility library for Solidity contracts.

 * @author Nick Johnson <[email protected]>

 *

 * @dev Functionality in this library is largely implemented using an

 *      abstraction called a 'slice'. A slice represents a part of a string -

 *      anything from the entire string to a single character, or even no

 *      characters at all (a 0-length slice). Since a slice only has to specify

 *      an offset and a length, copying and manipulating slices is a lot less

 *      expensive than copying and manipulating the strings they reference.

 *

 *      To further reduce gas costs, most functions on slice that need to return

 *      a slice modify the original one instead of allocating a new one; for

 *      instance, `s.split(".")` will return the text up to the first '.',

 *      modifying s to only contain the remainder of the string after the '.'.

 *      In situations where you do not want to modify the original slice, you

 *      can make a copy first with `.copy()`, for example:

 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since

 *      Solidity has no memory management, it will result in allocating many

 *      short-lived slices that are later discarded.

 *

 *      Functions that return two slices come in two versions: a non-allocating

 *      version that takes the second slice as an argument, modifying it in

 *      place, and an allocating version that allocates and returns the second

 *      slice; see `nextRune` for example.

 *

 *      Functions that have to copy string data will return strings rather than

 *      slices; these can be cast back to slices for further processing if

 *      required.

 *

 *      For convenience, some functions are provided with non-modifying

 *      variants that create a new slice and return both; for instance,

 *      `s.splitNew('.')` leaves s unmodified, and returns two values

 *      corresponding to the left and right parts of the string.

 */

/* solium-disable */





/**

 * @title ENSConsumer

 * @dev Helper contract to resolve ENS names.

 * @author Julien Niset - <[email protected]>

 */

contract ENSConsumer {



    using strings for *;



    // namehash('addr.reverse')

    bytes32 constant public ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;



    // the address of the ENS registry

    address ensRegistry;



    /**

    * @dev No address should be provided when deploying on Mainnet to avoid storage cost. The 

    * contract will use the hardcoded value.

    */

    constructor(address _ensRegistry) public {

        ensRegistry = _ensRegistry;

    }



    /**

    * @dev Resolves an ENS name to an address.

    * @param _node The namehash of the ENS name. 

    */

    function resolveEns(bytes32 _node) public view returns (address) {

        address resolver = getENSRegistry().resolver(_node);

        return ENSResolver(resolver).addr(_node);

    }



    /**

    * @dev Gets the official ENS registry.

    */

    function getENSRegistry() public view returns (ENSRegistry) {

        return ENSRegistry(ensRegistry);

    }



    /**

    * @dev Gets the official ENS reverse registrar. 

    */

    function getENSReverseRegistrar() public view returns (ENSReverseRegistrar) {

        return ENSReverseRegistrar(getENSRegistry().owner(ADDR_REVERSE_NODE));

    }

}



/**

 * @dev Interface for an ENS Mananger.

 */





/**

 * @title Proxy

 * @dev Basic proxy that delegates all calls to a fixed implementing contract.

 * The implementing contract cannot be upgraded.

 * @author Julien Niset - <[email protected]>

 */

contract Proxy {



    address implementation;



    event Received(uint indexed value, address indexed sender, bytes data);



    constructor(address _implementation) public {

        implementation = _implementation;

    }



    function() external payable {



        if(msg.data.length == 0 && msg.value > 0) { 

            emit Received(msg.value, msg.sender, msg.data); 

        }

        else {

            // solium-disable-next-line security/no-inline-assembly

            assembly {

                let target := sload(0)

                calldatacopy(0, 0, calldatasize())

                let result := delegatecall(gas, target, 0, calldatasize(), 0, 0)

                returndatacopy(0, 0, returndatasize())

                switch result 

                case 0 {revert(0, returndatasize())} 

                default {return (0, returndatasize())}

            }

        }

    }

}



/**

 * @title Module

 * @dev Interface for a module. 

 * A module MUST implement the addModule() method to ensure that a wallet with at least one module

 * can never end up in a "frozen" state.

 * @author Julien Niset - <[email protected]>

 */





/**

 * @title BaseWallet

 * @dev Simple modular wallet that authorises modules to call its invoke() method.

 * Based on https://gist.github.com/Arachnid/a619d31f6d32757a4328a428286da186 by 

 * @author Julien Niset - <[email protected]>

 */

contract BaseWallet {



    // The implementation of the proxy

    address public implementation;

    // The owner 

    address public owner;

    // The authorised modules

    mapping (address => bool) public authorised;

    // The enabled static calls

    mapping (bytes4 => address) public enabled;

    // The number of modules

    uint public modules;

    

    event AuthorisedModule(address indexed module, bool value);

    event EnabledStaticCall(address indexed module, bytes4 indexed method);

    event Invoked(address indexed module, address indexed target, uint indexed value, bytes data);

    event Received(uint indexed value, address indexed sender, bytes data);

    event OwnerChanged(address owner);

    

    /**

     * @dev Throws if the sender is not an authorised module.

     */

    modifier moduleOnly {

        require(authorised[msg.sender], "BW: msg.sender not an authorized module");

        _;

    }



    /**

     * @dev Inits the wallet by setting the owner and authorising a list of modules.

     * @param _owner The owner.

     * @param _modules The modules to authorise.

     */

    function init(address _owner, address[] _modules) external {

        require(owner == address(0) && modules == 0, "BW: wallet already initialised");

        require(_modules.length > 0, "BW: construction requires at least 1 module");

        owner = _owner;

        modules = _modules.length;

        for(uint256 i = 0; i < _modules.length; i++) {

            require(authorised[_modules[i]] == false, "BW: module is already added");

            authorised[_modules[i]] = true;

            Module(_modules[i]).init(this);

            emit AuthorisedModule(_modules[i], true);

        }

    }

    

    /**

     * @dev Enables/Disables a module.

     * @param _module The target module.

     * @param _value Set to true to authorise the module.

     */

    function authoriseModule(address _module, bool _value) external moduleOnly {

        if (authorised[_module] != _value) {

            if(_value == true) {

                modules += 1;

                authorised[_module] = true;

                Module(_module).init(this);

            }

            else {

                modules -= 1;

                require(modules > 0, "BW: wallet must have at least one module");

                delete authorised[_module];

            }

            emit AuthorisedModule(_module, _value);

        }

    }



    /**

    * @dev Enables a static method by specifying the target module to which the call

    * must be delegated.

    * @param _module The target module.

    * @param _method The static method signature.

    */

    function enableStaticCall(address _module, bytes4 _method) external moduleOnly {

        require(authorised[_module], "BW: must be an authorised module for static call");

        enabled[_method] = _module;

        emit EnabledStaticCall(_module, _method);

    }



    /**

     * @dev Sets a new owner for the wallet.

     * @param _newOwner The new owner.

     */

    function setOwner(address _newOwner) external moduleOnly {

        require(_newOwner != address(0), "BW: address cannot be null");

        owner = _newOwner;

        emit OwnerChanged(_newOwner);

    }

    

    /**

     * @dev Performs a generic transaction.

     * @param _target The address for the transaction.

     * @param _value The value of the transaction.

     * @param _data The data of the transaction.

     */

    function invoke(address _target, uint _value, bytes _data) external moduleOnly {

        // solium-disable-next-line security/no-call-value

        require(_target.call.value(_value)(_data), "BW: call to target failed");

        emit Invoked(msg.sender, _target, _value, _data);

    }



    /**

     * @dev This method makes it possible for the wallet to comply to interfaces expecting the wallet to

     * implement specific static methods. It delegates the static call to a target contract if the data corresponds 

     * to an enabled method, or logs the call otherwise.

     */

    function() public payable {

        if(msg.data.length > 0) { 

            address module = enabled[msg.sig];

            if(module == address(0)) {

                emit Received(msg.value, msg.sender, msg.data);

            } 

            else {

                require(authorised[module], "BW: must be an authorised module for static call");

                // solium-disable-next-line security/no-inline-assembly

                assembly {

                    calldatacopy(0, 0, calldatasize())

                    let result := staticcall(gas, module, 0, calldatasize(), 0, 0)

                    returndatacopy(0, 0, returndatasize())

                    switch result 

                    case 0 {revert(0, returndatasize())} 

                    default {return (0, returndatasize())}

                }

            }

        }

    }

}



/**

 * ERC20 contract interface.

 */

contract ERC20 {

    function totalSupply() public view returns (uint);

    function decimals() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);

}



/**

 * @title ModuleRegistry

 * @dev Registry of authorised modules. 

 * Modules must be registered before they can be authorised on a wallet.

 * @author Julien Niset - <[email protected]>

 */

contract ModuleRegistry is Owned {



    mapping (address => Info) internal modules;

    mapping (address => Info) internal upgraders;



    event ModuleRegistered(address indexed module, bytes32 name);

    event ModuleDeRegistered(address module);

    event UpgraderRegistered(address indexed upgrader, bytes32 name);

    event UpgraderDeRegistered(address upgrader);



    struct Info {

        bool exists;

        bytes32 name;

    }



    /**

     * @dev Registers a module.

     * @param _module The module.

     * @param _name The unique name of the module.

     */

    function registerModule(address _module, bytes32 _name) external onlyOwner {

        require(!modules[_module].exists, "MR: module already exists");

        modules[_module] = Info({exists: true, name: _name});

        emit ModuleRegistered(_module, _name);

    }



    /**

     * @dev Deregisters a module.

     * @param _module The module.

     */

    function deregisterModule(address _module) external onlyOwner {

        require(modules[_module].exists, "MR: module does not exists");

        delete modules[_module];

        emit ModuleDeRegistered(_module);

    }



        /**

     * @dev Registers an upgrader.

     * @param _upgrader The upgrader.

     * @param _name The unique name of the upgrader.

     */

    function registerUpgrader(address _upgrader, bytes32 _name) external onlyOwner {

        require(!upgraders[_upgrader].exists, "MR: upgrader already exists");

        upgraders[_upgrader] = Info({exists: true, name: _name});

        emit UpgraderRegistered(_upgrader, _name);

    }



    /**

     * @dev Deregisters an upgrader.

     * @param _upgrader The _upgrader.

     */

    function deregisterUpgrader(address _upgrader) external onlyOwner {

        require(upgraders[_upgrader].exists, "MR: upgrader does not exists");

        delete upgraders[_upgrader];

        emit UpgraderDeRegistered(_upgrader);

    }



    /**

    * @dev Utility method enbaling the owner of the registry to claim any ERC20 token that was sent to the

    * registry.

    * @param _token The token to recover.

    */

    function recoverToken(address _token) external onlyOwner {

        uint total = ERC20(_token).balanceOf(address(this));

        ERC20(_token).transfer(msg.sender, total);

    } 



    /**

     * @dev Gets the name of a module from its address.

     * @param _module The module address.

     * @return the name.

     */

    function moduleInfo(address _module) external view returns (bytes32) {

        return modules[_module].name;

    }



    /**

     * @dev Gets the name of an upgrader from its address.

     * @param _upgrader The upgrader address.

     * @return the name.

     */

    function upgraderInfo(address _upgrader) external view returns (bytes32) {

        return upgraders[_upgrader].name;

    }



    /**

     * @dev Checks if a module is registered.

     * @param _module The module address.

     * @return true if the module is registered.

     */

    function isRegisteredModule(address _module) external view returns (bool) {

        return modules[_module].exists;

    }



    /**

     * @dev Checks if a list of modules are registered.

     * @param _modules The list of modules address.

     * @return true if all the modules are registered.

     */

    function isRegisteredModule(address[] _modules) external view returns (bool) {

        for(uint i = 0; i < _modules.length; i++) {

            if (!modules[_modules[i]].exists) {

                return false;

            }

        }

        return true;

    }  



    /**

     * @dev Checks if an upgrader is registered.

     * @param _upgrader The upgrader address.

     * @return true if the upgrader is registered.

     */

    function isRegisteredUpgrader(address _upgrader) external view returns (bool) {

        return upgraders[_upgrader].exists;

    } 



}



/**

 * @title WalletFactory

 * @dev The WalletFactory contract creates and assigns wallets to accounts.

 * @author Julien Niset - <[email protected]>

 */

contract WalletFactory is Owned, Managed, ENSConsumer {



    // The address of the module registry

    address public moduleRegistry;

    // The address of the base wallet implementation

    address public walletImplementation;

    // The address of the ENS manager

    address public ensManager;

    // The address of the ENS resolver

    address public ensResolver;



    // *************** Events *************************** //



    event ModuleRegistryChanged(address addr);

    event WalletImplementationChanged(address addr);

    event ENSManagerChanged(address addr);

    event ENSResolverChanged(address addr);

    event WalletCreated(address indexed _wallet, address indexed _owner);



    // *************** Constructor ********************** //



    /**

     * @dev Default constructor.

     */

    constructor(

        address _ensRegistry, 

        address _moduleRegistry,

        address _walletImplementation, 

        address _ensManager, 

        address _ensResolver

    ) 

        ENSConsumer(_ensRegistry) 

        public 

    {

        moduleRegistry = _moduleRegistry;

        walletImplementation = _walletImplementation;

        ensManager = _ensManager;

        ensResolver = _ensResolver;

    }



    // *************** External Functions ********************* //



    /**

     * @dev Lets the manager create a wallet for an account. The wallet is initialised with a list of modules.

     * @param _owner The account address.

     * @param _modules The list of modules.

     * @param _label Optional ENS label of the new wallet (e.g. franck).

     */

    function createWallet(address _owner, address[] _modules, string _label) external onlyManager {

        require(_owner != address(0), "WF: owner cannot be null");

        require(_modules.length > 0, "WF: cannot assign with less than 1 module");

        require(ModuleRegistry(moduleRegistry).isRegisteredModule(_modules), "WF: one or more modules are not registered");

        // create the proxy

        Proxy proxy = new Proxy(walletImplementation);

        address wallet = address(proxy);

        // check for ENS

        bytes memory labelBytes = bytes(_label);

        if (labelBytes.length != 0) {

            // add the factory to the modules so it can claim the reverse ENS

            address[] memory extendedModules = new address[](_modules.length + 1);

            extendedModules[0] = address(this);

            for(uint i = 0; i < _modules.length; i++) {

                extendedModules[i + 1] = _modules[i];

            }

            // initialise the wallet with the owner and the extended modules

            BaseWallet(wallet).init(_owner, extendedModules);

            // register ENS

            registerWalletENS(wallet, _label);

            // remove the factory from the authorised modules

            BaseWallet(wallet).authoriseModule(address(this), false);

        } else {

            // initialise the wallet with the owner and the modules

            BaseWallet(wallet).init(_owner, _modules);

        }

        emit WalletCreated(wallet, _owner);

    }



    /**

     * @dev Lets the owner change the address of the module registry contract.

     * @param _moduleRegistry The address of the module registry contract.

     */

    function changeModuleRegistry(address _moduleRegistry) external onlyOwner {

        require(_moduleRegistry != address(0), "WF: address cannot be null");

        moduleRegistry = _moduleRegistry;

        emit ModuleRegistryChanged(_moduleRegistry);

    }



    /**

     * @dev Lets the owner change the address of the implementing contract.

     * @param _walletImplementation The address of the implementing contract.

     */

    function changeWalletImplementation(address _walletImplementation) external onlyOwner {

        require(_walletImplementation != address(0), "WF: address cannot be null");

        walletImplementation = _walletImplementation;

        emit WalletImplementationChanged(_walletImplementation);

    }



    /**

     * @dev Lets the owner change the address of the ENS manager contract.

     * @param _ensManager The address of the ENS manager contract.

     */

    function changeENSManager(address _ensManager) external onlyOwner {

        require(_ensManager != address(0), "WF: address cannot be null");

        ensManager = _ensManager;

        emit ENSManagerChanged(_ensManager);

    }



    /**

     * @dev Lets the owner change the address of the ENS resolver contract.

     * @param _ensResolver The address of the ENS resolver contract.

     */

    function changeENSResolver(address _ensResolver) external onlyOwner {

        require(_ensResolver != address(0), "WF: address cannot be null");

        ensResolver = _ensResolver;

        emit ENSResolverChanged(_ensResolver);

    }



    /**

     * @dev Register an ENS subname to a wallet.

     * @param _wallet The wallet address.

     * @param _label ENS label of the new wallet (e.g. franck).

     */

    function registerWalletENS(address _wallet, string _label) internal {

        // claim reverse

        bytes memory methodData = abi.encodeWithSignature("claimWithResolver(address,address)", ensManager, ensResolver);

        BaseWallet(_wallet).invoke(getENSReverseRegistrar(), 0, methodData);

        // register with ENS manager

        IENSManager(ensManager).register(_label, _wallet);

    }



    /**

     * @dev Inits the module for a wallet by logging an event.

     * The method can only be called by the wallet itself.

     * @param _wallet The wallet.

     */

    function init(BaseWallet _wallet) external pure {

        //do nothing

    }

}