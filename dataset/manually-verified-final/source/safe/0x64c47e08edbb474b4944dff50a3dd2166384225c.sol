interface ENS {

    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    event Transfer(bytes32 indexed node, address owner);

    event NewResolver(bytes32 indexed node, address resolver);

    event NewTTL(bytes32 indexed node, uint64 ttl);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external;
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external;
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external returns(bytes32);
    function setResolver(bytes32 node, address resolver) external;
    function setOwner(bytes32 node, address owner) external;
    function setTTL(bytes32 node, uint64 ttl) external;
    function setApprovalForAll(address operator, bool approved) external;
    function owner(bytes32 node) external view returns (address);
    function resolver(bytes32 node) external view returns (address);
    function ttl(bytes32 node) external view returns (uint64);
    function recordExists(bytes32 node) external view returns (bool);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract FIFSRegistrar {
    ENS ens;
    bytes32 rootNode;

    modifier only_owner(bytes32 label) {
        address currentOwner = ens.owner(keccak256(abi.encodePacked(rootNode, label)));
        require(currentOwner == address(0x0) || currentOwner == msg.sender);
        _;
    }

    constructor(ENS ensAddr, bytes32 node) public {
        ens = ensAddr;
        rootNode = node;
    }

    function register(bytes32 label, address owner) public only_owner(label) {
        ens.setSubnodeOwner(rootNode, label, owner);
    }
}
