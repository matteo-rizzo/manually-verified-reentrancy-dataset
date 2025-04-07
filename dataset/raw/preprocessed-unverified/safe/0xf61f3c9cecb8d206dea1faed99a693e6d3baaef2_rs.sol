// SPDX-License-Identifier: Apache-2.0
// Copyright 2017 Loopring Technology Limited.
pragma solidity ^0.7.0;


/// @title Ownable
/// @author Brecht Devos - <brecht@loopring.org>
/// @dev The Ownable contract has an owner address, and provides basic
///      authorization control functions, this simplifies the implementation of
///      "user permissions".


// Copyright 2017 Loopring Technology Limited.



/// @title AddressSet
/// @author Daniel Wang - <daniel@loopring.org>
contract AddressSet
{
    struct Set
    {
        address[] addresses;
        mapping (address => uint) positions;
        uint count;
    }
    mapping (bytes32 => Set) private sets;

    function addAddressToSet(
        bytes32 key,
        address addr,
        bool    maintainList
        ) internal
    {
        Set storage set = sets[key];
        require(set.positions[addr] == 0, "ALREADY_IN_SET");

        if (maintainList) {
            require(set.addresses.length == set.count, "PREVIOUSLY_NOT_MAINTAILED");
            set.addresses.push(addr);
        } else {
            require(set.addresses.length == 0, "MUST_MAINTAIN");
        }

        set.count += 1;
        set.positions[addr] = set.count;
    }

    function removeAddressFromSet(
        bytes32 key,
        address addr
        )
        internal
    {
        Set storage set = sets[key];
        uint pos = set.positions[addr];
        require(pos != 0, "NOT_IN_SET");

        delete set.positions[addr];
        set.count -= 1;

        if (set.addresses.length > 0) {
            address lastAddr = set.addresses[set.count];
            if (lastAddr != addr) {
                set.addresses[pos - 1] = lastAddr;
                set.positions[lastAddr] = pos;
            }
            set.addresses.pop();
        }
    }

    function removeSet(bytes32 key)
        internal
    {
        delete sets[key];
    }

    function isAddressInSet(
        bytes32 key,
        address addr
        )
        internal
        view
        returns (bool)
    {
        return sets[key].positions[addr] != 0;
    }

    function numAddressesInSet(bytes32 key)
        internal
        view
        returns (uint)
    {
        Set storage set = sets[key];
        return set.count;
    }

    function addressesInSet(bytes32 key)
        internal
        view
        returns (address[] memory)
    {
        Set storage set = sets[key];
        require(set.count == set.addresses.length, "NOT_MAINTAINED");
        return sets[key].addresses;
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


// Taken from Argent's code base - https://github.com/argentlabs/argent-contracts/blob/develop/contracts/ens/ENS.sol
// with few modifications.



/**
 * ENS Registry interface.
 */



/**
 * ENS Resolver interface.
 */
abstract contract ENSResolver {
    function addr(bytes32 _node) public view virtual returns (address);
    function setAddr(bytes32 _node, address _addr) public virtual;
    function name(bytes32 _node) public view virtual returns (string memory);
    function setName(bytes32 _node, string memory _name) public virtual;
}

/**
 * ENS Reverse Registrar interface.
 */
abstract contract ENSReverseRegistrar {
    function claim(address _owner) public virtual returns (bytes32 _node);
    function claimWithResolver(address _owner, address _resolver) public virtual returns (bytes32);
    function setName(string memory _name) public virtual returns (bytes32);
    function node(address _addr) public view virtual returns (bytes32);
}

// Copyright 2017 Loopring Technology Limited.



/// @title Utility Functions for uint
/// @author Daniel Wang - <daniel@loopring.org>


// Copyright 2017 Loopring Technology Limited.

pragma experimental ABIEncoderV2;


//Mainly taken from https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol





// Copyright 2017 Loopring Technology Limited.



/// @title Utility Functions for addresses
/// @author Daniel Wang - <daniel@loopring.org>
/// @author Brecht Devos - <brecht@loopring.org>





/// @title SignatureUtil
/// @author Daniel Wang - <daniel@loopring.org>
/// @dev This method supports multihash standard. Each signature's first byte indicates
///      the signature's type, the second byte indicates the signature's length, therefore,
///      each signature will have 2 extra bytes prefix. Mulitple signatures are concatenated
///      together.


// Taken from Argent's code base - https://github.com/argentlabs/argent-contracts/blob/develop/contracts/ens/ENSConsumer.sol
// with few modifications.





/**
 * @title ENSConsumer
 * @dev Helper contract to resolve ENS names.
 * @author Julien Niset - <julien@argent.im>
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
    constructor(address _ensRegistry) {
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

// Taken from Argent's code base - https://github.com/argentlabs/argent-contracts/blob/develop/contracts/ens/ArgentENSManager.sol
// with few modifications.






// Copyright 2017 Loopring Technology Limited.




// Copyright 2017 Loopring Technology Limited.





/// @title Claimable
/// @author Brecht Devos - <brecht@loopring.org>
/// @dev Extension for the Ownable contract, where the ownership needs
///      to be claimed. This allows the new owner to accept the transfer.
contract Claimable is Ownable
{
    address public pendingOwner;

    /// @dev Modifier throws if called by any account other than the pendingOwner.
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner, "UNAUTHORIZED");
        _;
    }

    /// @dev Allows the current owner to set the pendingOwner address.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(
        address newOwner
        )
        public
        override
        onlyOwner
    {
        require(newOwner != address(0) && newOwner != owner, "INVALID_ADDRESS");
        pendingOwner = newOwner;
    }

    /// @dev Allows the pendingOwner address to finalize the transfer.
    function claimOwnership()
        public
        onlyPendingOwner
    {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}



contract OwnerManagable is Claimable, AddressSet
{
    bytes32 internal constant MANAGER = keccak256("__MANAGED__");

    event ManagerAdded  (address manager);
    event ManagerRemoved(address manager);

    modifier onlyManager
    {
        require(isManager(msg.sender), "NOT_MANAGER");
        _;
    }

    modifier onlyOwnerOrManager
    {
        require(msg.sender == owner || isManager(msg.sender), "NOT_OWNER_OR_MANAGER");
        _;
    }

    constructor() Claimable() {}

    /// @dev Gets the managers.
    /// @return The list of managers.
    function managers()
        public
        view
        returns (address[] memory)
    {
        return addressesInSet(MANAGER);
    }

    /// @dev Gets the number of managers.
    /// @return The numer of managers.
    function numManagers()
        public
        view
        returns (uint)
    {
        return numAddressesInSet(MANAGER);
    }

    /// @dev Checks if an address is a manger.
    /// @param addr The address to check.
    /// @return True if the address is a manager, False otherwise.
    function isManager(address addr)
        public
        view
        returns (bool)
    {
        return isAddressInSet(MANAGER, addr);
    }

    /// @dev Adds a new manager.
    /// @param manager The new address to add.
    function addManager(address manager)
        public
        onlyOwner
    {
        addManagerInternal(manager);
    }

    /// @dev Removes a manager.
    /// @param manager The manager to remove.
    function removeManager(address manager)
        public
        onlyOwner
    {
        removeAddressFromSet(MANAGER, manager);
        emit ManagerRemoved(manager);
    }

    function addManagerInternal(address manager)
        internal
    {
        addAddressToSet(MANAGER, manager, true);
        emit ManagerAdded(manager);
    }
}


/**
 * @dev Interface for an ENS Mananger.
 */


/**
 * @title BaseENSManager
 * @dev Implementation of an ENS manager that orchestrates the complete
 * registration of subdomains for a single root (e.g. argent.eth).
 * The contract defines a manager role who is the only role that can trigger the registration of
 * a new subdomain.
 * @author Julien Niset - <julien@argent.im>
 */
contract BaseENSManager is IENSManager, OwnerManagable, ENSConsumer {

    using strings for *;
    using BytesUtil     for bytes;
    using MathUint      for uint;

    // The managed root name
    string public rootName;
    // The managed root node
    bytes32 public rootNode;
    // The address of the ENS resolver
    address public ensResolver;

    // *************** Events *************************** //

    event RootnodeOwnerChange(bytes32 indexed _rootnode, address indexed _newOwner);
    event ENSResolverChanged(address addr);
    event Registered(address indexed _wallet, address _owner, string _ens);
    event Unregistered(string _ens);

    // *************** Constructor ********************** //

    /**
     * @dev Constructor that sets the ENS root name and root node to manage.
     * @param _rootName The root name (e.g. argentx.eth).
     * @param _rootNode The node of the root name (e.g. namehash(argentx.eth)).
     */
    constructor(string memory _rootName, bytes32 _rootNode, address _ensRegistry, address _ensResolver)
        ENSConsumer(_ensRegistry)
    {
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
    function changeRootnodeOwner(address _newOwner) external override onlyOwner {
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
    * @param _wallet The wallet which owns the subdomain.
    * @param _owner The wallet's owner.
    * @param _label The subdomain label.
    * @param _approval The signature of _wallet, _owner and _label by a manager.
    */
    function register(
        address _wallet,
        address _owner,
        string  calldata _label,
        bytes   calldata _approval
        )
        external
        override
        onlyManager
    {
        verifyApproval(_wallet, _owner, _label, _approval);

        bytes32 labelNode = keccak256(abi.encodePacked(_label));
        bytes32 node = keccak256(abi.encodePacked(rootNode, labelNode));
        address currentOwner = getENSRegistry().owner(node);
        require(currentOwner == address(0), "AEM: _label is alrealdy owned");

        // Forward ENS
        getENSRegistry().setSubnodeOwner(rootNode, labelNode, address(this));
        getENSRegistry().setResolver(node, ensResolver);
        getENSRegistry().setOwner(node, _wallet);
        ENSResolver(ensResolver).setAddr(node, _wallet);

        // Reverse ENS
        strings.slice[] memory parts = new strings.slice[](2);
        parts[0] = _label.toSlice();
        parts[1] = rootName.toSlice();
        string memory name = ".".toSlice().join(parts);
        bytes32 reverseNode = getENSReverseRegistrar().node(_wallet);
        ENSResolver(ensResolver).setName(reverseNode, name);

        emit Registered(_wallet, _owner, name);
    }

    // *************** Public Functions ********************* //

    /**
    * @dev Resolves an address to an ENS name
    * @param _wallet The ENS owner address
    */
    function resolveName(address _wallet) public view override returns (string memory) {
        bytes32 reverseNode = getENSReverseRegistrar().node(_wallet);
        return ENSResolver(ensResolver).name(reverseNode);
    }

    /**
     * @dev Returns true is a given subnode is available.
     * @param _subnode The target subnode.
     * @return true if the subnode is available.
     */
    function isAvailable(bytes32 _subnode) public view override returns (bool) {
        bytes32 node = keccak256(abi.encodePacked(rootNode, _subnode));
        address currentOwner = getENSRegistry().owner(node);
        if(currentOwner == address(0)) {
            return true;
        }
        return false;
    }

    function verifyApproval(
        address _wallet,
        address _owner,
        string  memory _label,
        bytes   memory _approval
        )
        internal
        view
    {
        bytes32 messageHash = keccak256(
            abi.encodePacked(
                _wallet,
                _owner,
                _label
            )
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                messageHash
            )
        );

        address signer = SignatureUtil.recoverECDSASigner(hash, _approval);
        require(isManager(signer), "UNAUTHORIZED");
    }

}