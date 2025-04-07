/**
 *Submitted for verification at Etherscan.io on 2019-11-02
*/

pragma solidity 0.5.12;

/**
 * @title Owned
 * @author Authereum, Inc.
 * @dev Basic contract to define an owner.
 */


/**
 * @title Managed
 * @author Authereum, Inc.
 * @dev Basic contract that defines a set of managers. Only the owner can add/remove managers.
 */

contract Managed is Owned {

    // The managers
    mapping (address => bool) public managers;

    /// @dev Throws if the sender is not a manager
    modifier onlyManager {
        require(managers[msg.sender] == true, "Must be manager");
        _;
    }

    event ManagerAdded(address indexed _manager);
    event ManagerRevoked(address indexed _manager);

    /// @dev Adds a manager
    /// @param _manager The address of the manager
    function addManager(address _manager) external onlyOwner {
        require(_manager != address(0), "Address must not be null");
        if(managers[_manager] == false) {
            managers[_manager] = true;
            emit ManagerAdded(_manager);
        }
    }

    /// @dev Revokes a manager
    /// @param _manager The address of the manager
    function revokeManager(address _manager) external onlyOwner {
        require(managers[_manager] == true, "Target must be an existing manager");
        delete managers[_manager];
        emit ManagerRevoked(_manager);
    }
}

/**
 * ENS registry test contract.
 */
contract EnsRegistry {

    struct Record {
        address owner;
        address resolver;
        uint64 ttl;
    }

    mapping(bytes32=>Record) records;

    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed _node, bytes32 indexed _label, address _owner);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed _node, address _owner);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed _node, address _resolver);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed _node, uint64 _ttl);

    // Permits modifications only by the owner of the specified node.
    modifier only_owner(bytes32 _node) {
        require(records[_node].owner == msg.sender, "ENSTest: this method needs to be called by the owner of the node");
        _;
    }

    /**
     * Constructs a new ENS registrar.
     */
    constructor() public {
        records[bytes32(0)].owner = msg.sender;
    }

    /**
     * Returns the address that owns the specified node.
     */
    function owner(bytes32 _node) public view returns (address) {
        return records[_node].owner;
    }

    /**
     * Returns the address of the resolver for the specified node.
     */
    function resolver(bytes32 _node) public view returns (address) {
        return records[_node].resolver;
    }

    /**
     * Returns the TTL of a node, and any records associated with it.
     */
    function ttl(bytes32 _node) public view returns (uint64) {
        return records[_node].ttl;
    }

    /**
     * Transfers ownership of a node to a new address. May only be called by the current
     * owner of the node.
     * @param _node The node to transfer ownership of.
     * @param _owner The address of the new owner.
     */
    function setOwner(bytes32 _node, address _owner) public only_owner(_node) {
        emit Transfer(_node, _owner);
        records[_node].owner = _owner;
    }

    /**
     * Transfers ownership of a subnode sha3(node, label) to a new address. May only be
     * called by the owner of the parent node.
     * @param _node The parent node.
     * @param _label The hash of the label specifying the subnode.
     * @param _owner The address of the new owner.
     */
    function setSubnodeOwner(bytes32 _node, bytes32 _label, address _owner) public only_owner(_node) {
        bytes32 subnode = keccak256(abi.encodePacked(_node, _label));
        emit NewOwner(_node, _label, _owner);
        records[subnode].owner = _owner;
    }

    /**
     * Sets the resolver address for the specified node.
     * @param _node The node to update.
     * @param _resolver The address of the resolver.
     */
    function setResolver(bytes32 _node, address _resolver) public only_owner(_node) {
        emit NewResolver(_node, _resolver);
        records[_node].resolver = _resolver;
    }

    /**
     * Sets the TTL for the specified node.
     * @param _node The node to update.
     * @param _ttl The TTL in seconds.
     */
    function setTTL(bytes32 _node, uint64 _ttl) public only_owner(_node) {
        emit NewTTL(_node, _ttl);
        records[_node].ttl = _ttl;
    }
}

/**
 * ENS Resolver interface.
 */
contract EnsResolver {
    function setName(bytes32 _node, string calldata _name) external {}
}

/**
 * ENS Reverse registrar test contract.
 */
