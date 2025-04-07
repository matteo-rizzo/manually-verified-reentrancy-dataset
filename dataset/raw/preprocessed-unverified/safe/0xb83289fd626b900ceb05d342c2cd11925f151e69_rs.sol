/**

 *Submitted for verification at Etherscan.io on 2019-02-04

*/



pragma solidity ^0.4.24;



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

 * @dev Interface for an ENS Mananger.

 */





/**

 * @title ArgentENSManager

 * @dev Implementation of an ENS manager that orchestrates the complete

 * registration of subdomains for a single root (e.g. argent.xyz). 

 * The contract defines a manager role who is the only role that can trigger the registration of

 * a new subdomain.

 * @author Julien Niset - <[email protected]>

 */

contract ArgentENSManager is IENSManager, Owned, Managed, ENSConsumer {

    

    using strings for *;



    // The managed root name

    string public rootName;

    // The managed root node

    bytes32 public rootNode;

    // The address of the ENS resolver

    address public ensResolver;



    // *************** Events *************************** //



    event RootnodeOwnerChange(bytes32 indexed _rootnode, address indexed _newOwner);

    event ENSResolverChanged(address addr);

    event Registered(address indexed _owner, string _ens);

    event Unregistered(string _ens);



    // *************** Constructor ********************** //



    /**

     * @dev Constructor that sets the ENS root name and root node to manage.

     * @param _rootName The root name (e.g. argentx.eth).

     * @param _rootNode The node of the root name (e.g. namehash(argentx.eth)).

     */

    constructor(string _rootName, bytes32 _rootNode, address _ensRegistry, address _ensResolver) ENSConsumer(_ensRegistry) public {

        rootName = _rootName;

        rootNode = _rootNode;

        ensResolver = _ensResolver;

    }



    // *************** External Functions ********************* //



    /**

     * @dev This function must be called when the ENS Manager contract is replaced

     * and the address of the new Manager should be provided.

     * @param _newOwner The address of the new ENS manager that will manage the root node.

     */

    function changeRootnodeOwner(address _newOwner) external onlyOwner {

        getENSRegistry().setOwner(rootNode, _newOwner);

        emit RootnodeOwnerChange(rootNode, _newOwner);

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

    * @dev Lets the manager assign an ENS subdomain of the root node to a target address.

    * Registers both the forward and reverse ENS.

    * @param _label The subdomain label.

    * @param _owner The owner of the subdomain.

    */

    function register(string _label, address _owner) external onlyManager {

        bytes32 labelNode = keccak256(abi.encodePacked(_label));

        bytes32 node = keccak256(abi.encodePacked(rootNode, labelNode));

        address currentOwner = getENSRegistry().owner(node);

        require(currentOwner == 0, "AEM: _label is alrealdy owned");



        // Forward ENS

        getENSRegistry().setSubnodeOwner(rootNode, labelNode, address(this));

        getENSRegistry().setResolver(node, ensResolver);

        getENSRegistry().setOwner(node, _owner);

        ENSResolver(ensResolver).setAddr(node, _owner);



        // Reverse ENS

        strings.slice[] memory parts = new strings.slice[](2);

        parts[0] = _label.toSlice();

        parts[1] = rootName.toSlice();

        string memory name = ".".toSlice().join(parts);

        bytes32 reverseNode = getENSReverseRegistrar().node(_owner);

        ENSResolver(ensResolver).setName(reverseNode, name);



        emit Registered(_owner, name);

    }



    // *************** Public Functions ********************* //



    /**

     * @dev Returns true is a given subnode is available.

     * @param _subnode The target subnode.

     * @return true if the subnode is available.

     */

    function isAvailable(bytes32 _subnode) public view returns (bool) {

        bytes32 node = keccak256(abi.encodePacked(rootNode, _subnode));

        address currentOwner = getENSRegistry().owner(node);

        if(currentOwner == 0) {

            return true;

        }

        return false;

    }

}