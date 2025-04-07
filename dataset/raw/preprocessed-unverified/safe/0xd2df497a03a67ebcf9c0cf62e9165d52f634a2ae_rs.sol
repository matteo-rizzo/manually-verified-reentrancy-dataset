/**
 *Submitted for verification at Etherscan.io on 2020-02-20
*/

/**
Author: Authereum Labs, Inc.
*/

pragma solidity 0.5.16;




contract Managed is Owned {

    // The managers
    mapping (address => bool) public managers;

    /// @dev Throws if the sender is not a manager
    modifier onlyManager {
        require(managers[msg.sender] == true, "M: Must be manager");
        _;
    }

    event ManagerAdded(address indexed _manager);
    event ManagerRevoked(address indexed _manager);

    /// @dev Adds a manager
    /// @param _manager The address of the manager
    function addManager(address _manager) external onlyOwner {
        require(_manager != address(0), "M: Address must not be null");
        if(managers[_manager] == false) {
            managers[_manager] = true;
            emit ManagerAdded(_manager);
        }
    }

    /// @dev Revokes a manager
    /// @param _manager The address of the manager
    function revokeManager(address _manager) external onlyOwner {
        require(managers[_manager] == true, "M: Target must be an existing manager");
        delete managers[_manager];
        emit ManagerRevoked(_manager);
    }
}

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



