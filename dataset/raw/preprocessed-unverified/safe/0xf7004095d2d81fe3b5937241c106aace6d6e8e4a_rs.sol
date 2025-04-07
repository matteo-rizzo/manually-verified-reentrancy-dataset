/**

 *Submitted for verification at Etherscan.io on 2018-08-29

*/



pragma solidity ^0.4.23;



// File: @ensdomains/dnssec-oracle/contracts/BytesUtils.sol







// File: @ensdomains/dnssec-oracle/contracts/DNSSEC.sol







// File: @ensdomains/buffer/contracts/Buffer.sol



/**

* @dev A library for working with mutable byte buffers in Solidity.

*

* Byte buffers are mutable and expandable, and provide a variety of primitives

* for writing to them. At any time you can fetch a bytes object containing the

* current contents of the buffer. The bytes object should not be stored between

* operations, as it may change due to resizing of the buffer.

*/





// File: @ensdomains/dnssec-oracle/contracts/RRUtils.sol



/**

* @dev RRUtils is a library that provides utilities for parsing DNS resource records.

*/





// File: @ensdomains/ens/contracts/ENS.sol







// File: @ensdomains/ens/contracts/ENSRegistry.sol



/**

 * The ENS registry contract.

 */

contract ENSRegistry is ENS {

    struct Record {

        address owner;

        address resolver;

        uint64 ttl;

    }



    mapping (bytes32 => Record) records;



    // Permits modifications only by the owner of the specified node.

    modifier only_owner(bytes32 node) {

        require(records[node].owner == msg.sender);

        _;

    }



    /**

     * @dev Constructs a new ENS registrar.

     */

    function ENSRegistry() public {

        records[0x0].owner = msg.sender;

    }



    /**

     * @dev Transfers ownership of a node to a new address. May only be called by the current owner of the node.

     * @param node The node to transfer ownership of.

     * @param owner The address of the new owner.

     */

    function setOwner(bytes32 node, address owner) public only_owner(node) {

        Transfer(node, owner);

        records[node].owner = owner;

    }



    /**

     * @dev Transfers ownership of a subnode keccak256(node, label) to a new address. May only be called by the owner of the parent node.

     * @param node The parent node.

     * @param label The hash of the label specifying the subnode.

     * @param owner The address of the new owner.

     */

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) public only_owner(node) {

        var subnode = keccak256(node, label);

        NewOwner(node, label, owner);

        records[subnode].owner = owner;

    }



    /**

     * @dev Sets the resolver address for the specified node.

     * @param node The node to update.

     * @param resolver The address of the resolver.

     */

    function setResolver(bytes32 node, address resolver) public only_owner(node) {

        NewResolver(node, resolver);

        records[node].resolver = resolver;

    }



    /**

     * @dev Sets the TTL for the specified node.

     * @param node The node to update.

     * @param ttl The TTL in seconds.

     */

    function setTTL(bytes32 node, uint64 ttl) public only_owner(node) {

        NewTTL(node, ttl);

        records[node].ttl = ttl;

    }



    /**

     * @dev Returns the address that owns the specified node.

     * @param node The specified node.

     * @return address of the owner.

     */

    function owner(bytes32 node) public view returns (address) {

        return records[node].owner;

    }



    /**

     * @dev Returns the address of the resolver for the specified node.

     * @param node The specified node.

     * @return address of the resolver.

     */

    function resolver(bytes32 node) public view returns (address) {

        return records[node].resolver;

    }



    /**

     * @dev Returns the TTL of a node, and any records associated with it.

     * @param node The specified node.

     * @return ttl of the node.

     */

    function ttl(bytes32 node) public view returns (uint64) {

        return records[node].ttl;

    }



}



// File: contracts/DNSRegistrar.sol



/**

 * @dev An ENS registrar that allows the owner of a DNS name to claim the

 *      corresponding name in ENS.

 */

