pragma solidity 0.4.24;



contract safeSend {

    bool private txMutex3847834;



    // we want to be able to call outside contracts (e.g. the admin proxy contract)

    // but reentrency is bad, so here's a mutex.

    function doSafeSend(address toAddr, uint amount) internal {

        doSafeSendWData(toAddr, "", amount);

    }



    function doSafeSendWData(address toAddr, bytes data, uint amount) internal {

        require(txMutex3847834 == false, "ss-guard");

        txMutex3847834 = true;

        // we need to use address.call.value(v)() because we want

        // to be able to send to other contracts, even with no data,

        // which might use more than 2300 gas in their fallback function.

        require(toAddr.call.value(amount)(data), "ss-failed");

        txMutex3847834 = false;

    }

}



contract payoutAllC is safeSend {

    address private _payTo;



    event PayoutAll(address payTo, uint value);



    constructor(address initPayTo) public {

        // DEV NOTE: you can overwrite _getPayTo if you want to reuse other storage vars

        assert(initPayTo != address(0));

        _payTo = initPayTo;

    }



    function _getPayTo() internal view returns (address) {

        return _payTo;

    }



    function _setPayTo(address newPayTo) internal {

        _payTo = newPayTo;

    }



    function payoutAll() external {

        address a = _getPayTo();

        uint bal = address(this).balance;

        doSafeSend(a, bal);

        emit PayoutAll(a, bal);

    }

}



contract payoutAllCSettable is payoutAllC {

    constructor (address initPayTo) payoutAllC(initPayTo) public {

    }



    function setPayTo(address) external;

    function getPayTo() external view returns (address) {

        return _getPayTo();

    }

}



contract owned {

    address public owner;



    event OwnerChanged(address newOwner);



    modifier only_owner() {

        require(msg.sender == owner, "only_owner: forbidden");

        _;

    }



    modifier owner_or(address addr) {

        require(msg.sender == addr || msg.sender == owner, "!owner-or");

        _;

    }



    constructor() public {

        owner = msg.sender;

    }



    function setOwner(address newOwner) only_owner() external {

        owner = newOwner;

        emit OwnerChanged(newOwner);

    }

}



contract controlledIface {

    function controller() external view returns (address);

}



contract hasAdmins is owned {

    mapping (uint => mapping (address => bool)) admins;

    uint public currAdminEpoch = 0;

    bool public adminsDisabledForever = false;

    address[] adminLog;



    event AdminAdded(address indexed newAdmin);

    event AdminRemoved(address indexed oldAdmin);

    event AdminEpochInc();

    event AdminDisabledForever();



    modifier only_admin() {

        require(adminsDisabledForever == false, "admins must not be disabled");

        require(isAdmin(msg.sender), "only_admin: forbidden");

        _;

    }



    constructor() public {

        _setAdmin(msg.sender, true);

    }



    function isAdmin(address a) view public returns (bool) {

        return admins[currAdminEpoch][a];

    }



    function getAdminLogN() view external returns (uint) {

        return adminLog.length;

    }



    function getAdminLog(uint n) view external returns (address) {

        return adminLog[n];

    }



    function upgradeMeAdmin(address newAdmin) only_admin() external {

        // note: already checked msg.sender has admin with `only_admin` modifier

        require(msg.sender != owner, "owner cannot upgrade self");

        _setAdmin(msg.sender, false);

        _setAdmin(newAdmin, true);

    }



    function setAdmin(address a, bool _givePerms) only_admin() external {

        require(a != msg.sender && a != owner, "cannot change your own (or owner's) permissions");

        _setAdmin(a, _givePerms);

    }



    function _setAdmin(address a, bool _givePerms) internal {

        admins[currAdminEpoch][a] = _givePerms;

        if (_givePerms) {

            emit AdminAdded(a);

            adminLog.push(a);

        } else {

            emit AdminRemoved(a);

        }

    }



    // safety feature if admins go bad or something

    function incAdminEpoch() only_owner() external {

        currAdminEpoch++;

        admins[currAdminEpoch][msg.sender] = true;

        emit AdminEpochInc();

    }



    // this is internal so contracts can all it, but not exposed anywhere in this

    // contract.

    function disableAdminForever() internal {

        currAdminEpoch++;

        adminsDisabledForever = true;

        emit AdminDisabledForever();

    }

}