contract EnsResolver {

    bytes4 constant INTERFACE_META_ID = 0x01ffc9a7;
    bytes4 constant ADDR_INTERFACE_ID = 0x3b3b57de;
    bytes4 constant NAME_INTERFACE_ID = 0x691f3431;
    bytes4 constant ABI_INTERFACE_ID = 0x2203ab56;
    bytes4 constant PUBKEY_INTERFACE_ID = 0xc8690233;
    bytes4 constant TEXT_INTERFACE_ID = 0x59d1d43c;
    bytes4 constant CONTENTHASH_INTERFACE_ID = 0xbc1c58d1;

    event AddrChanged(bytes32 indexed node, address a);
    event NameChanged(bytes32 indexed node, string name);
    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);
    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);
    event TextChanged(bytes32 indexed node, string indexedKey, string key);
    event ContenthashChanged(bytes32 indexed node, bytes hash);

    struct PublicKey {
        bytes32 x;
        bytes32 y;
    }

    struct Record {
        address addr;
        string name;
        PublicKey pubkey;
        mapping(string=>string) text;
        mapping(uint256=>bytes) abis;
        bytes contenthash;
    }

    ENS ens;

    mapping (bytes32 => Record) records;

    modifier onlyOwner(bytes32 node) {
        require(ens.owner(node) == msg.sender);
        _;
    }

    /**
     * Constructor.
     * @param ensAddr The ENS registrar contract.
     */
    constructor(ENS ensAddr) public {
        ens = ensAddr;
    }

    /**
     * Sets the address associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param addr The address to set.
     */
    function setAddr(bytes32 node, address addr) public onlyOwner(node) {
        records[node].addr = addr;
        emit AddrChanged(node, addr);
    }

    /**
     * Sets the contenthash associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param hash The contenthash to set
     */
    function setContenthash(bytes32 node, bytes memory hash) public onlyOwner(node) {
        records[node].contenthash = hash;
        emit ContenthashChanged(node, hash);
    }

    /**
     * Sets the name associated with an ENS node, for reverse records.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param name The name to set.
     */
    function setName(bytes32 node, string memory name) public onlyOwner(node) {
        records[node].name = name;
        emit NameChanged(node, name);
    }

    /**
     * Sets the ABI associated with an ENS node.
     * Nodes may have one ABI of each content type. To remove an ABI, set it to
     * the empty string.
     * @param node The node to update.
     * @param contentType The content type of the ABI
     * @param data The ABI data.
     */
    function setABI(bytes32 node, uint256 contentType, bytes memory data) public onlyOwner(node) {
        // Content types must be powers of 2
        require(((contentType - 1) & contentType) == 0);

        records[node].abis[contentType] = data;
        emit ABIChanged(node, contentType);
    }

    /**
     * Sets the SECP256k1 public key associated with an ENS node.
     * @param node The ENS node to query
     * @param x the X coordinate of the curve point for the public key.
     * @param y the Y coordinate of the curve point for the public key.
     */
    function setPubkey(bytes32 node, bytes32 x, bytes32 y) public onlyOwner(node) {
        records[node].pubkey = PublicKey(x, y);
        emit PubkeyChanged(node, x, y);
    }

    /**
     * Sets the text data associated with an ENS node and key.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param key The key to set.
     * @param value The text data value to set.
     */
    function setText(bytes32 node, string memory key, string memory value) public onlyOwner(node) {
        records[node].text[key] = value;
        emit TextChanged(node, key, key);
    }

    /**
     * Returns the text data associated with an ENS node and key.
     * @param node The ENS node to query.
     * @param key The text data key to query.
     * @return The associated text data.
     */
    function text(bytes32 node, string memory key) public view returns (string memory) {
        return records[node].text[key];
    }

    /**
     * Returns the SECP256k1 public key associated with an ENS node.
     * Defined in EIP 619.
     * @param node The ENS node to query
     * @return x, y the X and Y coordinates of the curve point for the public key.
     */
    function pubkey(bytes32 node) public view returns (bytes32 x, bytes32 y) {
        return (records[node].pubkey.x, records[node].pubkey.y);
    }

    /**
     * Returns the ABI associated with an ENS node.
     * Defined in EIP205.
     * @param node The ENS node to query
     * @param contentTypes A bitwise OR of the ABI formats accepted by the caller.
     * @return contentType The content type of the return value
     * @return data The ABI data
     */
    function ABI(bytes32 node, uint256 contentTypes) public view returns (uint256 contentType, bytes memory data) {
        Record storage record = records[node];
        for (contentType = 1; contentType <= contentTypes; contentType <<= 1) {
            if ((contentType & contentTypes) != 0 && record.abis[contentType].length > 0) {
                data = record.abis[contentType];
                return (contentType, data);
            }
        }
        contentType = 0;
    }

    /**
     * Returns the name associated with an ENS node, for reverse records.
     * Defined in EIP181.
     * @param node The ENS node to query.
     * @return The associated name.
     */
    function name(bytes32 node) public view returns (string memory) {
        return records[node].name;
    }

    /**
     * Returns the address associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated address.
     */
    function addr(bytes32 node) public view returns (address) {
        return records[node].addr;
    }

    /**
     * Returns the contenthash associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated contenthash.
     */
    function contenthash(bytes32 node) public view returns (bytes memory) {
        return records[node].contenthash;
    }

    /**
     * Returns true if the resolver implements the interface specified by the provided hash.
     * @param interfaceID The ID of the interface to check for.
     * @return True if the contract implements the requested interface.
     */
    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == ADDR_INTERFACE_ID ||
        interfaceID == NAME_INTERFACE_ID ||
        interfaceID == ABI_INTERFACE_ID ||
        interfaceID == PUBKEY_INTERFACE_ID ||
        interfaceID == TEXT_INTERFACE_ID ||
        interfaceID == CONTENTHASH_INTERFACE_ID ||
        interfaceID == INTERFACE_META_ID;
    }
}

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
    function sha3HexAddress(address addr) private pure returns (bytes32 ret) {
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

contract AuthereumEnsResolverStateV1 {

    EnsRegistry ens;
    address public timelockContract;

    mapping (bytes32 => address) public addrs;
    mapping(bytes32 => string) public names;
    mapping(bytes32 => mapping(string => string)) public texts;
    mapping(bytes32 => bytes) public hashes;
}

contract AuthereumEnsResolverState is AuthereumEnsResolverStateV1 {}

contract AuthereumEnsResolver is Managed, AuthereumEnsResolverState {

    string constant public authereumEnsResolverVersion = "2019111500";

    bytes4 constant private INTERFACE_META_ID = 0x01ffc9a7;
    bytes4 constant private ADDR_INTERFACE_ID = 0x3b3b57de;
    bytes4 constant private NAME_INTERFACE_ID = 0x691f3431;
    bytes4 constant private TEXT_INTERFACE_ID = 0x59d1d43c;
    bytes4 constant private CONTENT_HASH_INTERFACE_ID = 0xbc1c58d1;

    event AddrChanged(bytes32 indexed node, address a);
    event NameChanged(bytes32 indexed node, string name);
    event TextChanged(bytes32 indexed node, string indexed indexedKey, string key, string value);
    event ContenthashChanged(bytes32 indexed node, bytes hash);

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
        addrs[_node]= _addr;
        emit AddrChanged(_node, _addr);
    }

    /// @dev Sets the name associated with an ENS node, for reverse records
    /// @notice May only be called by the owner of that node in the ENS registry
    /// @param _node The node to update
    /// @param _name The name to set
    function setName(bytes32 _node, string memory _name) public onlyManager {
        names[_node] = _name;
        emit NameChanged(_node, _name);
    }

    /// @dev Sets the text data associated with an ENS node and key
    /// @notice May only be called by the owner of that node in the ENS registry
    /// @param node The node to update
    /// @param key The key to set
    /// @param value The text data value to set
    function setText(bytes32 node, string memory key, string memory value) public onlyManager {
        texts[node][key] = value;
        emit TextChanged(node, key, key, value);
    }

    /// @dev Sets the contenthash associated with an ENS node
    /// @notice May only be called by the owner of that node in the ENS registry
    /// @param node The node to update
    /// @param hash The contenthash to set
    function setContenthash(bytes32 node, bytes memory hash) public onlyManager {
        hashes[node] = hash;
        emit ContenthashChanged(node, hash);
    }

    /**
     * Getters
     */

    /// @dev Returns the address associated with an ENS node
    /// @param _node The ENS node to query
    /// @return The associated address
    function addr(bytes32 _node) public view returns (address) {
        return addrs[_node];
    }

    /// @dev Returns the name associated with an ENS node, for reverse records
    /// @notice Defined in EIP181
    /// @param _node The ENS node to query
    /// @return The associated name
    function name(bytes32 _node) public view returns (string memory) {
        return names[_node];
    }

    /// @dev Returns the text data associated with an ENS node and key
    /// @param node The ENS node to query
    /// @param key The text data key to query
    ///@return The associated text data
    function text(bytes32 node, string memory key) public view returns (string memory) {
        return texts[node][key];
    }

    /// @dev Returns the contenthash associated with an ENS node
    /// @param node The ENS node to query
    /// @return The associated contenthash
    function contenthash(bytes32 node) public view returns (bytes memory) {
        return hashes[node];
    }

    /// @dev Returns true if the resolver implements the interface specified by the provided hash
    /// @param _interfaceID The ID of the interface to check for
    /// @return True if the contract implements the requested interface
    function supportsInterface(bytes4 _interfaceID) public pure returns (bool) {
        return _interfaceID == INTERFACE_META_ID ||
        _interfaceID == ADDR_INTERFACE_ID ||
        _interfaceID == NAME_INTERFACE_ID ||
        _interfaceID == TEXT_INTERFACE_ID ||
        _interfaceID == CONTENT_HASH_INTERFACE_ID;
    }
}