contract DNSRegistrar {

    using BytesUtils for bytes;

    using RRUtils for *;

    using Buffer for Buffer.buffer;



    uint16 constant CLASS_INET = 1;

    uint16 constant TYPE_TXT = 16;



    DNSSEC public oracle;

    ENS public ens;

    bytes public rootDomain;

    bytes32 public rootNode;



    event Claim(bytes32 indexed node, address indexed owner, bytes dnsname);



    constructor(DNSSEC _dnssec, ENS _ens, bytes _rootDomain, bytes32 _rootNode) public {

        oracle = _dnssec;

        ens = _ens;

        rootDomain = _rootDomain;

        rootNode = _rootNode;

    }



    /**

     * @dev Claims a name by proving ownership of its DNS equivalent.

     * @param name The name to claim, in DNS wire format.

     * @param proof A DNS RRSet proving ownership of the name. Must be verified

     *        in the DNSSEC oracle before calling. This RRSET must contain a TXT

     *        record for '_ens.' + name, with the value 'a=0x...'. Ownership of

     *        the name will be transferred to the address specified in the TXT

     *        record.

     */

    function claim(bytes name, bytes proof) public {

        bytes32 labelHash = getLabelHash(name);



        address addr = getOwnerAddress(name, proof);



        ens.setSubnodeOwner(rootNode, labelHash, addr);

        emit Claim(keccak256(rootNode, labelHash), addr, name);

    }



    /**

     * @dev Submits proofs to the DNSSEC oracle, then claims a name using those proofs.

     * @param name The name to claim, in DNS wire format.

     * @param input The data to be passed to the Oracle's `submitProofs` function. The last

     *        proof must be the TXT record required by the registrar.

     * @param proof The proof record for the first element in input.

     */

    function proveAndClaim(bytes name, bytes input, bytes proof) public {

        proof = oracle.submitRRSets(input, proof);

        claim(name, proof);

    }



    function getLabelHash(bytes memory name) internal view returns(bytes32) {

        uint len = name.readUint8(0);

        // Check this name is a direct subdomain of the one we're responsible for

        require(name.equals(len + 1, rootDomain));

        return name.keccak(1, len);

    }



    function getOwnerAddress(bytes memory name, bytes memory proof) internal view returns(address) {

        // Add "_ens." to the front of the name.

        Buffer.buffer memory buf;

        buf.init(name.length + 5);

        buf.append("\x04_ens");

        buf.append(name);

        bytes20 hash;

        uint64 inserted;

        // Check the provided TXT record has been validated by the oracle

        (, inserted, hash) = oracle.rrdata(TYPE_TXT, buf.buf);

        if(hash == bytes20(0) && proof.length == 0) return 0;



        require(hash == bytes20(keccak256(proof)));



        for(RRUtils.RRIterator memory iter = proof.iterateRRs(0); !iter.done(); iter.next()) {

            require(inserted + iter.ttl >= now, "DNS record is stale; refresh or delete it before proceeding.");



            address addr = parseRR(proof, iter.rdataOffset);

            if(addr != 0) {

                return addr;

            }

        }



        return 0;

    }



    function parseRR(bytes memory rdata, uint idx) internal pure returns(address) {

        while(idx < rdata.length) {

            uint len = rdata.readUint8(idx); idx += 1;

            address addr = parseString(rdata, idx, len);

            if(addr != 0) return addr;

            idx += len;

        }



        return 0;

    }



    function parseString(bytes memory str, uint idx, uint len) internal pure returns(address) {

        // TODO: More robust parsing that handles whitespace and multiple key/value pairs

        if(str.readUint32(idx) != 0x613d3078) return 0; // 0x613d3078 == 'a=0x'

        if(len < 44) return 0;

        return hexToAddress(str, idx + 4);

    }



    function hexToAddress(bytes memory str, uint idx) internal pure returns(address) {

        if(str.length - idx < 40) return 0;

        uint ret = 0;

        for(uint i = idx; i < idx + 40; i++) {

            ret <<= 4;

            uint x = str.readUint8(i);

            if(x >= 48 && x < 58) {

                ret |= x - 48;

            } else if(x >= 65 && x < 71) {

                ret |= x - 55;

            } else if(x >= 97 && x < 103) {

                ret |= x - 87;

            } else {

                return 0;

            }

        }

        return address(ret);

    }

}