contract EnsOwnerProxy is hasAdmins {

    bytes32 public ensNode;

    ENSIface public ens;

    PublicResolver public resolver;



    /**

     * @param _ensNode The node to administer

     * @param _ens The ENS Registrar

     * @param _resolver The ENS Resolver

     */

    constructor(bytes32 _ensNode, ENSIface _ens, PublicResolver _resolver) public {

        ensNode = _ensNode;

        ens = _ens;

        resolver = _resolver;

    }



    function setAddr(address addr) only_admin() external {

        _setAddr(addr);

    }



    function _setAddr(address addr) internal {

        resolver.setAddr(ensNode, addr);

    }



    function returnToOwner() only_owner() external {

        ens.setOwner(ensNode, owner);

    }



    function fwdToENS(bytes data) only_owner() external {

        require(address(ens).call(data), "fwding to ens failed");

    }



    function fwdToResolver(bytes data) only_owner() external {

        require(address(resolver).call(data), "fwding to resolver failed");

    }

}



contract permissioned is owned, hasAdmins {

    mapping (address => bool) editAllowed;

    bool public adminLockdown = false;



    event PermissionError(address editAddr);

    event PermissionGranted(address editAddr);

    event PermissionRevoked(address editAddr);

    event PermissionsUpgraded(address oldSC, address newSC);

    event SelfUpgrade(address oldSC, address newSC);

    event AdminLockdown();



    modifier only_editors() {

        require(editAllowed[msg.sender], "only_editors: forbidden");

        _;

    }



    modifier no_lockdown() {

        require(adminLockdown == false, "no_lockdown: check failed");

        _;

    }





    constructor() owned() hasAdmins() public {

    }





    function setPermissions(address e, bool _editPerms) no_lockdown() only_admin() external {

        editAllowed[e] = _editPerms;

        if (_editPerms)

            emit PermissionGranted(e);

        else

            emit PermissionRevoked(e);

    }



    function upgradePermissionedSC(address oldSC, address newSC) no_lockdown() only_admin() external {

        editAllowed[oldSC] = false;

        editAllowed[newSC] = true;

        emit PermissionsUpgraded(oldSC, newSC);

    }



    // always allow SCs to upgrade themselves, even after lockdown

    function upgradeMe(address newSC) only_editors() external {

        editAllowed[msg.sender] = false;

        editAllowed[newSC] = true;

        emit SelfUpgrade(msg.sender, newSC);

    }



    function hasPermissions(address a) public view returns (bool) {

        return editAllowed[a];

    }



    function doLockdown() external only_owner() no_lockdown() {

        disableAdminForever();

        adminLockdown = true;

        emit AdminLockdown();

    }

}



contract upgradePtr {

    address ptr = address(0);



    modifier not_upgraded() {

        require(ptr == address(0), "upgrade pointer is non-zero");

        _;

    }



    function getUpgradePointer() view external returns (address) {

        return ptr;

    }



    function doUpgradeInternal(address nextSC) internal {

        ptr = nextSC;

    }

}