contract EnsReverseRegistrar {

    string constant public ensReverseRegistrarVersion = "2019102500";

   // namehash('addr.reverse')
    bytes32 constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    EnsRegistry public ens;
    EnsResolver public defaultResolver;

    /**
     * @dev Constructor
     * @param ensAddr The address of the ENS registry.
     * @param resolverAddr The address of the default reverse resolver.
     */
    constructor(address ensAddr, address resolverAddr) public {
        ens = EnsRegistry(ensAddr);
        defaultResolver = EnsResolver(resolverAddr);
    }

    /**
     * @dev Transfers ownership of the reverse ENS record associated with the
     *      calling account.
     * @param owner The address to set as the owner of the reverse record in ENS.
     * @return The ENS node hash of the reverse record.
     */
    function claim(address owner) public returns (bytes32) {
        return claimWithResolver(owner, address(0));
    }

    /**
     * @dev Transfers ownership of the reverse ENS record associated with the
     *      calling account.
     * @param owner The address to set as the owner of the reverse record in ENS.
     * @param resolver The address of the resolver to set; 0 to leave unchanged.
     * @return The ENS node hash of the reverse record.
     */
    function claimWithResolver(address owner, address resolver) public returns (bytes32) {
        bytes32 label = sha3HexAddress(msg.sender);
        bytes32 node = keccak256(abi.encodePacked(ADDR_REVERSE_NODE, label));
        address currentOwner = ens.owner(node);

        // Update the resolver if required
        if(resolver != address(0) && resolver != address(ens.resolver(node))) {
            // Transfer the name to us first if it's not already
            if(currentOwner != address(this)) {
                ens.setSubnodeOwner(ADDR_REVERSE_NODE, label, address(this));
                currentOwner = address(this);
            }
            ens.setResolver(node, resolver);
        }

        // Update the owner if required
        if(currentOwner != owner) {
            ens.setSubnodeOwner(ADDR_REVERSE_NODE, label, owner);
        }

        return node;
    }

    /**
     * @dev Sets the `name()` record for the reverse ENS record associated with
     * the calling account. First updates the resolver to the default reverse
     * resolver if necessary.
     * @param name The name to set for this address.
     * @return The ENS node hash of the reverse record.
     */
    function setName(string memory name) public returns (bytes32 node) {
        node = claimWithResolver(address(this), address(defaultResolver));
        defaultResolver.setName(node, name);
        return node;
    }

    /**
     * @dev Returns the node hash for a given account's reverse records.
     * @param addr The address to hash
     * @return The ENS node hash.
     */
    function node(address addr) public returns (bytes32 ret) {
        return keccak256(abi.encodePacked(ADDR_REVERSE_NODE, sha3HexAddress(addr)));
    }

    /**
     * @dev An optimised function to compute the sha3 of the lower-case
     *      hexadecimal representation of an Ethereum address.
     * @param addr The address to hash
     * @return The SHA3 hash of the lower-case hexadecimal encoding of the
     *         input address.
     */
    function sha3HexAddress(address addr) private returns (bytes32 ret) {
        assembly {
            let lookup := 0x3031323334353637383961626364656600000000000000000000000000000000
            let i := 40

            for { } gt(i, 0) { } {
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
            }
            ret := keccak256(0, 40)
        }
    }
}

/**
 * @title AuthereumEnsResolver
  * @author Authereum, Inc.
 * @dev Authereum implementation of a Resolver.
 */