contract AuthereumEnsManager is Owned {
    using strings for *;

    string constant public authereumEnsManagerVersion = "2020020200";

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
    event RootnodeTextChanged(bytes32 indexed node, string indexed indexedKey, string key, string value);
    event RootnodeContenthashChanged(bytes32 indexed node, bytes hash);
    event AuthereumEnsResolverChanged(address indexed authereumEnsResolver);
    event AuthereumFactoryAddressChanged(address indexed authereumFactoryAddress);
    event AuthereumProxyBytecodeHashChanged(bytes32 indexed authereumProxyRuntimeCodeHash, bytes32 indexed authereumProxyCreationCodeHash);
    event Registered(address indexed owner, string ens);

    /// @dev Throws if the sender is not the Authereum factory
    modifier onlyAuthereumFactory() {
        require(msg.sender == authereumFactoryAddress, "AEM: Must be sent from the authereumFactoryAddress");
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

    /**
     * Canonical ENS
     */

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
     *  Rootnode - Registry
     */

    /// @dev This function is used when the rootnode owner is updated
    /// @param _newOwner The address of the new ENS manager that will manage the root node
    function changeRootnodeOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "AEM: Address must not be null");
        getEnsRegistry().setOwner(rootNode, _newOwner);
        emit RootnodeOwnerChanged(rootNode, _newOwner);
    }

    /// @dev This function is used when the rootnode resolver is updated
    /// @param _newResolver The address of the new ENS Resolver that will manage the root node
    function changeRootnodeResolver(address _newResolver) external onlyOwner {
        require(_newResolver != address(0), "AEM: Address must not be null");
        getEnsRegistry().setResolver(rootNode, _newResolver);
        emit RootnodeResolverChanged(rootNode, _newResolver);
    }

    /// @dev This function is used when the rootnode TTL is updated
    /// @param _newTtl The address of the new TTL that will manage the root node
    function changeRootnodeTTL(uint64 _newTtl) external onlyOwner {
        getEnsRegistry().setTTL(rootNode, _newTtl);
        emit RootnodeTTLChanged(rootNode, _newTtl);
    }

    /**
     *  Rootnode - Resolver
     */

    /// @dev This function is used when the rootnode text record is updated
    /// @param _newKey The key of the new text record for the root node
    /// @param _newValue The value of the new text record for the root node
    function changeRootnodeText(string calldata _newKey, string calldata _newValue) external onlyOwner {
        AuthereumEnsResolver(authereumEnsResolver).setText(rootNode, _newKey, _newValue);
        emit RootnodeTextChanged(rootNode, _newKey, _newKey, _newValue);
    }

    /// @dev This function is used when the rootnode contenthash is updated
    /// @param _newHash The new contenthash of the root node
    function changeRootnodeContenthash(bytes calldata _newHash) external onlyOwner {
        AuthereumEnsResolver(authereumEnsResolver).setContenthash(rootNode, _newHash);
        emit RootnodeContenthashChanged(rootNode, _newHash);
    }

    /**
     * State
     */

    /// @dev Lets the owner change the address of the Authereum ENS resolver contract
    /// @param _authereumEnsResolver The address of the Authereun ENS resolver contract
    function changeAuthereumEnsResolver(address _authereumEnsResolver) external onlyOwner {
        require(_authereumEnsResolver != address(0), "AEM: Address must not be null");
        authereumEnsResolver = _authereumEnsResolver;
        emit AuthereumEnsResolverChanged(_authereumEnsResolver);
    }

    /// @dev Lets the owner change the address of the Authereum factory
    /// @param _authereumFactoryAddress The address of the Authereum factory
    function changeAuthereumFactoryAddress(address _authereumFactoryAddress) external onlyOwner {
        require(_authereumFactoryAddress != address(0), "AEM: Address must not be null");
        authereumFactoryAddress = _authereumFactoryAddress;
        emit AuthereumFactoryAddressChanged(authereumFactoryAddress);
    }

    /**
     * Register
     */

    /// @dev Lets the manager assign an ENS subdomain of the root node to a target address
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
        require(currentOwner == address(0), "AEM: Label is already owned");

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