contract PublicResolver {



    bytes4 constant INTERFACE_META_ID = 0x01ffc9a7;

    bytes4 constant ADDR_INTERFACE_ID = 0x3b3b57de;

    bytes4 constant CONTENT_INTERFACE_ID = 0xd8389dc5;

    bytes4 constant NAME_INTERFACE_ID = 0x691f3431;

    bytes4 constant ABI_INTERFACE_ID = 0x2203ab56;

    bytes4 constant PUBKEY_INTERFACE_ID = 0xc8690233;

    bytes4 constant TEXT_INTERFACE_ID = 0x59d1d43c;



    event AddrChanged(bytes32 indexed node, address a);

    event ContentChanged(bytes32 indexed node, bytes32 hash);

    event NameChanged(bytes32 indexed node, string name);

    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);

    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);

    event TextChanged(bytes32 indexed node, string indexedKey, string key);



    struct PublicKey {

        bytes32 x;

        bytes32 y;

    }



    struct Record {

        address addr;

        bytes32 content;

        string name;

        PublicKey pubkey;

        mapping(string=>string) text;

        mapping(uint256=>bytes) abis;

    }



    ENSIface ens;



    mapping (bytes32 => Record) records;



    modifier only_owner(bytes32 node) {

        require(ens.owner(node) == msg.sender);

        _;

    }



    /**

     * Constructor.

     * @param ensAddr The ENS registrar contract.

     */

    constructor(ENSIface ensAddr) public {

        ens = ensAddr;

    }



    /**

     * Sets the address associated with an ENS node.

     * May only be called by the owner of that node in the ENS registry.

     * @param node The node to update.

     * @param addr The address to set.

     */

    function setAddr(bytes32 node, address addr) public only_owner(node) {

        records[node].addr = addr;

        emit AddrChanged(node, addr);

    }



    /**

     * Sets the content hash associated with an ENS node.

     * May only be called by the owner of that node in the ENS registry.

     * Note that this resource type is not standardized, and will likely change

     * in future to a resource type based on multihash.

     * @param node The node to update.

     * @param hash The content hash to set

     */

    function setContent(bytes32 node, bytes32 hash) public only_owner(node) {

        records[node].content = hash;

        emit ContentChanged(node, hash);

    }



    /**

     * Sets the name associated with an ENS node, for reverse records.

     * May only be called by the owner of that node in the ENS registry.

     * @param node The node to update.

     * @param name The name to set.

     */

    function setName(bytes32 node, string name) public only_owner(node) {

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

    function setABI(bytes32 node, uint256 contentType, bytes data) public only_owner(node) {

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

    function setPubkey(bytes32 node, bytes32 x, bytes32 y) public only_owner(node) {

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

    function setText(bytes32 node, string key, string value) public only_owner(node) {

        records[node].text[key] = value;

        emit TextChanged(node, key, key);

    }



    /**

     * Returns the text data associated with an ENS node and key.

     * @param node The ENS node to query.

     * @param key The text data key to query.

     * @return The associated text data.

     */

    function text(bytes32 node, string key) public view returns (string) {

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

    function ABI(bytes32 node, uint256 contentTypes) public view returns (uint256 contentType, bytes data) {

        Record storage record = records[node];

        for (contentType = 1; contentType <= contentTypes; contentType <<= 1) {

            if ((contentType & contentTypes) != 0 && record.abis[contentType].length > 0) {

                data = record.abis[contentType];

                return;

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

    function name(bytes32 node) public view returns (string) {

        return records[node].name;

    }



    /**

     * Returns the content hash associated with an ENS node.

     * Note that this resource type is not standardized, and will likely change

     * in future to a resource type based on multihash.

     * @param node The ENS node to query.

     * @return The associated content hash.

     */

    function content(bytes32 node) public view returns (bytes32) {

        return records[node].content;

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

     * Returns true if the resolver implements the interface specified by the provided hash.

     * @param interfaceID The ID of the interface to check for.

     * @return True if the contract implements the requested interface.

     */

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {

        return interfaceID == ADDR_INTERFACE_ID ||

        interfaceID == CONTENT_INTERFACE_ID ||

        interfaceID == NAME_INTERFACE_ID ||

        interfaceID == ABI_INTERFACE_ID ||

        interfaceID == PUBKEY_INTERFACE_ID ||

        interfaceID == TEXT_INTERFACE_ID ||

        interfaceID == INTERFACE_META_ID;

    }

}