contract AuthereumEnsResolver is Managed {

    string constant public authereumEnsResolverVersion = "2019102500";

    bytes4 constant INTERFACE_META_ID = 0x01ffc9a7;
    bytes4 constant ADDR_INTERFACE_ID = 0x3b3b57de;
    bytes4 constant NAME_INTERFACE_ID = 0x691f3431;

    event AddrChanged(bytes32 indexed node, address a);
    event NameChanged(bytes32 indexed node, string name);

    struct Record {
        address addr;
        string name;
    }

    EnsRegistry ens;
    mapping (bytes32 => Record) records;
    address public authereumEnsManager;
    address public timelockContract;

    /// @dev Constructor
    /// @param _ensAddr The ENS registrar contract
    /// @param _timelockContract Authereum timelock contract address
    constructor(EnsRegistry _ensAddr, address _timelockContract) public {
        ens = _ensAddr;
        timelockContract = _timelockContract;
    }

    /**
     * Setters
     */

    /// @dev Sets the address associated with an ENS node
    /// @notice May only be called by the owner of that node in the ENS registry
    /// @param _node The node to update
    /// @param _addr The address to set
    function setAddr(bytes32 _node, address _addr) public onlyManager {
        records[_node].addr = _addr;
        emit AddrChanged(_node, _addr);
    }

    /// @dev Sets the name associated with an ENS node, for reverse records
    /// @notice May only be called by the owner of that node in the ENS registry
    /// @param _node The node to update
    /// @param _name The name to set
    function setName(bytes32 _node, string memory _name) public onlyManager {
        records[_node].name = _name;
        emit NameChanged(_node, _name);
    }

    /**
     * Getters
     */

    /// @dev Returns the address associated with an ENS node
    /// @param _node The ENS node to query
    /// @return The associated address
    function addr(bytes32 _node) public view returns (address) {
        return records[_node].addr;
    }

    /// @dev Returns the name associated with an ENS node, for reverse records
    /// @notice Defined in EIP181
    /// @param _node The ENS node to query
    /// @return The associated name
    function name(bytes32 _node) public view returns (string memory) {
        return records[_node].name;
    }

    /// @dev Returns true if the resolver implements the interface specified by the provided hash
    /// @param _interfaceID The ID of the interface to check for
    /// @return True if the contract implements the requested interface
    function supportsInterface(bytes4 _interfaceID) public pure returns (bool) {
        return _interfaceID == INTERFACE_META_ID ||
        _interfaceID == ADDR_INTERFACE_ID ||
        _interfaceID == NAME_INTERFACE_ID;
    }
}


/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <arachnid@notdot.net>
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
 * @title AuthereumEnsManager
 * @author Authereum, Inc.
 * @dev Used to manage all subdomains.
 * @dev This is also known as the Authereum registrar.
 * @dev The public ENS registry is used. The resolver is custom.
 */

contract AuthereumEnsManager is Owned {
    using strings for *;

    string constant public authereumEnsManagerVersion = "2019102500";

    // namehash('addr.reverse')
    bytes32 constant public ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;
    address ensRegistry;

    // The managed root name
    string public rootName;
    // The managed root node
    bytes32 public rootNode;
    // The address of the authereumEnsResolver
    address public authereumEnsResolver;
    // The address of the Authereum factory
    address public authereumFactoryAddress;
    // A mapping of the runtimeCodeHash to creationCodeHash
    mapping(bytes32 => bytes32) public authereumProxyBytecodeHashMapping;

    event RootnodeOwnerChanged(bytes32 indexed rootnode, address indexed newOwner);
    event RootnodeResolverChanged(bytes32 indexed rootnode, address indexed newResolver);
    event RootnodeTTLChanged(bytes32 indexed rootnode, uint64 indexed newTtl);
    event AuthereumEnsResolverChanged(address indexed authereumEnsResolver);
    event AuthereumFactoryAddressChanged(address indexed authereumFactoryAddress);
    event AuthereumProxyBytecodeHashChanged(bytes32 indexed authereumProxyRuntimeCodeHash, bytes32 indexed authereumProxyCreationCodeHash);
    event Registered(address indexed owner, string ens);

    /// @dev Throws if the sender is not the Authereum factory.
    modifier onlyAuthereumFactory() {
        require(msg.sender == authereumFactoryAddress, "Must be sent form the authereumFactoryAddress");
        _;
    }

    /// @dev Constructor that sets the ENS root name and root node to manage
    /// @param _rootName The root name (e.g. authereum.eth)
    /// @param _rootNode The node of the root name (e.g. namehash(authereum.eth))
    /// @param _ensRegistry Public ENS Registry address
    /// @param _authereumEnsResolver Custom Autheruem ENS Resolver address
    constructor(
        string memory _rootName,
        bytes32 _rootNode,
        address _ensRegistry,
        address _authereumEnsResolver
    )
        public
    {
        rootName = _rootName;
        rootNode = _rootNode;
        ensRegistry = _ensRegistry;
        authereumEnsResolver = _authereumEnsResolver;
    }

    /// @dev Resolves an ENS name to an address
    /// @param _node The namehash of the ENS name
    /// @return The address associated with an ENS node
    function resolveEns(bytes32 _node) public returns (address) {
        address resolver = getEnsRegistry().resolver(_node);
        return AuthereumEnsResolver(resolver).addr(_node);
    }

    /// @dev Gets the official ENS registry
    /// @return The official ENS registry address
    function getEnsRegistry() public view returns (EnsRegistry) {
        return EnsRegistry(ensRegistry);
    }

    /// @dev Gets the official ENS reverse registrar
    /// @return The official ENS reverse registrar address
    function getEnsReverseRegistrar() public view returns (EnsReverseRegistrar) {
        return EnsReverseRegistrar(getEnsRegistry().owner(ADDR_REVERSE_NODE));
    }

    /**
     *  External functions
     */

    /// @dev This function is used when the rootnode owner is updated
    /// @param _newOwner The address of the new ENS manager that will manage the root node.
    function changeRootnodeOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Address cannot be null");
        getEnsRegistry().setOwner(rootNode, _newOwner);
        emit RootnodeOwnerChanged(rootNode, _newOwner);
    }

    /// @dev This function is used when the rootnode resolver is updated
    /// @param _newResolver The address of the new ENS Resolver that will manage the root node.
    function changeRootnodeResolver(address _newResolver) external onlyOwner {
        require(_newResolver != address(0), "Address cannot be null");
        getEnsRegistry().setResolver(rootNode, _newResolver);
        emit RootnodeResolverChanged(rootNode, _newResolver);
    }

    /// @dev This function is used when the rootnode TTL is updated
    /// @param _newTtl The address of the new TTL that will manage the root node
    function changeRootnodeTTL(uint64 _newTtl) external onlyOwner {
        getEnsRegistry().setTTL(rootNode, _newTtl);
        emit RootnodeTTLChanged(rootNode, _newTtl);
    }

    /// @dev Lets the owner change the address of the Authereum ENS resolver contract
    /// @param _authereumEnsResolver The address of the Authereun ENS resolver contract
    function changeEnsResolver(address _authereumEnsResolver) external onlyOwner {
        require(_authereumEnsResolver != address(0), "Address cannot be null");
        authereumEnsResolver = _authereumEnsResolver;
        emit AuthereumEnsResolverChanged(_authereumEnsResolver);
    }

    /// @dev Lets the owner change the address of the Authereum factory
    /// @param _authereumFactoryAddress The address of the Authereum factory
    function changeAuthereumFactoryAddress(address _authereumFactoryAddress) external onlyOwner {
        require(_authereumFactoryAddress != address(0), "Address cannot be null");
        authereumFactoryAddress = _authereumFactoryAddress;
        emit AuthereumFactoryAddressChanged(authereumFactoryAddress);
    }

    /// @dev Lets the manager assign an ENS subdomain of the root node to a target address.
    /// @notice Registers both the forward and reverse ENS
    /// @param _label The subdomain label
    /// @param _owner The owner of the subdomain
    function register(
        string calldata _label,
        address _owner
    )
        external
        onlyAuthereumFactory
    {
        bytes32 labelNode = keccak256(abi.encodePacked(_label));
        bytes32 node = keccak256(abi.encodePacked(rootNode, labelNode));
        address currentOwner = getEnsRegistry().owner(node);
        require(currentOwner == address(0), "Label is already owned");

        // Forward ENS
        getEnsRegistry().setSubnodeOwner(rootNode, labelNode, address(this));
        getEnsRegistry().setResolver(node, authereumEnsResolver);
        getEnsRegistry().setOwner(node, _owner);
        AuthereumEnsResolver(authereumEnsResolver).setAddr(node, _owner);

        // Reverse ENS
        strings.slice[] memory parts = new strings.slice[](2);
        parts[0] = _label.toSlice();
        parts[1] = rootName.toSlice();
        string memory name = ".".toSlice().join(parts);
        bytes32 reverseNode = EnsReverseRegistrar(getEnsReverseRegistrar()).node(_owner);
        AuthereumEnsResolver(authereumEnsResolver).setName(reverseNode, name);

        emit Registered(_owner, name);
    }

    /**
     *  Public functions
     */

    /// @dev Returns true is a given subnode is available
    /// @param _subnode The target subnode
    /// @return True if the subnode is available
    function isAvailable(bytes32 _subnode) public view returns (bool) {
        bytes32 node = keccak256(abi.encodePacked(rootNode, _subnode));
        address currentOwner = getEnsRegistry().owner(node);
        if(currentOwner == address(0)) {
            return true;
        }
        return false;
    }
}